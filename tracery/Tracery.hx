package tracery;

/**
 * ...
 * @author 
 */
class Tracery
{
	public static var rng = Math.random;
	
	public static function setRng(newRng)
	{
		rng = newRng;
	}

	public static function createGrammar(raw:Dynamic)
	{
		return new Grammar(raw);
	}
	
	public static function parseTag(tagContents:String) : ParseTagResult
	{
		var parsed : ParseTagResult = {
			preactions: [],
			postactions: [],
			symbol: null,
			errors: [],
			modifiers: [],
		};
		
		var sections = parse(tagContents);
		var symbolSection = null;
		for (section in sections.sections)
		{
			if (section.type == PLAINTEXT)
			{
				if (symbolSection == null)
				{
					symbolSection = section.raw;
				}
				else
				{
					throw 'multiple main sections in $tagContents';
				}
			}
			else
			{
				parsed.preactions.push(
				{
					type: section.type,
					raw: section.raw,
				});
			}
		}
		
		if (symbolSection == null)
		{
			// throw 'no main section in $tagContents';
		}
		else
		{
			var components : Array<String>= symbolSection.split(".");
			parsed.symbol = components[0];
			parsed.modifiers = components.slice(1);
		}
		return parsed;
	}
	
	
	public static function parse(rule:String) : ParseResult
	{
		var depth = 0;
		var inTag = false;
		var sections : ParseResult = {
			sections : [],
			errors : [],
		};
		var escaped = false;
		
		var start = 0;
		
		var escapedSubstring = "";
		var lastEscapedChar = -1;
		
		if (rule == null)
		{
			return sections;
		}
		
		var createSection = function(start : Int, end : Int, type : TraceryNodeType)
		{
			if (end - start < 1)
			{
				if (type == TraceryNodeType.TAG)
				{
					sections.errors.push('$start: empty tag');
				}
				if (type == TraceryNodeType.ACTION)
				{
					sections.errors.push('$start: empty action');
				}
			}
			
			var rawSubstring : String;
			if (lastEscapedChar != -1) 
			{
				rawSubstring = '$escapedSubstring\\${rule.substring(lastEscapedChar + 1,end)}';
			}
			else
			{
				rawSubstring = rule.substring(start, end);
			}
			sections.sections.push(
			{
				type: type,
				raw: rawSubstring
			});
			lastEscapedChar = -1;
			escapedSubstring = "";
		};
		
		for (i in 0...rule.length)
		{
			if (!escaped)
			{
				var c = rule.charAt(i);
				
				switch (c)
				{
				// Enter a deeper bracketed section
				case '[':
					if (depth == 0 && !inTag)
					{
						if (start < i)
						{
							createSection(start, i, PLAINTEXT);
						}
						start = i + 1;
					}
					depth++;
					
				case ']':
					depth--;
					
					// End a bracketed section
					if (depth == 0 && !inTag)
					{
						createSection(start, i, ACTION);
						start = i + 1;
					}
				
				// Hashtag
				//   ignore if not at depth 0, that means we are in a bracket
				case '#':
					if (depth == 0)
					{
						if (inTag)
						{
							createSection(start, i, TAG);
							start = i + 1;
						}
						else
						{
							if (start < i)
							{
								createSection(start, i, PLAINTEXT);
							}
							start = i + 1;
						}
						inTag = !inTag;
					}
					
				case '\\':
					escaped = true;
					escapedSubstring = escapedSubstring + rule.substring(start, i);
					start = i + 1;
					lastEscapedChar = i;
				
				default:
					//no-op
				}
			}
			else
			{
				escaped = false;
			}
		}
		if (start < rule.length)
		{
			createSection(start, rule.length, PLAINTEXT);
		}
		
		if (inTag)
		{
			sections.errors.push("Unclosed tag");
		}
		if (depth > 0)
		{
			sections.errors.push("Too many [");
		}
		if (depth < 0)
		{
			sections.errors.push("Too many ]");
		}
		
		// Strip out empty plaintext sections
		
		sections.sections = Lambda.array(Lambda.filter(sections.sections, function(section:SectionItem)
		{
			return !(section.type == TraceryNodeType.PLAINTEXT && 
				section.raw.length == 0);
		}));
		
		return sections;
		
	}
}