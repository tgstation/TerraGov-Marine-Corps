// Set a client's focus to an object and override these procs on that object to let it handle keypresses
/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return


/datum/proc/key_up(key, client/user) // Called when a key is released
	return


/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return

// removes all the existing macros
/client/proc/erase_all_macros()
	var/erase_output = ""
	var/list/macro_set = params2list(winget(src, "default.*", "command")) // The third arg doesnt matter here as we're just removing them all
	for(var/k in 1 to length(macro_set))
		var/list/split_name = splittext(macro_set[k], ".")
		var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
		erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)


/client/proc/set_macros()
	set waitfor = FALSE

	erase_all_macros()

	var/list/macro_set = SSinput.macro_set
	for(var/k in 1 to length(macro_set))
		var/key = macro_set[k]
		var/command = macro_set[key]
		winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[command]")

	if(prefs.focus_chat)
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")
	else
		winset(src, null, "input.focus=false input.background-color=[COLOR_INPUT_DISABLED]")
