package tracery.modifiers;

import tracery.Modifier.ModifierParam;

/**
 * ...
 * @author 
 */
class ModsEngBasicHelper
{
	static public function isVowel(c:String) {
		var c2 = c.toLowerCase();
		return (c2 == 'a') || (c2 == 'e') || (c2 == 'i') || (c2 == 'o') || (c2 == 'u');
	};

	static public function isAlphaNum(c:String) {
		return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9');
	}

	static public function escapeRegExp(str:String) {
		var regexp = ~/([.*+?^=!:${}()|\[\]\/\\])/g;
		return regexp.replace(str, "\\$1");
	}
}

class ModsEngBasic
{
	static public var baseEngModifiers : Map<String, Modifier> = [
		"replace" => function(s:String, params:Array<ModifierParam>)
		{
			//http://stackoverflow.com/questions/1144783/replacing-all-occurrences-of-a-string-in-javascript
			var regexp = new EReg(ModsEngBasicHelper.escapeRegExp(params[0]), 'g');
			return regexp.replace(s, params[1]);
		},
		
		"capitalizeAll" => function(s:String, params:Array<ModifierParam>)
		{
			var s2 : String = "";
			var capNext = true;

			for (i in 0...s.length) {

				if (!ModsEngBasicHelper.isAlphaNum(s.charAt(i))) {
					capNext = true;
					s2 += s.charAt(i);
				} else {
					if (!capNext) {
						s2 += s.charAt(i);
					} else {
						s2 += s.charAt(i).toUpperCase();
						capNext = false;
					}

				}
			}
			return s2;
		},
		
		"capitalize" => function(s:String, params:Array<ModifierParam>)
		{
			return s.charAt(0).toUpperCase() + s.substring(1);
		},
		
		"a" => function(s:String, params:Array<ModifierParam>)
		{
			if (s.length > 0) {
				if (s.charAt(0).toLowerCase() == 'u') {
					if (s.length > 2) {
						if (s.charAt(2).toLowerCase() == 'i')
							return "a " + s;
					}
				}

				if (ModsEngBasicHelper.isVowel(s.charAt(0))) {
					return "an " + s;
				}
			}

			return "a " + s;
		},
		
		"firstS" => function(s:String, params:Array<ModifierParam>)
		{
			trace(s);
			var s2 = s.split(" ");

			var finished = baseEngModifiers["s"](s2[0], []) + " " + s2.slice(1).join(" ");
			trace(finished);
			return finished;
		},
		
		"s" => function(s:String, params:Array<ModifierParam>)
		{
			switch (s.charAt(s.length - 1)) {
			case 's':
				return s + "es";
			case 'h':
				return s + "es";
			case 'x':
				return s + "es";
			case 'y':
				if (!ModsEngBasicHelper.isVowel(s.charAt(s.length - 2)))
					return s.substring(0, s.length - 1) + "ies";
				else
					return s + "s";
			default:
				return s + "s";
			}
		},
		
		"ed" => function(s:String, params:Array<ModifierParam>)
		{
			switch (s.charAt(s.length -1)) {
			case 's':
				return s + "ed";
			case 'e':
				return s + "d";
			case 'h':
				return s + "ed";
			case 'x':
				return s + "ed";
			case 'y':
				if (!ModsEngBasicHelper.isVowel(s.charAt(s.length - 2)))
					return s.substring(0, s.length - 1) + "ied";
				else
					return s + "d";
			default:
				return s + "ed";
			}
		},
	];
}