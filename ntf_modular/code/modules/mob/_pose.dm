/mob
	var/pose = ""

/mob/examine(mob/user)
	. = ..()
	if(pose)
		. += "\n[span_notice(span_collapsible("Temporary Flavor Text", "[pose]"))]"

/mob/verb/set_pose(msg as null)
	set category = "IC"
	set name = "Set Temporary Flavor Text"
	set desc = "Set a temporary additional flavor text.  Will be lost when you return to the lobby or the server restarts.  Set to !clear to clear."
	if(!msg)
		msg = tgui_input_text(usr, callee.desc, callee.name, "", MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)
	msg = copytext_char(trim(sanitize(msg)), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return
	if(msg == "!clear")
		pose = ""
		to_chat(usr, span_infoplain("Temporary Flavor Text cleared."))
	else
		pose = msg
		to_chat(usr, span_infoplain("Temporary Flavor Text set."))

/mob/new_player/set_pose()
	to_chat(usr, span_warning("Cannot set Temporary Flavor Text in lobby!"))
