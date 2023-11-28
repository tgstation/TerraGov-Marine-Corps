//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN 38
//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX 45

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
		key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
		parent.set_macros()
		to_chat(parent, span_userdanger("Empty keybindings, setting to default"))

	// Add missing keybindings for T L O M for when they were removed as defaults
	if(current_version < 42)
		var/list/missing_keybinds = list(
			"T" = "say",
			"M" = "me",
			"O" = "ooc",
			"L" = "looc",
		)
		for(var/key in missing_keybinds)
			var/kb_path = missing_keybinds[key]
			if(!(key in key_bindings) || !islist(key_bindings[key]))
				key_bindings[key] = list()
			if(!(kb_path in key_bindings[key]))
				key_bindings[key] += list(kb_path)

		to_chat(parent, span_userdanger("Forced keybindings for say (T), me (M), ooc (O), looc (L) have been applied."))

	// Reset the xeno crit health alerts to default
	if(current_version < 43)
		WRITE_FILE(S["mute_xeno_health_alert_messages"], TRUE)
		mute_xeno_health_alert_messages = TRUE
		to_chat(parent, span_userdanger("Preferences for Mute xeno health alert messages have been reverted to default settings; these are now muted. Go into Preferences and set Mute xeno health alert messages to No if you wish to get xeno critical health alerts."))

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

	if(savefile_version == 43)
		var/datum/loadout_manager/manager = load_loadout_manager()
		if(istype(manager))
			loadout_manager.loadouts_data = convert_loadouts_list(manager?.loadouts_data)

	if(savefile_version < 45) // merged sound_tts_blips and sound_tts
		var/used_blips = FALSE
		READ_FILE(S["sound_tts_blips"], used_blips)
		var/used_tts = TRUE
		READ_FILE(S["sound_tts"], used_tts)
		var/new_val = TTS_SOUND_ENABLED
		if(!used_tts)
			new_val = TTS_SOUND_OFF
		else if(used_blips)
			new_val = TTS_SOUND_BLIPS
		WRITE_FILE(S["sound_tts"], new_val)
		sound_tts = new_val


	savefile_version = SAVEFILE_VERSION_MAX
	save_preferences()
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
			save_keybinds()
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
	READ_FILE(S["fullscreen_mode"], fullscreen_mode)
	READ_FILE(S["show_typing"], show_typing)
	READ_FILE(S["ghost_hud"], ghost_hud)
	READ_FILE(S["windowflashing"], windowflashing)
	READ_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	READ_FILE(S["widescreenpref"], widescreenpref)
	READ_FILE(S["pixel_size"], pixel_size)
	READ_FILE(S["scaling_method"], scaling_method)
	READ_FILE(S["menuoptions"], menuoptions)
	READ_FILE(S["ghost_vision"], ghost_vision)
	READ_FILE(S["ghost_orbit"], ghost_orbit)
	READ_FILE(S["ghost_form"], ghost_form)
	READ_FILE(S["ghost_others"], ghost_others)
	READ_FILE(S["clientfps"], clientfps)
	READ_FILE(S["parallax"], parallax)
	READ_FILE(S["tooltips"], tooltips)
	READ_FILE(S["sound_tts"], sound_tts)
	READ_FILE(S["volume_tts"], volume_tts)
	READ_FILE(S["fast_mc_refresh"], fast_mc_refresh)
	READ_FILE(S["split_admin_tabs"], split_admin_tabs)

	READ_FILE(S["key_bindings"], key_bindings)
	READ_FILE(S["custom_emotes"], custom_emotes)
	READ_FILE(S["chem_macros"], chem_macros)

	READ_FILE(S["mute_self_combat_messages"], mute_self_combat_messages)
	READ_FILE(S["mute_others_combat_messages"], mute_others_combat_messages)
	READ_FILE(S["mute_xeno_health_alert_messages"], mute_xeno_health_alert_messages)

	// Runechat options
	READ_FILE(S["chat_on_map"], chat_on_map)
	READ_FILE(S["max_chat_length"], max_chat_length)
	READ_FILE(S["see_chat_non_mob"], see_chat_non_mob)
	READ_FILE(S["see_rc_emotes"], see_rc_emotes)

	// Tgui options
	READ_FILE(S["tgui_fancy"], tgui_fancy)
	READ_FILE(S["tgui_lock"], tgui_lock)
	READ_FILE(S["tgui_input"], tgui_input)
	READ_FILE(S["tgui_input_big_buttons"], tgui_input_big_buttons)
	READ_FILE(S["tgui_input_buttons_swap"], tgui_input_buttons_swap)

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	default_slot = sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor = sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor))
	be_special = sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	ui_style = sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color = sanitize_hexcolor(ui_style_color, 6, TRUE, initial(ui_style_color))
	ui_style_alpha = sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat = sanitize_integer(toggles_chat, NONE, MAX_BITFLAG, initial(toggles_chat))
	toggles_sound = sanitize_integer(toggles_sound, NONE, MAX_BITFLAG, initial(toggles_sound))
	toggles_gameplay = sanitize_integer(toggles_gameplay, NONE, MAX_BITFLAG, initial(toggles_gameplay))
	fullscreen_mode = sanitize_integer(fullscreen_mode, FALSE, TRUE, initial(fullscreen_mode))
	show_typing = sanitize_integer(show_typing, FALSE, TRUE, initial(show_typing))
	ghost_hud = sanitize_integer(ghost_hud, NONE, MAX_BITFLAG, initial(ghost_hud))
	windowflashing = sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	auto_fit_viewport = sanitize_integer(auto_fit_viewport, FALSE, TRUE, initial(auto_fit_viewport))
	widescreenpref = sanitize_integer(widescreenpref, FALSE, TRUE, initial(widescreenpref))
	pixel_size = sanitize_float(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, 0.5, initial(pixel_size))
	scaling_method = sanitize_text(scaling_method, initial(scaling_method))
	ghost_vision = sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit = sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form = sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others = sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	clientfps = sanitize_integer(clientfps, 0, 240, initial(clientfps))
	parallax = sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	tooltips = sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))
	sound_tts = sanitize_inlist(sound_tts, GLOB.all_tts_options, initial(sound_tts))
	volume_tts = sanitize_integer(volume_tts, 1, 100, initial(volume_tts))

	key_bindings = sanitize_islist(key_bindings, list())
	custom_emotes = sanitize_is_full_emote_list(custom_emotes)
	chem_macros = sanitize_islist(chem_macros, list())
	quick_equip = sanitize_islist(quick_equip, QUICK_EQUIP_ORDER, MAX_QUICK_EQUIP_SLOTS, TRUE, VALID_EQUIP_SLOTS)
	slot_draw_order_pref = sanitize_islist(slot_draw_order_pref, SLOT_DRAW_ORDER, length(SLOT_DRAW_ORDER), TRUE, SLOT_DRAW_ORDER)

	mute_self_combat_messages = sanitize_integer(mute_self_combat_messages, FALSE, TRUE, initial(mute_self_combat_messages))
	mute_others_combat_messages = sanitize_integer(mute_others_combat_messages, FALSE, TRUE, initial(mute_others_combat_messages))
	mute_xeno_health_alert_messages = sanitize_integer(mute_xeno_health_alert_messages, FALSE, TRUE, initial(mute_xeno_health_alert_messages))

	chat_on_map = sanitize_integer(chat_on_map, FALSE, TRUE, initial(chat_on_map))
	max_chat_length = sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	see_chat_non_mob = sanitize_integer(see_chat_non_mob, FALSE, TRUE, initial(see_chat_non_mob))
	see_rc_emotes = sanitize_integer(see_rc_emotes, FALSE, TRUE, initial(see_rc_emotes))

	tgui_fancy = sanitize_integer(tgui_fancy, FALSE, TRUE, initial(tgui_fancy))
	tgui_lock = sanitize_integer(tgui_fancy, FALSE, TRUE, initial(tgui_lock))
	tgui_input = sanitize_integer(tgui_input, FALSE, TRUE, initial(tgui_input))
	tgui_input_big_buttons = sanitize_integer(tgui_input_big_buttons, FALSE, TRUE, initial(tgui_input_big_buttons))
	tgui_input_buttons_swap = sanitize_integer(tgui_input_buttons_swap, FALSE, TRUE, initial(tgui_input_buttons_swap))

	fast_mc_refresh = sanitize_integer(fast_mc_refresh, FALSE, TRUE, initial(fast_mc_refresh))
	split_admin_tabs = sanitize_integer(split_admin_tabs, FALSE, TRUE, initial(split_admin_tabs))
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
		to_chat(parent, span_warning("Writing to the savefile failed, please try again."))
		return FALSE

	WRITE_FILE(S["version"], savefile_version)

	default_slot = sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor = sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor))

	ui_style = sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color = sanitize_hexcolor(ui_style_color, 6, TRUE, initial(ui_style_color))
	ui_style_alpha = sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat = sanitize_integer(toggles_chat, NONE, MAX_BITFLAG, initial(toggles_chat))
	toggles_sound = sanitize_integer(toggles_sound, NONE, MAX_BITFLAG, initial(toggles_sound))
	toggles_gameplay = sanitize_integer(toggles_gameplay, NONE, MAX_BITFLAG, initial(toggles_gameplay))
	fullscreen_mode = sanitize_integer(fullscreen_mode, FALSE, TRUE, initial(fullscreen_mode))
	show_typing = sanitize_integer(show_typing, FALSE, TRUE, initial(show_typing))
	ghost_hud = sanitize_integer(ghost_hud, NONE, MAX_BITFLAG, initial(ghost_hud))
	windowflashing = sanitize_integer(windowflashing, FALSE, TRUE, initial(windowflashing))
	auto_fit_viewport = sanitize_integer(auto_fit_viewport, FALSE, TRUE, initial(auto_fit_viewport))
	widescreenpref = sanitize_integer(widescreenpref, FALSE, TRUE, initial(widescreenpref))
	pixel_size = sanitize_float(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, 0.5, initial(pixel_size))
	scaling_method = sanitize_text(scaling_method, initial(scaling_method))
	chem_macros = sanitize_islist(chem_macros, list())
	ghost_vision = sanitize_integer(ghost_vision, FALSE, TRUE, initial(ghost_vision))
	ghost_orbit = sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_form = sanitize_inlist_assoc(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_others = sanitize_inlist(ghost_others, GLOB.ghost_others_options, initial(ghost_others))
	clientfps = sanitize_integer(clientfps, 0, 240, initial(clientfps))
	parallax = sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	tooltips = sanitize_integer(tooltips, FALSE, TRUE, initial(tooltips))
	sound_tts = sanitize_inlist(sound_tts, GLOB.all_tts_options, initial(sound_tts))
	volume_tts = sanitize_integer(volume_tts, 1, 100, initial(volume_tts))

	mute_self_combat_messages = sanitize_integer(mute_self_combat_messages, FALSE, TRUE, initial(mute_self_combat_messages))
	mute_others_combat_messages = sanitize_integer(mute_others_combat_messages, FALSE, TRUE, initial(mute_others_combat_messages))
	mute_xeno_health_alert_messages = sanitize_integer(mute_xeno_health_alert_messages, FALSE, TRUE, initial(mute_xeno_health_alert_messages))

	// Runechat
	chat_on_map = sanitize_integer(chat_on_map, FALSE, TRUE, initial(chat_on_map))
	max_chat_length = sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	see_chat_non_mob = sanitize_integer(see_chat_non_mob, FALSE, TRUE, initial(see_chat_non_mob))
	see_rc_emotes = sanitize_integer(see_rc_emotes, FALSE, TRUE, initial(see_rc_emotes))

	tgui_fancy = sanitize_integer(tgui_fancy, FALSE, TRUE, initial(tgui_fancy))
	tgui_lock = sanitize_integer(tgui_fancy, FALSE, TRUE, initial(tgui_lock))
	tgui_input = sanitize_integer(tgui_input, FALSE, TRUE, initial(tgui_input))
	tgui_input_big_buttons = sanitize_integer(tgui_input_big_buttons, FALSE, TRUE, initial(tgui_input_big_buttons))
	tgui_input_buttons_swap = sanitize_integer(tgui_input_buttons_swap, FALSE, TRUE, initial(tgui_input_buttons_swap))

	// Admin
	fast_mc_refresh = sanitize_integer(fast_mc_refresh, FALSE, TRUE, initial(fast_mc_refresh))
	split_admin_tabs = sanitize_integer(split_admin_tabs, FALSE, TRUE, initial(split_admin_tabs))

	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["ooccolor"], ooccolor)

	WRITE_FILE(S["ui_style"], ui_style)
	WRITE_FILE(S["ui_style_color"], ui_style_color)
	WRITE_FILE(S["ui_style_alpha"], ui_style_alpha)

	WRITE_FILE(S["toggles_chat"], toggles_chat)
	WRITE_FILE(S["toggles_sound"], toggles_sound)
	WRITE_FILE(S["toggles_gameplay"], toggles_gameplay)
	WRITE_FILE(S["fullscreen_mode"], fullscreen_mode)
	WRITE_FILE(S["show_typing"], show_typing)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["windowflashing"], windowflashing)
	WRITE_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	WRITE_FILE(S["widescreenpref"], widescreenpref)
	WRITE_FILE(S["pixel_size"], pixel_size)
	WRITE_FILE(S["scaling_method"], scaling_method)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["chem_macros"], chem_macros)
	WRITE_FILE(S["ghost_vision"], ghost_vision)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["clientfps"], clientfps)
	WRITE_FILE(S["parallax"], parallax)
	WRITE_FILE(S["tooltips"], tooltips)
	WRITE_FILE(S["sound_tts"], sound_tts)
	WRITE_FILE(S["volume_tts"], volume_tts)

	WRITE_FILE(S["mute_self_combat_messages"], mute_self_combat_messages)
	WRITE_FILE(S["mute_others_combat_messages"], mute_others_combat_messages)
	WRITE_FILE(S["mute_xeno_health_alert_messages"], mute_xeno_health_alert_messages)

	// Runechat options
	WRITE_FILE(S["chat_on_map"], chat_on_map)
	WRITE_FILE(S["max_chat_length"], max_chat_length)
	WRITE_FILE(S["see_chat_non_mob"], see_chat_non_mob)
	WRITE_FILE(S["see_rc_emotes"], see_rc_emotes)

	// Tgui options
	WRITE_FILE(S["tgui_fancy"], tgui_fancy)
	WRITE_FILE(S["tgui_lock"], tgui_lock)
	WRITE_FILE(S["tgui_input"], tgui_input)
	WRITE_FILE(S["tgui_input_big_buttons"], tgui_input_big_buttons)
	WRITE_FILE(S["tgui_input_buttons_swap"], tgui_input_buttons_swap)

	// Admin options
	WRITE_FILE(S["fast_mc_refresh"], fast_mc_refresh)
	WRITE_FILE(S["split_admin_tabs"], split_admin_tabs)

	return TRUE

/datum/preferences/proc/save_keybinds()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	key_bindings = sanitize_islist(key_bindings, list())
	custom_emotes = sanitize_is_full_emote_list(custom_emotes)
	WRITE_FILE(S["key_bindings"], key_bindings)
	WRITE_FILE(S["custom_emotes"], custom_emotes)

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
	READ_FILE(S["robot_type"], robot_type)
	READ_FILE(S["xeno_name"], xeno_name)
	READ_FILE(S["ai_name"], ai_name)

	READ_FILE(S["real_name"], real_name)
	READ_FILE(S["random_name"], random_name)
	READ_FILE(S["gender"], gender)
	READ_FILE(S["age"], age)
	READ_FILE(S["species"], species)
	READ_FILE(S["ethnicity"], ethnicity)
	READ_FILE(S["good_eyesight"], good_eyesight)
	READ_FILE(S["preferred_squad"], preferred_squad)
	READ_FILE(S["preferred_squad_som"], preferred_squad_som)
	READ_FILE(S["alternate_option"], alternate_option)
	READ_FILE(S["job_preferences"], job_preferences)
	READ_FILE(S["quick_equip"], quick_equip)
	READ_FILE(S["gear"], gear)
	READ_FILE(S["underwear"], underwear)
	READ_FILE(S["undershirt"], undershirt)
	READ_FILE(S["backpack"], backpack)

	READ_FILE(S["h_style"], h_style)
	READ_FILE(S["r_hair"], r_hair)
	READ_FILE(S["g_hair"], g_hair)
	READ_FILE(S["b_hair"], b_hair)

	READ_FILE(S["grad_style"], grad_style)
	READ_FILE(S["r_grad"], r_grad)
	READ_FILE(S["g_grad"], g_grad)
	READ_FILE(S["b_grad"], b_grad)

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

	READ_FILE(S["tts_voice"], tts_voice)
	READ_FILE(S["tts_pitch"], tts_pitch)

	READ_FILE(S["med_record"], med_record)
	READ_FILE(S["sec_record"], sec_record)
	READ_FILE(S["gen_record"], gen_record)
	READ_FILE(S["exploit_record"], exploit_record)
	READ_FILE(S["flavor_text"], flavor_text)


	be_special = sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	synthetic_name = reject_bad_name(synthetic_name, TRUE)
	synthetic_type = sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))
	robot_type = sanitize_inlist(robot_type, ROBOT_TYPES, initial(robot_type))
	xeno_name = reject_bad_name(xeno_name)
	ai_name = reject_bad_name(ai_name, TRUE)

	real_name = reject_bad_name(real_name, TRUE)
	random_name = sanitize_integer(random_name, TRUE, TRUE, initial(random_name))
	gender = sanitize_gender(gender, TRUE, TRUE)
	age = sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	species = sanitize_inlist(species, GLOB.all_species, initial(species))
	ethnicity = sanitize_ethnicity(ethnicity)
	good_eyesight = sanitize_integer(good_eyesight, FALSE, TRUE, initial(good_eyesight))
	preferred_squad = sanitize_inlist(preferred_squad, SELECTABLE_SQUADS, initial(preferred_squad))
	preferred_squad_som = sanitize_inlist(preferred_squad_som, SELECTABLE_SQUADS_SOM, initial(preferred_squad_som))
	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_preferences = SANITIZE_LIST(job_preferences)
	quick_equip = sanitize_islist(quick_equip, QUICK_EQUIP_ORDER, MAX_QUICK_EQUIP_SLOTS, TRUE, VALID_EQUIP_SLOTS)
	slot_draw_order_pref = sanitize_islist(slot_draw_order_pref, SLOT_DRAW_ORDER, length(SLOT_DRAW_ORDER), TRUE, SLOT_DRAW_ORDER)
	for(var/quick_equip_slots in quick_equip)
		quick_equip_slots = sanitize_inlist(quick_equip_slots, SLOT_DRAW_ORDER[quick_equip], quick_equip_slots)
	gear = sanitize_islist(gear, default = list(), check_valid = TRUE, possible_input_list = GLOB.gear_datums)
	if(gender == MALE)
		underwear = sanitize_integer(underwear, 1, length(GLOB.underwear_m), initial(underwear))
		undershirt = sanitize_integer(undershirt, 1, length(GLOB.undershirt_m), initial(undershirt))
	else
		underwear = sanitize_integer(underwear, 1, length(GLOB.underwear_f), initial(underwear))
		undershirt = sanitize_integer(undershirt, 1, length(GLOB.undershirt_f), initial(undershirt))
	backpack = sanitize_integer(backpack, 1, length(GLOB.backpacklist), initial(backpack))

	h_style = sanitize_inlist(h_style, GLOB.hair_styles_list, initial(h_style))
	r_hair = sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair = sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair = sanitize_integer(b_hair, 0, 255, initial(b_hair))

	grad_style = sanitize_inlist(grad_style, GLOB.hair_gradients_list, initial(grad_style))
	r_grad = sanitize_integer(r_grad, 0, 255, initial(r_grad))
	g_grad = sanitize_integer(g_grad, 0, 255, initial(g_grad))
	b_grad = sanitize_integer(b_grad, 0, 255, initial(b_grad))

	f_style = sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))
	r_facial = sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial = sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial = sanitize_integer(b_facial, 0, 255, initial(b_facial))

	r_eyes = sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes = sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes = sanitize_integer(b_eyes, 0, 255, initial(b_eyes))

	moth_wings = sanitize_inlist(moth_wings, GLOB.moth_wings_list, initial(moth_wings))

	citizenship = sanitize_inlist(citizenship, CITIZENSHIP_CHOICES, initial(citizenship))
	religion = sanitize_inlist(religion, RELIGION_CHOICES, initial(religion))

	tts_voice = sanitize_inlist_tts(tts_voice)
	tts_pitch = sanitize_integer(tts_pitch, -12, 12, initial(tts_pitch))

	med_record = sanitize_text(med_record, initial(med_record))
	sec_record = sanitize_text(sec_record, initial(sec_record))
	gen_record = sanitize_text(gen_record, initial(gen_record))
	exploit_record = sanitize_text(exploit_record, initial(exploit_record))
	flavor_text = sanitize_text(flavor_text, initial(flavor_text))

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
		to_chat(parent, span_warning("Writing to the savefile failed, please try again."))
		return FALSE

	be_special = sanitize_integer(be_special, NONE, MAX_BITFLAG, initial(be_special))

	synthetic_name = reject_bad_name(synthetic_name, TRUE)
	synthetic_type = sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))
	robot_type = sanitize_inlist(robot_type, ROBOT_TYPES, initial(robot_type))
	xeno_name = reject_bad_name(xeno_name)
	ai_name = reject_bad_name(ai_name, TRUE)

	real_name = reject_bad_name(real_name, TRUE)
	random_name = sanitize_integer(random_name, FALSE, TRUE, initial(random_name))
	gender = sanitize_gender(gender, TRUE, TRUE)
	age = sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	species = sanitize_inlist(species, GLOB.all_species, initial(species))
	ethnicity = sanitize_ethnicity(ethnicity)
	good_eyesight = sanitize_integer(good_eyesight, FALSE, TRUE, initial(good_eyesight))
	preferred_squad = sanitize_inlist(preferred_squad, SELECTABLE_SQUADS, initial(preferred_squad))
	preferred_squad_som = sanitize_inlist(preferred_squad_som, SELECTABLE_SQUADS_SOM, initial(preferred_squad_som))
	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_preferences = SANITIZE_LIST(job_preferences)
	quick_equip = sanitize_islist(quick_equip, QUICK_EQUIP_ORDER, MAX_QUICK_EQUIP_SLOTS, TRUE, VALID_EQUIP_SLOTS)
	for(var/quick_equip_slots in quick_equip)
		quick_equip_slots = sanitize_inlist(quick_equip_slots, SLOT_DRAW_ORDER[quick_equip], quick_equip_slots)
	slot_draw_order_pref = sanitize_islist(slot_draw_order_pref, SLOT_DRAW_ORDER, length(SLOT_DRAW_ORDER), TRUE, SLOT_DRAW_ORDER)
	if(gender == MALE)
		underwear = sanitize_integer(underwear, 1, length(GLOB.underwear_m), initial(underwear))
		undershirt = sanitize_integer(undershirt, 1, length(GLOB.undershirt_m), initial(undershirt))
	else
		underwear = sanitize_integer(underwear, 1, length(GLOB.underwear_f), initial(underwear))
	undershirt = sanitize_integer(undershirt, 1, length(GLOB.undershirt_f), initial(undershirt))
	backpack = sanitize_integer(backpack, 1, length(GLOB.backpacklist), initial(backpack))

	h_style = sanitize_inlist(h_style, GLOB.hair_styles_list, initial(h_style))
	r_hair = sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair = sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair = sanitize_integer(b_hair, 0, 255, initial(b_hair))

	grad_style = sanitize_inlist(grad_style, GLOB.hair_gradients_list, initial(grad_style))
	r_grad = sanitize_integer(r_grad, 0, 255, initial(r_grad))
	g_grad = sanitize_integer(g_grad, 0, 255, initial(g_grad))
	b_grad = sanitize_integer(b_grad, 0, 255, initial(b_grad))

	f_style = sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))
	r_facial = sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial = sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial = sanitize_integer(b_facial, 0, 255, initial(b_facial))

	r_eyes = sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes = sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes = sanitize_integer(b_eyes, 0, 255, initial(b_eyes))

	moth_wings = sanitize_inlist(moth_wings, GLOB.moth_wings_list, initial(moth_wings))

	citizenship = sanitize_inlist(citizenship, CITIZENSHIP_CHOICES, initial(citizenship))
	religion = sanitize_inlist(religion, RELIGION_CHOICES, initial(religion))

	tts_voice = sanitize_inlist_tts(tts_voice)
	tts_pitch = sanitize_integer(tts_pitch, -12, 12, initial(tts_pitch))

	med_record = sanitize_text(med_record, initial(med_record))
	sec_record = sanitize_text(sec_record, initial(sec_record))
	gen_record = sanitize_text(gen_record, initial(gen_record))
	exploit_record = sanitize_text(exploit_record, initial(exploit_record))
	flavor_text = sanitize_text(flavor_text, initial(flavor_text))

	WRITE_FILE(S["be_special"], be_special)

	WRITE_FILE(S["synthetic_name"], synthetic_name)
	WRITE_FILE(S["synthetic_type"], synthetic_type)
	WRITE_FILE(S["robot_type"], robot_type)
	WRITE_FILE(S["xeno_name"], xeno_name)
	WRITE_FILE(S["ai_name"], ai_name)

	WRITE_FILE(S["real_name"], real_name)
	WRITE_FILE(S["random_name"], random_name)
	WRITE_FILE(S["gender"], gender)
	WRITE_FILE(S["age"], age)
	WRITE_FILE(S["species"], species)
	WRITE_FILE(S["ethnicity"], ethnicity)
	WRITE_FILE(S["good_eyesight"], good_eyesight)
	WRITE_FILE(S["preferred_squad"], preferred_squad)
	WRITE_FILE(S["preferred_squad_som"], preferred_squad_som)
	WRITE_FILE(S["alternate_option"], alternate_option)
	WRITE_FILE(S["job_preferences"], job_preferences)
	WRITE_FILE(S["quick_equip"], quick_equip)
	WRITE_FILE(S["gear"], gear)
	WRITE_FILE(S["underwear"], underwear)
	WRITE_FILE(S["undershirt"], undershirt)
	WRITE_FILE(S["backpack"], backpack)

	WRITE_FILE(S["h_style"], h_style)
	WRITE_FILE(S["r_hair"], r_hair)
	WRITE_FILE(S["g_hair"], g_hair)
	WRITE_FILE(S["b_hair"], b_hair)

	WRITE_FILE(S["grad_style"], grad_style)
	WRITE_FILE(S["r_grad"], r_grad)
	WRITE_FILE(S["g_grad"], g_grad)
	WRITE_FILE(S["b_grad"], b_grad)

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

	WRITE_FILE(S["tts_voice"], tts_voice)
	WRITE_FILE(S["tts_pitch"], tts_pitch)

	WRITE_FILE(S["med_record"], med_record)
	WRITE_FILE(S["sec_record"], sec_record)
	WRITE_FILE(S["gen_record"], gen_record)
	WRITE_FILE(S["exploit_record"], exploit_record)
	WRITE_FILE(S["flavor_text"], flavor_text)

	return TRUE

///Save a loadout into the savefile
/datum/preferences/proc/save_loadout(datum/loadout/loadout)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	loadout.loadout_vendor = null
	var/loadout_json = jatum_serialize(loadout)
	WRITE_FILE(S["[loadout.name + loadout.job]"], loadout_json)
	return TRUE

///Delete a loadout from the savefile
/datum/preferences/proc/delete_loadout(loadout_name, loadout_job)
	if(!path)
		return
	if(!fexists(path))
		return
	var/savefile/S = new /savefile(path)
	if(!S)
		return
	S.cd = "/loadouts"
	WRITE_FILE(S["[loadout_name + loadout_job]"], "")

///Load a loadout from the savefile and returns it
/datum/preferences/proc/load_loadout(loadout_name, loadout_job)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	var/loadout_json = ""
	READ_FILE(S["[loadout_name + loadout_job]"], loadout_json)
	if(!loadout_json)
		return FALSE
	var/datum/loadout/loadout = jatum_deserialize(loadout_json)
	return loadout

///Save the loadout list
/datum/preferences/proc/save_loadout_list(loadouts_data, loadout_version)
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	loadouts_data = sanitize_islist(loadouts_data, list())
	WRITE_FILE(S["loadouts_list"], loadouts_data)
	WRITE_FILE(S["loadout_version"], loadout_version)
	return TRUE

///Load the loadout list
/datum/preferences/proc/load_loadout_list()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	var/loadout_version = 0
	READ_FILE(S["loadout_version"], loadout_version)

	var/list/loadouts_data = list()
	READ_FILE(S["loadouts_list"], loadouts_data)
	return sanitize_islist(loadouts_data, list())

/**
 * Load from a savefile and unserialize the loadout manager
 * This is deprecated and should be used only to convert old loadout list save system to new one
 */
/datum/preferences/proc/load_loadout_manager()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/loadouts"
	var/json_loadout_manager = ""
	READ_FILE(S["loadouts_manager"], json_loadout_manager)
	if(!json_loadout_manager)
		return FALSE
	var/datum/loadout_manager/manager = jatum_deserialize(json_loadout_manager)
	return manager


///Erase all loadouts that could be saved on the savefile
/datum/preferences/proc/reset_loadouts_file()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.dir.Remove("loadouts")

/datum/preferences/proc/save()
	return (save_preferences() && save_character() && save_keybinds())


/datum/preferences/proc/load()
	return (load_preferences() && load_character())
