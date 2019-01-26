/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 *			SQL sanitization
 *			Text sanitization
 *			Text searches
 *			Text modification
 *			Misc
 */


/*
 * SQL sanitization
 */

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitizeSQL(var/t as text)
	var/sqltext = dbcon.Quote(t);
	return copytext(sqltext, 2, lentext(sqltext));//Quote() adds quotes around input, we already do that

/*
 * Text sanitization
 */

//Simply removes < and > and limits the length of the message
/proc/strip_html_simple(var/t,var/limit=MAX_MESSAGE_LEN)
	var/list/strip_chars = list("<",">")
	t = copytext(t,1,limit)
	for(var/char in strip_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + copytext(t, index+1)
			index = findtext(t, char)
	return t

//Removes a few problematic characters
/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"=" ","\t"=" ","ï¿½"="ï¿½"))
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char)
	return t

/proc/readd_quotes(var/t)
	var/list/repl_chars = list("&#34;" = "\"", "&#39;" = "\"")
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+5)
			index = findtext(t, char)
	return t

//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(var/input, var/max_length = MAX_MESSAGE_LEN, var/encode = 1, var/trim = 1, var/extra = 1, var/mode = SANITIZE_CHAT)
	if(!input)
		return

	if(max_length)
		input = copytext(input,1,max_length)

	//code in modules/l10n/localisation.dm
	input = sanitize_local(input, mode)

	if(extra)
		input = replace_characters(input, list("\n"=" ","\t"=" "))

	if(encode)
		// The below \ escapes have a space inserted to attempt to enable Travis auto-checking of span class usage. Please do not remove the space.
		//In addition to processing html, llhtml_encode removes byond formatting codes like "\ red", "\ i" and other.
		//It is important to avoid double-encode text, it can "break" quotes and some other characters.
		//Also, keep in mind that escaped characters don't work in the interface (window titles, lower left corner of the main window, etc.)
		input = lhtml_encode(input)
	else
		//If not need encode text, simply remove < and >
		//note: we can also remove here byond formatting codes: 0xFF + next byte
		input = replace_characters(input, list("<"=" ", ">"=" "))

	if(trim)
		//Maybe, we need trim text twice? Here and before copytext?
		input = trim(input)

	return input

/proc/fix_rus_nanoui(var/input)
	input = replacetext(input, "À", "&#1040;")
	input = replacetext(input, "Á", "&#1041;")
	input = replacetext(input, "Â", "&#1042;")
	input = replacetext(input, "Ã", "&#1043;")
	input = replacetext(input, "Ä", "&#1044;")
	input = replacetext(input, "Å", "&#1045;")
	input = replacetext(input, "Æ", "&#1046;")
	input = replacetext(input, "Ç", "&#1047;")
	input = replacetext(input, "È", "&#1048;")
	input = replacetext(input, "É", "&#1049;")
	input = replacetext(input, "Ê", "&#1050;")
	input = replacetext(input, "Ë", "&#1051;")
	input = replacetext(input, "Ì", "&#1052;")
	input = replacetext(input, "Í", "&#1053;")
	input = replacetext(input, "Î", "&#1054;")
	input = replacetext(input, "Ï", "&#1055;")
	input = replacetext(input, "Ð", "&#1056;")
	input = replacetext(input, "Ñ", "&#1057;")
	input = replacetext(input, "Ò", "&#1058;")
	input = replacetext(input, "Ó", "&#1059;")
	input = replacetext(input, "Ô", "&#1060;")
	input = replacetext(input, "Õ", "&#1061;")
	input = replacetext(input, "Ö", "&#1062;")
	input = replacetext(input, "×", "&#1063;")
	input = replacetext(input, "Ø", "&#1064;")
	input = replacetext(input, "Ù", "&#1065;")
	input = replacetext(input, "Ú", "&#1066;")
	input = replacetext(input, "Û", "&#1067;")
	input = replacetext(input, "Ü", "&#1068;")
	input = replacetext(input, "Ý", "&#1069;")
	input = replacetext(input, "Þ", "&#1070;")
	input = replacetext(input, "ß", "&#1071;")
	input = replacetext(input, "à", "&#1072;")
	input = replacetext(input, "á", "&#1073;")
	input = replacetext(input, "â", "&#1074;")
	input = replacetext(input, "ã", "&#1075;")
	input = replacetext(input, "ä", "&#1076;")
	input = replacetext(input, "å", "&#1077;")
	input = replacetext(input, "æ", "&#1078;")
	input = replacetext(input, "ç", "&#1079;")
	input = replacetext(input, "è", "&#1080;")
	input = replacetext(input, "é", "&#1081;")
	input = replacetext(input, "ê", "&#1082;")
	input = replacetext(input, "ë", "&#1083;")
	input = replacetext(input, "ì", "&#1084;")
	input = replacetext(input, "í", "&#1085;")
	input = replacetext(input, "î", "&#1086;")
	input = replacetext(input, "ï", "&#1087;")
	input = replacetext(input, "ð", "&#1088;")
	input = replacetext(input, "ñ", "&#1089;")
	input = replacetext(input, "ò", "&#1090;")
	input = replacetext(input, "ó", "&#1091;")
	input = replacetext(input, "ô", "&#1092;")
	input = replacetext(input, "õ", "&#1093;")
	input = replacetext(input, "ö", "&#1094;")
	input = replacetext(input, "÷", "&#1095;")
	input = replacetext(input, "ø", "&#1096;")
	input = replacetext(input, "ù", "&#1097;")
	input = replacetext(input, "ú", "&#1098;")
	input = replacetext(input, "û", "&#1099;")
	input = replacetext(input, "ü", "&#1100;")
	input = replacetext(input, "ý", "&#1101;")
	input = replacetext(input, "þ", "&#1102;")
	input = replacetext(input, "ÿ", "&#1103;")
	input = replacetext(input, "¸", "&#1105;")
	input = replacetext(input, "¨", "&#1025;")
	return input

/proc/fix_rus_stats(var/text)
	text = replacetext(text, "À", "&#192;") // Fuck BYOND
	text = replacetext(text, "Á", "&#193;")
	text = replacetext(text, "Â", "&#194;")
	text = replacetext(text, "Ã", "&#195;")
	text = replacetext(text, "Ä", "&#196;")
	text = replacetext(text, "Å", "&#197;")
	text = replacetext(text, "Æ", "&#198;")
	text = replacetext(text, "Ç", "&#199;")
	text = replacetext(text, "È", "&#200;")
	text = replacetext(text, "É", "&#201;")
	text = replacetext(text, "Ê", "&#202;")
	text = replacetext(text, "Ë", "&#203;")
	text = replacetext(text, "Ì", "&#204;")
	text = replacetext(text, "Í", "&#205;")
	text = replacetext(text, "Î", "&#206;")
	text = replacetext(text, "Ï", "&#207;")
	text = replacetext(text, "Ð", "&#208;")
	text = replacetext(text, "Ñ", "&#209;")
	text = replacetext(text, "Ò", "&#210;")
	text = replacetext(text, "Ó", "&#211;")
	text = replacetext(text, "Ô", "&#212;")
	text = replacetext(text, "Õ", "&#213;")
	text = replacetext(text, "Ö", "&#214;")
	text = replacetext(text, "×", "&#215;")
	text = replacetext(text, "Ø", "&#216;")
	text = replacetext(text, "Ù", "&#217;")
	text = replacetext(text, "Ú", "&#218;")
	text = replacetext(text, "Û", "&#219;")
	text = replacetext(text, "Ü", "&#220;")
	text = replacetext(text, "Ý", "&#221;")
	text = replacetext(text, "Þ", "&#222;")
	text = replacetext(text, "ß", "&#223;")
	text = replacetext(text, "à", "&#224;")
	text = replacetext(text, "á", "&#225;")
	text = replacetext(text, "â", "&#226;")
	text = replacetext(text, "ã", "&#227;")
	text = replacetext(text, "ä", "&#228;")
	text = replacetext(text, "å", "&#229;")
	text = replacetext(text, "æ", "&#230;")
	text = replacetext(text, "ç", "&#231;")
	text = replacetext(text, "è", "&#232;")
	text = replacetext(text, "é", "&#233;")
	text = replacetext(text, "ê", "&#234;")
	text = replacetext(text, "ë", "&#235;")
	text = replacetext(text, "ì", "&#236;")
	text = replacetext(text, "í", "&#237;")
	text = replacetext(text, "î", "&#238;")
	text = replacetext(text, "ï", "&#239;")
	text = replacetext(text, "ð", "&#240;")
	text = replacetext(text, "ñ", "&#241;")
	text = replacetext(text, "ò", "&#242;")
	text = replacetext(text, "ó", "&#243;")
	text = replacetext(text, "ô", "&#244;")
	text = replacetext(text, "õ", "&#245;")
	text = replacetext(text, "ö", "&#246;")
	text = replacetext(text, "÷", "&#247;")
	text = replacetext(text, "ø", "&#248;")
	text = replacetext(text, "ù", "&#249;")
	text = replacetext(text, "ú", "&#250;")
	text = replacetext(text, "û", "&#251;")
	text = replacetext(text, "ü", "&#251;")
	text = replacetext(text, "ý", "&#253;")
	text = replacetext(text, "þ", "&#254;")
	text = replacetext(text, "ÿ", "&#255;")
	text = replacetext(text, "¸", "&#184;")
	text = replacetext(text, "¨", "&#168;")
	return text

/proc/replace_characters(var/t,var/list/repl_chars)
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

//Runs sanitize and strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' after sanitize() calls byond's lhtml_encode()
/proc/strip_html(var/t,var/limit=MAX_MESSAGE_LEN)
	return copytext((sanitize(strip_html_simple(t))),1,limit)

//Runs byond's sanitization proc along-side strip_html_simple
//I believe strip_html_simple() is required to run first to prevent '<' from displaying as '&lt;' that lhtml_encode() would cause
/proc/adminscrub(var/t,var/limit=MAX_MESSAGE_LEN)
	return copytext((lhtml_encode(strip_html_simple(t))),1,limit)


//Returns null if there is any bad text in the string
/proc/reject_bad_text(var/text, var/max_length=512)
	if(length(text) > max_length)	return			//message too long
	var/non_whitespace = 0
	for(var/i=1, i<=length(text), i++)
		switch(text2ascii(text,i))
			if(62,60,92,47)	return			//rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 255)	return			//rejects weird letters like ï¿½
			if(0 to 31)		return			//more weird stuff
			if(32)			continue		//whitespace
			else			non_whitespace = 1
	if(non_whitespace)		return text		//only accepts the text if it has some non-spaces

// Used to get a sanitized input.
/proc/stripped_input(var/mob/user, var/message = "", var/title = "", var/default = "", var/max_length=MAX_MESSAGE_LEN)
	var/name = input(user, message, title, default) as text|null
	return lhtml_encode(trim(name, max_length))

// Used to get a properly sanitized multiline input, of max_length
/proc/stripped_multiline_input(var/mob/user, var/message = "", var/title = "", var/default = "", var/max_length=MAX_MESSAGE_LEN)
	var/name = input(user, message, title, default) as message|null
	return lhtml_encode(trim(name, max_length))

//Filters out undesirable characters from names
/proc/reject_bad_name(var/t_in, var/allow_numbers=0, var/max_length=MAX_NAME_LEN)
	if(!t_in || length(t_in) > max_length)
		return //Rejects the input if it is null or if it is longer then the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/t_out = ""

	for(var/i=1, i<=length(t_in), i++)
		var/ascii_char = text2ascii(t_in,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group<2)		t_out += ascii2text(ascii_char-32)	//Force uppercase first character
				else						t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				t_out += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 3

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if(!last_char_group) continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			// ~  |  @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				t_out += ascii2text(ascii_char)
				last_char_group = 2

			//Space
			if(32)
				if(last_char_group <= 1)	continue	//suppress double-spaces and spaces at start of string
				t_out += ascii2text(ascii_char)
				last_char_group = 1
			else
				return

	if(number_of_alphanumeric < 2)	return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == 1)
		t_out = copytext(t_out,1,length(t_out))	//removes the last character (in this case a space)

	for(var/bad_name in list("space","floor","wall","r-wall","monkey","unknown","inactive ai"))	//prevents these common metagamey names
		if(cmptext(t_out,bad_name))	return	//(not case sensitive)

	return t_out

//checks text for html tags
//if tag is not in whitelist (var/list/paper_tag_whitelist in global.dm)
//relpaces < with &lt;
proc/checkhtml(var/t)
	t = sanitize_simple(t, list("&#"="."))
	var/p = findtext(t,"<",1)
	while (p)	//going through all the tags
		var/start = p++
		var/tag = copytext(t,p, p+1)
		if (tag != "/")
			while (reject_bad_text(copytext(t, p, p+1), 1))
				tag = copytext(t,start, p)
				p++
			tag = copytext(t,start+1, p)
			if (!(tag in paper_tag_whitelist))	//if it's unkown tag, disarming it
				t = copytext(t,1,start-1) + "&lt;" + copytext(t,start+1)
		p = findtext(t,"<",p)
	return t
/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

//Checks the beginning of a string for a specified sub-string. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix_case(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

//Checks the end of a string for a specified substring. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix_case(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx(text, suffix, start, null)

/*
 * Text modification
 */
/proc/oldreplacetext(text, find, replacement)
	return list2text(text2list(text, find), replacement)

/proc/oldreplacetextEx(text, find, replacement)
	return list2text(text2listEx(text, find), replacement)

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
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns a string with the first element of the string capitalized.
/proc/capitalize(var/t as text)
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
	var/spaces = add_lspace("",delta/2-1)
	return spaces + new_message + spaces

//Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)


/proc/stringmerge(var/text,var/compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	if(lentext(text) != lentext(compare))
		return 0
	for(var/i = 1, i < lentext(text), i++)
		var/a = copytext(text,i,i+1)
		var/b = copytext(compare,i,i+1)
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext,1,i) + b + copytext(newtext, i+1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext,1,i) + a + copytext(newtext, i+1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

/proc/stringpercent(var/text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= lentext(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/proc/reverse_text(var/text = "")
	var/new_text = ""
	for(var/i = length(text); i > 0; i--)
		new_text += copytext(text, i, i+1)
	return new_text

//Used in preferences' SetFlavorText and human's set_flavor verb
//Previews a string of len or less length
proc/TextPreview(var/string,var/len=40)
	if(lentext(string) <= len)
		if(!lentext(string))
			return "\[...\]"
		else
			return string
	else
		return "[copytext(string, 1, 37)]..."
