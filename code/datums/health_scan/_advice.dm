/// List of all non-abstract advice datums
GLOBAL_LIST_INIT(scanner_advice, init_advice_datums())

/// Initializes every non-abstract advice datum
/proc/init_advice_datums()
	. = list()
	for(var/datum/scanner_advice/advice_type AS in sortTim(subtypesof(/datum/scanner_advice), GLOBAL_PROC_REF(cmp_scanner_advice_priority)))
		if(initial(advice_type.abstract_type) == advice_type)
			continue
		.[advice_type] = new advice_type

/**
 * Represents an individual, situational advice entry in the health analyzer.
 *
 * Each datum that isn't abstract is initialized and placed in `GLOB.scanner_advice`.
 *
 * When health analyzers handle advice they will iterate through this global list and
 * call [/datum/scanner_advice/proc/can_show], if it returns TRUE we move on to
 * [/datum/scanner_advice/proc/get_data] and feed the list that returns into the analyzer's UI data.
 */
/datum/scanner_advice
	/// Order this will be initialized and therefore show in the advice section.
	/// Multiple datums using the same priority will show in BYOND declarative order.
	/// Used for controlling the order that advice shows like the old system.
	var/priority = ADVICE_PRIORITY_DEFAULT
	/// Won't initialize if our type is this
	var/abstract_type = /datum/scanner_advice

/**
 * Proc for if this advice is eligible to show up in the health analyzer.
 *
 * If the return value is non-null `get_data` will be called for getting the advvice
 * contents, otherwise ignored.
 */
/datum/scanner_advice/proc/can_show(mob/living/carbon/human/patient, mob/user)
	CRASH("[type]/can_show is calling parent or has not implemented checks.")

/**
 * Proc for getting the data of this advice. Returning multiple lists is supported.
 *
 * This system looks dumber than just static vars/etc, *but* static data can't be viable for
 * everything, since some datums want to change their data based on species and other factors.
 *
 * Usage rules:
 * * Keys are not optional. TGUI won't bluescreen if one is missing, but it is quite jarring for users if something is empty/default.
 * * The name of every entry must be kept short so it doesn't span more than one line on the default width of the UI.
 * * HTML tags like `<b>`/`<i>`/etc may not be used in names or tooltips. TGUI can't use these tags outside of compile time expressions.
 *
 * Examples:
 * ```dm
 * // single advice:
 * . = list(
 * 	ADVICE_TEXT = "Friend detected :)"
 * 	ADVICE_TOOLTIP = "FontAwesome worm please save me"
 * 	ADVICE_ICON = FA_ICON_WORM,
 * 	ADVICE_ICON_COLOR = "#FF99FF" // this can be a hex code, a tgui map color or juke map color
 * )
 * ...
 * // multiple entries:
 * . = list()
 * . += list(list(
 * 	ADVICE_TEXT = "Wormy detected :)"
 * 	ADVICE_TOOLTIP = "FontAwesome worm please save me"
 * 	ADVICE_ICON = FA_ICON_WORM,
 * 	ADVICE_ICON_COLOR = "#FF99FF"
 * ))
 * . += list(list(
 * 	ADVICE_TEXT = "Feline detected :)"
 * 	ADVICE_TOOLTIP = "FontAwesome cat please save me"
 * 	ADVICE_ICON = FA_ICON_CAT,
 * 	ADVICE_ICON_COLOR = "#FFCCFF"
 * ))
 * ```
 */
/datum/scanner_advice/proc/get_data(mob/living/carbon/human/patient, mob/user)
	CRASH("[type]/get_data is calling parent or has not implemented data.")
