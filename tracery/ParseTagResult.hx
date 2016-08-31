package tracery;
import tracery.Symbol;

/**
 * @author 
 */
typedef ParseTagResult =
{
	symbol : String,
	modifiers : Array<String>,
	errors : Errors,
	preactions : Array<SectionItem>,
	postactions : Array<SectionItem>,
};