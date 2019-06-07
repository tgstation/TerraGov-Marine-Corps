/mob/living/carbon/xenomorph/shrike
	caste_base_type = /mob/living/carbon/xenomorph/shrike
	name = "Shrike"
	desc = "A large, lanky alien creature. It seems psychically unstable."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = FALSE
	health = 240
	maxHealth = 240
	plasma_stored = 300
	speed = -0.2
	pixel_x = -16
	old_x = -16
	drag_delay = 3 //pulling a medium dead xeno is hard
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	xeno_explosion_resistance = 2 //some resistance against explosion stuns.
	job = ROLE_XENO_QUEEN
	var/calling_larvas = FALSE
	var/using_psychic_choke = FALSE
	var/last_choke_change = 0 //Time

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/lay_egg,
		/datum/action/xeno_action/call_of_the_burrowed,
		/datum/action/xeno_action/choose_resin,
		/datum/action/xeno_action/activable/secrete_resin,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/activable/psychic_fling,
		/datum/action/xeno_action/activable/psychic_choke,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/shrike/Initialize()
	. = ..()
	if(is_centcom_level(z))//so admins can safely spawn queens in Thunderdome for tests.
		return
	if(!hive.living_xeno_shrike)
		hive.living_xeno_shrike = src
	if(!hive.living_xeno_ruler)
		hive.update_ruler()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/shrike/handle_decay()
	if(prob(20+abs(3*upgrade_as_number())))
		use_plasma(min(rand(1,2), plasma_stored))


// ***************************************
// *********** Name
// ***************************************
/mob/living/carbon/xenomorph/shrike/generate_name()
	name = "[hive.prefix][xeno_caste.upgrade_name] [xeno_caste.display_name]" //No number, shrikes are unique.

	//Update linked data so they show up properly
	real_name = name
	if(mind)
		mind.name = name


// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/shrike/stop_pulling()
	if(isliving(pulling))
		var/mob/living/L = pulling
		grab_resist_level = 0 //zero it out
		L.SetStunned(0)
	return ..()


/mob/living/carbon/xenomorph/shrike/start_pulling(atom/movable/AM, lunge, no_msg)
	if(!check_state() || !isliving(AM))
		return FALSE

	var/mob/living/L = AM

	if(ishuman(L) && using_psychic_choke)
		if(..(L, TRUE))
			return neck_grab(L)
		return FALSE

	return ..()


/mob/living/carbon/xenomorph/shrike/proc/neck_grab(mob/living/L)
	grab_level = GRAB_NECK
	L.drop_all_held_items()
	L.Stun(1)
	return TRUE


/mob/living/carbon/xenomorph/shrike/pull_power(atom/movable/grabbed_thing)
	if(!using_psychic_choke)
		return FALSE

	if(last_choke_change + 3 SECONDS > world.time)
		return FALSE
	last_choke_change = world.time

	playsound(grabbed_thing.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

	var/obj/item/grab/G = get_active_held_item()
	if(!G) //Somehow we stopped grabbing.
		return FALSE

	switch(grab_level)
		if(GRAB_NECK)
			grab_level = GRAB_KILL
			G.icon_state = "disarm/kill"
			log_combat(src, grabbed_thing, "psychically strangled", addition="(kill intent)")
			msg_admin_attack("[key_name(src)] psychically strangled (kill intent) [key_name(grabbed_thing)]")
			to_chat(src, "<span class='danger'>We tighten our psychic grip on [grabbed_thing]'s neck!</span>")
			grabbed_thing.visible_message("<span class='danger'>The invisible force has tightened its grip on [grabbed_thing]'s neck!</span>", null, null, 5)
		if(GRAB_KILL)
			grab_level = GRAB_KILL
			G.icon_state = "disarm/kill1"
			log_combat(src, grabbed_thing, "neck grabbed")
			msg_admin_attack("[key_name(src)] grabbed the neck of [key_name(grabbed_thing)]")
			to_chat(src, "<span class='warning'>We loosen our psychic grip on [grabbed_thing]'s neck!</span>")
			grabbed_thing.visible_message("<span class='warning'>The invisible force has loosened its grip on [grabbed_thing]'s neck...</span>", null, null, 5)