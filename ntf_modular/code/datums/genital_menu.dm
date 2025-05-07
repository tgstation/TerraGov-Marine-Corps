GLOBAL_LIST_INIT(possible_cock_sprites, list(
	"Default" = null,
	"Penis" = "cock"
))

GLOBAL_LIST_INIT(possible_ass_sprites, list(
	"Default" = null,
	"Ass" = "ass"
))

GLOBAL_LIST_INIT(possible_boob_sprites, list(
	"Default" = null,
	"Small" = "boobs_s",
	"Medium" = "boobs_m",
	"Large" = "boobs_l",
))

/datum/genital_menu
	/// The human we are attached to
	var/mob/living/carbon/human/human

/datum/genital_menu/New(mob/living/carbon/human/human)
	. = ..()
	src.human = human

/datum/genital_menu/Destroy(force, ...)
	human = null
	return ..()

/datum/genital_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "GenitalMenu")
		ui.open()

/datum/genital_menu/ui_state(mob/user)
	return GLOB.language_menu_state

/datum/genital_menu/ui_data(mob/user)
	var/list/data = list(
		"cockState" = human.cock,
		"assState" = human.ass,
		"boobState" = human.boobs,
	)
	data["possibleCockStates"] = list()
	for(var/entry in GLOB.possible_cock_sprites)
		data["possibleCockStates"] += entry

	data["possibleAssStates"] = list()
	for(var/entry in GLOB.possible_ass_sprites)
		data["possibleAssStates"] += entry

	data["possibleBoobStates"] = list()
	for(var/entry in GLOB.possible_boob_sprites)
		data["possibleBoobStates"] += entry

	return data

/datum/genital_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!human)
		return

	switch(action)
		if("changeCock")
			var/new_cock = params["newState"]
			if(!(new_cock in GLOB.possible_cock_sprites))
				return TRUE

			human.cock = GLOB.possible_cock_sprites[new_cock]
			human.client?.prefs?.genitalia_cock = human.cock
			human.update_genitals()
			return TRUE

		if("changeAss")
			var/new_ass = params["newState"]
			if(!(new_ass in GLOB.possible_ass_sprites))
				return TRUE

			human.ass = GLOB.possible_ass_sprites[new_ass]
			human.client?.prefs?.genitalia_ass = human.ass
			human.update_genitals()
			return TRUE

		if("changeBoobs")
			var/new_boobs = params["newState"]
			if(!(new_boobs in GLOB.possible_boob_sprites))
				return TRUE

			human.boobs = GLOB.possible_boob_sprites[new_boobs]
			human.client?.prefs?.genitalia_boobs = human.boobs
			human.update_genitals()
			return TRUE

		if("reset")
			human.boobs = null
			human.ass = null
			human.cock = null
			human.client?.prefs?.genitalia_boobs = null
			human.client?.prefs?.genitalia_ass = null
			human.client?.prefs?.genitalia_cock = null
			human.update_genitals()
			return TRUE
