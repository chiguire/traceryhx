package tracery;
import tracery.Errors;
import tracery.Modifier;
import tracery.TraceryNodeType;

/**
 * ...
 * @author 
 */
class TraceryNode
{
	public var errors (default, null): Errors;
	public var grammar (default, null): Grammar;
	public var parent (default, null): TraceryNode;
	public var depth (default, null): Int;
	public var childIndex (default, null): Int;
	public var raw (default, null): String;
	
	public var children(default, null): Array<TraceryNode>;
	public var finishedText(default, null): String;
	public var childRule(default, null) : Dynamic;
	
	public var type(default, null): TraceryNodeType;
	
	private var isExpanded : Bool;
	private var expansionErrors : Errors;
	
	private var preactions : Array<NodeAction>;
	private var postactions : Array<NodeAction>;
	
	private var symbol : String;
	private var modifiers : Array<String>;
	private var action : NodeAction;
	
	public function new(parent : TraceryNode, grammar : Grammar, childIndex : Int, settings : Settings) 
	{
		errors = [];
		isExpanded = false;
		
		// No input? Add an error, but continue anyways
		if (settings.raw == null)
		{
			errors.push("Empty input for node");
			settings.raw = "";
		}
		
		// If the root node of an expansion, it will have the grammar passed as the 'parent'
		//  set the grammar from the 'parent', and set all other values for a root node
		if (grammar != null)
		{
			this.grammar = grammar;
			this.parent = null;
			this.depth = 0;
			this.childIndex = 0;
		}
		else
		{
			this.grammar = parent.grammar;
			this.parent = parent;
			this.depth = parent.depth + 1;
			this.childIndex = childIndex;
		}
		
		this.raw = settings.raw;
		this.type = settings.type;
		this.isExpanded = false;
		
		if (this.grammar == null)
		{
			trace("No grammar specified for this node", this);
		}
	}
	
	
	public function toString()
	{
		return 'Node(\'$raw\' $type d:$depth)';
	}
	
	
	public function expandChildren(childRule, preventRecursion : Bool)
	{
		children = [];
		finishedText = "";
		
		// Set the rule for making children,
		// and expand it into section
		this.childRule = childRule;
		
		if (this.childRule != null)
		{
			var sections = Tracery.parse(this.childRule);
			
			// Add errors to this
			if (sections.errors.length > 0)
			{
				errors = errors.concat(sections.errors);
			}
			
			for (i in 0...sections.sections.length)
			{
				this.children[i] = new TraceryNode(this, null, i, sections.sections[i]);
				if (!preventRecursion)
				{
					children[i].expand(preventRecursion);
				}
				
				// Add in the finished text
				finishedText += children[i].finishedText;
			}
		}
		else
		{
			// In normal operation this shouldn't ever happen
			errors.push("No child rule provided, can't expand children");
			trace("No child rule provided, can't expand children");
		}
	}
	
	// Expand this rule (possibly creating children)
	public function expand(preventRecursion:Bool)
	{
		if (!isExpanded)
		{
			isExpanded = true;
			
			expansionErrors = [];
			
			// Types of nodes
			// -1: raw, needs parsing (RAW)
			//  0: Plaintext (PLAINTEXT)
			//  1: Tag ("#symbol.mod.mod2.mod3#" or "#[pushTarget:pushRule]symbol.mod") (TAG)
			//  2: Action ("[pushTarget:pushRule], [pushTarget:POP]", more in the future) (ACTION)
			
			switch (type)
			{
			// Raw rule
			case RAW:
				expandChildren(raw, preventRecursion);
				
			// plaintext, do nothing but copy text into finsihed text
			case PLAINTEXT:
				finishedText = raw;
				
			// Tag
			case TAG:
				// Parse to find any actions, and figure out what the symbol is
				preactions = [];
				postactions = [];
				
				var parsed = Tracery.parseTag(raw);
				
				// Break into symbol actions and modifiers
				symbol = parsed.symbol;
				modifiers = parsed.modifiers;
				
				// Create all the preactions from the raw syntax
				for (preaction in parsed.preactions)
				{
					preactions.push(new NodeAction(this, preaction.raw));
				}
				for (postaction in parsed.postactions)
				{
					//postactions.push(new NodeAction(this, postaction.raw));
				}
				
				// Make undo actions for all preactions (pops for each push)
				for (preaction in preactions)
				{
					if (preaction.type == NodeActionType.PUSH)
					{
						postactions.push(preaction.createUndo());
					}
				}
				
				// Activate all the preactions
				for (preaction in preactions)
				{
					preaction.activate();
				}
				
				finishedText = raw;
				
				// Expand (passing the node, this allows tracking of recurson depth)
				
				var selectedRule = grammar.selectRule(symbol, this, errors);
				
				expandChildren(selectedRule, preventRecursion);
				
				// Apply modifiers
				// TODO: Update parse function to not trigger on hashtags within parenthesis within tags,
				//   so that modifier parameters can contain tags "#story.replace(#protagonist#, #newCharacters#)#"
				for (modifier in modifiers)
				{
					var modName : String = modifier;
					var modParams = [];
					var startOfParenthesis = modName.indexOf("(");
					
					if (startOfParenthesis > 0)
					{
						var regExp = ~/\(([^)]+)\)/;
						
						// Todo: ignore any escaped commas. For now, commas always split
						var results = regExp.match(modifier);
						if (results)
						{
							var modParams = regExp.split(modName);
							modName = modifier.substring(0, startOfParenthesis);
						}
						
					}
					
					var mod : Modifier = grammar.modifiers[modName];
					
					// Missing modifier?
					if (mod == null)
					{
						errors.push('Missing modifier $modName');
						finishedText += ' ((.$modName))';
					}
					else
					{
						finishedText = mod(finishedText, modParams);
						
					}
				}
				
				// Perform post-actions
				for (postaction in postactions)
				{
					postaction.activate();
				}
				
			case ACTION:
				
				// Just a bare action? Expand it!
				action = new NodeAction(this, raw);
				action.activate();
				
				// No visible text for an action
				// TODO: some visible text for if there is a failure to perform the action?
				finishedText = "";
			}
		}
		else
		{
			//trace('Already expanded $this');
		}
	}
	
	public function clearEscapeChars()
	{
		finishedText = 
			StringTools.replace(
				StringTools.replace(
					finishedText, 
					"\\\\", 
					"DOUBLEBACKSLASH"),
				"DOUBLEBACKSLASH",
				"\\");
	}
}