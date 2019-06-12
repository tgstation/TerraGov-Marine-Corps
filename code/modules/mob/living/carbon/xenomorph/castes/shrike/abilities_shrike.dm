#define CALLING_BURROWED_DURATION 15 SECONDS

// ***************************************
// *********** Call of the Burrowed
// ***************************************
/datum/action/xeno_action/call_of_the_burrowed
	name = "Call of the Burrowed"
	action_icon_state = "larva_growth"
	cooldown_timer = 3 MINUTES
	keybind_signal = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED


/datum/action/xeno_action/call_of_the_burrowed/action_activate()
	var/mob/living/carbon/xenomorph/shrike/caller = owner
	ENABLE_BITFIELD(caller.shrike_flags, SHRIKE_FLAG_CALLING_LARVAS)

	caller.visible_message("<span class='xenowarning'>A strange buzzing hum starts to emanate from \the [caller]!</span>", \
	"<span class='xenowarning'>You call forth the larvas to rise from their slumber!</span>")
	notify_ghosts("\The <b>[caller]</b> is calling for the burrowed larvas to wake up!", enter_link = "join_larva=1", enter_text = "Join as Larva", source = caller, action = NOTIFY_JOIN_AS_LARVA)

	addtimer(CALLBACK(caller, /mob/living/carbon/xenomorph/shrike.proc/calling_larvas_end), CALLING_BURROWED_DURATION)

	add_cooldown()


/mob/living/carbon/xenomorph/shrike/proc/calling_larvas_end()
	DISABLE_BITFIELD(shrike_flags, SHRIKE_FLAG_CALLING_LARVAS)


// ***************************************
// *********** Psychic Fling
// ***************************************
/datum/action/xeno_action/activable/psychic_fling
	name = "Psychic Fling"
	action_icon_state = "fling"
	mechanics_text = "Knock a target flying up to 3 tiles. Ranged ability."
	cooldown_timer = 12 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_FLING


/datum/action/xeno_action/activable/psychic_fling/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>You gather enough mental strength to fling something again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_fling/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE
	var/mob/living/carbon/xenomorph/shrike/S = owner
	var/max_dist = (S == S.hive.living_xeno_ruler) ? 6 : 3 //We can fling targets further away if we are the ruler.
	if(get_dist(S, A) > max_dist)
		return FALSE
	if(!ishuman(A))
		return FALSE


/datum/action/xeno_action/activable/psychic_fling/use_ability(atom/A)
	var/mob/living/victim = A
	round_statistics.psychic_flings++

	owner.visible_message("<span class='xenowarning'>A strange and violent psychic aura is suddenly emitted from \the [owner]!</span>", \
	"<span class='xenowarning'>You violently fling [victim] with the power of your mind!</span>")
	victim.visible_message("<span class='xenowarning'>[victim] is violently flung to the side by an unseen force!</span>", \
	"<span class='xenowarning'>You are violently flung to the side by an unseen force!</span>")
	playsound(owner,'sound/effects/magic.ogg', 75, 1)
	playsound(victim,'sound/weapons/alien_claw_block.ogg', 75, 1)

	succeed_activate()
	victim.apply_effects(1, 2) 	// Stun
	shake_camera(victim, 2, 1)

	var/facing = get_dir(owner, victim)
	var/fling_distance = 3
	var/turf/T = victim.loc
	var/turf/temp

	for(var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if(!temp)
			break
		T = temp
	victim.throw_at(T, fling_distance, 1, owner, TRUE)

	add_cooldown()


// ***************************************
// *********** Psychic Choke
// ***************************************
/datum/action/xeno_action/activable/psychic_choke
	name = "Psychic Choke"
	action_icon_state = "screech"
	mechanics_text = "Stun and start choking a target. Ranged ability."
	cooldown_timer = 30 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CHOKE


/datum/action/xeno_action/activable/psychic_choke/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>You gather enough mental strength to choke something again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_choke/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE
	var/mob/living/carbon/xenomorph/shrike/S = owner
	var/dist = get_dist(S, A)
	switch(dist)
		if(-1 to 1)
			if(!silent)
				to_chat(S, "<span class='warning'>The target is too close, you need some room to focus!</span>")
			return FALSE
		if(4 to INFINITY)
			if(!silent)
				to_chat(S, "<span class='warning'>Too far, our mind power does not reach it...</span>")
			return FALSE
	if(!ishuman(A))
		return FALSE
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD || !isturf(A.loc))
		return FALSE


/datum/action/xeno_action/activable/psychic_choke/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/shrike/assailant = owner
	var/mob/living/carbon/human/victim = A

	if(assailant.psychic_victim) //We are already using the ability.
		if(assailant.psychic_victim == victim)
			assailant.swap_psychic_grab() //If we are clicking on the same mob, just swap the grab level.
			return TRUE
		assailant.stop_psychic_grab() //Else let's end the ongoing one before we start the next.

	assailant.psychic_victim = victim

	if(assailant.get_active_held_item())
		assailant.drop_held_item() //Do we have a hugger? No longer.

	round_statistics.psychic_chokes++
	assailant.visible_message("<span class='xenowarning'>A strange and violent psychic aura is suddenly emitted from \the [assailant]!</span>", \
	"<span class='xenowarning'>You choke [victim] with the power of your mind!</span>")
	victim.visible_message("<span class='xenowarning'>[victim] is suddenly grabbed by the neck by an unseen force!</span>", \
	"<span class='xenowarning'>Your is suddenly grabbed by an unseen force!</span>")
	playsound(victim,'sound/effects/magic.ogg', 75, 1)

	victim.drop_all_held_items()
	victim.Stun(2)

	new /obj/item/tk_grab/shrike(assailant) //Grab starts "inside" the shrike. It will auto-equip to her hands, set her as its master and her victim as its target, and then start processing the grab.

	assailant.changeNext_move(CLICK_CD_RANGE)

	assailant.flick_attack_overlay(victim, "grab")

	log_combat(assailant, victim, "psychically grabbed")
	msg_admin_attack("[key_name(assailant)] psychically grabbed [key_name(victim)]" )

	succeed_activate()
	add_cooldown()