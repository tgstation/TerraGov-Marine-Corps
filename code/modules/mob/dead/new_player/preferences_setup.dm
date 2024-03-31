
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override, antag_override = FALSE)
	if(randomise[RANDOM_SPECIES])
		random_species()
	else if(randomise[RANDOM_NAME])
		real_name = pref_species.random_name(gender,1)
	if(!pref_species)
		random_species()
	if(gender_override && !(randomise[RANDOM_GENDER] || randomise[RANDOM_GENDER_ANTAG] && antag_override))
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	if(randomise[RANDOM_AGE] || randomise[RANDOM_AGE_ANTAG] && antag_override)
		age = AGE_ADULT
	if(randomise[RANDOM_UNDERWEAR])
		underwear = pref_species.random_underwear(gender)
	if(randomise[RANDOM_UNDERWEAR_COLOR])
		underwear_color = random_short_color()
	if(randomise[RANDOM_UNDERSHIRT])
		undershirt = random_undershirt(gender)
	if(randomise[RANDOM_SOCKS])
		socks = random_socks()
	if(randomise[RANDOM_BACKPACK])
		backpack = random_backpack()
	if(randomise[RANDOM_JUMPSUIT_STYLE])
		jumpsuit_style = pick(GLOB.jumpsuitlist)
	if(randomise[RANDOM_HAIRSTYLE])
		hairstyle = pref_species.random_hairstyle(gender)
	if(randomise[RANDOM_FACIAL_HAIRSTYLE])
		facial_hairstyle = pref_species.random_facial_hairstyle(gender)
	if(randomise[RANDOM_HAIR_COLOR])
		var/list/hairs
		if(age == AGE_OLD && OLDGREY in pref_species.species_traits)
			hairs = pref_species.get_oldhc_list()
		else
			hairs = pref_species.get_hairc_list()
		hair_color = hairs[pick(hairs)]
		facial_hair_color = hair_color
	if(randomise[RANDOM_FACIAL_HAIR_COLOR])
		var/list/hairs
		if(age == AGE_OLD && OLDGREY in pref_species.species_traits)
			hairs = pref_species.get_oldhc_list()
		else
			hairs = pref_species.get_hairc_list()
		hair_color = hairs[pick(hairs)]
		facial_hair_color = hair_color
	if(randomise[RANDOM_SKIN_TONE])
		var/list/skins = pref_species.get_skin_list()
		skin_tone = skins[pick(skins)]
	if(randomise[RANDOM_EYE_COLOR])
		eye_color = random_eye_color()
	features = random_features()
	if(pref_species.default_features["ears"])
		features["ears"] = pref_species.default_features["ears"]
	for(var/X in GLOB.horns_list.Copy())
		var/datum/sprite_accessory/S = GLOB.horns_list[X]
		if(!(pref_species in S.specuse))
			continue
		if(S.gender == NEUTER)
			features["horns"] = X
			break
		if(gender == S.gender)
			features["horns"] = X
			break
	for(var/X in GLOB.tails_list_human.Copy())
		var/datum/sprite_accessory/S = GLOB.tails_list_human[X]
		if(!(pref_species in S.specuse))
			continue
		if(S.gender == NEUTER)
			features["tail_human"] = X
			break
		if(gender == S.gender)
			features["tail_human"] = X
			break
	accessory = "Nothing"

/datum/preferences/proc/random_species()
	var/random_species_type = GLOB.species_list[pick(GLOB.roundstart_races)]
	pref_species = new random_species_type
	if(randomise[RANDOM_NAME])
		real_name = pref_species.random_name(gender,1)

/datum/preferences/proc/update_preview_icon()
	set waitfor = 0
	if(!parent)
		return
	if(parent.is_new_player())
		return
//	last_preview_update = world.time
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = SOUTH))
			return
		if(istype(previewJob,/datum/job/cyborg))
			parent.show_character_previews(image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH))
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin, 1, TRUE, TRUE)

	if(previewJob)
		testing("previewjob")
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = parent)

	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)


/datum/preferences/proc/spec_check(mob/user)
	if(!(pref_species.name in GLOB.roundstart_races))
		return FALSE
	if(user)
		if(pref_species.patreon_req > user.patreonlevel())
			return FALSE
	return TRUE

/mob/proc/patreonlevel()
	if(client)
		return client.patreonlevel()