/datum/preferences/proc/randomize_appearance_for(mob/living/carbon/human/H)
	if(H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE

	ethnicity = random_ethnicity()
	body_type = random_body_type()

	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)
	randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_eyes_color()
	randomize_species_specific()
	underwear = rand(1, GLOB.underwear_m.len)
	undershirt = rand(1, GLOB.undershirt_t.len)
	backpack = 2
	age = rand(AGE_MIN,AGE_MAX)
	if(H)
		copy_to(H, TRUE)


/datum/preferences/proc/randomize_hair_color(target = "hair")
	if(prob (75) && target == "facial")
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/red
	var/green
	var/blue

	switch(pick(15;"black", 15;"grey", 15;"brown", 15;"lightbrown", 5;"white", 15;"blonde", 10;"red"))
		if("black")
			red = 10
			green = 10
			blue = 10
		if("grey")
			red = 50
			green = 50
			blue = 50
		if("brown")
			red = 70
			green = 35
			blue = 0
		if("lightbrown")
			red = 100
			green = 50
			blue = 0
		if("white")
			red = 235
			green = 235
			blue = 235
		if("blonde")
			red = 240
			green = 240
			blue = 0
		if("red")
			red = 128
			green = 0
			blue = 0

	red = CLAMP(red + rand(-25, 25), 0, 255)
	green = CLAMP(green + rand(-25, 25), 0, 255)
	blue = CLAMP(blue + rand(-25, 25), 0, 255)

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	switch(pick(15;"black", 15;"green", 15;"brown", 15;"blue", 15;"lightblue", 5;"red"))
		if("black")
			red = 10
			green = 10
			blue = 10
		if("green")
			red = 200
			green = 0
			blue = 0
		if("brown")
			red = 100
			green = 50
			blue = 0
		if("blue")
			red = 0
			green = 0
			blue = 200
		if("lightblue")
			red = 0
			green = 150
			blue = 255
		if("red")
			red = 220
			green = 0
			blue = 0

	red = CLAMP(red + rand(-25, 25), 0, 255)
	green = CLAMP(green + rand(-25, 25), 0, 255)
	blue = CLAMP(blue + rand(-25, 25), 0, 255)

	r_eyes = red
	g_eyes = green
	b_eyes = blue


/datum/preferences/proc/update_preview_icon()
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = JOBS_PRIORITY_NEVER
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin)

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = parent)

	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)


/datum/preferences/proc/randomize_species_specific()
	moth_wings = pick(GLOB.moth_wings_list - "Burnt Off")


/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = FALSE)
	if(random_name)
		var/datum/species/S = GLOB.all_species[species]
		real_name = S.random_name(gender)


	if(CONFIG_GET(flag/humans_need_surnames) && species == "Human")
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace || firstspace == name_length)
			real_name += " " + pick(GLOB.last_names)

	character.real_name = real_name
	character.name = character.real_name

	character.flavor_text = flavor_text

	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record
	character.exploit_record = exploit_record

	character.age = age
	character.gender = gender
	character.ethnicity = ethnicity
	character.body_type = body_type

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.h_style = h_style
	character.f_style = f_style

	character.citizenship = citizenship
	character.religion = religion

	character.moth_wings = moth_wings
	character.underwear = underwear
	character.undershirt = undershirt
	character.backpack = backpack

	character.update_body()
	character.update_hair()


/datum/preferences/proc/random_character()
	gender = pick(MALE, FEMALE)
	var/datum/species/S = GLOB.all_species[DEFAULT_SPECIES]
	real_name = S.random_name(gender)
	age = rand(AGE_MIN, AGE_MAX)
	h_style = pick("Crewcut", "Bald", "Short Hair")