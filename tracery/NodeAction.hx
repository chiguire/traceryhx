package tracery;
import tracery.NodeActionType;

// An action that occurs when a node is expanded
// Types of actions:
// 0 Push: [key:rule]
// 1 Pop: [key:POP]
// 2 function: [functionName(param0,param1)] (TODO!)
class NodeAction
{
	public var node(default, null): TraceryNode;
	public var raw(default, null): String;
	public var type(default, null): NodeActionType;
	public var target(default, null): String;
	public var rule(default, null) : String;

	public var ruleSections(default, null) : Array<String>;
	public var finishedRules(default, null) : Array<String>;
	
	public function new(node : TraceryNode, raw : String) 
	{
		//if (node == null)
		//{
		//	trace("No node for NodeAction");
		//}
		//if (raw == null)
		//{
		//	trace("No raw commands for NodeAction");
		//}
		
		this.node = node;
		
		var sections = raw.split(":");
		target = sections[0];
		
		// No colon? A function!
		if (sections.length == 1)
		{
			type = FUNCTION;
		}
		// Colon? It's either a push or a pop
		else
		{
			rule = sections[1];
			if (rule == "POP")
			{
				type = POP;
			}
			else
			{
				type = PUSH;
			}
		}
	}
	
	public function createUndo()
	{
		if (type == PUSH)
		{
			return new NodeAction(node, '$target:POP');
		}
		// TODO Not sure how to make Undo actions for functions or POPs
		return null;
	}
	
	public function activate()
	{
		var grammar = node.grammar;
		switch (type)
		{
		case PUSH:
			// split into sections (the way to denote an array of rules)
			ruleSections = rule.split(",");
			finishedRules = [];
			for (ruleSection in ruleSections)
			{
				var n = new TraceryNode(
					null, 
					grammar, 
					0,
					{
						type: RAW,
						raw: ruleSection,
					}
				);
				
				n.expand(false);
				
				finishedRules.push(n.finishedText);
			}
			
			// TODO: escape commas properly
			grammar.pushRules(target, finishedRules, this);
			
		case POP:
			grammar.popRules(target);
			
		case FUNCTION:
			grammar.flatten(target, true);
		}
	}
	
	public function toText()
	{
		return switch (type)
		{
		case PUSH: '$target:$rule';
		case POP:  '$target:POP';
		case FUNCTION: '((some function))';
		default: '((Unknown Action))';
		};
	}
}