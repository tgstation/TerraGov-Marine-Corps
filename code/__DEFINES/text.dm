/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext_char(x, findtextEx_char(x, "x") + 1))

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace_char(text, ""))

/// Simply removes the < and > characters, and limits the length of the message.
#define STRIP_HTML_SIMPLE(text, limit) (GLOB.angular_brackets.Replace_char(copytext_char(text, 1, limit), ""))
