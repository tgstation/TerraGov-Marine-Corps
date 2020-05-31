#define strip_improper(input_text) replacetext(replacetext(input_text, "\proper", ""), "\improper", "")


// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(t)
	return SSdbcore.Quote("[t]")


/proc/format_table_name(table)
	return CONFIG_GET(string/feedback_tableprefix) + table


//Simply removes < and > and limits the length of the message
/proc/strip_html_simple(t, limit = MAX_MESSAGE_LEN)
	var/list/strip_chars = list("<",">")
	t = copytext(t, 1, limit)
	for(var/char in strip_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + copytext(t, index + 1)
			index = findtext(t, char)
	return t


//Removes a few problematic characters
/proc/sanitize_simple(t, list/repl_chars = list("\n"=" ","\t"=" ","�"="�"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index + 1)
			index = findtext(t, char)
	return t


/proc/readd_quotes(t)
	var/list/repl_chars = list("&#34;" = "\"", "&#39;" = "\"")
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index + 5)
			index = findtext(t, char)
	return t


//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(t, list/repl_chars)
	return html_encode(sanitize_simple(t, repl_chars))


//Runs sanitize and strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' after sanitize() calls byond's html_encode()
/proc/strip_html(t, limit = MAX_MESSAGE_LEN)
	return copytext((sanitize(strip_html_simple(t))), 1, limit)


//Runs byond's sanitization proc along-side strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' that html_encode() would cause
/proc/adminscrub(t, limit = MAX_MESSAGE_LEN)
	return copytext((html_encode(strip_html_simple(t))), 1, limit)


//Returns null if there is any bad text in the string
/proc/reject_bad_text(text, max_length = MAX_MESSAGE_LEN, ascii_only = TRUE)
	var/char_count = 0
	var/non_whitespace = FALSE
	var/lenbytes = length(text)
	var/char = ""
	for(var/i = 1, i <= lenbytes, i += length(char))
		char = text[i]
		char_count++
		if(char_count > max_length)
			return
		switch(text2ascii(char))
			if(62, 60, 92, 47) // <, >, \, /
				return
			if(0 to 31)
				return
			if(32)
				continue
			if(127 to INFINITY)
				if(ascii_only)
					return
			else
				non_whitespace = TRUE
	if(non_whitespace)
		return text		//only accepts the text if it has some non-spaces


// Used to get a properly sanitized input, of max_length
// no_trim is self explanatory but it prevents the input from being trimed if you intend to parse newlines or whitespace.
/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length = MAX_MESSAGE_LEN, no_trim = FALSE)
	var/name = input(user, message, title, default) as text|null
	if(no_trim)
		return copytext(html_encode(name), 1, max_length)
	else
		return trim(html_encode(name), max_length) //trim is "outside" because html_encode can expand single symbols into multiple symbols (such as turning < into &lt;)

// Used to get a properly sanitized multiline input, of max_length
/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length=MAX_MESSAGE_LEN, no_trim=FALSE)
	var/name = input(user, message, title, default) as message|null
	if(no_trim)
		return copytext(html_encode(name), 1, max_length)
	else
		return trim(html_encode(name), max_length)


#define NO_CHARS_DETECTED 0
#define SPACES_DETECTED 1
#define SYMBOLS_DETECTED 2
#define NUMBERS_DETECTED 3
#define LETTERS_DETECTED 4

//Filters out undesirable characters from names
/proc/reject_bad_name(t_in, allow_numbers = FALSE, max_length = MAX_NAME_LEN, ascii_only = TRUE)
	if(!t_in)
		return //Rejects the input if it is null

	var/number_of_alphanumeric = 0
	var/last_char_group = NO_CHARS_DETECTED
	var/t_out = ""
	var/t_len = length(t_in)
	var/charcount = 0
	var/char = ""


	for(var/i = 1, i <= t_len, i += length(char))
		char = t_in[i]

		switch(text2ascii(char))
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED || last_char_group == SYMBOLS_DETECTED) //start of a word
					char = uppertext(char)
				number_of_alphanumeric++
				last_char_group = LETTERS_DETECTED

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(last_char_group == NO_CHARS_DETECTED || !allow_numbers) //suppress at start of string
					continue
				number_of_alphanumeric++
				last_char_group = NUMBERS_DETECTED

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if(last_char_group == NO_CHARS_DETECTED)
					continue
				last_char_group = SYMBOLS_DETECTED

			// ~   |   @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(last_char_group == NO_CHARS_DETECTED || !allow_numbers) //suppress at start of string
					continue
				last_char_group = SYMBOLS_DETECTED

			//Space
			if(32)
				if(last_char_group == NO_CHARS_DETECTED || last_char_group == SPACES_DETECTED) //suppress double-spaces and spaces at start of string
					continue
				last_char_group = SPACES_DETECTED

			if(127 to INFINITY)
				if(ascii_only)
					continue
				last_char_group = SYMBOLS_DETECTED //for now, we'll treat all non-ascii characters like symbols even though most are letters

			else
				continue

		t_out += char
		charcount++
		if(charcount >= max_length)
			break

	if(number_of_alphanumeric < 2)
		return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == SPACES_DETECTED)
		t_out = copytext_char(t_out, 1, -1) //removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))
			return	//(not case sensitive)

	return t_out

#undef NO_CHARS_DETECTED
#undef SPACES_DETECTED
#undef NUMBERS_DETECTED
#undef LETTERS_DETECTED


//Adds 'char' ahead of 'text' until there are 'count' characters total
/proc/add_leading(text, count, char = " ")
	var/charcount = count - length_char(text)
	var/list/chars_to_add[max(charcount + 1, 0)]
	return jointext(chars_to_add, char) + text

//Adds 'char' behind 'text' until there are 'count' characters total
/proc/add_trailing(text, count, char = " ")
	var/charcount = count - length_char(text)
	var/list/chars_to_add[max(charcount + 1, 0)]
	return text + jointext(chars_to_add, char)


//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for(var/i in 1 to length(text))
		if(text2ascii(text, i) <= 32)
			continue
		return copytext(text, i)
	return ""


//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for(var/i = length(text), i > 0, i--)
		if(text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)
	return ""


//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text, max_length)
	if(max_length)
		text = copytext_char(text, 1, max_length)
	return trim_left(trim_right(text))


//Returns a string with the first element of the string capitalized.
/proc/capitalize(t)
	. = t
	if(t)
		. = t[1]
		return uppertext(.) + copytext(t, 1 + length(.))


/proc/stringmerge(text,compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	var/text_it = 1 //iterators
	var/comp_it = 1
	var/newtext_it = 1
	var/text_length = length(text)
	var/comp_length = length(compare)
	while(comp_it <= comp_length && text_it <= text_length)
		var/a = text[text_it]
		var/b = compare[comp_it]
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext, 1, newtext_it) + b + copytext(newtext, newtext_it + length(newtext[newtext_it]))
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext, 1, newtext_it) + a + copytext(newtext, newtext_it + length(newtext[newtext_it]))
			else //The lists disagree, Uh-oh!
				return 0
		text_it += length(a)
		comp_it += length(b)
		newtext_it += length(newtext[newtext_it])

	return newtext


/proc/stringpercent(text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	var/lentext = length(text)
	var/a = ""
	for(var/i = 1, i <= lentext, i += length(a))
		a = text[i]
		if(a == character)
			count++
	return count


/proc/repeat_string(times, string = "")
	. = ""
	for(var/i in 1 to times)
		. += string


//Used in preferences' SetFlavorText and human's set_flavor verb
//Previews a string of len or less length
/proc/TextPreview(string, length = 40)
	if(length_char(string) > length(string))
		if(length_char(string) > length)
			return "[copytext_char(string, 1, 37)]..."
		if(!length(string))
			return "\[...\]"
		return string
	if(!length(string))
		return "\[...\]"
	if(length(string) > length)
		return "[copytext(string, 1, 37)]..."
	return string


//Used for applying byonds text macros to strings that are loaded at runtime
/proc/apply_text_macros(string)
	var/next_backslash = findtext(string, "\\")
	if(!next_backslash)
		return string

	var/leng = length(string)

	var/next_space = findtext(string, " ", next_backslash + length(string[next_backslash]))
	if(!next_space)
		next_space = leng - next_backslash

	if(!next_space)	//trailing bs
		return string

	var/base = next_backslash == 1 ? "" : copytext(string, 1, next_backslash)
	var/macro = lowertext(copytext(string, next_backslash + length(string[next_backslash]), next_space))
	var/rest = next_backslash > leng ? "" : copytext(string, next_space + length(string[next_space]))

	//See https://secure.byond.com/docs/ref/info.html#/DM/text/macros
	switch(macro)
		//prefixes/agnostic
		if("the")
			rest = text("\the []", rest)
		if("a")
			rest = text("\a []", rest)
		if("an")
			rest = text("\an []", rest)
		if("proper")
			rest = text("\proper []", rest)
		if("improper")
			rest = text("\improper []", rest)
		if("roman")
			rest = text("\roman []", rest)
		//postfixes
		if("th")
			base = text("[]\th", rest)
		if("s")
			base = text("[]\s", rest)
		if("he")
			base = text("[]\he", rest)
		if("she")
			base = text("[]\she", rest)
		if("his")
			base = text("[]\his", rest)
		if("himself")
			base = text("[]\himself", rest)
		if("herself")
			base = text("[]\herself", rest)
		if("hers")
			base = text("[]\hers", rest)

	. = base
	if(rest)
		. += .(rest)


GLOBAL_LIST_INIT(sanitize, list("<script", "/script>", "<iframe", "/iframe>", "<input", "<video", "<body", "<form", "<link", "<applet", "<frameset", "onerror",
	"onpageshow", "onscroll", "onforminput", "oninput", "onstorage", "onresize", "onpopstate", "onpagehide", "ononline", "onoffline", "onmessage", "onload",
	"onhashchange", "onbeforeunload", "onbeforeprint", "onafterprint", "onkeydown", "onkeyup", "onkeypress", "onfocus", "oncontextmenu", "onchange", "onblur",
	"oninvalid", "onreset", "onsearch", "onselect", "onsubmit", "ondblclick", "onclick", "onmousedown", "onmousemove", "onmousewheel", "onwheel", "onmouseup",
	"onmouseover", "onmouseout", "ondrop", "ondragstart", "ondragover", "ondragleave", "ondragenter", "ondragend", "ondrag", "onpaste", "oncut", "oncopy",
	"ontoggle", "onvolumechange", "onwaiting", "ontimeupdate", "onsuspend", "onstalled", "onseeking", "onseeked", "onratechange", "onprogress", "onplaying",
	"onplay", "onpause", "onloadstart", "onloadedmetadata", "onloadeddata", "onended", "onemptied", "ondurationchange", "oncuechange", "oncanplaythrough",
	"oncanplay", "onabort", "<source", "<event-source"))
GLOBAL_PROTECT(sanitize)

/proc/noscript(text)
	for(var/i in GLOB.sanitize)
		text = replacetext(text, i, "")
	return text


/proc/sanitize_filename(t)
	return sanitize_simple(t, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))


/proc/sanitizediscord(text)
	text = replacetext(text, "\improper", "")
	text = replacetext(text, "\proper", "")
	text = replacetext(text, "<@", "")
	text = replacetext(text, "@here", "")
	text = replacetext(text, "@everyone", "")
	return text


GLOBAL_LIST_INIT(zero_character_only, list("0"))
GLOBAL_LIST_INIT(hex_characters, list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"))
GLOBAL_LIST_INIT(alphabet, list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"))
GLOBAL_LIST_INIT(binary, list("0","1"))

//json decode that will return null on parse error instead of runtiming.
/proc/safe_json_decode(data)
	try
		return json_decode(data)
	catch
		return
