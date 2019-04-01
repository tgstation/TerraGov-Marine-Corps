/datum/preferences/proc/randomize_appearance_for(var/mob/living/carbon/human/H)
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
	if(!SSatoms.initialized)
		return // clothing wont work properly
		
	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin)

	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob


	for(var/datum/job/job in SSjob.occupations)
		if(!jobs_high)
			break
		if(job.prefflag == jobs_high)
			previewJob = job
			break

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE)
	COMPILE_OVERLAYS(mannequin)
	if(parent)
		parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)


/datum/preferences/proc/randomize_species_specific()
	moth_wings = pick(GLOB.moth_wings_list - "Burnt Off")
