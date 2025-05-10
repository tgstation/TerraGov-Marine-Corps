/datum/buildmode_mode/loadout
	key = "loadout"

	/// The currently selected loadout datum
	var/datum/loadout/loadout

/datum/buildmode_mode/loadout/Destroy()
	loadout = null
	return ..()

/datum/buildmode_mode/loadout/show_help(client/user)
	to_chat(user, custom_boxed_message("purple_box",\
		"[span_bold("Select loadout to equip")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Equip the selected loadout")] -> Left Mouse Button on mob/living/carbon/human\n\
		[span_bold("Copy their loadout")] -> Right Mouse Button on mob/living/carbon/human\n\
		[span_bold("Strip and delete current loadout")] -> Shift + Left Mouse Button Button on mob/living/carbon/human"))

/datum/buildmode_mode/loadout/change_settings(client/user)
	var/loadout_choice = tgui_input_list(user, "Choose a loadout", "Loadout choice", SSpersistence.custom_loadouts)
	if(!loadout_choice)
		return
	loadout = SSpersistence.load_loadout(loadout_choice)
	if(!loadout)
		to_chat(user, "Error when loading loadout")

/datum/buildmode_mode/loadout/handle_click(client/user, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/shift_click = pa.Find("shift")

	if(!ishuman(object))
		return

	var/mob/living/carbon/human/dollie = object

	if(right_click)
		var/loadout_name = input(user, "Chose a name for this loadout", "Copy loadout from mob") as text
		if(!loadout_name)
			return
		loadout = create_empty_loadout(loadout_name, dollie.job.title)
		loadout.save_mob_loadout(dollie, TRUE)
		SSpersistence.save_loadout(loadout)
		to_chat(user, span_notice("New loadout copied from [dollie]."))
		return

	if(shift_click && left_click)
		dollie.delete_equipment()
		return

	if(left_click)
		dollie.delete_equipment()
		if(isnull(loadout))
			to_chat(user, span_warning("Pick an loadout first."))
			return
		loadout.equip_mob(dollie)
		dollie.job = SSjob.name_occupations[loadout.job]
		dollie.set_skills(getSkillsType(dollie.job.skills_type))
		if(dollie.wear_id)
			dollie.wear_id.registered_name = dollie.name
			dollie.wear_id.assignment = dollie.job.title
			dollie.wear_id.rank = dollie.job.title
