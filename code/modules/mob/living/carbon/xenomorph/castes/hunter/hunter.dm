/mob/living/carbon/xenomorph/hunter
	caste_base_type = /mob/living/carbon/xenomorph/hunter
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hunter Running"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	var/stealth_delay = null
	var/last_stealth = null
	var/used_stealth = FALSE
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/activable/stealth,
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/hunter/Initialize()
	. = ..()
	RegisterSignal(src, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_ATTACK_BARRICADE,
		COMSIG_XENOMORPH_ATTACK_CLOSET,
		COMSIG_XENOMORPH_ATTACK_RAZORWIRE,
		COMSIG_XENOMORPH_ATTACK_BED,
		COMSIG_XENOMORPH_ATTACK_NEST,
		COMSIG_XENOMORPH_ATTACK_TABLE,
		COMSIG_XENOMORPH_ATTACK_RACK,
		COMSIG_XENOMORPH_ATTACK_SENTRY,
		COMSIG_XENOMORPH_ATTACK_M56_POST,
		COMSIG_XENOMORPH_ATTACK_M56,
		COMSIG_XENOMORPH_ATTACK_TANK,
		COMSIG_XENOMORPH_ATTACK_LIVING,
		COMSIG_XENOMORPH_DISARM_HUMAN,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_XENOMORPH_FIRE_BURNING), .proc/cancel_stealth)
	RegisterSignal(src, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/damage_taken)

// ***************************************
// *********** Mob override
// ***************************************
/mob/living/carbon/xenomorph/hunter/movement_delay()
	. = ..()
	if(stealth)
		handle_stealth_movement()

/mob/living/carbon/xenomorph/hunter/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Sneak Attack Multiplier: [sneak_bonus] / [HUNTER_SNEAKATTACK_MAX_MULTIPLIER]")

// ***************************************
// *********** Stealth overrides
// ***************************************
/mob/living/carbon/xenomorph/hunter/proc/damage_taken(mob/living/carbon/xenomorph/hunter/X, damage_taken)
	if(damage_taken > 15)
		cancel_stealth()

/mob/living/carbon/xenomorph/hunter/proc/handle_stealth_movement()
	//Initial stealth
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY) //We don't start out at max invisibility
		alpha = HUNTER_STEALTH_RUN_ALPHA //50% invisible
		return
	//Stationary stealth
	else if(last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY) //If we're standing still for 4 seconds we become almost completely invisible
		alpha = HUNTER_STEALTH_STILL_ALPHA //95% invisible
	//Walking stealth
	else if(m_intent == MOVE_INTENT_WALK)
		alpha = HUNTER_STEALTH_WALK_ALPHA //80% invisible
		use_plasma(HUNTER_STEALTH_WALK_PLASMADRAIN * 0.5)
		if(sneak_bonus < HUNTER_SNEAKATTACK_MAX_MULTIPLIER)
			sneak_bonus = round(min(sneak_bonus + HUNTER_SNEAKATTACK_WALK_INCREASE, 3.5), 0.01) //Recover sneak attack multiplier rapidly
			if(sneak_bonus >= HUNTER_SNEAKATTACK_MAX_MULTIPLIER)
				to_chat(src, "<span class='xenodanger'>Your sneak attack is now at maximum power.</span>")
	//Running stealth
	else
		alpha = HUNTER_STEALTH_RUN_ALPHA //50% invisible
		use_plasma(HUNTER_STEALTH_RUN_PLASMADRAIN * 0.5)
		sneak_bonus = round(max(sneak_bonus - HUNTER_SNEAKATTACK_RUN_REDUCTION, 1.25), 0.01) //Rapidly lose sneak attack damage while running and stealthed
	if(!plasma_stored)
		to_chat(src, "<span class='xenodanger'>You lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/mob/living/carbon/xenomorph/hunter/handle_status_effects()
	. = ..()
	handle_stealth()

/mob/living/carbon/xenomorph/hunter/proc/handle_stealth()
	if(!stealth_router(HANDLE_STEALTH_CHECK))
		return
	if(stat != CONSCIOUS || stealth == FALSE || lying || resting) //Can't stealth while unconscious/resting
		cancel_stealth()
		return
	//Initial stealth
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY) //We don't start out at max invisibility
		alpha = HUNTER_STEALTH_RUN_ALPHA
		return
	//Stationary stealth
	else if(last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY) //If we're standing still for 4 seconds we become almost completely invisible
		alpha = HUNTER_STEALTH_STILL_ALPHA
	//Walking stealth
	else if(m_intent == MOVE_INTENT_WALK)
		alpha = HUNTER_STEALTH_WALK_ALPHA
	//Running stealth
	else
		alpha = HUNTER_STEALTH_RUN_ALPHA
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!plasma_stored)
		to_chat(src, "<span class='xenodanger'>You lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/mob/living/carbon/xenomorph/hunter/stealth_router(code = 0)
	switch(code)
		if(HANDLE_STEALTH_CHECK)
			if(stealth)
				return TRUE
			else
				return FALSE
		if(HANDLE_SNEAK_ATTACK_CHECK)
			if(can_sneak_attack)
				return TRUE
			else
				return FALSE

/mob/living/carbon/xenomorph/hunter/handle_living_plasma_updates()
	var/turf/T = loc
	if(!T || !istype(T))
		return
	if(current_aura)
		plasma_stored -= 5
	if(plasma_stored == xeno_caste.plasma_max)
		return
	var/modifier = 1
	if(stealth && last_move_intent > world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		modifier = 0.0
	else
		modifier = 0.5
	if(locate(/obj/effect/alien/weeds) in T)
		plasma_stored += xeno_caste.plasma_gain * modifier
		if(recovery_aura)
			plasma_stored += round(xeno_caste.plasma_gain * recovery_aura * 0.25 * modifier) //Divided by four because it gets massive fast. 1 is equivalent to weed regen! Only the strongest pheromones should bypass weeds
	else if(!hive?.living_xeno_queen || hive.living_xeno_queen.loc.z == loc.z) //We only regenerate plasma off weeds while on the same Z level as the queen; if one's alive
		plasma_stored++
	if(plasma_stored > xeno_caste.plasma_max)
		plasma_stored = xeno_caste.plasma_max
	else if(plasma_stored < 0)
		plasma_stored = 0
		if(current_aura)
			current_aura = null
			to_chat(src, "<span class='warning'>You have ran out of plasma and stopped emitting pheromones.</span>")

	hud_set_plasma() //update plasma amount on the plasma mob_hud

// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/hunter/gib()

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	remains.icon_state = "Hunter Gibs"

	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.

	return ..()

/mob/living/carbon/xenomorph/hunter/apply_alpha_channel(var/image/I)
	I.alpha = src.alpha
	return I

/mob/living/carbon/xenomorph/hunter/gib_animation()
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, "Hunter Gibbed", icon)

