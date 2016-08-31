package tracery;
import tracery.Errors;
import haxe.Json;

/**
 * ...
 * @author 
 */

class Symbol
{
	public var key(default, null) : String;
	public var grammar(default, null) : Grammar;
	public var rawRules(default, null) : Dynamic;
	public var baseRules(default, null) : RuleSet;
	public var stack(default, null) : Array <RuleSet>;
	public var uses(default, null) : Array<TraceryNode>;
	public var isDynamic(default, null) : Bool;
	
	public function new(grammar:Grammar, key : String, rawRules : Dynamic) 
	{
		// Symbols can be made with a single value, and array, or array of objects of (conditions/values)
		this.key = key;
		this.grammar = grammar;
		this.rawRules = rawRules;
		isDynamic = false;
		
		this.baseRules = new RuleSet(this.grammar, rawRules);
		clearState();
	}
	
	public function clearState()
	{
		
		// Clear the stack and clear all ruleset usages
		stack = [baseRules];
		
		uses = [];
		baseRules.clearState();
	}
	
	public function pushRules(rawRules:Dynamic)
	{
		var rules = new RuleSet(grammar, rawRules);
		stack.push(rules);
	}
	
	public function popRules()
	{
		stack.pop();
	}
	
	public function selectRule(node : TraceryNode, errors : Errors)
	{
		uses.push(node);
		
		if (stack.length == 0)
		{
			errors.push('The rule stack for \'$key\' is empty, too many pops?');
			return '(($key))';
		}
		
		return stack[stack.length - 1].selectRule();
	}
	
	public function getActiveRules()
	{
		if (stack.length == 0)
		{
			return null;
		}
		return stack[stack.length - 1].selectRule();
	}
	
	public function rulesToJSON()
	{
		return Json.stringify(rawRules);
	}
	
	public function markAsDynamic() {
		isDynamic = true;
	}
}