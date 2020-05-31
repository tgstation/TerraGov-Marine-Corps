//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	38
//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	41

/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	READ_FILE(S["version"], savefile_version)

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	if(current_version < 39)
		key_bindings = (!focus_chat) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
		parent.update_movement_keys(src)
		to_chat(parent, "<span class='userdanger'>Empty keybindings, setting default to [!focus_chat ? "Hotkey" : "Classic"] mode</span>")

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
				var/delpath = "data/player_saves/[ckey[1]]/[ckey]/"
				if(delpath && fexists(delpath))
					fdel(delpath)
				break
		return FALSE

	if(savefile_version < 39)
		WRITE_FILE(S["toggles_gameplay"], toggles_gameplay)

	if(savefile_version < 41)
		WRITE_FILE(S["chat_on_map"], chat_on_map)
		WRITE_FILE(S["max_chat_length"], max_chat_length)
		WRITE_FILE(S["see_chat_non_mob"], see_chat_non_mob)

	savefile_version = SAVEFILE_VERSION_MAX
	return TRUE


/datum/preferences/proc/load_path(ckey, filename = "preferences.sav")
	ckey = ckey(ckey)
	if(!ckey)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

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

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE

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
	READ_FILE(S["toggles_gameplay"], toggles_gameplay)
	READ_FILE(S["show_typing"], show_typing)
	READ_FILE(S["ghost_hud"], ghost_hud)
	READ_FILE(S["windowflashing"], windowflashing)
	READ_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	READ_FILE(S["menuoptions"], menuoptions)
	READ_FILE(S["ghost_vision"], ghost_vision)
	READ_FILE(S["ghost_orbit"], ghost_orbit)
	READ_FILE(S["ghost_form"], ghost_form)
	READ_FILE(S["ghost_others"], ghost_others)
	READ_FILE(S["observer_actions"], observer_actions)
	READ_FILE(S["focus_chat"], focus_chat)
	READ_FILE(S["clientfps"], clientfps)
	READ_FILE(S["tooltips"], tooltips)
	READ_FILE(S["key_bindings"], key_bindings)

	// Runechat options
	READ_FILE(S["chat_on_map"], chat_on_map)
	READ_FILE(S["max_chat_length"], max_chat_length)
	READ_FILE(S["see_chat_non_mob"], see_chat_non_mob)


	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor		= sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor))
	be_special		= sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	ui_style		= sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color	= sanitize_hexcolor(ui_style_color, 6, TRUE, initial(ui_style_color))
	ui_style_alpha	= sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat	= sanitize_integer(toggles_chat, NONE, MAX_BITFLAG, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, NONE, MAX_BITFLAG, initial(toggles_sound))
	toggles_gameplay= sanitize_integer(toggles_gameplay, NONE, MAX_BITFLAG, initial(toggles_gameplay))
	show_typing		= sanitize_integer(show_typing, FALSE, TRUE, initial(show_typing))
	ghost_hud 		= sanitize_integer(ghost_hud, NONE, MAX_BITFLAG, initial(ghost_hud))
	windowflashing	= sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	auto_fit_viewport= sanitize_integer(auto_fit_viewport, FALSE, TRUE, initial(auto_fit_viewport))
	ghost_vision	= sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit		= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form		= sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	observer_actions= sanitize_integer(observer_actions, FALSE, TRUE, initial(observer_actions))
	focus_chat		= sanitize_integer(focus_chat, FALSE, TRUE, initial(focus_chat))
	clientfps		= sanitize_integer(clientfps, 0, 240, initial(clientfps))
	tooltips		= sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))

	key_bindings 	= sanitize_islist(key_bindings, list())

	chat_on_map			= sanitize_integer(chat_on_map, FALSE, TRUE, initial(chat_on_map))
	max_chat_length		= sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	see_chat_non_mob	= sanitize_integer(see_chat_non_mob, FALSE, TRUE, initial(see_chat_non_mob))

	return TRUE


/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	try
		WRITE_FILE(S["savefile_write_test"], "lebowskilebowski")
	catch
		to_chat(parent, "<span class='warning'>Writing to the savefile failed, please try again.</span>")
		return FALSE

	WRITE_FILE(S["version"], savefile_version)

	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor		= sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor))

	ui_style		= sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color	= sanitize_hexcolor(ui_style_color, 6, TRUE, initial(ui_style_color))
	ui_style_alpha	= sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat	= sanitize_integer(toggles_chat, NONE, MAX_BITFLAG, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, NONE, MAX_BITFLAG, initial(toggles_sound))
	toggles_gameplay= sanitize_integer(toggles_gameplay, NONE, MAX_BITFLAG, initial(toggles_gameplay))
	show_typing		= sanitize_integer(show_typing, FALSE, TRUE, initial(show_typing))
	ghost_hud 		= sanitize_integer(ghost_hud, NONE, MAX_BITFLAG, initial(ghost_hud))
	windowflashing	= sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	auto_fit_viewport= sanitize_integer(auto_fit_viewport, FALSE, TRUE, initial(auto_fit_viewport))
	key_bindings	= sanitize_islist(key_bindings, list())
	ghost_vision	= sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit		= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form		= sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	observer_actions= sanitize_integer(observer_actions, FALSE, TRUE, initial(observer_actions))
	focus_chat		= sanitize_integer(focus_chat, FALSE, TRUE, initial(focus_chat))
	clientfps		= sanitize_integer(clientfps, 0, 240, initial(clientfps))
	tooltips		= sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))

	// Runechat
	chat_on_map			= sanitize_integer(chat_on_map, FALSE, TRUE, initial(chat_on_map))
	max_chat_length		= sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	see_chat_non_mob	= sanitize_integer(see_chat_non_mob, FALSE, TRUE, initial(see_chat_non_mob))

	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["ooccolor"], ooccolor)

	WRITE_FILE(S["ui_style"], ui_style)
	WRITE_FILE(S["ui_style_color"], ui_style_color)
	WRITE_FILE(S["ui_style_alpha"], ui_style_alpha)

	WRITE_FILE(S["toggles_chat"], toggles_chat)
	WRITE_FILE(S["toggles_sound"], toggles_sound)
	WRITE_FILE(S["toggles_gameplay"], toggles_gameplay)
	WRITE_FILE(S["show_typing"], show_typing)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["windowflashing"], windowflashing)
	WRITE_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["key_bindings"], key_bindings)
	WRITE_FILE(S["ghost_vision"], ghost_vision)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["observer_actions"], observer_actions)
	WRITE_FILE(S["focus_chat"], focus_chat)
	WRITE_FILE(S["clientfps"], clientfps)
	WRITE_FILE(S["tooltips"], tooltips)

	// Runechat options
	WRITE_FILE(S["chat_on_map"], chat_on_map)
	WRITE_FILE(S["max_chat_length"], max_chat_length)
	WRITE_FILE(S["see_chat_non_mob"], see_chat_non_mob)

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
	READ_FILE(S["ai_name"], ai_name)

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
	ai_name			= reject_bad_name(ai_name, TRUE)

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
	if(!ai_name)
		ai_name = "ARES v3.2"
	if(!real_name)
		real_name = GLOB.namepool[/datum/namepool].get_random_name(gender)

	return TRUE


/datum/preferences/proc/save_character()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/character[default_slot]"

	try
		WRITE_FILE(S["savefile_write_test"], "lebowskilebowski")
	catch
		to_chat(parent, "<span class='warning'>Writing to the savefile failed, please try again.</span>")
		return FALSE

	be_special		= sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	synthetic_name	= reject_bad_name(synthetic_name)
	synthetic_type	= sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))
	xeno_name		= reject_bad_name(xeno_name)
	ai_name			= reject_bad_name(ai_name, TRUE)

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
	WRITE_FILE(S["ai_name"], ai_name)

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
