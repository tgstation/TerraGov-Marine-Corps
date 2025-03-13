
/**
 * Generate a name devices
 *
 * Creates a randomly generated tag or name for devices or anything really
 * it keeps track of a special list that makes sure no name is used more than
 * once
 *
 * args:
 * * len (int)(Optional) Default=5 The length of the name
 * * prefix (string)(Optional) static text in front of the random name
 * * postfix (string)(Optional) static text in back of the random name
 * Returns (string) The generated name
 */
/proc/assign_random_name(len=5, prefix="", postfix="")
	//DO NOT REMOVE NAMES HERE UNLESS YOU KNOW WHAT YOU'RE DOING
	//All names already used
	var/static/list/used_names = list()

	var/static/valid_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var/list/new_name = list()
	var/text
	// machine id's should be fun random chars hinting at a larger world
	do
		new_name.Cut()
		new_name += prefix
		for(var/i = 1 to len)
			new_name += valid_chars[rand(1,length(valid_chars))]
		new_name += postfix
		text = new_name.Join()
	while(used_names[text])
	used_names[text] = TRUE
	return text
