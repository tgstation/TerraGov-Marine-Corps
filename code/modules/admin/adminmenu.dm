
/datum/verbs/menu/Admin/Generate_list(client/C)
	if (C.holder)
		. = ..()

/datum/verbs/menu/Admin/verb/playerpanel()
	set name = "Player Panel New"
	set desc = ""
	set category = "GameMaster"
	if(usr.client.holder)
		usr.client.holder.player_panel_new()
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel New") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

