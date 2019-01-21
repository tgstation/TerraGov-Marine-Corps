/datum/admins/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	set desc = "Allows you to ghost and re-enter body at will."

	if(!check_rights(R_ADMIN) || !is_mentor())
		return

	if(!owner?.mob)
		return

	var/mob/M = owner.mob

	if(istype(M, /mob/new_player))
		return

	if(istype(M, /mob/dead/observer))
		var/mob/dead/observer/ghost = M
		ghost.can_reenter_corpse = TRUE
		ghost.reenter_corpse()
	else
		M.ghostize(TRUE)
		if(M && !M.key)
			M.key = "@[usr.key]"
			if(M.client)
				M.client.change_view(world.view)

		message_admins("[key_name(usr)] admin ghosted.")
		log_admin("[key_name(usr)] admin ghosted.")


/datum/admins/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility."

	if(!check_rights(R_ADMIN))
		return

	if(!owner?.mob)
		return

	var/mob/M = owner.mob

	if(M.invisibility == INVISIBILITY_OBSERVER)
		M.invisibility = initial(M.invisibility)
		M.alpha = max(M.alpha + 100, 255)
		M.add_to_all_mob_huds()
	else
		M.invisibility = INVISIBILITY_OBSERVER
		M.alpha = max(M.alpha - 100, 0)
		M.remove_from_all_mob_huds()

	log_admin("[key_name(usr)] has [(M.invisibility == INVISIBILITY_OBSERVER) ? "enabled" : "disabled"] invisimin.")
	message_admins("[key_name_admin(usr)] has [(M.invisibility == INVISIBILITY_OBSERVER) ? "enabled" : "disabled"] invisimin.")


/datum/admins/proc/stealth_mode()
	set category = "Admin"
	set name = "Stealth Mode"
	set desc = "Allows you to change your ckey for non-admins to see."

	if(!check_rights(R_ADMIN))
		return

	if(fakekey)
		fakekey = null
	else
		var/new_key = ckeyEx(input("Enter your desired display name.",, owner.key) as text|null)
		if(!new_key)
			return
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		fakekey = new_key

	log_admin("[key_name(usr)] has turned stealth mode [fakekey ? "on" : "off"].")
	message_admins("[key_name_admin(usr)] has turned stealth mode [fakekey ? "on" : "off"]")


/datum/admins/proc/deadmin_self()
	set name = "De-Admin Self"
	set category = "Admin"
	set desc = "Temporarily removes your admin powers."

	if(alert("Do you really want to de-admin temporarily?", , "Yes", "No") == "No")
		return

	verbs += /datum/admins/proc/readmin_self
	deadmin_self()

	log_admin("[key_name(usr)] deadmined themselves.")
	message_admins("[key_name_admin(usr)] deadmined themselves.")


/datum/admins/proc/readmin_self()
	set name = "Re-admin Self"
	set category = "Admin"
	set desc = "Gives you your powers back."

	verbs -= /datum/admins/proc/readmin_self
	readmin_self()

	log_admin("[key_name(usr)] readmined themselves.")
	message_admins("[key_name_admin(usr)] readmined themselves.")


/datum/admins/proc/jobs_free()
	set name = "Job Slots - Free"
	set category = "Admin"
	set desc = "Allows you to free a job slot."

	if(!check_rights(R_ADMIN))
		return

	var/list/roles = list()
	var/datum/job/J
	for(var/r in RoleAuthority.roles_for_mode) //All the roles in the game.
		J = RoleAuthority.roles_for_mode[r]
		if(J.total_positions != -1 && J.get_total_positions(1) <= J.current_positions)
			roles += r

	if(!roles.len)
		to_chat(usr, "<span class='warning'>There are no fully staffed roles.</span>")
		return

	var/role = input("Please select role slot to free", "Free role slot") as null|anything in roles
	RoleAuthority.free_role(RoleAuthority.roles_for_mode[role])

	log_admin("[key_name(usr)] has made a [role] slot free.")
	message_admins("[key_name_admin(usr)] has made a [role] slot free.")


/datum/admins/proc/jobs_list()
	set category = "Admin"
	set name = "Job Slots - List"
	set desc = "Lists all roles and their current status."

	if(!check_rights(R_ADMIN))
		return

	if(!RoleAuthority)
		return

	var/datum/job/J
	var/i
	for(i in RoleAuthority.roles_by_name)
		J = RoleAuthority.roles_by_name[i]
		if(J.flags_startup_parameters & ROLE_ADD_TO_MODE)
			to_chat(src, "[J.title]: [J.get_total_positions(1)] / [J.current_positions]")

	log_admin("[key_name(usr)] checked job slots.")
	message_admins("[key_name_admin(usr)] checked job slots.")


/datum/admins/proc/change_key(mob/M in living_mob_list)
	set category = "Admin"
	set name = "Change CKey"
	set desc = "Allows you to properly change the ckey of a mob."

	if(!check_rights(R_ADMIN))
		return

	if(M.gc_destroyed)
		return

	var/new_ckey = input("Enter new ckey:","CKey") as null|text

	if(!new_ckey)
		return

	M.ghostize(FALSE)
	M.ckey = new_ckey
	if(M.client)
		M.client.change_view(world.view)

	log_admin("[key_name(usr)] changed [M.name] ckey to [new_ckey].")
	message_admins("[key_name_admin(usr)] changed [M.name] ckey to [new_ckey].")


/datum/admins/proc/rejuvenate(mob/living/M as mob in mob_list)
	set category = "Admin"
	set name = "Rejuvenate"
	set desc = "Revives a mob."

	if(!check_rights(R_ADMIN))
		return

	if(!M || !istype(M))
		return

	M.revive()

	log_admin("[key_name(usr)] revived [key_name(M)].")
	message_admins("[key_name_admin(usr)] revived [key_name_admin(M)].")


/datum/admins/proc/toggle_sleep(var/mob/living/M as mob in mob_list)
	set category = "Admin"
	set name = "Toggle Sleeping"

	if(!check_rights(R_ADMIN))
		return

	if(M.sleeping > 0)
		M.sleeping = 0
	else
		M.sleeping = 9999999

	log_admin("[key_name(usr)] toggled sleeping on [key_name(M)].")
	message_admins("[key_name_admin(usr)] toggled sleeping on [key_name_admin(M)].")


/datum/admins/proc/toggle_sleep_area()
	set category = "Admin"
	set name = "Toggle Sleeping Area"

	if(!check_rights(R_ADMIN))
		return

	switch(alert("Sleep or unsleep everyone?",,"Sleep","Unsleep","Cancel"))
		if("Sleep")
			for(var/mob/living/M in view())
				M.sleeping = 9999999
			log_admin("[key_name(usr)] has slept everyone in view.")
			message_admins("[key_name_admin(usr)] has slept everyone in view.")
		if("Unsleep")
			for(var/mob/living/M in view())
				M.sleeping = 0
			log_admin("[key_name(usr)] has unslept everyone in view.")
			message_admins("[key_name_admin(usr)] has unslept everyone in view.")


/datum/admins/proc/change_squad(var/mob/living/carbon/human/H in mob_list)
	set category = "Admin"
	set name = "Change Squad"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H) || !ticker || !H.mind?.assigned_role)
		return

	if(!(H.mind.assigned_role in list("Squad Marine", "Squad Engineer", "Squad Medic", "Squad Smartgunner", "Squad Specialist", "Squad Leader")))
		return

	var/datum/squad/S = input(usr, "Choose the marine's new squad") as null|anything in RoleAuthority.squads

	if(!S)
		return

	H.set_everything(H.mind.assigned_role)

	H.assigned_squad?.remove_marine_from_squad(H)

	S.put_marine_in_squad(H)

	//Crew manifest
	for(var/datum/data/record/t in data_core.general)
		if(t.fields["name"] == H.real_name)
			t.fields["squad"] = S.name
			break

	var/obj/item/card/id/ID = H.wear_id
	ID.assigned_fireteam = 0

	//Headset frequency.
	if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer/marine))
		var/obj/item/device/radio/headset/almayer/marine/E = H.wear_ear
		E.set_frequency(S.radio_freq)
	else
		if(H.wear_ear)
			qdel(H.wear_ear)
			H.update_icons()
		H.wear_ear = new /obj/item/device/radio/headset/almayer/marine
		var/obj/item/device/radio/headset/almayer/marine/E = H.wear_ear
		E.set_frequency(S.radio_freq)
		H.update_icons()

	H.hud_set_squad()

	log_admin("[key_name(src)] has changed the squad of [key_name(H)] to [S.name].")
	message_admins("[key_name_admin(usr)] has changed the squad of [key_name_admin(H)] to [S.name].")


/datum/admins/proc/direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Take Over"
	set desc = "Rohesie's verb."

	if(!check_rights(R_ADMIN))
		return

	if(M.gc_destroyed)
		return

	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey], they will be made a ghost. Are you sure?",,"Yes","No") == "Yes")
			M.ghostize()
		else
			return

	var/mob/adminmob = owner.mob
	M.ckey = owner.ckey

	if(M.client)
		M.client.change_view(world.view)

	if(isobserver(adminmob))
		qdel(adminmob)

	log_admin("[key_name(usr)] took over [key_name(M)].")
	message_admins("[key_name_admin(usr)] took over [key_name_admin(M)].")