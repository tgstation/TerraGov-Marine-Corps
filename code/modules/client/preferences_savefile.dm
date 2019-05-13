#define SAVEFILE_VERSION_MIN	20
#define SAVEFILE_VERSION_MAX	22

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
		S["windowflashing"]	<< TRUE

	savefile_version = SAVEFILE_VERSION_MAX
	return TRUE


/datum/preferences/proc/load_path(ckey, filename = "preferences.sav")
	ckey = ckey(ckey)
	if(!ckey)
		return
	path = "data/player_saves/[copytext(ckey, 1, 2)]/[ckey]/[filename]"

	if(savefile_version < 21)
		muted << NOFLAGS

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

	S["version"] >> savefile_version
	if(!savefile_version || !isnum(savefile_version) || savefile_version != SAVEFILE_VERSION_MAX)
		if(!savefile_update(S))
			savefile_version = SAVEFILE_VERSION_MAX
			save_preferences()
			save_character()
			return FALSE

	S["default_slot"]		>> default_slot
	S["lastchangelog"]		>> lastchangelog
	S["ooccolor"]			>> ooccolor

	S["ui_style"]			>> ui_style
	S["ui_style_color"]		>> ui_style_color
	S["ui_style_alpha"]		>> ui_style_alpha

	S["toggles_chat"]		>> toggles_chat
	S["toggles_sound"]		>> toggles_sound
	S["show_typing"]		>> show_typing
	S["ghost_hud"]			>> ghost_hud
	S["windowflashing"]		>> windowflashing

	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	be_special		= sanitize_integer(be_special, 0, 8388608, initial(be_special))

	ui_style		= sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color	= sanitize_hexcolor(ui_style_color, initial(ui_style_color))
	ui_style_alpha	= sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat	= sanitize_integer(toggles_chat, 0, 8388608, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, 0, 8388608, initial(toggles_sound))
	show_typing		= sanitize_integer(show_typing, 0, 1, initial(show_typing))
	ghost_hud 		= sanitize_integer(ghost_hud, 0, 8388608, initial(ghost_hud))
	windowflashing	= sanitize_integer(windowflashing, 0, 1, initial(windowflashing))

	return TRUE


/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE

	S.cd = "/"
	S["version"] << savefile_version

	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))

	ui_style		= sanitize_inlist(ui_style, UI_STYLES, initial(ui_style))
	ui_style_color	= sanitize_hexcolor(ui_style_color, initial(ui_style_color))
	ui_style_alpha	= sanitize_integer(ui_style_alpha, 0, 255, initial(ui_style_alpha))

	toggles_chat	= sanitize_integer(toggles_chat, 0, 8388608, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, 0, 8388608, initial(toggles_sound))
	show_typing		= sanitize_integer(show_typing, 0, 1, initial(show_typing))
	ghost_hud 		= sanitize_integer(ghost_hud, 0, 8388608, initial(ghost_hud))
	windowflashing	= sanitize_integer(windowflashing, 0, 1, initial(windowflashing))

	S["default_slot"]		<< default_slot
	S["lastchangelog"]		<< lastchangelog
	S["ooccolor"]			<< ooccolor

	S["ui_style"]			<< ui_style
	S["ui_style_color"]		<< ui_style_color
	S["ui_style_alpha"]		<< ui_style_alpha

	S["toggles_chat"]		<< toggles_chat
	S["toggles_sound"]		<< toggles_sound
	S["show_typing"]		<< show_typing
	S["ghost_hud"]			<< ghost_hud
	S["windowflashing"]		<< windowflashing

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
		S["default_slot"] << slot
	S.cd = "/character[slot]"

	S["be_special"]			>> be_special

	S["synthetic_name"]		>> synthetic_name
	S["synthetic_type"]		>> synthetic_type

	S["xeno_name"]			>> xeno_name

	S["real_name"]			>> real_name
	S["random_name"]		>> random_name
	S["gender"]				>> gender
	S["age"]				>> age
	S["species"]			>> species
	S["ethnicity"]			>> ethnicity
	S["body_type"]			>> body_type
	S["good_eyesight"]		>> good_eyesight
	S["preferred_squad"]	>> preferred_squad
	S["alternate_option"]	>> alternate_option
	S["jobs_high"]			>> jobs_high
	S["jobs_medium"]		>> jobs_medium
	S["jobs_low"]			>> jobs_low
	S["preferred_slot"] 	>> preferred_slot
	S["gear"]				>> gear
	S["underwear"]			>> underwear
	S["undershirt"]			>> undershirt
	S["backpack"]			>> backpack

	S["h_style"]			>> h_style
	S["r_hair"]				>> r_hair
	S["g_hair"]				>> g_hair
	S["b_hair"]				>> b_hair

	S["f_style"]			>> f_style
	S["r_facial"]			>> r_facial
	S["g_facial"]			>> g_facial
	S["b_facial"]			>> b_facial

	S["r_eyes"]				>> r_eyes
	S["g_eyes"]				>> g_eyes
	S["b_eyes"]				>> b_eyes

	S["moth_wings"]			>> moth_wings

	S["citizenship"] 		>> citizenship
	S["religion"] 			>> religion
	S["nanotrasen_relation"]>> nanotrasen_relation

	S["med_record"]			>> med_record
	S["sec_record"]			>> sec_record
	S["gen_record"]			>> gen_record
	S["exploit_record"]		>> exploit_record
	S["metadata"]			>> metadata
	S["flavor_text"]		>> flavor_text


	be_special		= sanitize_integer(be_special, 0, 8388608, initial(be_special))

	synthetic_name	= reject_bad_name(synthetic_name)
	synthetic_type	= sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))

	xeno_name		= reject_bad_name(xeno_name)

	real_name		= reject_bad_name(real_name)
	random_name		= sanitize_integer(random_name, 0, 1, initial(random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	species			= sanitize_inlist(species, GLOB.all_species, initial(species))
	ethnicity		= sanitize_ethnicity(ethnicity)
	body_type		= sanitize_body_type(body_type)
	good_eyesight	= sanitize_integer(good_eyesight, 0, 1, initial(good_eyesight))
	preferred_squad	= sanitize_inlist(preferred_squad, SELECTABLE_SQUADS, initial(preferred_squad))
	alternate_option= sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	jobs_high 		= sanitize_integer(jobs_high, 0, 8388608, initial(jobs_high))
	jobs_medium 	= sanitize_integer(jobs_medium, 0, 8388608, initial(jobs_medium))
	jobs_low 		= sanitize_integer(jobs_low, 0, 8388608, initial(jobs_low))
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
	metadata		= sanitize_text(metadata, initial(metadata))
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

	be_special		= sanitize_integer(be_special, 0, 8388608, initial(be_special))

	synthetic_name	= reject_bad_name(synthetic_name)
	synthetic_type	= sanitize_inlist(synthetic_type, SYNTH_TYPES, initial(synthetic_type))

	xeno_name		= reject_bad_name(xeno_name)

	real_name		= reject_bad_name(real_name)
	random_name		= sanitize_integer(random_name, 0, 1, initial(random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	species			= sanitize_inlist(species, GLOB.all_species, initial(species))
	ethnicity		= sanitize_ethnicity(ethnicity)
	body_type		= sanitize_body_type(body_type)
	good_eyesight	= sanitize_integer(good_eyesight, 0, 1, initial(good_eyesight))
	preferred_squad	= sanitize_inlist(preferred_squad, SELECTABLE_SQUADS, initial(preferred_squad))
	alternate_option= sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	jobs_high 		= sanitize_integer(jobs_high, 0, 8388608, initial(jobs_high))
	jobs_medium 	= sanitize_integer(jobs_medium, 0, 8388608, initial(jobs_medium))
	jobs_low 		= sanitize_integer(jobs_low, 0, 8388608, initial(jobs_low))
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
	metadata		= sanitize_text(metadata, initial(metadata))
	flavor_text		= sanitize_text(flavor_text, initial(flavor_text))

	S["be_special"]			<< be_special

	S["synthetic_name"]		<< synthetic_name
	S["synthetic_type"]		<< synthetic_type

	S["xeno_name"]			<< xeno_name

	S["real_name"]			<< real_name
	S["random_name"]		<< random_name
	S["gender"]				<< gender
	S["age"]				<< age
	S["species"]			<< species
	S["ethnicity"]			<< ethnicity
	S["body_type"]			<< body_type
	S["good_eyesight"]		<< good_eyesight
	S["preferred_squad"]	<< preferred_squad
	S["alternate_option"]	<< alternate_option
	S["jobs_high"]			<< jobs_high
	S["jobs_medium"]		<< jobs_medium
	S["jobs_low"]			<< jobs_low
	S["preferred_slot"] 	<< preferred_slot
	S["gear"]				<< gear
	S["underwear"]			<< underwear
	S["undershirt"]			<< undershirt
	S["backpack"]			<< backpack

	S["h_style"]			<< h_style
	S["r_hair"]				<< r_hair
	S["g_hair"]				<< g_hair
	S["b_hair"]				<< b_hair

	S["f_style"]			<< f_style
	S["r_facial"]			<< r_facial
	S["g_facial"]			<< g_facial
	S["b_facial"]			<< b_facial

	S["r_eyes"]				<< r_eyes
	S["g_eyes"]				<< g_eyes
	S["b_eyes"]				<< b_eyes

	S["moth_wings"]			<< moth_wings

	S["citizenship"] 		<< citizenship
	S["religion"] 			<< religion
	S["nanotrasen_relation"]<< nanotrasen_relation

	S["med_record"]			<< med_record
	S["sec_record"]			<< sec_record
	S["gen_record"]			<< gen_record
	S["exploit_record"]		<< exploit_record
	S["metadata"]			<< metadata
	S["flavor_text"]		<< flavor_text

	return TRUE


/datum/preferences/proc/save()
	save_preferences()
	save_character()
	

/datum/preferences/proc/load()
	load_preferences()
	load_character()