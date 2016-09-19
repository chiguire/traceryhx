package tracery;
import tracery.Errors;

/**
 * ...
 * @author 
 */
class RuleSet
{
	public var grammar(default, null) : Grammar;
	public var raw(default, null) : Dynamic;
	public var falloff(default, null) : Float;
	public var defaultRules(default, null) : Array<Dynamic>;
	public var defaultUses(default, null) : Array<Int>;
	public var conditionalRule(default, null) : Dynamic;
	public var conditionalValues(default, null) : Map<String, RuleSet>;
	public var ranking(default, null) : Array<RuleSet>;
	public var distribution(default, null) : DistributionType;
	public var shuffledDeck(default, null) : Array<Int>;
	
	public function new(grammar : Grammar, raw:Dynamic) 
	{
		this.grammar = grammar;
		this.raw = raw;
		falloff = 1;
		
		if (Std.is(raw, Array)) {
			defaultRules = [];
			
			for (i in (0...raw.length)) {
				defaultRules.push(Std.string(raw[i]));
			}	
		}
		else if (Std.is (raw, String)) {
			defaultRules = [Std.string(raw)];
		}
		else { // if (raw === 'object')
			// TODO: support for conditional and hierarchical rule sets
		}
	}
	
	public function selectRule(?errors:Errors)
	{
		//trace('Get rule', raw);
		// Is there a conditional?
		if (conditionalRule != null)
		{
			var value = grammar.expand(conditionalRule, true);
			//does this value match any of the conditionals?
			if (conditionalValues.exists(value.finishedText))
			{
				var v = conditionalValues.get(value.finishedText).selectRule(errors);
				if (v != null)
				{
					return v;
				}
			}
			// No returned value?
		}
		
		// Is there a ranked order?
		if (ranking != null)
		{
			for (r in ranking)
			{
				var v = r.selectRule();
				if (v != null)
				{
					return v;
				}
			}
			
			// Still no returned value?
		}
		
		if (defaultRules != null)
		{
			var index = 0;
			// Select from this basic array of rules
			
			// Get the distribution from the grammar if there is no other
			var distribution : DistributionType = 
				if (this.distribution != null)         this.distribution
				else if (grammar.distribution != null) grammar.distribution;
				else                                   DistributionType.RANDOM_INDEX;
			
			switch (distribution)
			{
				case SHUFFLE:
					// create a shuffle desk
					if (shuffledDeck == null || shuffledDeck.length == 0)
					{
						// make an array
						shuffledDeck = fyshuffle([for (i in 0...defaultRules.length) i], falloff);
					}
					
					index = shuffledDeck.pop();
					
				case WEIGHTED:
					errors.push("Weighted distribution not yet implemented");
					
				case FALLOFF:
					errors.push("Falloff distribution not yet implemented");
					
				default:
					index = Math.floor(Math.pow(Tracery.rng(), falloff) * defaultRules.length);
			}
			
			if (defaultUses == null)
			{
				defaultUses = [];
			}
			
			//defaultUses[index] = if (defaultUses[index] == null) 1 else ++defaultUses[index];
			++defaultUses[index];
			
			return defaultRules[index];
		}
		
		if (errors != null)
		{
			errors.push('No default rules defined for $this');
		}
		return null;
	}
	
	
	public function clearState()
	{
		if (defaultUses != null)
		{
			defaultUses = [];
		}
	}
	
	
	private static function fyshuffle(array:Array<Int>, falloff : Float)
	{
		var currentIndex = array.length;
		
		// While there remain elements to shuffle...
		while (0 != currentIndex)
		{
			
			// Pick a remaining element...
			var randomIndex = Math.floor(Tracery.rng() * currentIndex);
			currentIndex--;
			
			// And swap it with the current element.
			var temporaryValue = array[currentIndex];
			array[currentIndex] = array[randomIndex];
			array[randomIndex] = temporaryValue;
		}
		
		return array;
	}
}