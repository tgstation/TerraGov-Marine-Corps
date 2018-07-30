#define SAVEFILE_VERSION_MIN	8
#define SAVEFILE_VERSION_MAX	12

//handles converting savefiles to new formats
//MAKE SURE YOU KEEP THIS UP TO DATE!
//If the sanity checks are capable of handling any issues. Only increase SAVEFILE_VERSION_MAX,
//this will mean that savefile_version will still be over SAVEFILE_VERSION_MIN, meaning
//this savefile update doesn't run everytime we load from the savefile.
//This is mainly for format changes, such as the bitflags in toggles changing order or something.
//if a file can't be updated, return 0 to delete it and start again
//if a file was updated, return 1
/datum/preferences/proc/savefile_update(savefile/S)
	if(!isnum(savefile_version) || savefile_version < SAVEFILE_VERSION_MIN)	//lazily delete everything + additional files so they can be saved in the new format
		for(var/ckey in preferences_datums)
			var/datum/preferences/D = preferences_datums[ckey]
			if(D == src)
				var/delpath = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/"
				if(delpath && fexists(delpath))
					fdel(delpath)
				break
		return 0

	if(savefile_version < 12) //we've split toggles into toggles_sound and toggles_chat
//		if(S["toggles"])
//			cdel(S["toggles"])
		S["toggles_chat"] << TOGGLES_SOUND_DEFAULT
		S["toggles_chat"] << TOGGLES_CHAT_DEFAULT

	savefile_version = SAVEFILE_VERSION_MAX
	return 1

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)	return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"
	savefile_version = SAVEFILE_VERSION_MAX

/datum/preferences/proc/load_preferences()
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] >> savefile_version
	//Conversion
	if(!savefile_version || !isnum(savefile_version) || savefile_version != SAVEFILE_VERSION_MAX)
		if(!savefile_update(S))  //handles updates
			savefile_version = SAVEFILE_VERSION_MAX
			save_preferences()
			save_character()
			return 0

	//general preferences
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	S["be_special"]			>> be_special
	S["default_slot"]		>> default_slot
	S["toggles_chat"]		>> toggles_chat
	S["toggles_sound"]		>> toggles_sound
	S["UI_style_color"]		>> UI_style_color
	S["UI_style_alpha"]		>> UI_style_alpha

	S["synth_name"]			>> synthetic_name
	S["synth_type"]			>> synthetic_type
	S["pred_name"]			>> predator_name
	S["pred_gender"]		>> predator_gender
	S["pred_age"]			>> predator_age
	S["pred_mask_type"]		>> predator_mask_type
	S["pred_armor_type"]	>> predator_armor_type
	S["pred_boot_type"]		>> predator_boot_type

	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight","Orange","old"), initial(UI_style))
	be_special		= sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles_chat	= sanitize_integer(toggles_chat, 0, 65535, initial(toggles_chat))
	toggles_sound	= sanitize_integer(toggles_sound, 0, 65535, initial(toggles_sound))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))

	synthetic_name 		= synthetic_name ? sanitize_text(synthetic_name, initial(synthetic_name)) : initial(synthetic_name)
	synthetic_type		= sanitize_text(synthetic_type, initial(synthetic_type))
	predator_name 		= predator_name ? sanitize_text(predator_name, initial(predator_name)) : initial(predator_name)
	predator_gender 	= sanitize_text(predator_gender, initial(predator_gender))
	predator_age 		= sanitize_integer(predator_age, 100, 10000, initial(predator_age))
	predator_mask_type 	= sanitize_integer(predator_mask_type,1,1000000,initial(predator_mask_type))
	predator_armor_type = sanitize_integer(predator_armor_type,1,1000000,initial(predator_armor_type))
	predator_boot_type 	= sanitize_integer(predator_boot_type,1,1000000,initial(predator_boot_type))

	return 1

/datum/preferences/proc/save_preferences()
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] << savefile_version

	//general preferences
	S["ooccolor"]			<< ooccolor
	S["lastchangelog"]		<< lastchangelog
	S["UI_style"]			<< UI_style
	S["be_special"]			<< be_special
	S["default_slot"]		<< default_slot
	S["toggles_chat"]		<< toggles_chat
	S["toggles_sound"]		<< toggles_sound

	S["synth_name"] 		<< synthetic_name
	S["synth_type"]			<< synthetic_type
	S["pred_name"] 			<< predator_name
	S["pred_gender"] 		<< predator_gender
	S["pred_age"]			<< predator_age
	S["pred_mask_type"] 	<< predator_mask_type
	S["pred_armor_type"] 	<< predator_armor_type
	S["pred_boot_type"] 	<< predator_boot_type

	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"
	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot
	S.cd = "/character[slot]"

	//Character
	S["OOC_Notes"]			>> metadata
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["gender"]				>> gender
	S["age"]				>> age
	S["ethnicity"]			>> ethnicity
	S["body_type"]			>> body_type
	S["language"]			>> language
	S["spawnpoint"]			>> spawnpoint

	//colors to be consolidated into hex strings (requires some work with dna code)
	S["hair_red"]			>> r_hair
	S["hair_green"]			>> g_hair
	S["hair_blue"]			>> b_hair
	S["facial_red"]			>> r_facial
	S["facial_green"]		>> g_facial
	S["facial_blue"]		>> b_facial
	S["skin_red"]			>> r_skin
	S["skin_green"]			>> g_skin
	S["skin_blue"]			>> b_skin
	S["hair_style_name"]	>> h_style
	S["facial_style_name"]	>> f_style
	S["eyes_red"]			>> r_eyes
	S["eyes_green"]			>> g_eyes
	S["eyes_blue"]			>> b_eyes
	S["underwear"]			>> underwear
	S["undershirt"]			>> undershirt
	S["backbag"]			>> backbag
	//S["b_type"]				>> b_type

	//Jobs
	S["alternate_option"]	>> alternate_option
	S["job_command_high"]	>> job_command_high
	S["job_command_med"]	>> job_command_med
	S["job_command_low"]	>> job_command_low
	S["job_medsci_high"]	>> job_medsci_high
	S["job_medsci_med"]		>> job_medsci_med
	S["job_medsci_low"]		>> job_medsci_low
	S["job_engi_high"]		>> job_engi_high
	S["job_engi_med"]		>> job_engi_med
	S["job_engi_low"]		>> job_engi_low
	S["job_marines_high"]	>> job_marines_high
	S["job_marines_med"]	>> job_marines_med
	S["job_marines_low"]	>> job_marines_low

	//Flavour Text
	S["flavor_texts_general"]	>> flavor_texts["general"]
	S["flavor_texts_head"]		>> flavor_texts["head"]
	S["flavor_texts_face"]		>> flavor_texts["face"]
	S["flavor_texts_eyes"]		>> flavor_texts["eyes"]
	S["flavor_texts_torso"]		>> flavor_texts["torso"]
	S["flavor_texts_arms"]		>> flavor_texts["arms"]
	S["flavor_texts_hands"]		>> flavor_texts["hands"]
	S["flavor_texts_legs"]		>> flavor_texts["legs"]
	S["flavor_texts_feet"]		>> flavor_texts["feet"]

	//Miscellaneous
	S["med_record"]			>> med_record
	S["sec_record"]			>> sec_record
	S["gen_record"]			>> gen_record
	S["be_special"]			>> be_special
	S["disabilities"]		>> disabilities
	S["player_alt_titles"]	>> player_alt_titles
	S["used_skillpoints"]	>> used_skillpoints
	S["skills"]				>> skills
	S["skill_specialization"] >> skill_specialization
	S["organ_data"]			>> organ_data
	S["gear"]				>> gear
	S["home_system"] 		>> home_system
	S["citizenship"] 		>> citizenship
	S["faction"] 			>> faction
	S["religion"] 			>> religion

	S["preferred_squad"]		>> preferred_squad
	S["nanotrasen_relation"] 	>> nanotrasen_relation
	//S["skin_style"]			>> skin_style

	S["uplinklocation"] >> uplinklocation
	S["exploit_record"]	>> exploit_record

	S["UI_style_color"]		>> UI_style_color
	S["UI_style_alpha"]		>> UI_style_alpha

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)

	if(isnull(language)) language = "None"
	if(isnull(spawnpoint)) spawnpoint = "Arrivals Shuttle"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(!real_name) real_name = random_name(gender)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	ethnicity		= sanitize_ethnicity(ethnicity)
	body_type		= sanitize_body_type(body_type)
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	r_skin			= sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin			= sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin			= sanitize_integer(b_skin, 0, 255, initial(b_skin))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	undershirt		= sanitize_integer(undershirt, 1, undershirt_t.len, initial(undershirt))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	//b_type			= sanitize_text(b_type, initial(b_type))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_command_high = sanitize_integer(job_command_high, 0, 65535, initial(job_command_high))
	job_command_med = sanitize_integer(job_command_med, 0, 65535, initial(job_command_med))
	job_command_low = sanitize_integer(job_command_low, 0, 65535, initial(job_command_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engi_high = sanitize_integer(job_engi_high, 0, 65535, initial(job_engi_high))
	job_engi_med = sanitize_integer(job_engi_med, 0, 65535, initial(job_engi_med))
	job_engi_low = sanitize_integer(job_engi_low, 0, 65535, initial(job_engi_low))
	job_marines_high = sanitize_integer(job_marines_high, 0, 65535, initial(job_marines_high))
	job_marines_med = sanitize_integer(job_marines_med, 0, 65535, initial(job_marines_med))
	job_marines_low = sanitize_integer(job_marines_low, 0, 65535, initial(job_marines_low))

	if(!skills) skills = list()
	if(!used_skillpoints) used_skillpoints= 0
	if(isnull(disabilities)) disabilities = 0
	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()
	if(!gear) src.gear = list()
	//if(!skin_style) skin_style = "Default"

	if(!home_system) home_system = "Unset"
	if(!citizenship) citizenship = "None"
	if(!faction)     faction =     "None"
	if(!religion)    religion =    "None"
	if(!preferred_squad)	preferred_squad = "None"

	return 1

/datum/preferences/proc/save_character()
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/character[default_slot]"

	//Character
	S["OOC_Notes"]			<< metadata
	S["real_name"]			<< real_name
	S["name_is_always_random"] << be_random_name
	S["gender"]				<< gender
	S["age"]				<< age
	S["ethnicity"]			<< ethnicity
	S["body_type"]			<< body_type
	S["language"]			<< language
	S["hair_red"]			<< r_hair
	S["hair_green"]			<< g_hair
	S["hair_blue"]			<< b_hair
	S["facial_red"]			<< r_facial
	S["facial_green"]		<< g_facial
	S["facial_blue"]		<< b_facial
	S["skin_red"]			<< r_skin
	S["skin_green"]			<< g_skin
	S["skin_blue"]			<< b_skin
	S["hair_style_name"]	<< h_style
	S["facial_style_name"]	<< f_style
	S["eyes_red"]			<< r_eyes
	S["eyes_green"]			<< g_eyes
	S["eyes_blue"]			<< b_eyes
	S["underwear"]			<< underwear
	S["undershirt"]			<< undershirt
	S["backbag"]			<< backbag
	//S["b_type"]				<< b_type
	S["spawnpoint"]			<< spawnpoint

	//Jobs
	S["alternate_option"]	<< alternate_option
	S["job_command_high"]	<< job_command_high
	S["job_command_med"]	<< job_command_med
	S["job_command_low"]	<< job_command_low
	S["job_medsci_high"]	<< job_medsci_high
	S["job_medsci_med"]		<< job_medsci_med
	S["job_medsci_low"]		<< job_medsci_low
	S["job_engi_high"]		<< job_engi_high
	S["job_engi_med"]		<< job_engi_med
	S["job_engi_low"]		<< job_engi_low
	S["job_marines_high"]	<< job_marines_high
	S["job_marines_med"]	<< job_marines_med
	S["job_marines_low"]	<< job_marines_low

	//Flavour Text
	S["flavor_texts_general"]	<< flavor_texts["general"]
	S["flavor_texts_head"]		<< flavor_texts["head"]
	S["flavor_texts_face"]		<< flavor_texts["face"]
	S["flavor_texts_eyes"]		<< flavor_texts["eyes"]
	S["flavor_texts_torso"]		<< flavor_texts["torso"]
	S["flavor_texts_arms"]		<< flavor_texts["arms"]
	S["flavor_texts_hands"]		<< flavor_texts["hands"]
	S["flavor_texts_legs"]		<< flavor_texts["legs"]
	S["flavor_texts_feet"]		<< flavor_texts["feet"]

	//Miscellaneous
	S["med_record"]			<< med_record
	S["sec_record"]			<< sec_record
	S["gen_record"]			<< gen_record
	S["player_alt_titles"]		<< player_alt_titles
	S["be_special"]			<< be_special
	S["disabilities"]		<< disabilities
	S["used_skillpoints"]	<< used_skillpoints
	S["skills"]				<< skills
	S["skill_specialization"] << skill_specialization
	S["organ_data"]			<< organ_data
	S["gear"]				<< gear
	S["home_system"] 		<< home_system
	S["citizenship"] 		<< citizenship
	S["faction"] 			<< faction
	S["religion"] 			<< religion

	S["nanotrasen_relation"] 	<< nanotrasen_relation
	S["preferred_squad"]		<< preferred_squad
	//S["skin_style"]			<< skin_style

	S["uplinklocation"] << uplinklocation
	S["exploit_record"]	<< exploit_record

	S["UI_style_color"]		<< UI_style_color
	S["UI_style_alpha"]		<< UI_style_alpha

	return 1


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
