//Returns an integer given a hex input
/proc/hex2num(hex)
	if(!istext(hex))
		return

	var/num = 0
	var/power = 0
	var/i = length(hex)

	while(i > 0)
		var/char = copytext(hex, i, i + 1)
		switch(char)
			if("9", "8", "7", "6", "5", "4", "3", "2", "1")
				num += text2num(char) * 16 ** power
			if("a", "A")
				num += 16 ** power * 10
			if("b", "B")
				num += 16 ** power * 11
			if("c", "C")
				num += 16 ** power * 12
			if("d", "D")
				num += 16 ** power * 13
			if("e", "E")
				num += 16 ** power * 14
			if("f", "F")
				num += 16 ** power * 15
			else
				return
		power++
		i--
	return num


//Returns the hex value of a number given a value assumed to be a base-ten value
/proc/num2hex(num, placeholder)
	if(placeholder == null)
		placeholder = 2

	if(!isnum(num))
		return

	if(num == 0)
		var/final = ""
		for(var/i in 1 to placeholder) 
			final = "[final]0"
		return final

	var/hex = ""
	var/i = 0
	while(16 ** i < num)
		i++
	var/power = null
	power = i - 1
	while(power >= 0)
		var/val = round(num / 16 ** power)
		num -= val * 16 ** power
		switch(val)
			if(9, 8, 7, 6, 5, 4, 3, 2, 1, 0)
				hex += text("[]", val)
			if(10)
				hex += "A"
			if(11)
				hex += "B"
			if(12)
				hex += "C"
			if(13)
				hex += "D"
			if(14)
				hex += "E"
			if(15)
				hex += "F"
			else
		power--
	while(length(hex) < placeholder)
		hex = text("0[]", hex)
	return hex


// Concatenates a list of strings into a single string.  A seperator may optionally be provided.
/proc/list2text(list/ls, sep)
	if(ls.len <= 1) // Early-out code for empty or singleton lists.
		return ls.len ? ls[1] : ""

	var/l = ls.len // Made local for sanic speed.
	var/i = 0 // Incremented every time a list index is accessed.

	if(sep <> null)
		// Macros expand to long argument lists like so: sep, ls[++i], sep, ls[++i], sep, ls[++i], etc...
		#define S1    sep, ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		// Having the small concatenations come before the large ones boosted speed by an average of at least 5%.
		if(l-1 & 0x01) // 'i' will always be 1 here.
			. = text("[][][]", ., S1) // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][][][][][]", ., S4) // And so on....
		if(l-i & 0x08)
			. = text("[][][][][][][][][][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

	else
		// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
		#define S1    ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		if(l-1 & 0x01) // 'i' will always be 1 here.
			. += S1 // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][]", ., S4) // And so on...
		if(l-i & 0x08)
			. = text("[][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
				[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1


//Converts a string into a list by splitting the string at each delimiter found. (discarding the seperator)
/proc/text2list(text, delimiter = "\n")
	var/delim_len = length(delimiter)
	if(delim_len < 1) 
		return list(text)

	. = list()
	var/last_found = 1
	var/found
	do
		found = findtext(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)


//Splits the text of a file at seperator and returns them in a list.
/proc/file2list(filename, seperator = "\n")
	return text2list(return_file_text(filename),seperator)


//Turns a direction into text
/proc/num2dir(direction)
	switch(direction)
		if(1) 
			return NORTH
		if(2) 
			return SOUTH
		if(4) 
			return EAST
		if(8) 
			return WEST


//Turns a direction into text
/proc/dir2text(direction)
	switch(direction)
		if(NORTH)
			return "north"
		if(SOUTH)
			return "south"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
		if(NORTHEAST)
			return "northeast"
		if(SOUTHEAST)
			return "southeast"
		if(NORTHWEST)
			return "northwest"
		if(SOUTHWEST)
			return "southwest"


//Turns a direction into text
/proc/dir2text_short(direction)
	switch(direction)
		if(NORTH)
			return "N"
		if(SOUTH)
			return "S"
		if(EAST)
			return "E"
		if(WEST)
			return "W"
		if(NORTHEAST)
			return "NE"
		if(SOUTHEAST)
			return "SE"
		if(NORTHWEST)
			return "NW"
		if(SOUTHWEST)
			return "SW"


//Turns text into proper directions
/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return NORTH
		if("SOUTH")
			return SOUTH
		if("EAST")
			return EAST
		if("WEST")
			return WEST
		if("NORTHEAST")
			return NORTHEAST
		if("NORTHWEST")
			return NORTHWEST
		if("SOUTHEAST")
			return SOUTHEAST
		if("SOUTHWEST")
			return SOUTHWEST


//Converts an angle (degrees) into an ss13 direction
/proc/angle2dir(degree)
	degree = ((degree + 22.5) % 365)
	if(degree < 45)		
		return NORTH
	if(degree < 90)		
		return NORTHEAST
	if(degree < 135)	
		return EAST
	if(degree < 180)	
		return SOUTHEAST
	if(degree < 225)	
		return SOUTH
	if(degree < 270)	
		return SOUTHWEST
	if(degree < 315)	
		return WEST
	return NORTH|WEST


//returns the north-zero clockwise angle in degrees, given a direction
/proc/dir2angle(D)
	switch(D)
		if(NORTH)		
			return 0
		if(SOUTH)		
			return 180
		if(EAST)		
			return 90
		if(WEST)		
			return 270
		if(NORTHEAST)	
			return 45
		if(SOUTHEAST)	
			return 135
		if(NORTHWEST)	
			return 315
		if(SOUTHWEST)	
			return 225


//Returns the angle in english
/proc/angle2text(degree)
	return dir2text(angle2dir(degree))


//Converts a blend_mode constant to one acceptable to icon.Blend()
/proc/blendMode2iconMode(blend_mode)
	switch(blend_mode)
		if(BLEND_MULTIPLY) 
			return ICON_MULTIPLY
		if(BLEND_ADD)      
			return ICON_ADD
		if(BLEND_SUBTRACT) 
			return ICON_SUBTRACT
		else               
			return ICON_OVERLAY


//Converts a rights bitfield into a string
/proc/rights2text(rights, seperator = "")
	if(rights & R_ASAY)			
		. += "[seperator]+ASAY"
	if(rights & R_ADMINTICKET)	
		. += "[seperator]+ADMINTICKET"
	if(rights & R_ADMIN)		
		. += "[seperator]+ADMIN"
	if(rights & R_BAN)			
		. += "[seperator]+BAN"
	if(rights & R_FUN)			
		. += "[seperator]+FUN"
	if(rights & R_SERVER)		
		. += "[seperator]+SERVER"
	if(rights & R_DEBUG)		
		. += "[seperator]+DEBUG"
	if(rights & R_PERMISSIONS)	
		. += "[seperator]+PERMISSIONS"
	if(rights & R_COLOR)		
		. += "[seperator]+COLOR"
	if(rights & R_VAREDIT)		
		. += "[seperator]+VAREDIT"
	if(rights & R_SOUND)		
		. += "[seperator]+SOUND"
	if(rights & R_SPAWN)		
		. += "[seperator]+SPAWN"
	if(rights & R_MENTOR)		
		. += "[seperator]+MENTOR"
	if(rights & R_DBRANKS)		
		. += "[seperator]+DBRANKS"

	return .


/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if("Retro")
			return 'icons/mob/screen/retro.dmi'
		if("Plasmafire")
			return 'icons/mob/screen/plasmafire.dmi'
		if("Slimecore")
			return 'icons/mob/screen/slimecore.dmi'
		if("Operative")
			return 'icons/mob/screen/operative.dmi'
		if("Clockwork")
			return 'icons/mob/screen/clockwork.dmi'
		if("White")
			return 'icons/mob/screen/White.dmi'
	return 'icons/mob/screen/midnight.dmi'


//Splits the text of a file at seperator and returns them in a list.
//returns an empty list if the file doesn't exist
/world/proc/file2list(filename, seperator = "\n", trim = TRUE)
	if(trim)
		return splittext(trim(file2text(filename)),seperator)
	return splittext(file2text(filename),seperator)


//returns a string the last bit of a type, without the preceeding '/'
/proc/type2top(the_type)
	//handle the builtins manually
	if(!ispath(the_type))
		return
	switch(the_type)
		if(/datum)
			return "datum"
		if(/atom)
			return "atom"
		if(/obj)
			return "obj"
		if(/mob)
			return "mob"
		if(/area)
			return "area"
		if(/turf)
			return "turf"
		else //regex everything else (works for /proc too)
			return lowertext(replacetext("[the_type]", "[type2parent(the_type)]/", ""))


/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return
			if(/obj || /mob)
				return /atom/movable
			if(/area || /turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))


/proc/string2listofvars(t_string, datum/var_source)
	if(!t_string || !var_source)
		return list()

	. = list()

	var/var_found = findtext(t_string, "\[") //Not the actual variables, just a generic "should we even bother" check
	if(var_found)
		//Find var names

		// "A dog said hi [name]!"
		// splittext() --> list("A dog said hi ","name]!"
		// jointext() --> "A dog said hi name]!"
		// splittext() --> list("A","dog","said","hi","name]!")

		t_string = replacetext(t_string,"\[","\[ ")//Necessary to resolve "word[var_name]" scenarios
		var/list/list_value = splittext(t_string,"\[")
		var/intermediate_stage = jointext(list_value, null)

		list_value = splittext(intermediate_stage," ")
		for(var/value in list_value)
			if(!findtext(value, "]"))
				continue

			value = splittext(value, "]") //"name]!" --> list("name","!")
			for(var/A in value)
				if(!var_source.vars.Find(A))
					continue
				. += A

#define MAX_BITFIELD_BITS 24
//Converts a bitfield to a list of numbers
/proc/bitfield2list(bitfield = 0, list/L)
	var/list/r = list()
	if(islist(L))
		var/max = min(length(L), MAX_BITFIELD_BITS)
		for(var/i in 0 to max-1)
			if(bitfield & (1 << i))
				r += L[i+1]
	else
		for(var/i in 0 to MAX_BITFIELD_BITS-1)
			if(bitfield & (1 << i))
				r += (1 << i)

	return r
