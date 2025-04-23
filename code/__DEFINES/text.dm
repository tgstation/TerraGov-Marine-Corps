/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/**
 * Pixel-perfect scaled fonts for use in the MAP element as defined in skin.dmf
 *
 * Four sizes to choose from, use the sizes as mentioned below.
 * Between the variations and a step there should be an option that fits your use case.
 * BYOND uses pt sizing, different than px used in TGUI. Using px will make it look blurry due to poor antialiasing.
 *
 * Default sizes are prefilled in the macro for ease of use and a consistent visual look.
 * To use a step other than the default in the macro, specify it in a span style.
 * For example: MAPTEXT_PIXELLARI("<span style='font-size: 24pt'>Some large maptext here</span>")
 */
/// Large size (ie: context tooltips) - Size options: 12pt 24pt.
#define MAPTEXT_PIXELLARI(text) {"<span style='font-family: \"Pixellari\"; font-size: 12pt; -dm-text-outline: 1px black'>[##text]</span>"}

/// Standard size (ie: normal runechat) - Size options: 6pt 12pt 18pt.
#define MAPTEXT_GRAND9K(text) {"<span style='font-family: \"Grand9K Pixel\"; font-size: 6pt; -dm-text-outline: 1px black'>[##text]</span>"}

/// Small size. (ie: context subtooltips, spell delays) - Size options: 12pt 24pt.
#define MAPTEXT_TINY_UNICODE(text) {"<span style='font-family: \"TinyUnicode\"; font-size: 12pt; line-height: 0.75; -dm-text-outline: 1px black'>[##text]</span>"}

/// Smallest size. (ie: whisper runechat) - Size options: 6pt 12pt 18pt.
#define MAPTEXT_SPESSFONT(text) {"<span style='font-family: \"Spess Font\"; font-size: 6pt; line-height: 1.4; -dm-text-outline: 1px black'>[##text]</span>"}

#define CENTER_ALIGN_TEXT "center"
#define LEFT_ALIGN_TEXT "left"
#define RIGHT_ALIGN_TEXT "right"


#define MAPTEXT_HUDMESSAGE_TITLE(text, alignment) {"<span style='font-family: \"F25 Bank\"; font-size: 12pt; line-height: 1.25; text-align: [##alignment]'><u>[##text]</u></span>"}

#define MAPTEXT_HUDMESSAGE(text, alignment) {"<span style='font-family: \"F25 Bank\"; font-size: 10pt; line-height: 1; text-align: [##alignment]; -dm-text-outline: 1px black'>[##text]</span>"}

#define HUD_ANNOUNCEMENT_FORMATTING(title, text, alignment) (MAPTEXT_HUDMESSAGE_TITLE(##title, ##alignment) + "<br>" + MAPTEXT_HUDMESSAGE(##text, ##alignment))

/**
 * Prepares a text to be used for maptext, using a variable size font.
 *
 * More flexible but doesn't scale pixel perfect to BYOND icon resolutions.
 * (May be blurry.) Can use any size in pt or px.
 *
 * You MUST Specify the size when using the macro
 * For example: MAPTEXT_VCR_OSD_MONO("<span style='font-size: 24pt'>Some large maptext here</span>")
 */
/// Prepares a text to be used for maptext, using a variable size font.
/// Variable size font. More flexible but doesn't scale pixel perfect to BYOND icon resolutions. (May be blurry.) Can use any size in pt or px.
#define MAPTEXT_VCR_OSD_MONO(text) {"<span style='font-family: \"VCR OSD Mono\"'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
/// resolves the MeasureText() return value once, then resolves the height, then sets return_var to that.
#define WXH_TO_HEIGHT(measurement, return_var) \
	do { \
		var/_measurement = measurement; \
		return_var = text2num(copytext(_measurement, findtextEx(_measurement, "x") + 1)); \
	} while(FALSE)

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

/// Simply removes the < and > characters, and limits the length of the message.
#define STRIP_HTML_SIMPLE(text, limit) (GLOB.angular_brackets.Replace(copytext(text, 1, limit), ""))

/**
 * stuff like `copytext(input, length(input))` will trim the last character of the input,
 * because DM does it so it copies until the char BEFORE the `end` arg, so we need to bump `end` by 1 in these cases.
 */
#define PREVENT_CHARACTER_TRIM_LOSS(integer) (integer + 1)

/// BYOND's string procs don't support being used on datum references (as in it doesn't look for a name for stringification)
/// We just use this macro to ensure that we will only pass strings to this BYOND-level function without developers needing to really worry about it.
#define LOWER_TEXT(thing) lowertext(UNLINT("[thing]"))
