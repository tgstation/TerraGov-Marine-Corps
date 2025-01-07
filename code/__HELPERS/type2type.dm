//Splits the text of a file at seperator and returns them in a list.
//returns an empty list if the file doesn't exist
/world/proc/file2list(filename, seperator="\n", trim = TRUE)
	if (trim)
		return splittext(trim(file2text(filename)),seperator)
	return splittext(file2text(filename),seperator)

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
	degree = SIMPLIFY_DEGREES(degree + 22.5)
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
	if(rights & R_RUNTIME)
		. += "[seperator]+RUNTIME"
	if(rights & R_LOG)
		. += "[seperator]+LOG"
	if(rights & R_POLLS)
		. += "[seperator]+POLLS"


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
		if("Glass")
			return 'icons/mob/screen/glass.dmi'
		if("Minimalist")
			return 'icons/mob/screen/minimalist.dmi'
		if("Holo")
			return 'icons/mob/screen/holo.dmi'
	return 'icons/mob/screen/midnight.dmi'


//Splits the text of a file at seperator and returns them in a list.
//returns an empty list if the file doesn't exist
/proc/file2list(filename, seperator = "\n", trim = TRUE)
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
				return null
			if(/obj, /mob)
				return /atom/movable
			if(/area, /turf)
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

/// Return html to load a url.
/// for use inside of browse() calls to html assets that might be loaded on a cdn.
/proc/url2htmlloader(url)
	return {"<html><head><meta http-equiv="refresh" content="0;URL='[url]'"/></head><body onLoad="parent.location='[url]'"></body></html>"}

//word of warning: using a matrix like this as a color value will simplify it back to a string after being set
///Takes a hex color provided as string and returns the proper color matrix using hex2num.
/proc/color_hex2color_matrix(string)
	var/length = length(string)
	if((length != 7 && length != 9) || length != length_char(string))
		return color_matrix_identity()
	var/r = hex2num(copytext(string, 2, 4))/255
	var/g = hex2num(copytext(string, 4, 6))/255
	var/b = hex2num(copytext(string, 6, 8))/255
	var/a = 1
	if(length == 9)
		a = hex2num(copytext(string, 8, 10))/255
	if(!isnum(r) || !isnum(g) || !isnum(b) || !isnum(a))
		return color_matrix_identity()
	return list(r,0,0,0, 0,g,0,0, 0,0,b,0, 0,0,0,a, 0,0,0,0)

///will drop all values not on the diagonal
///returns a hex color
/proc/color_matrix2color_hex(list/the_matrix)
	if(!istype(the_matrix) || the_matrix.len != 20)
		return "#ffffffff"
	return rgb(the_matrix[1]*255, the_matrix[6]*255, the_matrix[11]*255, the_matrix[16]*255)
