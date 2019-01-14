/client/proc/cmd_admin_drop_everything(mob/M as mob in mob_list)
	set category = null
	set name = "Drop Everything"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		if(istype(W,/obj/item/alien_embryo)) continue
		M.drop_inv_item_on_ground(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_prison(mob/M as mob in mob_list)
	set category = "Admin"
	set name = "Prison"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if (ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.drop_inv_item_on_ground(W)
		//teleport person to cell
		M.KnockOut(5)
		sleep(5)	//so they black out before warping
		M.loc = pick(prisonwarp)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), WEAR_BODY)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), WEAR_FEET)
		spawn(50)
			to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'> [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>", 1)
		feedback_add_details("admin_verb","PRISON") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in mob_list)
	set category = null
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		to_chat(src, "Only staff members may use this command.")
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text

	if(!msg)
		return

	if(usr?.client?.holder)
		to_chat(M, "\bold You hear a voice in your head... \italic [msg]")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("<span class='boldnotice'> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]</span>", 1)
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_check_new_players()	//Allows mentors / admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check new Players"
	if(!holder)
		to_chat(src, "Only staff members may use this command.")

	var/age = alert(src, "Age check", "Show accounts yonger then _____ days","7", "30" , "All")

	if(age == "All")
		age = 9999999
	else
		age = text2num(age)

	var/missing_ages = 0
	var/msg = ""

	var/highlight_special_characters = 1
	if(is_mentor(usr.client))
		highlight_special_characters = 0

	for(var/client/C in clients)
		if(C.player_age == "Requires database")
			missing_ages = 1
			continue
		if(C.player_age < age)
			msg += "[key_name(C, 1, 1, highlight_special_characters)]: account is [C.player_age] days old<br>"

	if(missing_ages)
		to_chat(src, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		src << browse(msg, "window=Player_age_check")
	else
		to_chat(src, "No matches for that age range found.")


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Special Verbs"
	set name = "Narrate - Global"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if(!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='boldnotice'> GlobalNarrate: [key_name_admin(usr)] : [msg]<BR></span>", 1)
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = null
	set name = "Narrate - Direct"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins("<span class='boldnotice'> DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]<BR></span>", 1)
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Godmode"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	M.status_flags ^= GODMODE
	to_chat(usr, "<span class='notice'> Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]</span>")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!config.automute_on)	return
	else
		if(!usr || !usr.client)
			return
		if(!usr.client.holder)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: You don't have permission to do this.</font>")
			return
		if(!M.client)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: This mob doesn't have a client tied to it.</font>")
		if(M.client.holder)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: You cannot mute an admin/mod.</font>")
	if(!M.client)		return
	if(M.client.holder)	return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)			mute_string = "IC (say and emote)"
		if(MUTE_OOC)		mute_string = "OOC"
		if(MUTE_PRAY)		mute_string = "pray"
		if(MUTE_ADMINHELP)	mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)	mute_string = "deadchat and DSAY"
		if(MUTE_ALL)		mute_string = "everything"
		else				return

	if(automute)
		muteunmute = "auto-muted"
		M.client.prefs.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(M.client.prefs.muted & mute_type)
		muteunmute = "unmuted"
		M.client.prefs.muted &= ~mute_type
	else
		muteunmute = "muted"
		M.client.prefs.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
	to_chat(M, "You have been [muteunmute] from [mute_string].")
	feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_add_random_ai_law()
	set category = "Fun"
	set name = "Add Random AI Law"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_announcement.Announce("Ion storm detected in proximity. Recommendation: Check all AI-controlled equipment for data corruption.", "Anomaly Alert", new_sound = 'sound/AI/ionstorm.ogg')

	IonStorm(0)
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/*
Allow admins to set players to be able to respawn/bypass 30 min wait, without the admin having to edit variables directly
Ccomp's first proc.
*/

/client/proc/get_ghosts(var/notify = 0,var/what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortNames(mob_list)                           // get the mob list.
	/var/any=0
	for(var/mob/dead/observer/M in sortmob)
		mobs.Add(M)                                             //filter it where it's only ghosts
		any = 1                                                 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify)
			to_chat(src, "There doesn't appear to be any ghosts for you to select.")
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M                                        //get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs


/client/proc/allow_character_respawn()
	set category = "Special Verbs"
	set name = "Allow Player Corpse Re-Enter"
	set desc = "Let's the player bypass the 30 minute wait to respawn or allow them to re-enter their corpse."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/list/ghosts= get_ghosts(1,1)

	var/target = input("Please, select a ghost!", "COME BACK TO LIFE!", null, null) as null|anything in ghosts
	if(!target)
		to_chat(src, "Hrm, appears you didn't select a ghost"		)
		return

	var/mob/dead/observer/G = ghosts[target]
//	if(G.has_enabled_antagHUD && config.antag_hud_restricted)
//		var/response = alert(src, "Are you sure you wish to allow this individual to play?","Ghost has used AntagHUD","Yes","No")
//		if(response == "No") return
	G.timeofdeath=-19999						/* time of death is checked in /mob/verb/abandon_mob() which is the Respawn verb.
									   timeofdeath is used for bodies on autopsy but since we're messing with a ghost I'm pretty sure
									   there won't be an autopsy.
									*/
//	G.has_enabled_antagHUD = 2
	G.can_reenter_corpse = 1

	G:show_message(text("<span class='boldnotice'>You may now respawn.  You should roleplay as if you learned nothing about the round during your time with the dead.</span>"), 1)
	log_admin("[key_name(usr)] allowed [key_name(G)] to bypass the 30 minute respawn limit")
	message_admins("Admin [key_name_admin(usr)] allowed [key_name_admin(G)] to bypass the 30 minute respawn limit", 1)

/*
/client/proc/toggle_antagHUD_use()
	set category = "Server"
	set name = "Toggle antagHUD usage"
	set desc = "Toggles antagHUD usage for observers"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(config.antag_hud_allowed)
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						//Remove the verb from non-admin ghosts
				g.verbs -= /mob/dead/observer/verb/toggle_antagHUD
			if(g.antagHUD)
				g.antagHUD = 0						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = 2				// We'll allow them to respawn
				to_chat(g, "<span class='danger'>The Administrator has disabled AntagHUD </span>")
		config.antag_hud_allowed = 0
		to_chat(src, "<span class='danger'>AntagHUD usage has been disabled</span>")
		action = "disabled"
	else
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				g.verbs += /mob/dead/observer/verb/toggle_antagHUD
			to_chat(g, "<span class='boldnotice'>The Administrator has enabled AntagHUD </span>"	)
		config.antag_hud_allowed = 1
		action = "enabled"
		to_chat(src, "<span class='boldnotice'>AntagHUD usage has been enabled</span>")


	log_admin("[key_name(usr)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(usr)] has [action] antagHUD usage for observers", 1)



/client/proc/toggle_antagHUD_restrictions()
	set category = "Server"
	set name = "Toggle antagHUD Restrictions"
	set desc = "Restricts players that have used antagHUD from being able to join this round."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(config.antag_hud_restricted)
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='boldnotice'>The administrator has lifted restrictions on joining the round if you use AntagHUD</span>")
		action = "lifted restrictions"
		config.antag_hud_restricted = 0
		to_chat(src, "<span class='boldnotice'>AntagHUD restrictions have been lifted</span>")
	else
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='danger'>The administrator has placed restrictions on joining the round if you use AntagHUD</span>")
			to_chat(g, "<span class='danger'>Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions </span>")
			g.antagHUD = 0
			g.has_enabled_antagHUD = 0
		action = "placed restrictions"
		config.antag_hud_restricted = 1
		to_chat(src, "<span class='danger'>AntagHUD restrictions have been enabled</span>")

	log_admin("[key_name(usr)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(usr)] has [action] on joining the round if they use AntagHUD", 1)
*/
/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something

		//check if they were a monkey
		if(findtext(G_found.real_name,"monkey"))
			if(alert("This character appears to have been a monkey. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/mob/living/carbon/monkey/new_monkey = new(pick(latejoin))
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				if(new_monkey.client) new_monkey.client.change_view(world.view)
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.")
				message_admins("<span class='notice'> [key_name_admin(usr)] has respawned [new_monkey.key] as a filthy xeno.</span>", 1)
				return	//all done. The ghost is auto-deleted

	//Ok, it's not a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.gender = record_found.fields["sex"]
		new_character.age = record_found.fields["age"]
		new_character.b_type = record_found.fields["b_type"]
	else
		new_character.gender = pick(MALE,FEMALE)
		var/datum/preferences/A = new()
		A.randomize_appearance_for(new_character)
		new_character.real_name = G_found.real_name

	if(!new_character.real_name)
		if(new_character.gender == MALE)
			new_character.real_name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
		else
			new_character.real_name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)	new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.


	//DNA
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.fields["enzymes"]
		var/list/newUI = record_found.fields["identity"]
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.key = G_found.key
	if(new_character.client) new_character.client.change_view(world.view)

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("traitor")
			ticker.mode.equip_traitor(new_character)

	RoleAuthority.equip_role(new_character, RoleAuthority.roles_for_mode[new_character.mind.assigned_role], pick(latejoin))//Or we simply equip them.
	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins("<span class='notice'> [admin] has respawned [player_key] as [new_character.real_name].</span>", 1)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character


//Added for testing purposes. Blast from the past seeing Respawn Character. ~N
/datum/admins/proc/force_predator_round()
	set category = "Server"
	set name = "Force Predator Round"
	set desc = "Force a predator round for the round type. Only works on maps that support Predator spawns."

	if(!ticker || ticker.current_state < GAME_STATE_PLAYING || !ticker.mode)
		to_chat(usr, "<span class='warning'>The game hasn't started yet!</span>")
		return

	var/datum/game_mode/predator_round = ticker.mode

	if(!(predator_round.flags_round_type & MODE_PREDATOR))
		predator_round.flags_round_type |= MODE_PREDATOR
		to_chat(usr, "The Hunt is now enabled.")
	else
		to_chat(usr, "The Hunt is already in progress.")
		return

	feedback_add_details("admin_verb","FPRED")
	log_admin("[key_name(usr)] admin-forced a predator round.")
	message_admins("<span class='notice'> [key_name_admin(usr)] admin-forced a predator round.</span>", 1)
	return

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return
	for(var/mob/living/silicon/ai/M in mob_list)
		if (M.stat == 2)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else if (M.see_in_dark == 0)
			to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
		else
			M.add_ion_law(input)
			for(var/mob/living/silicon/ai/O in mob_list)
				to_chat(O, "<span class='warning'>" + input + "<span class='warning'>...LAWS UPDATED</span>")
				O.show_laws()

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_announcement.Announce("Ion storm detected in proximity. Recommendation: Check all AI-controlled equipment for data corruption.", "Anomaly Alert", new_sound = 'sound/AI/ionstorm.ogg')
	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in mob_list)
	set category = null
	set name = "Rejuvenate"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	if(config.allow_admin_rev)
		M.revive()

		log_admin("[key_name(usr)] healed / revived [key_name(M)]")
		message_admins("<span class='warning'> Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!</span>", 1)
	else
		alert("Admin revive disabled")
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	var/customname = input(usr, "Pick a title for the report.", "Title") as text|null
	if(!input)
		return
	if(!customname)
		customname = "TGMC Update"
	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/paper/P = new /obj/item/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	switch(alert("Should this be announced to the general population?",,"Yes","No"))
		if("Yes")
			command_announcement.Announce(input, customname, new_sound = 'sound/AI/commandreport.ogg');
		if("No")
			command_announcement.Announce("<span class='warning'> New update available at all communication consoles.</span>", customname, new_sound = 'sound/AI/commandreport.ogg')

	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report", 1)
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_AI_report()
	set category = "Special Verbs"
	set name = "Create AI Report"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This should be a message from the ship's AI.  Check with online staff before you send this. Do not use html.", "What?", "") as message|null
	if(!input) return FALSE
	if(ai_system.Announce(input))

		for (var/obj/machinery/computer/communications/C in machines)
			if(! (C.stat & (BROKEN|NOPOWER) ) )
				var/obj/item/paper/P = new /obj/item/paper( C.loc )
				P.name = "'[MAIN_AI_SYSTEM] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[MAIN_AI_SYSTEM] Update")
				C.messagetext.Add(P.info)

		log_admin("[key_name(src)] has created an AI report: [input]")
		message_admins("[key_name_admin(src)] has created an AI report: [input]", 1)
		feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		to_chat(usr, "<span class='warning'>[MAIN_AI_SYSTEM] is not responding. It may be offline or destroyed.</span>")


/client/proc/show_hive_status()
	set name = "Show Hive Status"
	set desc = "Check the status of the hive."
	set category = "Special Verbs"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	check_hive_status()


/client/proc/cmd_admin_xeno_report()
	set category = "Special Verbs"
	set name = "Create Queen Mother Report"
	set desc = "Basically a MOTHER report, but only for Xenos"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This should be a message from the ruler of the Xenomorph race.", "What?", "") as message|null
	var/customname = "Queen Mother Psychic Directive"
	if(!input) return FALSE

	var/data = "<h1>[customname]</h1><br><br><br><span class='warning'>[input]<br><br></span>"

	for(var/mob/M in player_list)
		if(isXeno(M) || isobserver(M))
			to_chat(M, data)

	log_admin("[key_name(src)] has created a Queen Mother report: [input]")
	message_admins("[key_name_admin(src)] has created a Queen Mother report", 1)
	feedback_add_details("admin_verb","QMR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in world)
	set category = "Debug"
	set name = "Delete"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[usr]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) deleted [O] at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		qdel(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "Job Slots - List"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(RoleAuthority)
		var/datum/job/J
		var/i
		for(i in RoleAuthority.roles_by_name)
			J = RoleAuthority.roles_by_name[i]
			if(J.flags_startup_parameters & ROLE_ADD_TO_MODE) to_chat(src, "[J.title]: [J.get_total_positions(1)] / [J.current_positions]")
	feedback_add_details("admin_verb","LFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_changekey(mob/O in living_mob_list)
	set category = "Admin"
	set name = "Change CKey"
	var/new_ckey = null

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(O.gc_destroyed) return //mob was garbage collected

	new_ckey = input("Enter new ckey:","CKey") as null|text

	if(!new_ckey || new_ckey == null)
		return

	O.ghostize(0)
	log_admin("[key_name(usr)] modified [O.name]'s ckey to [new_ckey]")
	message_admins("[key_name_admin(usr)] modified [O.name]'s ckey to [new_ckey]", 1)
	feedback_add_details("admin_verb","KEY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	O.ckey = new_ckey
	if(O.client) O.client.change_view(world.view)

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null) return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_FUN))	return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if(istype(M, /mob/dead/observer))
		gibs(M.loc, M.viruses)
		return

	M.gib()
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gib Self"
	set category = "Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if (istype(mob, /mob/dead/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(usr)] used gibself.")
		message_admins("<span class='notice'> [key_name_admin(usr)] used gibself.</span>", 1)
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/*
/client/proc/cmd_manual_ban()
	set name = "Manual Ban"
	set category = "Special Verbs"
	if(!authenticated || !holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/mob/M = null
	switch(alert("How would you like to ban someone today?", "Manual Ban", "Key List", "Enter Manually", "Cancel"))
		if("Key List")
			var/list/keys = list()
			for(var/mob/M in player_list)
				keys += M.client
			var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
			if(!selection)
				return
			M = selection:mob
			if ((M.client && M.client.holder && (M.client.holder.level >= holder.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

	switch(alert("Temporary Ban?",,"Yes","No"))
	if("Yes")
		var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		if(M)
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
			to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
			to_chat(M, "<span class='warning'> To try to resolve this matter head to http:)
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")
			world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=[mins]&server=[oldreplacetext(config.server_name, "#", "")]")
			qdel(M.client)
			qdel(M)
		else

	if("No")
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
		to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
		to_chat(M, "<span class='warning'>This is a permanent ban.</span>")
		to_chat(M, "<span class='warning'> To try to resolve this matter head to http:)
		log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.</span>")
		world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=perma&server=[oldreplacetext(config.server_name, "#", "")]")
		qdel(M.client)
		qdel(M)
*/

/client/proc/update_world()
	// If I see anyone granting powers to specific keys like the code that was here,
	// I will both remove their SVN access and permanently ban them from my servers.
	return

/client/proc/cmd_admin_check_contents(mob/living/M as mob in mob_list)
	set category = null
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/* This proc is DEFERRED. Does not do anything.
/client/proc/cmd_admin_remove_phoron()
	set category = "Debug"
	set name = "Stabilize Atmos."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","STATM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
// DEFERRED
	spawn(0)
		for(var/turf/T in view())
			T.poison = 0
			T.oldpoison = 0
			T.tmppoison = 0
			T.oxygen = 755985
			T.oldoxy = 755985
			T.tmpoxy = 755985
			T.co2 = 14.8176
			T.oldco2 = 14.8176
			T.tmpco2 = 14.8176
			T.n2 = 2.844e+006
			T.on2 = 2.844e+006
			T.tn2 = 2.844e+006
			T.tsl_gas = 0
			T.osl_gas = 0
			T.sl_gas = 0
			T.temp = 293.15
			T.otemp = 293.15
			T.ttemp = 293.15
*/

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == world.view)
		var/newview = input("Select view range:", "Change View Range", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,21,28,35,50,128)
		if(newview && newview != view)
			change_view(newview)
	else
		change_view(world.view)

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("<span class='notice'> [key_name_admin(usr)] changed their view range to [view].</span>", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_attack_log(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	to_chat(usr, text("<span class='danger'>Attack Log for []</span>", mob))
	show_individual_logging_panel(M)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_FUN))	return

	if (ticker && ticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(ticker.random_players)
		ticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_chat(world, "<span class='boldnotice'>Admin [usr.key] has forced the players to have completely random identities!</span>")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	ticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"

	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	if(!check_rights(R_SERVER))	return

	if(!config.allow_random_events)
		config.allow_random_events = 1
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.", 1)
	else
		config.allow_random_events = 0
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.", 1)
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/*
/client/proc/editzoneair(var/turf/T in turfs)
	set name = "Edit Zone Air"
	set category = "Debug"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(T)
		if(T.zone && T.zone.air)
			debug_variables(T.zone.air)
*/
/client/proc/toggle_own_ghost_vis()
	set name = "Show/Hide Own Ghost"
	set desc = "Toggle your visibility as a ghost to other ghosts."
	set category = "Preferences"

	if(!holder) return

	if(isobserver(usr))
		if(usr.invisibility <> 60 && usr.layer <> 4.0)
			usr.invisibility = 60
			usr.layer = MOB_LAYER
			to_chat(usr, "<span class='warning'>Ghost visibility returned to normal.</span>")
		else
			usr.invisibility = 70
			usr.layer = BELOW_MOB_LAYER
			to_chat(usr, "<span class='warning'>Your ghost is now invisibile to other ghosts.</span>")
		log_admin("Admin [key_name(src)] has toggled Ordukai Mode.")
	else
		to_chat(usr, "<span class='warning'>You need to be a ghost in order to use this.</span>")



/client/proc/check_round_statistics()
	set category = "Special Verbs"
	set name = "Round Statistics"
	if(!check_rights(R_ADMIN))	return

	debug_variables(round_statistics)


/client/proc/award_medal()
	set category = "Fun"
	set name = "Award a Medal"
	if(!check_rights(R_ADMIN))	return

	give_medal_award()

/proc/get_all_humans()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		if(ishuman(C.mob))
			C.mob.loc = get_turf(usr)

/proc/get_all_xenos()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		if(isXeno(C.mob))
			C.mob.loc = get_turf(usr)

/proc/get_all()
	if(!check_rights(R_ADMIN))	return

	for(var/client/C in clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		C.mob.loc = get_turf(usr)

/proc/rejuv_all()
	if(!check_rights(R_ADMIN))	return

	for(var/mob/living/M in living_mob_list)
		if(isobserver(M) || M.stat == DEAD || !M.client)
			continue
		M.rejuvenate()
