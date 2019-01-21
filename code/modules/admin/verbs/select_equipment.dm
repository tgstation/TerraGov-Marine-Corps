/client/proc/cmd_admin_select_mob_rank(var/mob/living/carbon/human/H in GLOB.mob_list)
	set category = null
	set name = "Select Rank"

	if(!istype(H))
		return

	var/rank_list = list("Custom") + RoleAuthority.roles_by_name

	var/newrank = input("Select new rank for [H]", "Change the mob's rank and skills") as null|anything in rank_list

	if(!newrank)
		return

	if(!H?.mind)
		return

	feedback_add_details("admin_verb","SMRK") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(newrank != "Custom")
		H.set_everything(H, newrank)
	else
		var/newcommtitle = input("Write the custom title appearing on the comms themselves, for example: \[Command (Title)]", "Comms title") as null|text

		if(!newcommtitle)
			return
		if(!H?.mind)
			return

		H.mind.role_comm_title = newcommtitle
		var/obj/item/card/id/I = H.wear_id

		if(!istype(I) || I != H.wear_id)
			to_chat(usr, "The mob has no id card, unable to modify ID and chat title.")
		else
			var/newchattitle = input("Write the custom title appearing in all chats: Title Jane Doe says", "Chat title") as null|text

			if(!H || I != H.wear_id)
				return

			I.paygrade = newchattitle

			var/IDtitle = input("Write the custom title appearing on the ID itself: Jane Doe's ID Card (Title)", "ID title") as null|text

			if(!H || I != H.wear_id)
				return

			I.rank = IDtitle
			I.assignment = IDtitle
			I.name = "[I.registered_name]'s ID Card[IDtitle ? " ([I.assignment])" : ""]"

		if(!H.mind)
			to_chat(usr, "The mob has no mind, unable to modify skills.")

		else
			var/newskillset = input("Select a skillset", "Skill Set") as null|anything in RoleAuthority.roles_by_name

			if(!newskillset)
				return

			if(!H?.mind)
				return

			var/datum/job/J = RoleAuthority.roles_by_name[newskillset]
			H.mind.set_cm_skills(J.skills_type)


/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in GLOB.mob_list)
	set category = null
	set name = "Select Equipment"

	if(!ishuman(M))
		return

	var/list/dresspacks = list("Strip") + RoleAuthority.roles_by_equipment
	var/list/paths = list("Strip") + RoleAuthority.roles_by_equipment_paths

	var/dresscode = input("Choose equipment for [M]", "Select Equipment") as null|anything in dresspacks

	if(!dresscode)
		return

	var/path = paths[dresspacks.Find(dresscode)]

	feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for(var/obj/item/I in M)
		if(istype(I, /obj/item/implant) || istype(I, /obj/item/card/id))
			continue
		qdel(I)

	var/datum/job/J = new path
	J.generate_equipment(M)
	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("<span class='notice'> [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode].</span>", 1)
	return
