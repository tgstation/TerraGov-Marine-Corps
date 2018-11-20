/client/proc/cmd_admin_select_mob_rank(var/mob/living/carbon/human/H in mob_list)
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
		var/newcommtitle = input("Write the custom title appearing on comms chat (e.g. Spc)", "Comms title") as null|text

		if(!newcommtitle)
			return
		if(!H?.mind)
			return

		H.mind.role_comm_title = newcommtitle
		var/obj/item/card/id/I = H.wear_id

		if(!istype(I) || I != H.wear_id)
			to_chat(usr, "The mob has no id card, unable to modify ID and chat title.")
		else
			var/newchattitle = input("Write the custom title appearing in chat (e.g. SGT)", "Chat title") as null|text
			
			if(!newchattitle)
				return
			if(!H || I != H.wear_id)
				return

			I.paygrade = newchattitle

			var/IDtitle = input("Write the custom title on your ID (e.g. Squad Specialist)", "ID title") as null|text

			if(!IDtitle)
				return
			if(!H || I != H.wear_id)
				return

			I.rank = IDtitle
			I.assignment = IDtitle
			I.name = "[I.registered_name]'s ID Card ([I.assignment])"

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


/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in mob_list)
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
		cdel(I)

	var/datum/job/J = new path
	J.generate_equipment(M)
	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("\blue [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode].", 1)
	return


/mob/living/proc/set_ID(new_job)
	return

/mob/living/carbon/human/set_ID(new_job)
	var/datum/job/J = RoleAuthority.roles_by_name[new_job]
	if(new_job)
		if(wear_id)
			var/obj/item/card/id/I = wear_id.GetID()
			if(I)
				var/title_alt = J.get_alternative_title(src)
				I.access = J.get_access()
				I.rank = J.title
				I.assignment = title_alt ? title_alt :  J.disp_title
				I.name = "[I.registered_name]'s ID Card ([I.assignment])"
				I.paygrade = J.paygrade
		else
			J.equip_identification(src, J)