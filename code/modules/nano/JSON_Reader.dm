#define JSON_GET_CHAR(json, i) ( copytext(json, i, i + 1) )
#define JSON_IS_WHITESPACE(char) ( char == " " || char == "\t" || char == "\n" || text2ascii(char) == 13 )
#define JSON_GET_TOKEN(i) ( tokens[i] )
#define JSON_NEXT_TOKEN(tokens, i) ( tokens[++i] )


/datum/json_token
	var/value

/datum/json_token/New(v)
	value = v

/datum/json_token/text

/datum/json_token/number

/datum/json_token/word

/datum/json_token/symbol

/datum/json_token/eof


/datum/json_reader
	var/list/string	= list("'", "\"")
	var/list/symbols = list("{", "}", "\[", "]", ":", "\"", "'", ",")
	var/list/sequences = list("b" = 8, "t" = 9, "n" = 10, "f" = 12, "r" = 13)
	var/list/tokens
	var/json
	var/i


/datum/json_reader/proc/ScanJson(json)
	src.json = json
	. = new/list()
	i = 1
	for(i, i <= lentext(json), i++)
		var/char = JSON_GET_CHAR(json, i)
		if(JSON_IS_WHITESPACE(char))
			continue
		if(string.Find(char))
			. += read_string(char)
		else if(symbols.Find(char))
			. += new/datum/json_token/symbol(char)
		else if(is_digit(char))
			. += read_number()
		else
			. += read_word()
	. += new/datum/json_token/eof()


/datum/json_reader/proc/read_word()
	var/val = ""
	for(i, i <= lentext(json), i++)
		var/char = JSON_GET_CHAR(json, i)
		if(JSON_IS_WHITESPACE(char) || symbols.Find(char))
			i-- // let scanner handle this character
			return new/datum/json_token/word(val)
		val += char


/datum/json_reader/proc/read_string(delim)
	var/escape 	= FALSE
	var/val		= ""
	while(++i <= lentext(json))
		var/char = JSON_GET_CHAR(json, i)
		if(escape)
			switch(char)
				if("\\", "'", "\"", "/", "u")
					val += char
				else
					// TODO: support octal, hex, unicode sequences
					ASSERT(sequences.Find(char))
					val += ascii2text(sequences[char])
		else
			if(char == delim)
				return new/datum/json_token/text(val)
			else if(char == "\\")
				escape = TRUE
			else
				val += char
	CRASH("Unterminated string.")

/datum/json_reader/proc/read_number()
	var/val = ""
	var/char = JSON_GET_CHAR(json, i)
	while(is_digit(char) || char == "." || lowertext(char) == "e")
		val += char
		i++
		char = JSON_GET_CHAR(json, i)
	i-- // allow scanner to read the first non-number character
	return new/datum/json_token/number(text2num(val))


/datum/json_reader/proc/is_digit(char)
	var/c = text2ascii(char)
	return ( 48 <= c && c <= 57 || char == "+" || char == "-" )


// parser
/datum/json_reader/proc/ReadObject(list/tokens)
	src.tokens = tokens
	. = new/list()
	i = 1
	read_token("{", /datum/json_token/symbol)
	while(i <= tokens.len)
		var/datum/json_token/K = JSON_GET_TOKEN(i)
		check_type(/datum/json_token/word, /datum/json_token/text)
		JSON_NEXT_TOKEN(tokens, i)
		read_token(":", /datum/json_token/symbol)

		.[K.value] = read_value()

		var/datum/json_token/S = JSON_GET_TOKEN(i)
		check_type(/datum/json_token/symbol)
		switch(S.value)
			if(",")
				JSON_NEXT_TOKEN(tokens, i)
				continue
			if("}")
				JSON_NEXT_TOKEN(tokens, i)
				return
			else
				die(S)


/datum/json_reader/proc/read_token(val, type)
	var/datum/json_token/T = JSON_GET_TOKEN(i)
	if(!(T.value == val && istype(T, type)))
		CRASH("Expected '[val]', found '[T.value]'.")
	JSON_NEXT_TOKEN(tokens, i)
	return T


/datum/json_reader/proc/check_type(...)
	var/datum/json_token/T = JSON_GET_TOKEN(i)
	for(var/type in args)
		if(istype(T, type))
			return
	CRASH("Bad token type: [T.type].")


/datum/json_reader/proc/check_value(...)
	var/datum/json_token/T = JSON_GET_TOKEN(i)
	ASSERT(args.Find(T.value))


/datum/json_reader/proc/read_key()
	var/char = JSON_GET_CHAR(json, i)
	if(char == "\"" || char == "'")
		return read_string(char)


/datum/json_reader/proc/read_value()
	var/datum/json_token/T = JSON_GET_TOKEN(i)
	switch(T.type)
		if(/datum/json_token/text, /datum/json_token/number)
			JSON_NEXT_TOKEN(tokens, i)
			return T.value
		if(/datum/json_token/word)
			JSON_NEXT_TOKEN(tokens, i)
			switch(T.value)
				if("true")
					return TRUE
				if("false")
					return FALSE
				if("null")
					return null
		if(/datum/json_token/symbol)
			switch(T.value)
				if("\[")
					return read_array()
				if("{")
					return ReadObject(tokens.Copy(i))
	die(T)


/datum/json_reader/proc/read_array()
	read_token("\[", /datum/json_token/symbol)
	. = new/list()
	var/list/L = .
	while(i <= tokens.len)
		// Avoid using Add() or += in case a list is returned.
		L.len++
		L[L.len] = read_value()
		var/datum/json_token/T = JSON_GET_TOKEN(i)
		check_type(/datum/json_token/symbol)
		switch(T.value)
			if(",")
				JSON_NEXT_TOKEN(tokens, i)
				continue
			if("]")
				JSON_NEXT_TOKEN(tokens, i)
				return
			else
				die(T)
				JSON_NEXT_TOKEN(tokens, i)
		CRASH("Unterminated array.")


/datum/json_reader/proc/die(datum/json_token/T)
	if(!T)
		T = JSON_GET_TOKEN(i)
	CRASH("Unexpected token: [T.value].")


#undef JSON_GET_CHAR
#undef JSON_IS_WHITESPACE
#undef JSON_GET_TOKEN
#undef JSON_NEXT_TOKEN