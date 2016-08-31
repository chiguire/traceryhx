package tracery;
import tracery.DistributionType;
import tracery.Errors;

/**
 * ...
 * @author 
 */
class Grammar
{
	private var raw : String;
	public var modifiers (default, null): Map<String, Modifier>;
	private var symbols : Map<String, Symbol>;
	private var subgrammars : Array<Grammar>;
	public var distribution (default, null): DistributionType;
	private var errors : Errors;
	
	public function new(raw : Dynamic, ?settings : Settings) 
	{
		modifiers = new Map<String,Modifier>();
		errors = [];
		loadFromRawObj(raw);
	}
	
	public function clearState()
	{
		for (s in symbols)
		{
			s.clearState();
		}
	}
	
	public function addModifiers(mods:Map<String, Modifier>)
	{
		// copy over the base modifiers
		for (k in mods.keys())
		{
			modifiers[k] = mods[k];
		}
	}
	
	public function loadFromRawObj(raw)
	{
		this.raw = Std.string(raw);
		this.symbols = new Map<String, Symbol>();
		this.subgrammars = [];
		
		if (raw != null)
		{
			// Add all rules to the grammar
			for (fieldname in Reflect.fields(raw)) 
			{
				symbols[fieldname] = new Symbol(this, fieldname, Reflect.field(raw, fieldname));
			}
		}
	}
	
	public function createRoot(rule : Dynamic)
	{
		// Create a node and subnodes
		var root = new TraceryNode(null, this, 0,
		{
			type: RAW,
			raw : rule,
		});
		
		return root;
	}
	
	public function expand(rule:Dynamic, allowEscapeChars : Bool)
	{
		var root = createRoot(rule);
		root.expand(false);
		if (!allowEscapeChars)
		{
			root.clearEscapeChars();
		}
		
		return root;
	}
	
	public function flatten(rule:Dynamic, allowEscapeChars : Bool)
	{
		var root = expand(rule, allowEscapeChars);
		
		return root.finishedText;
	}
	
	public function toJSON() 
	{
		var symbolJSON = [];
		for (k in symbols.keys())
		{
			symbolJSON.push(' "$k" : ${symbols[k].rulesToJSON()}');
		}
		
		return '{\n${symbolJSON.join(",\n")}\n}';
	}
	
	public function pushRules(key : String, rawRules : Dynamic, sourceAction : NodeAction)
	{
		if (!symbols.exists(key))
		{
			symbols[key] = new Symbol(this, key, rawRules);
			if (sourceAction != null)
			{
				symbols[key].markAsDynamic();
			}
			else
			{
				symbols[key].pushRules(rawRules);
			}
		}
	}
	
	public function popRules(key:String) 
	{
		if (!symbols.exists(key)) 
		{
			errors.push('Can\'t pop: no symbol for key $key');
		}
		symbols[key].popRules();
	}
	
	public function selectRule(key:String, node:TraceryNode, errors:Errors)
	{
		if (symbols.exists(key))
		{
			var rule = symbols[key].selectRule(node, errors);
			
			return rule;
		}
		
		// Failover to alternative subgrammars
		for (sg in subgrammars)
		{
			if (sg.symbols.exists(key))
			{
				return sg.symbols[key].selectRule(node, errors);
			}
		}
		
		// No symbol?
		errors.push('No symbol for \'$key\'');
		return '(($key))';
	}
}