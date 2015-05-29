//Xenomorph - Larva - Colonial Marines - Apophis775 - Last Edit: 24JAN2015
//Nope, added stuff by Abby - including Update Icons

/mob/living/carbon/Xenomorph/Larva
	name = "Alien Larva"
	real_name = "Alien Larva"
	speak_emote = list("hisses")
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
	caste = "Bloody Larva"
	icon_state = "Bloody Larva"
	language = "Hivemind"
	amount_grown = 0
	max_grown = 200
	maxHealth = 25
	health = 25
	plasma_gain = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	evolves_to = list("Drone", "Runner", "Sentinel") //Add sentinel etc here
	can_slash = 0
	see_in_dark = 20
	caste_desc = "D'awwwww, so cute!"
	pass_flags = PASSTABLE
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/xenohide,
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
	if(!isnull(src.loc))
		if(locate(/obj/effect/alien/weeds) in loc)
			amount_grown++ //Double growth on weeds.
	return

/mob/living/carbon/Xenomorph/Larva/update_icons()
	var/state = "Bloody"
	if(amount_grown > 150)
		state = "Normal"
	else if(amount_grown > 50)
		state = "Normal"

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
