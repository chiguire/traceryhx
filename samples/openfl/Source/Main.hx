package;

import tracery.Tracery;
import tracery.modifiers.ModsEngBasic;

import openfl.display.Sprite;


class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		var foo = {
			vipTitle : ["Dr.", "Professor", "Lord", "Sir", "Captain", "His Majesty"],
			occupationBase : ["firefighter", "scientist", "spy", "smuggler", "mechanic", "astronaut", "adventurer", "pirate", "cowboy", "vampire", "detective", "soldier", "marine", "doctor", "ninja"],
			occupation : ["space #occupationBase#", "erotic #occupationBase#", "professional #occupationBase#", "gentleman #occupationBase#", "#occupationBase#"],
			name : ["Chesty", "Butch", "Saber", "Drake", "Thorax", "Brash", "Abs", "Burt", "Slate", "Bret", "Duke"],
			surnameStart : "Up Pants Chest Pants Chest Pants Chest Pants Chest Pants Chest Pants Chest Pants Chest Pants Chest West Long East North River South Snith Cross Aft Aver Ever Down Whit Rob Rod Hesel Kings Queens Ed Sift For Farring Coven Craig Cath Chil Clif Grit Grand Orla Prat Milt Wilt Berk Draft Red Black".split(" "),
			surnameEnd : "castle hammer master end wrench bottom hammer wick shire gren glen swith bury every stern ner brath mill bly ham tine field groat sythe well bow bone wind storm horn thorne cart bry ton man watch leath heath ley".split(" "),
			characterType : "android velociraptor dragon gorilla sasquatch alien squid cuttlefish".split(" "),
			character : ["#characterType#", "#characterMod# #characterType#"],
			drink : ["cup of chamomile tea", "glass of milk", "shot of vodka", "dry martini", "fuzzy navel", "appletini", "double shot of gin", "Campari", "glass of champagne", "bottle of Domaine Leroy Musigny Grand Cru"],
			said : ["purred", "whispered", "said", "murmurred", "growled"],
			characterMod : ["cybernetic", "robotic"],
			description : ["muscled", "sexy", "dark", "well-dressed", "masculine", "dramatic", "dramatically lit", "boyish", "burly", "handsome", "erotic"],
			surname : ["Mc#surnameStart.capitalize##surnameEnd#", "#surnameStart.capitalize##surnameEnd#"],
			locationAdj : ["dimly lit", "crowded", "smoke-filled"],
			locationBase : ["space station", "film studio", "70s nightclub", "undersea research station"],
			titleNoun : ["desire", "night", "awakening", "surrender", "obsession", "vision", "proposition", "game", "promise", "arrangement", "treasure", "dream", "embrace", "struggle", "pleasure", "discovery", "wish", "need"],
			titleAdj : ["dark", "erotic", "leather", "rough", "punishing", "burly", "country", "neon", "big-city", "whiskey", "shattered", "broken", "breathless", "tangled", "complicated", "captured", "priceless", "bound", "sinful", "forgotten", "forbidden", "gothic", "interstellar"],
			title : ["#titleAdj.a# #titleNoun#", "#titleAdj# #titleNoun.s#", "#mcName#'s #titleNoun#"],
		   
			response:[" <p>The #description# #scType# looked at him with interest.  'I'm #scName#.  #vipTitle# #scName# #surname#, #occupation#,' the #scType# #said#. 'I'll have #drink.a#.' <p>"],
			meeting: ["#scType.a.capitalize# was sitting by the bar, alone, #description#, #description#.  #mcName# introduced himself.  'I'm #mcName#', he #said#. 'I'm #occupation.a#.  Can I buy you a drink?'"],
			entry : ["...<p>#mcName# #surname# walked into the #locationAdj# #place#."],
			plot : ["<h2>#title.capitalizeAll#</h2><p>#entry#<p>#meeting#<p>#response#"],
			origin : "#[place:#locationBase#][mcType:#character#][scType:#character#][mcName:#name#][scName:#name#]plot#",
		};
		
		var bar = {
			"yourdescription":["You were reading a maths book"],
			"regret":["It's a shame we couldn't chat about Gödel"],
			"invitation":["drinks?","Care to talk?"],
			"mydescription":["Boy in striped jeans"],
			"origin":["#yourdescription#. #regret#. #invitation# - #mydescription#"]
		}
		
		var grammar = Tracery.createGrammar(foo);
		grammar.addModifiers(ModsEngBasic.baseEngModifiers);
		trace("Grammar result: " + grammar);
		
		trace("Flatten result: " + grammar.flatten("#origin#", false));
		trace("Flatten result: " + grammar.flatten("#origin#", false));
		trace("Flatten result: " + grammar.flatten("#origin#", false));
		trace("Flatten result: " + grammar.flatten("#origin#", false));
	}
	
	
}