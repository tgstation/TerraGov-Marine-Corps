//Xenomorph - Larva - Colonial Marines - Apophis775 - Last Edit: 24JAN2015
//Nope, added stuff by Abby - including Update Icons

/mob/living/carbon/Xenomorph/Larva
	name = "Alien Larva"
	real_name = "Alien Larva"
	speak_emote = list("hisses")
	caste = "Bloody Larva"
	icon_state = "Bloody Larva"
	language = "Hivemind"
	amount_grown = 0
	max_grown = 100
	maxHealth = 35
	health = 35
	plasma_gain = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	evolves_to = list("Drone", "Runner", "Sentinel") //Add sentinel etc here
	see_in_dark = 8
	caste_desc = "D'awwwww, so cute!"
	pass_flags = PASSTABLE
	speed = -1.2 //Zoom!
	away_timer = 300
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/Larva/proc/xenohide,
		/mob/living/carbon/Xenomorph/proc/vent_crawl
		)

/mob/living/carbon/Xenomorph/Larva/Stat()
	..()
	if(istype(src,/mob/living/carbon/Xenomorph/Larva))
		stat(null, "Progress: [amount_grown]/[max_grown]")

//Larva Progression.. Most of this stuff is obsolete.
/mob/living/carbon/Xenomorph/Larva/update_progression()
	..()
	if(amount_grown < max_grown)
		amount_grown++
	if(!isnull(src.loc) && amount_grown < max_grown)
		if(locate(/obj/effect/alien/weeds) in loc)
			amount_grown++ //Double growth on weeds.
	return

/mob/living/carbon/Xenomorph/Larva/update_icons()
	var/state = "Bloody"
	if(amount_grown > 150)
		state = "Normal"
	else if(amount_grown > 50)
		state = "Normal"
	if(state == "Normal" && amount_grown < 100)
		name = "Larva ([nicknumber])"
	else if(amount_grown >=100)
		name = "Mature Larva ([nicknumber])"

	if(stat == DEAD)
		icon_state = "[state] Larva Dead"
	else if (handcuffed || legcuffed)
		icon_state = "[state] Larva Cuff"
	else if (stunned)
		icon_state = "[state] Larva Stunned"
	else if(lying || resting)
		icon_state = "[state] Larva Sleeping"
	else
		icon_state = "[state] Larva"

/mob/living/carbon/Xenomorph/Larva/proc/xenohide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"
	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot do this in your current state."
		return
	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\blue You are now hiding.")
	else
		layer = MOB_LAYER
		src << text("\blue You have stopped hiding.")
	return
