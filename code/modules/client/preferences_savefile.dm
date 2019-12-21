//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	20
//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	39

/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	savefile_version = read_file(S, "version")

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
		parent.update_movement_keys()
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
				var/delpath = "data/player_saves/[copytext(ckey, 1, 2)]/[ckey]/"
				if(delpath && fexists(delpath))
					fdel(delpath)
				break
		return FALSE

	if(savefile_version < 22)
		write_file(S, "windowflashing", TRUE)

	if(savefile_version < 24)
		write_file(S, "menuoptions", list())

	if(savefile_version < 25)
		write_file(S, "ghost_vision", TRUE)
		write_file(S, "ghost_orbit", GHOST_ORBIT_CIRCLE)
		write_file(S, "ghost_form", GHOST_DEFAULT_FORM)
		write_file(S, "ghost_others", GHOST_OTHERS_DEFAULT_OPTION)

	if(savefile_version < 27)
		switch(S["ui_style"])
			if("Orange")
				write_file(S, "ui_style", "Plasmafire")
			if("old")
				write_file(S, "ui_style", "Retro")
		if(S["ui_style_alpha"] > 230)
			write_file(S, "ui_style_alpha", 230)

	if(savefile_version < 28)
		write_file(S, "tooltips", TRUE)

	if(savefile_version < 29)
		write_file(S, "metadata", null)
		write_file(S, "jobs_low", null)
		write_file(S, "jobs_medium", null)
		write_file(S, "jobs_high", null)
		write_file(S, "job_preferences", list())

	if(savefile_version < 32)
		write_file(S, "observer_actions", TRUE)

	if(savefile_version < 35)
		write_file(S, "focus_chat", FALSE)

	if(savefile_version < 36)
		write_file(S, "clientfps", 0)

	if(savefile_version < 37)
		write_file(S, "ai_name", "ARES v3.2")

	if(savefile_version < 38)
		write_file(S, "menuoptions", list())

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

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE

	savefile_version = read_file(S, "version")
	if(!savefile_version || !isnum(savefile_version) || savefile_version != SAVEFILE_VERSION_MAX)
		if(!savefile_update(S))
			savefile_version = SAVEFILE_VERSION_MAX
			save_preferences()
			save_character()
			return FALSE

	default_slot = read_file(S, "default_slot")
	lastchangelog = read_file(S, "lastchangelog")
	ooccolor = read_file(S, "ooccolor")

	ui_style = read_file(S, "ui_style")
	ui_style_color = read_file(S, "ui_style_color")
	ui_style_alpha = read_file(S, "ui_style_alpha")

	toggles_chat = read_file(S, "toggles_chat")
	toggles_sound = read_file(S, "toggles_sound")
	show_typing = read_file(S, "show_typing")
	ghost_hud = read_file(S, "ghost_hud")
	windowflashing = read_file(S, "windowflashing")
	menuoptions = read_file(S, "menuoptions")
	ghost_vision = read_file(S, "ghost_vision")
	ghost_orbit = read_file(S, "ghost_orbit")
	ghost_form = read_file(S, "ghost_form")
	ghost_others = read_file(S, "ghost_others")
	observer_actions= read_file(S, "observer_actions")
	focus_chat = read_file(S, "focus_chat")
	clientfps = read_file(S, "clientfps")
	tooltips = read_file(S, "tooltips")
	key_bindings = read_file(S, "key_bindings")

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

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
	observer_actions= sanitize_integer(observer_actions, FALSE, TRUE, initial(observer_actions))
	focus_chat		= sanitize_integer(focus_chat, FALSE, TRUE, initial(focus_chat))
	clientfps		= sanitize_integer(clientfps, 0, 240, initial(clientfps))
	tooltips		= sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))

	key_bindings 	= sanitize_islist(key_bindings, list())

	return TRUE


/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	try
		write_file(S, "savefile_write_test", "lebowskilebowski")
	catch
		to_chat(parent, "<span class='warning'>Writing to the savefile failed, please try again.</span>")
		return FALSE

	write_file(S, "version", savefile_version)

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
	key_bindings	= sanitize_islist(key_bindings, list())
	ghost_vision	= sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit		= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form		= sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	observer_actions= sanitize_integer(observer_actions, FALSE, TRUE, initial(observer_actions))
	focus_chat		= sanitize_integer(focus_chat, FALSE, TRUE, initial(focus_chat))
	clientfps		= sanitize_integer(clientfps, 0, 240, initial(clientfps))
	tooltips		= sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))

	write_file(S, "default_slot", default_slot)
	write_file(S, "lastchangelog", lastchangelog)
	write_file(S, "ooccolor", ooccolor)

	write_file(S, "ui_style", ui_style)
	write_file(S, "ui_style_color", ui_style_color)
	write_file(S, "ui_style_alpha", ui_style_alpha)

	write_file(S, "toggles_chat", toggles_chat)
	write_file(S, "toggles_sound", toggles_sound)
	write_file(S, "show_typing", show_typing)
	write_file(S, "ghost_hud", ghost_hud)
	write_file(S, "windowflashing", windowflashing)
	write_file(S, "menuoptions", menuoptions)
	write_file(S, "key_bindings", key_bindings)
	write_file(S, "ghost_vision", ghost_vision)
	write_file(S, "ghost_orbit", ghost_orbit)
	write_file(S, "ghost_form", ghost_form)
	write_file(S, "ghost_others", ghost_others)
	write_file(S, "observer_actions", observer_actions)
	write_file(S, "focus_chat", focus_chat)
	write_file(S, "clientfps", clientfps)
	write_file(S, "tooltips", tooltips)

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
		write_file(S, "default_slot", slot)
	S.cd = "/character[slot]"

	be_special = read_file(S, "be_special")

	synthetic_name = read_file(S, "synthetic_name")
	synthetic_type = read_file(S, "synthetic_type")
	xeno_name = read_file(S, "xeno_name")
	ai_name = read_file(S, "ai_name")

	real_name = read_file(S, "real_name")
	random_name = read_file(S, "random_name")
	gender = read_file(S, "gender")
	age = read_file(S, "age")
	species = read_file(S, "species")
	ethnicity = read_file(S, "ethnicity")
	body_type = read_file(S, "body_type")
	good_eyesight = read_file(S, "good_eyesight")
	preferred_squad = read_file(S, "preferred_squad")
	alternate_option = read_file(S, "alternate_option")
	job_preferences = read_file(S, "job_preferences")
	preferred_slot = read_file(S, "preferred_slot")
	gear = read_file(S, "gear")
	underwear = read_file(S, "underwear")
	undershirt = read_file(S, "undershirt")
	backpack = read_file(S, "backpack")

	h_style = read_file(S, "h_style")
	r_hair = read_file(S, "r_hair")
	g_hair = read_file(S, "g_hair")
	b_hair = read_file(S, "b_hair")

	f_style = read_file(S, "f_style")
	r_facial = read_file(S, "r_facial")
	g_facial = read_file(S, "g_facial")
	b_facial = read_file(S, "b_facial")

	r_eyes = read_file(S, "r_eyes")
	g_eyes = read_file(S, "g_eyes")
	b_eyes = read_file(S, "b_eyes")

	moth_wings = read_file(S, "moth_wings")

	citizenship = read_file(S, "citizenship")
	religion = read_file(S, "religion")
	nanotrasen_relation = read_file(S, "nanotrasen_relation")

	med_record = read_file(S, "med_record")
	sec_record = read_file(S, "sec_record")
	gen_record = read_file(S, "gen_record")
	exploit_record = read_file(S, "exploit_record")
	flavor_text = read_file(S, "flavor_text")


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
		write_file(S, "savefile_write_test", "lebowskilebowski")
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

	write_file(S, "be_special", be_special)

	write_file(S, "synthetic_name", synthetic_name)
	write_file(S, "synthetic_type", synthetic_type)
	write_file(S, "xeno_name", xeno_name)
	write_file(S, "ai_name", ai_name)

	write_file(S, "real_name", real_name)
	write_file(S, "random_name", random_name)
	write_file(S, "gender", gender)
	write_file(S, "age", age)
	write_file(S, "species", species)
	write_file(S, "ethnicity", ethnicity)
	write_file(S, "body_type", body_type)
	write_file(S, "good_eyesight", good_eyesight)
	write_file(S, "preferred_squad", preferred_squad)
	write_file(S, "alternate_option", alternate_option)
	write_file(S, "job_preferences", job_preferences)
	write_file(S, "preferred_slot", preferred_slot)
	write_file(S, "gear", gear)
	write_file(S, "underwear", underwear)
	write_file(S, "undershirt", undershirt)
	write_file(S, "backpack", backpack)

	write_file(S, "h_style", h_style)
	write_file(S, "r_hair", r_hair)
	write_file(S, "g_hair", g_hair)
	write_file(S, "b_hair", b_hair)

	write_file(S, "f_style", f_style)
	write_file(S, "r_facial", r_facial)
	write_file(S, "g_facial", g_facial)
	write_file(S, "b_facial", b_facial)

	write_file(S, "r_eyes", r_eyes)
	write_file(S, "g_eyes", g_eyes)
	write_file(S, "b_eyes", b_eyes)

	write_file(S, "moth_wings", moth_wings)

	write_file(S, "citizenship", citizenship)
	write_file(S, "religion", religion)
	write_file(S, "nanotrasen_relation", nanotrasen_relation)

	write_file(S, "med_record", med_record)
	write_file(S, "sec_record", sec_record)
	write_file(S, "gen_record", gen_record)
	write_file(S, "exploit_record", exploit_record)
	write_file(S, "flavor_text", flavor_text)

	return TRUE


/datum/preferences/proc/save()
	return (save_preferences() && save_character())


/datum/preferences/proc/load()
	return (load_preferences() && load_character())
