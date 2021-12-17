/datum/buildmode_mode/loadout
	key = "loadout"
	var/datum/loadout/loadout

/datum/buildmode_mode/loadout/Destroy()
	loadout = null
	return ..()

/datum/buildmode_mode/loadout/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************\n\
		Right Mouse Button on buildmode button = Select loadout to equip.\n\
		Left Mouse Button on mob/living/carbon/human = Equip the selected loadout.\n\
		Right Mouse Button on mob/living/carbon/human = Copy thier loadout.\n\
		Shift + Left Mouse Button Button on mob/living/carbon/human = Strip and delete current loadout.\n\
		***********************************************************</span>")

/datum/buildmode_mode/loadout/Reset()
	. = ..()
	loadout = null

/datum/buildmode_mode/loadout/change_settings(client/c)
	var/loadout_choice = tgui_input_list(c, "Chose a loadout", "Loadout choice", SSpersistence.custom_loadouts)
	if(!loadout_choice)
		return
	loadout = SSpersistence.load_loadout(loadout_choice)
	if(!loadout)
		to_chat(c, "Error when loading loadout")

/datum/buildmode_mode/loadout/handle_click(client/c, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/shift_click = pa.Find("shift")

	if(!ishuman(object))
		return

	var/mob/living/carbon/human/dollie = object

	if(right_click)
		var/loadout_name = input(c, "Chose a name for this loadout", "Copy loadout from mob") as text
		if(!loadout_name)
			return
		loadout = create_empty_loadout(loadout_name, dollie.job.title)
		loadout.save_mob_loadout(dollie, TRUE)
		SSpersistence.save_loadout(loadout)
		to_chat(c, span_notice("New loadout copied from [dollie]."))
		return

	if(shift_click && left_click)
		dollie.delete_equipment()
		return

	if(left_click)
		dollie.delete_equipment()
		if(isnull(loadout))
			to_chat(c, span_warning("Pick an loadout first."))
			return
		loadout.equip_mob(dollie)
		dollie.job = SSjob.name_occupations[loadout.job]
		dollie.skills = getSkillsType(dollie.job.skills_type)
		if(dollie.wear_id)
			dollie.wear_id.registered_name = dollie.name
			dollie.wear_id.assignment = dollie.job.title
			dollie.wear_id.rank = dollie.job.title


