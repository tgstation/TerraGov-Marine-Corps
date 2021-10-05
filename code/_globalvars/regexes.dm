//These are a bunch of regex datums for use /((any|every|no|some|head|foot)where(wolf)?\sand\s)+(\.[\.\s]+\s?where\?)?/i
GLOBAL_DATUM_INIT(is_http_protocol, /regex, regex("^https?://"))

GLOBAL_DATUM_INIT(is_website, /regex, regex("http|www.|\[a-z0-9_-]+.(com|org|net|mil|edu)+", "i"))
GLOBAL_DATUM_INIT(is_email, /regex, regex("\[a-z0-9_-]+@\[a-z0-9_-]+.\[a-z0-9_-]+", "i"))
GLOBAL_DATUM_INIT(is_alphanumeric, /regex, regex("\[a-z0-9]+", "i"))
GLOBAL_DATUM_INIT(is_punctuation, /regex, regex("\[.!?]+", "i"))

//All < and > characters
GLOBAL_DATUM_INIT(angular_brackets, /regex, regex(@"[<>]", "g"))

//All characters forbidden by filenames: ", \, \n, \t, /, ?, %, *, :, |, <, >
GLOBAL_DATUM_INIT(filename_forbidden_chars, /regex, regex(@{""|[\\\n\t/?%*:|<>]"}, "g"))
// had to use the OR operator for quotes instead of putting them in the character class because it breaks the syntax highlighting otherwise.
