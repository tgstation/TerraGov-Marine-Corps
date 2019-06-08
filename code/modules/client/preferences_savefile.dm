#define SAVEFILE_VERSION_MIN	20
#define SAVEFILE_VERSION_MAX	30

//handles converting savefiles to new formats
//MAKE SURE YOU KEEP THIS UP TO DATE!
//If the sanity checks are capable of handling any issues. Only increase SAVEFILE_VERSION_MAX,
//this will mean that savefile_version will still be over SAVEFILE_VERSION_MIN, meaning
//this savefile update doesn't run everytime we load from the savefile.
//This is mainly for format changes, such as the bitflags in toggles changing order or something.
//if a file can't be updated, return FALSE to delete it and start again
//if a file was updated, return TRUE
/datum/preferences/proc/savefile_update(savefile/S)
	if(!isnum(savefile_version) || savefile_version < SAVEFILE_VERSION_MIN)	//lazily delete everything + additional files so they can be saved in the new format
		for(var/ckey in GLOB.preferences_datums)
			var/datum/preferences/D = GLOB.preferences_datums[ckey]
			if(D == src)
				var/delpath = "data/player_saves/[copytext(ckey, 1, 2)]/[ckey]/"
				if(delpath && fexists(delpath))
					fdel(delpath)
				break
		return FALSE

	if(savefile_version < 30)
		WRITE_FILE(S["key_bindings"], deepCopyList(GLOB.keybinding_list_by_key))

	if(savefile_version < 29)
		WRITE_FILE(S["metadata"], null)
		WRITE_FILE(S["jobs_low"], null)
		WRITE_FILE(S["jobs_medium"], null)
		WRITE_FILE(S["jobs_high"], null)
		WRITE_FILE(S["job_preferences"], list())

	if(savefile_version < 28)
		WRITE_FILE(S["tooltips"], TRUE)

	if(savefile_version < 27)
		switch(S["ui_style"])
			if("Orange")
				WRITE_FILE(S["ui_style"], "Plasmafire")
			if("old")
				WRITE_FILE(S["ui_style"], "Retro")
		if(S["ui_style_alpha"] > 230)
			WRITE_FILE(S["ui_style_alpha"], 230)

	if(savefile_version < 26)
		WRITE_FILE(S["key_bindings"], deepCopyList(GLOB.keybinding_list_by_key))

	if(savefile_version < 25)
		WRITE_FILE(S["ghost_vision"], TRUE)
		WRITE_FILE(S["ghost_orbit"], GHOST_ORBIT_CIRCLE)
		WRITE_FILE(S["ghost_form"], GHOST_DEFAULT_FORM)
		WRITE_FILE(S["ghost_others"], GHOST_OTHERS_DEFAULT_OPTION)

	if(savefile_version < 24)
		WRITE_FILE(S["menuoptions"], list())

	if(savefile_version < 23)
		WRITE_FILE(S["hotkeys"], TRUE)

	if(savefile_version < 22)
		WRITE_FILE(S["windowflashing"], TRUE)

	savefile_version = SAVEFILE_VERSION_MAX
	return TRUE


/datum/preferences/proc/load_path(ckey, filename = "preferences.sav")
	ckey = ckey(ckey)
	if(!ckey)
		return
	path = "data/player_saves/[copytext(ckey, 1, 2)]/[ckey]/[filename]"

	if(savefile_version < 21)
		muted << NONE

	savefile_version = SAVEFILE_VERSION_MAX


/datum/preferences/proc/load_preferences()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	READ_FILE(S["version"], savefile_version)
	if(!savefile_version || !isnum(savefile_version) || savefile_version != SAVEFILE_VERSION_MAX)
		if(!savefile_update(S))
			savefile_version = SAVEFILE_VERSION_MAX
			save_preferences()
			save_character()
			return FALSE

	READ_FILE(S["default_slot"], default_slot)
	READ_FILE(S["lastchangelog"], lastchangelog)
	READ_FILE(S["ooccolor"], ooccolor)

	READ_FILE(S["ui_style"], ui_style)
	READ_FILE(S["ui_style_color"], ui_style_color)
	READ_FILE(S["ui_style_alpha"], ui_style_alpha)

	READ_FILE(S["toggles_chat"], toggles_chat)
	READ_FILE(S["toggles_sound"], toggles_sound)
	READ_FILE(S["show_typing"], show_typing)
	READ_FILE(S["ghost_hud"], ghost_hud)
	READ_FILE(S["windowflashing"], windowflashing)
	READ_FILE(S["menuoptions"], menuoptions)
	READ_FILE(S["ghost_vision"], ghost_vision)
	READ_FILE(S["ghost_orbit"], ghost_orbit)
	READ_FILE(S["ghost_form"], ghost_form)
	READ_FILE(S["ghost_others"], ghost_others)
	READ_FILE(S["hotkeys"], hotkeys)
	READ_FILE(S["tooltips"], tooltips)
	READ_FILE(S["key_bindings"], key_bindings)

	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	be_special		= sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	ui_style		= sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color	= sanitize_hexcolor(ui_style_color, initial(ui_style_color))
	ui_style_alpha	= sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat	= sanitize_integer(toggles_chat, NONE, MAX_BITFLAG, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, NONE, MAX_BITFLAG, initial(toggles_sound))
	show_typing		= sanitize_integer(show_typing, FALSE, TRUE, initial(show_typing))
	ghost_hud 		= sanitize_integer(ghost_hud, NONE, MAX_BITFLAG, initial(ghost_hud))
	windowflashing	= sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	ghost_vision	= sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit		= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form		= sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	hotkeys			= sanitize_integer(hotkeys, FALSE, TRUE, initial(hotkeys))
	tooltips		= sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))

	key_bindings 	= sanitize_islist(key_bindings, deepCopyList(GLOB.keybinding_list_by_key))

	return TRUE


/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE

	S.cd = "/"
	WRITE_FILE(S["version"], savefile_version)

	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))

	ui_style		= sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color	= sanitize_hexcolor(ui_style_color, initial(ui_style_color))
	ui_style_alpha	= sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat	= sanitize_integer(toggles_chat, NONE, MAX_BITFLAG, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, NONE, MAX_BITFLAG, initial(toggles_sound))
	show_typing		= sanitize_integer(show_typing, FALSE, TRUE, initial(show_typing))
	ghost_hud 		= sanitize_integer(ghost_hud, NONE, MAX_BITFLAG, initial(ghost_hud))
	windowflashing	= sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	key_bindings	= sanitize_islist(key_bindings, deepCopyList(GLOB.keybinding_list_by_key))
	ghost_vision	= sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit		= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form		= sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	hotkeys			= sanitize_integer(hotkeys, FALSE, TRUE, initial(hotkeys))
	tooltips		= sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))

	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["ooccolor"], ooccolor)

	WRITE_FILE(S["ui_style"], ui_style)
	WRITE_FILE(S["ui_style_color"], ui_style_color)
	WRITE_FILE(S["ui_style_alpha"], ui_style_alpha)

	WRITE_FILE(S["toggles_chat"], toggles_chat)
	WRITE_FILE(S["toggles_sound"], toggles_sound)
	WRITE_FILE(S["show_typing"], show_typing)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["windowflashing"], windowflashing)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["key_bindings"], key_bindings)
	WRITE_FILE(S["ghost_vision"], ghost_vision)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["hotkeys"], hotkeys)
	WRITE_FILE(S["tooltips"], tooltips)

	return TRUE


/datum/preferences/proc/load_character(slot)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"], slot)
	S.cd = "/character[slot]"

	READ_FILE(S["be_special"], be_special)

	READ_FILE(S["synthetic_name"], synthetic_name)
	READ_FILE(S["synthetic_type"], synthetic_type)

	READ_FILE(S["xeno_name"], xeno_name)

	READ_FILE(S["real_name"], real_name)
	READ_FILE(S["random_name"], random_name)
	READ_FILE(S["gender"], gender)
	READ_FILE(S["age"], age)
	READ_FILE(S["species"], species)
	READ_FILE(S["ethnicity"], ethnicity)
	READ_FILE(S["body_type"], body_type)
	READ_FILE(S["good_eyesight"], good_eyesight)
	READ_FILE(S["preferred_squad"], preferred_squad)
	READ_FILE(S["alternate_option"], alternate_option)
	READ_FILE(S["job_preferences"], job_preferences)
	READ_FILE(S["preferred_slot"], preferred_slot)
	READ_FILE(S["gear"], gear)
	READ_FILE(S["underwear"], underwear)
	READ_FILE(S["undershirt"], undershirt)
	READ_FILE(S["backpack"], backpack)

	READ_FILE(S["h_style"], h_style)
	READ_FILE(S["r_hair"], r_hair)
	READ_FILE(S["g_hair"], g_hair)
	READ_FILE(S["b_hair"], b_hair)

	READ_FILE(S["f_style"], f_style)
	READ_FILE(S["r_facial"], r_facial)
	READ_FILE(S["g_facial"], g_facial)
	READ_FILE(S["b_facial"], b_facial)

	READ_FILE(S["r_eyes"], r_eyes)
	READ_FILE(S["g_eyes"], g_eyes)
	READ_FILE(S["b_eyes"], b_eyes)

	READ_FILE(S["moth_wings"], moth_wings)

	READ_FILE(S["citizenship"], citizenship)
	READ_FILE(S["religion"], religion)
	READ_FILE(S["nanotrasen_relation"], nanotrasen_relation)

	READ_FILE(S["med_record"], med_record)
	READ_FILE(S["sec_record"], sec_record)
	READ_FILE(S["gen_record"], gen_record)
	READ_FILE(S["exploit_record"], exploit_record)
	READ_FILE(S["flavor_text"], flavor_text)


	be_special		= sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	synthetic_name	= reject_bad_name(synthetic_name)
	synthetic_type	= sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))

	xeno_name		= reject_bad_name(xeno_name)

	real_name		= reject_bad_name(real_name)
	random_name		= sanitize_integer(random_name, FALSE, TRUE, initial(random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	species			= sanitize_inlist(species, GLOB.all_species, initial(species))
	ethnicity		= sanitize_ethnicity(ethnicity)
	body_type		= sanitize_body_type(body_type)
	good_eyesight	= sanitize_integer(good_eyesight, FALSE, TRUE, initial(good_eyesight))
	preferred_squad	= sanitize_inlist(preferred_squad, SELECTABLE_SQUADS, initial(preferred_squad))
	alternate_option= sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_preferences = SANITIZE_LIST(job_preferences)
	preferred_slot	= sanitize_inlist(preferred_slot, SLOT_DRAW_ORDER, initial(preferred_slot))
	if(gender == MALE)
		underwear		= sanitize_integer(underwear, 1, length(GLOB.underwear_m), initial(underwear))
	else
		underwear		= sanitize_integer(underwear, 1, length(GLOB.underwear_f), initial(underwear))
	undershirt		= sanitize_integer(undershirt, 1, length(GLOB.undershirt_t), initial(undershirt))
	backpack		= sanitize_integer(backpack, 1, length(GLOB.backpacklist), initial(backpack))

	h_style			= sanitize_inlist(h_style, GLOB.hair_styles_list, initial(h_style))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))

	f_style			= sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))

	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))

	moth_wings		= sanitize_inlist(moth_wings, GLOB.moth_wings_list, initial(moth_wings))

	citizenship		= sanitize_inlist(citizenship, CITIZENSHIP_CHOICES, initial(citizenship))
	religion		= sanitize_inlist(religion, RELIGION_CHOICES, initial(religion))
	nanotrasen_relation = sanitize_inlist(nanotrasen_relation, CORP_RELATIONS, initial(nanotrasen_relation))

	med_record		= sanitize_text(med_record, initial(med_record))
	sec_record		= sanitize_text(sec_record, initial(sec_record))
	gen_record		= sanitize_text(gen_record, initial(gen_record))
	exploit_record	= sanitize_text(exploit_record, initial(exploit_record))
	flavor_text		= sanitize_text(flavor_text, initial(flavor_text))

	if(!synthetic_name)
		synthetic_name = "David"
	if(!xeno_name)
		xeno_name = "Undefined"
	if(!real_name)
		if(gender == FEMALE)
			real_name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			real_name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	return TRUE


/datum/preferences/proc/save_character()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/character[default_slot]"

	be_special		= sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	synthetic_name	= reject_bad_name(synthetic_name)
	synthetic_type	= sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))

	xeno_name		= reject_bad_name(xeno_name)

	real_name		= reject_bad_name(real_name)
	random_name		= sanitize_integer(random_name, FALSE, TRUE, initial(random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	species			= sanitize_inlist(species, GLOB.all_species, initial(species))
	ethnicity		= sanitize_ethnicity(ethnicity)
	body_type		= sanitize_body_type(body_type)
	good_eyesight	= sanitize_integer(good_eyesight, FALSE, TRUE, initial(good_eyesight))
	preferred_squad	= sanitize_inlist(preferred_squad, SELECTABLE_SQUADS, initial(preferred_squad))
	alternate_option= sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_preferences = SANITIZE_LIST(job_preferences)
	preferred_slot	= sanitize_inlist(preferred_slot, SLOT_DRAW_ORDER, initial(preferred_slot))
	if(gender == MALE)
		underwear		= sanitize_integer(underwear, 1, length(GLOB.underwear_m), initial(underwear))
	else
		underwear		= sanitize_integer(underwear, 1, length(GLOB.underwear_f), initial(underwear))
	undershirt		= sanitize_integer(undershirt, 1, length(GLOB.undershirt_t), initial(undershirt))
	backpack		= sanitize_integer(backpack, 1, length(GLOB.backpacklist), initial(backpack))

	h_style			= sanitize_inlist(h_style, GLOB.hair_styles_list, initial(h_style))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))

	f_style			= sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))

	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))

	moth_wings		= sanitize_inlist(moth_wings, GLOB.moth_wings_list, initial(moth_wings))

	citizenship		= sanitize_inlist(citizenship, CITIZENSHIP_CHOICES, initial(citizenship))
	religion		= sanitize_inlist(religion, RELIGION_CHOICES, initial(religion))
	nanotrasen_relation = sanitize_inlist(nanotrasen_relation, CORP_RELATIONS, initial(nanotrasen_relation))

	med_record		= sanitize_text(med_record, initial(med_record))
	sec_record		= sanitize_text(sec_record, initial(sec_record))
	gen_record		= sanitize_text(gen_record, initial(gen_record))
	exploit_record	= sanitize_text(exploit_record, initial(exploit_record))
	flavor_text		= sanitize_text(flavor_text, initial(flavor_text))

	WRITE_FILE(S["be_special"], be_special)

	WRITE_FILE(S["synthetic_name"], synthetic_name)
	WRITE_FILE(S["synthetic_type"], synthetic_type)

	WRITE_FILE(S["xeno_name"], xeno_name)

	WRITE_FILE(S["real_name"], real_name)
	WRITE_FILE(S["random_name"], random_name)
	WRITE_FILE(S["gender"], gender)
	WRITE_FILE(S["age"], age)
	WRITE_FILE(S["species"], species)
	WRITE_FILE(S["ethnicity"], ethnicity)
	WRITE_FILE(S["body_type"], body_type)
	WRITE_FILE(S["good_eyesight"], good_eyesight)
	WRITE_FILE(S["preferred_squad"], preferred_squad)
	WRITE_FILE(S["alternate_option"], alternate_option)
	WRITE_FILE(S["job_preferences"], job_preferences)
	WRITE_FILE(S["preferred_slot"], preferred_slot)
	WRITE_FILE(S["gear"], gear)
	WRITE_FILE(S["underwear"], underwear)
	WRITE_FILE(S["undershirt"], undershirt)
	WRITE_FILE(S["backpack"], backpack)

	WRITE_FILE(S["h_style"], h_style)
	WRITE_FILE(S["r_hair"], r_hair)
	WRITE_FILE(S["g_hair"], g_hair)
	WRITE_FILE(S["b_hair"], b_hair)

	WRITE_FILE(S["f_style"], f_style)
	WRITE_FILE(S["r_facial"], r_facial)
	WRITE_FILE(S["g_facial"], g_facial)
	WRITE_FILE(S["b_facial"], b_facial)

	WRITE_FILE(S["r_eyes"], r_eyes)
	WRITE_FILE(S["g_eyes"], g_eyes)
	WRITE_FILE(S["b_eyes"], b_eyes)

	WRITE_FILE(S["moth_wings"], moth_wings)

	WRITE_FILE(S["citizenship"], citizenship)
	WRITE_FILE(S["religion"], religion)
	WRITE_FILE(S["nanotrasen_relation"], nanotrasen_relation)

	WRITE_FILE(S["med_record"], med_record)
	WRITE_FILE(S["sec_record"], sec_record)
	WRITE_FILE(S["gen_record"], gen_record)
	WRITE_FILE(S["exploit_record"], exploit_record)
	WRITE_FILE(S["flavor_text"], flavor_text)

	return TRUE


/datum/preferences/proc/save()
	return (save_preferences() && save_character())


/datum/preferences/proc/load()
	return (load_preferences() && load_character())