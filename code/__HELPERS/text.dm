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
/proc/reject_bad_text(text, max_length = MAX_MESSAGE_LEN)
	if(length(text) > max_length)	
		return			//message too long

	var/non_whitespace = FALSE
	for(var/i in 1 to length(text))
		switch(text2ascii(text, i))
			if(62, 60, 92, 47)	
				return			//rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 255)	
				return			//rejects weird letters like �
			if(0 to 31)		
				return			//more weird stuff
			if(32)			
				continue		//whitespace
			else			
				non_whitespace = TRUE

	if(non_whitespace)		
		return text		//only accepts the text if it has some non-spaces


// Used to get a sanitized input.
/proc/stripped_input(mob/user, message = "", title = "", default = "", max_length = MAX_MESSAGE_LEN)
	var/name = input(user, message, title, default) as text|null
	return html_encode(trim(name, max_length))


// Used to get a properly sanitized multiline input, of max_length
/proc/stripped_multiline_input(mob/user, message = "", title = "", default = "", max_length = MAX_MESSAGE_LEN)
	var/name = input(user, message, title, default) as message|null
	return html_encode(trim(name, max_length))


//Filters out undesirable characters from names
/proc/reject_bad_name(t_in, allow_numbers = FALSE, max_length = MAX_NAME_LEN)
	if(!t_in || length(t_in) > max_length)
		return //Rejects the input if it is null or if it is longer then the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/t_out = ""

	for(var/i in 1 to length(t_in))
		var/ascii_char = text2ascii(t_in,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group<2)		
					t_out += ascii2text(ascii_char-32)	//Force uppercase first character
				else						
					t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(!last_char_group)		
					continue	//suppress at start of string
				if(!allow_numbers)			
					continue
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 3

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if(!last_char_group) 
					continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			// ~  |  @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(!last_char_group)		
					continue	//suppress at start of string
				if(!allow_numbers)			
					continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			//Space
			if(32)
				if(last_char_group <= 1)	
					continue	//suppress double-spaces and spaces at start of string
				t_out += ascii2text(ascii_char)
				last_char_group = 1
			else
				return

	if(number_of_alphanumeric < 2)	
		return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == 1)
		t_out = copytext(t_out, 1, length(t_out))	//removes the last character (in this case a space)

	return t_out


//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)


/proc/oldreplacetext(text, find, replacement)
	return list2text(text2list(text, find), replacement)


//Adds 'u' number of zeros ahead of the text 't'
/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t


//Adds 'u' number of spaces ahead of the text 't'
/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t


//Adds 'u' number of spaces behind the text 't'
/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t


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
/proc/trim(text)
	return trim_left(trim_right(text))


//Returns a string with the first element of the string capitalized.
/proc/capitalize(t)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)


//Centers text by adding spaces to either side of the string.
/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = add_lspace("", delta / 2 - 1)
	return spaces + new_message + spaces


//Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)


/proc/stringmerge(text, compare, replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	if(lentext(text) != lentext(compare))
		return FALSE
	for(var/i in 1 to lentext(text)-1)
		var/a = copytext(text, i, i + 1)
		var/b = copytext(compare, i, i + 1)
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext, 1, i) + b + copytext(newtext, i + 1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext, 1, i) + a + copytext(newtext, i + 1)
			else //The lists disagree, Uh-oh!
				return FALSE
	return newtext


/proc/stringpercent(text, character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i in 1 to lentext(text))
		var/a = copytext(text, i, i + 1)
		if(a == character)
			count++
	return count


//Used in preferences' SetFlavorText and human's set_flavor verb
//Previews a string of len or less length
/proc/TextPreview(string, length = 40)
	if(lentext(string) <= length)
		if(!lentext(string))
			return "\[...\]"
		else
			return string
	else
		return "[copytext(string, 1, 37)]..."


//Used for applying byonds text macros to strings that are loaded at runtime
/proc/apply_text_macros(string)
	var/next_backslash = findtext(string, "\\")
	if(!next_backslash)
		return string

	var/leng = length(string)

	var/next_space = findtext(string, " ", next_backslash + 1)
	if(!next_space)
		next_space = leng - next_backslash

	if(!next_space)	//trailing bs
		return string

	var/base = next_backslash == 1 ? "" : copytext(string, 1, next_backslash)
	var/macro = lowertext(copytext(string, next_backslash + 1, next_space))
	var/rest = next_backslash > leng ? "" : copytext(string, next_space + 1)

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


/proc/noscript(text)
	text = replacetext(text, "<script", "")
	text = replacetext(text, "/script>", "")
	text = replacetext(text, "<iframe", "")
	text = replacetext(text, "/iframe>", "")
	text = replacetext(text, "<input", "")
	text = replacetext(text, "<video", "")
	text = replacetext(text, "<body", "")
	text = replacetext(text, "<form", "")
	text = replacetext(text, "<link", "")
	text = replacetext(text, "<applet", "")
	text = replacetext(text, "<frameset", "")
	text = replacetext(text, "onerror", "")
	text = replacetext(text, "onpageshow", "")
	text = replacetext(text, "onscroll", "")
	text = replacetext(text, "onforminput", "")
	text = replacetext(text, "oninput", "")
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
