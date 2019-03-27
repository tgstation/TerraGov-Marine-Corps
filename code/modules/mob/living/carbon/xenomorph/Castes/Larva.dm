/datum/xeno_caste/larva
	caste_name = "Bloody Larva"
	display_name = "Bloody Larva"
	upgrade_name = ""
	caste_desc = "D'awwwww, so cute!"
	caste_type_path = /mob/living/carbon/Xenomorph/Larva
	tier = XENO_TIER_ZERO
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 0
	melee_damage_upper = 0

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_gain = 1

	// *** Health *** //
	max_health = 35
	crit_health = -25

	// *** Evolution *** //
	evolves_to = list(/mob/living/carbon/Xenomorph/Drone, /mob/living/carbon/Xenomorph/Runner, /mob/living/carbon/Xenomorph/Sentinel, /mob/living/carbon/Xenomorph/Defender)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_INNATE_HEALING|CASTE_DECAY_PROOF

/datum/xeno_caste/larva/young
	upgrade = XENO_UPGRADE_INVALID

/mob/living/carbon/Xenomorph/Larva
	caste_base_type = /mob/living/carbon/Xenomorph/Larva
	speak_emote = list("hisses")
	icon_state = "Bloody Larva"
	amount_grown = 0
	max_grown = 100
	maxHealth = 35
	health = 35
	see_in_dark = 8
	flags_pass = PASSTABLE | PASSMOB
	away_timer = XENO_AFK_TIMER
	tier = XENO_TIER_ZERO  //Larva's don't count towards Pop limits
	upgrade = XENO_UPGRADE_INVALID
	gib_chance = 25
	wound_type = "alien" //used to match appropriate wound overlays
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/xenohide,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl
		)

	var/base_icon_state = "Larva"

/mob/living/carbon/Xenomorph/Larva/UnarmedAttack(atom/A)
	a_intent = INTENT_HELP //Forces help intent for all interactions.
	. = ..()

/mob/living/carbon/Xenomorph/Larva/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Progress: [amount_grown]/[max_grown]")


//Larva Progression.. Most of this stuff is obsolete.
/mob/living/carbon/Xenomorph/Larva/update_progression()
	if(amount_grown < max_grown)
		amount_grown++
	if(!isnull(src.loc) && amount_grown < max_grown)
		if(locate(/obj/effect/alien/weeds) in loc)
			amount_grown++ //Double growth on weeds.

/mob/living/carbon/Xenomorph/Larva/generate_name()
	var/progress = "" //Naming convention, three different names

	switch(amount_grown)
		if(0 to 49) //We're still bloody
			progress = "Bloody "
		if(100 to INFINITY)
			progress = "Mature "

	name = "\improper [hive.prefix][progress]Larva ([nicknumber])"

	//Update linked data so they show up properly
	real_name = name
	if(mind)
		mind.name = name //This gives them the proper name in deadchat if they explode on death. It's always the small things

/mob/living/carbon/Xenomorph/Larva/update_icons()
	generate_name()
	
	var/bloody = ""
	if(amount_grown < 50)
		bloody = "Bloody "

	color = hive.color

	if(stat == DEAD)
		icon_state = "[bloody][base_icon_state] Dead"
	else if(handcuffed || legcuffed)
		icon_state = "[bloody][base_icon_state] Cuff"

	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "[bloody][base_icon_state] Sleeping"
		else
			icon_state = "[bloody][base_icon_state] Stunned"
	else
		icon_state = "[bloody][base_icon_state]"

// predlarva dont have a bloody state
/mob/living/carbon/Xenomorph/Larva/predalien/update_icons()
	generate_name()

	color = hive.color

	if(stat == DEAD)
		icon_state = "[base_icon_state] Dead"
	else if(handcuffed || legcuffed)
		icon_state = "[base_icon_state] Cuff"

	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "[base_icon_state] Sleeping"
		else
			icon_state = "[base_icon_state] Stunned"
	else
		icon_state = "[base_icon_state]"

/mob/living/carbon/Xenomorph/Larva/start_pulling(atom/movable/AM)
	return

/mob/living/carbon/Xenomorph/Larva/pull_response(mob/puller)
	return TRUE
