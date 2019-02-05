//toggles
/client/verb/toggle_see_stats()
	set name = "Toggle End of Round Stats"
	set category = "Preferences"
	set desc = ".Toggle Between seeing the end of round stats or not seeing them."
	prefs.toggles_chat ^= CHAT_STATISTICS
	to_chat(src, "At the end of the round you will [(prefs.toggles_chat & CHAT_STATISTICS) ? "see all statistics" : "not see any statistics"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TERS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs"
	prefs.toggles_chat ^= CHAT_GHOSTEARS
	to_chat(src, "As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	prefs.toggles_chat ^= CHAT_GHOSTSIGHT
	to_chat(src, "As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_radio()
	set name = "Enable/Disable GhostRadio"
	set category = "Preferences"
	set desc = ".Toggle between hearing all radio chatter, or only from nearby speakers"
	prefs.toggles_chat ^= CHAT_GHOSTRADIO
	to_chat(src, "As a ghost, you will now [(prefs.toggles_chat & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGR")

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from radios and speakers"
	if(!holder) return
	prefs.toggles_chat ^= CHAT_RADIO
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles_chat & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers")
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_hivemind()
	set name = "Show/Hide GhostHivemind"
	set category = "Preferences"
	set desc = ".Toggle seeing all chatter from the Xenomorph Hivemind"
	prefs.toggles_chat ^= CHAT_GHOSTHIVEMIND
	to_chat(src, "As a ghost, you will [(prefs.toggles_chat & CHAT_GHOSTHIVEMIND) ? "now see chatter from the Xenomorph Hivemind" : "no longer see chatter from the Xenomorph Hivemind"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are recieved"
	if(!holder)	return
	prefs.toggles_sound ^= SOUND_ADMINHELP
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles_sound & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	feedback_add_details("admin_verb","AHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat"
	prefs.toggles_chat ^= CHAT_DEAD
	prefs.save_preferences()

	if(src.holder)
		to_chat(src, "You will [(prefs.toggles_chat & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	else
		to_chat(src, "As a ghost, you will [(prefs.toggles_chat & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")

	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers"
	prefs.toggles_chat ^= CHAT_PRAYER
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.toggles_chat & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music"
	prefs.toggles_sound ^= SOUND_LOBBY
	prefs.save_preferences()
	if(prefs.toggles_sound & SOUND_LOBBY)
		to_chat(src, "You will now hear music in the game lobby.")
		if(isnewplayer(mob))
			playtitlemusic()
	else
		to_chat(src, "You will no longer hear music in the game lobby.")
		if(isnewplayer(mob))
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz
	feedback_add_details("admin_verb","TLobby") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat"
	prefs.toggles_chat ^= CHAT_OOC
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.toggles_chat & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects"
	prefs.toggles_sound ^= SOUND_AMBIENCE
	prefs.save_preferences()
	if(prefs.toggles_sound & SOUND_AMBIENCE)
		to_chat(src, "You will now hear ambient sounds.")
	else
		to_chat(src, "You will no longer hear ambient sounds.")
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
	feedback_add_details("admin_verb","TAmbi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//be special
/client/verb/toggle_be_special(role in be_special_flags)
	set name = "Toggle SpecialRole Candidacy"
	set category = "Preferences"
	set desc = "Toggles which special roles you would like to be a candidate for, during events."
	var/role_flag = be_special_flags[role]
	if(!role_flag)	return
	prefs.be_special ^= role_flag
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.be_special & role_flag) ? "now" : "no longer"] be considered for [role] events (where possible).")
	feedback_add_details("admin_verb","TBeSpecial") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


// /client/verb/change_ui()
// 	set name = "Change UI"
// 	set category = "Preferences"
// 	set desc = "Configure your user interface"
//
// 	if(!ishuman(usr))
// 		to_chat(usr, "This only for human")
// 		return
//
// 	var/UI_style_new = input(usr, "Select a style, we recommend White for customization") in list("White", "Midnight", "Orange", "old", "Slimecore", "Operative", "Clockwork")
// 	if(!UI_style_new) return
//
// 	var/UI_style_alpha_new = input(usr, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
// 	if(!UI_style_alpha_new|!(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
//
// 	var/UI_style_color_new = input(usr, "Choose your UI color, dark colors are not recommended!") as color|null
// 	if(!UI_style_color_new) return
//
// 	//update UI
// 	var/list/icons = usr.hud_used.adding + usr.hud_used.other +usr.hud_used.hotkeybuttons
// 	icons.Add(usr.zone_sel)
//
// 	for(var/obj/screen/I in icons)
// 		if(I.name in list("help", "harm", "disarm", "grab")) continue
// 		I.icon = ui_style2icon(UI_style_new)
// 		I.color = UI_style_color_new
// 		I.alpha = UI_style_alpha_new
//
//
//
// 	if(alert("Like it? Save changes?",,"Yes", "No") == "Yes")
// 		prefs.UI_style = UI_style_new
// 		prefs.UI_style_alpha = UI_style_alpha_new
// 		prefs.UI_style_color = UI_style_color_new
// 		prefs.save_preferences()
// 		to_chat(usr, "UI was saved")
