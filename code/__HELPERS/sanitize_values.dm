//general stuff
/proc/sanitize_integer(number, min = 0, max = 1, default = 0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default


/proc/sanitize_text(text, default = "")
	if(istext(text))
		return text
	return default


/proc/sanitize_islist(value, default)
	if(length(value))
		return value
	if(default)
		return default


/proc/sanitize_inlist(value, list/L, default)
	if(value in L)	
		return value
	if(default)			
		return default
	if(length(L))
		return L[1]


/proc/sanitize_inlist_assoc(value, list/L, default)
	for(var/i in L)
		if(L[i] == value)
			return value
	if(default)			
		return default


//more specialised stuff
/proc/sanitize_gender(gender, neuter = FALSE, plural = FALSE, default = MALE)
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)	
				return gender
			else		
				return default
		if(PLURAL)
			if(plural)	
				return gender
			else		
				return default
	return default


/proc/sanitize_ethnicity(ethnicity, default = "Western")
	if(ethnicity in GLOB.ethnicities_list)
		return ethnicity

	return default


/proc/sanitize_body_type(body_type, default = "Mesomorphic (Average)")
	if(body_type in GLOB.body_types_list)
		return body_type

	return default


/proc/sanitize_hexcolor(color, default = "#000000")
	if(!istext(color)) 
		return default

	var/len = length(color)

	if(len != 7 && len !=4) 
		return default

	if(text2ascii(color,1) != 35) 
		return default	//35 is the ascii code for "#"

	. = "#"

	for(var/i in 2 to len)
		var/ascii = text2ascii(color,i)
		switch(ascii)
			if(48 to 57)	
				. += ascii2text(ascii)		//numbers 0 to 9
			if(97 to 102)	
				. += ascii2text(ascii)		//letters a to f
			if(65 to 70)	
				. += ascii2text(ascii+32)	//letters A to F - translates to lowercase
			else			
				return default
	return .
