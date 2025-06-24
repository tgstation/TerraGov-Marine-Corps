/datum/species/human
	name = "Human"
	unarmed_type = /datum/unarmed_attack/punch
	species_flags = HAS_LIPS|HAS_UNDERWEAR
	count_human = TRUE
	limb_type = SPECIES_LIMB_HUMAN

	screams = list(MALE = SFX_MALE_SCREAM, FEMALE = SFX_FEMALE_SCREAM)
	paincries = list(MALE = SFX_MALE_PAIN, FEMALE = SFX_FEMALE_PAIN)
	goredcries = list(MALE = SFX_MALE_GORED, FEMALE = SFX_FEMALE_GORED)
	gasps = list(MALE = SFX_MALE_GASP, FEMALE = SFX_FEMALE_GASP)
	coughs = list(MALE = SFX_MALE_COUGH, FEMALE = SFX_FEMALE_COUGH)
	burstscreams = list(MALE = SFX_MALE_PREBURST, FEMALE = SFX_FEMALE_PREBURST)
	warcries = list(MALE = SFX_MALE_WARCRY, FEMALE = SFX_FEMALE_WARCRY)
	special_death_message = "<big>You have perished.</big><br><small>But it is not the end of you yet... if you still have your body with your head still attached, wait until somebody can resurrect you...</small>"
	joinable_roundstart = TRUE

/datum/species/human/prefs_name(datum/preferences/prefs)
	. = ..()
	if(CONFIG_GET(flag/humans_need_surnames))
		var/firstspace = findtext(., " ")
		if(!firstspace || firstspace == length(.))
			. += " " + pick(SSstrings.get_list_from_file("names/last_name"))
