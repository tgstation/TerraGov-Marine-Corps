//Xenomorph - Larva - Colonial Marines - Apophis775 - Last Edit: 11JUN16


/mob/living/carbon/Xenomorph/Larva
	name = "Bloody Larva"
	caste = "Bloody Larva"
	speak_emote = list("hisses")
	icon_state = "Bloody Larva"
	amount_grown = 0
	max_grown = 100
	maxHealth = 35
	health = 35
	plasma_gain = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	evolves_to = list("Drone", "Runner", "Sentinel", "Defender") //Add sentinel etc here
	see_in_dark = 8
	caste_desc = "D'awwwww, so cute!"
	flags_pass = PASSTABLE | PASSMOB
	speed = -1.6 //Zoom!
	away_timer = 300
	tier = 0  //Larva's don't count towards Pop limits
	upgrade = -1
	crit_health = -25
	gib_chance = 25
	innate_healing = TRUE //heals even outside weeds so you're not stuck unable to evolve when hiding on the ship wounded.
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl
		)

/mob/living/carbon/Xenomorph/Larva/predalien
	icon_state = "Predalien Larva"
	caste = "Predalien Larva"
	evolves_to = list("Predalien")

/mob/living/carbon/Xenomorph/Larva/UnarmedAttack(atom/A)
	a_intent = "help" //Forces help intent for all interactions.
	. = ..()

/mob/living/carbon/Xenomorph/Larva/Stat()
	if (!..())
		return 0

	stat(null, "Progress: [amount_grown]/[max_grown]")
	return 1


//Larva Progression.. Most of this stuff is obsolete.
/mob/living/carbon/Xenomorph/Larva/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	if(!isnull(src.loc) && amount_grown < max_grown)
		if(locate(/obj/effect/alien/weeds) in loc)
			amount_grown++ //Double growth on weeds.


//Larva code is just a mess, so let's get it over with
/mob/living/carbon/Xenomorph/Larva/update_icons()

	var/progress = "" //Naming convention, three different names
	var/state = "" //Icon convention, two different sprite sets

	var/name_prefix = ""

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else
		hivenumber = XENO_HIVE_NORMAL
		hive = hive_datum[hivenumber]

	name_prefix = hive.prefix
	color = hive.color
	if(name_prefix == "Corrupted ")
		add_language("English")
	else
		remove_language("English") // its hacky doing it here sort of

	switch(amount_grown)
		if(0 to 49) //We're still bloody
			progress = "Bloody "
			state = "Bloody "
		if(50 to 99)
			progress = ""
			state = ""
		if(100 to INFINITY)
			progress = "Mature "

	name = "\improper [name_prefix][progress]Larva ([nicknumber])"

	if(istype(src,/mob/living/carbon/Xenomorph/Larva/predalien)) state = "Predalien " //Sort of a hack.

	//Update linked data so they show up properly
	real_name = name
	if(mind)
		mind.name = name //This gives them the proper name in deadchat if they explode on death. It's always the small things

	if(stat == DEAD)
		icon_state = "[state]Larva Dead"
	else if(handcuffed || legcuffed)
		icon_state = "[state]Larva Cuff"

	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "[state]Larva Sleeping"
		else
			icon_state = "[state]Larva Stunned"
	else
		icon_state = "[state]Larva"

/mob/living/carbon/Xenomorph/Larva/start_pulling(atom/movable/AM)
	return

/mob/living/carbon/Xenomorph/Larva/pull_response(mob/puller)
	return TRUE
