#define CALLING_BURROWED_DURATION 15 SECONDS

// ***************************************
// *********** Call of the Burrowed
// ***************************************
/datum/action/xeno_action/call_of_the_burrowed
	name = "Call of the Burrowed"
	action_icon_state = "larva_growth"
	plasma_cost = 400
	cooldown_timer = 2 MINUTES
	keybind_signal = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED


/datum/action/xeno_action/call_of_the_burrowed/action_activate()
	var/mob/living/carbon/xenomorph/shrike/caller = owner
	RegisterSignal(caller.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)

	playsound(caller,'sound/magic/invoke_general.ogg', 75, 1)
	new /obj/effect/temp_visual/telekinesis(get_turf(caller))
	caller.visible_message("<span class='xenowarning'>A strange buzzing hum starts to emanate from \the [caller]!</span>", \
	"<span class='xenodanger'>We call forth the larvas to rise from their slumber!</span>")
	notify_ghosts("\The <b>[caller]</b> is calling for the burrowed larvas to wake up!", enter_link = "join_larva=1", enter_text = "Join as Larva", source = caller, action = NOTIFY_JOIN_AS_LARVA)

	addtimer(CALLBACK(src, .proc/calling_larvas_end, caller), CALLING_BURROWED_DURATION)

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/call_of_the_burrowed/proc/calling_larvas_end(mob/living/carbon/xenomorph/shrike/caller)
	UnregisterSignal(caller.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))


/datum/action/xeno_action/call_of_the_burrowed/proc/is_burrowed_larva_host(datum/source, list/mothers) //Should only register while a viable candidate.
	if(!owner.incapacitated())
		mothers += owner //Adding them to the list.


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
	to_chat(owner, "<span class='notice'>We gather enough mental strength to fling something again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_fling/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/xenomorph/shrike/user = owner
	var/max_dist = (user == user.hive.living_xeno_ruler) ? 6 : 3 //We can fling targets further away if we are the ruler.
	if(!owner.line_of_sight(target, max_dist))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't focus properly without a clear line of sight!</span>")
		return FALSE
	var/mob/living/carbon/human/victim = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && victim.stat == DEAD)
		return FALSE


/datum/action/xeno_action/activable/psychic_fling/use_ability(atom/target)
	var/mob/living/victim = target
	GLOB.round_statistics.psychic_flings++

	owner.visible_message("<span class='xenowarning'>A strange and violent psychic aura is suddenly emitted from \the [owner]!</span>", \
	"<span class='xenowarning'>We violently fling [victim] with the power of our mind!</span>")
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
	var/obj/item/tk_grab/shrike/psychic_hold


/datum/action/xeno_action/activable/psychic_choke/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to choke something again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_choke/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	var/dist = get_dist(owner, target)
	switch(dist)
		if(-1 to 1)
			if(!silent)
				to_chat(owner, "<span class='warning'>The target is too close, we need some room to focus!</span>")
			return FALSE
		if(2 to 3)
			if(!owner.line_of_sight(target))
				if(!silent)
					to_chat(owner, "<span class='warning'>We can't focus properly without a clear line of sight!</span>")
				return FALSE
		if(4 to INFINITY)
			if(!silent)
				to_chat(owner, "<span class='warning'>Too far, our mind power does not reach it...</span>")
			return FALSE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/victim = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && victim.stat == DEAD)
		return FALSE


/datum/action/xeno_action/activable/psychic_choke/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/shrike/assailant = owner
	var/mob/living/carbon/human/victim = target

	if(psychic_hold) //We are already using the ability.
		if(psychic_hold.focus == victim)
			psychic_hold.swap_psychic_grab() //If we are clicking on the same mob, just swap the grab level.
			return TRUE
		qdel(psychic_hold) //Else let's end the ongoing one before we start the next. Their Destroy() will clean up the mess.

	if(assailant.get_active_held_item())
		assailant.drop_held_item() //Do we have a hugger? No longer.

	GLOB.round_statistics.psychic_chokes++
	assailant.visible_message("<span class='xenowarning'>A strange and violent psychic aura is suddenly emitted from \the [assailant]!</span>", \
	"<span class='xenowarning'>We choke [victim] with the power of our mind!</span>")
	victim.visible_message("<span class='xenowarning'>[victim] is suddenly grabbed by the neck by an unseen force!</span>", \
	"<span class='xenowarning'>You are suddenly grabbed by an unseen force!</span>")
	playsound(victim,'sound/effects/magic.ogg', 75, 1)

	victim.drop_all_held_items()
	victim.Stun(2)

	psychic_hold = new(assailant, victim, src) //Grab starts "inside" the shrike. It will auto-equip to her hands, set her as its master and her victim as its target, and then start processing the grab.

	assailant.changeNext_move(CLICK_CD_RANGE)

	assailant.flick_attack_overlay(victim, "grab")

	log_combat(assailant, victim, "psychically grabbed")
	msg_admin_attack("[key_name(assailant)] psychically grabbed [key_name(victim)]" )

	succeed_activate()
	add_cooldown()


// ***************************************
// *********** Psychic Cure
// ***************************************
/datum/action/xeno_action/activable/psychic_cure
	name = "Psychic Cure"
	action_icon_state = "heal_xeno"
	mechanics_text = "Heal and remove debuffs from a target."
	cooldown_timer = 1 MINUTES
	plasma_cost = 200
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_CURE


/datum/action/xeno_action/activable/psychic_cure/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to cure sisters again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_cure/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	var/dist = get_dist(owner, target)
	switch(dist)
		if(-1)
			if(!silent && target == owner)
				to_chat(owner, "<span class='warning'>We cannot cure ourselves.</span>")
			return FALSE
		if(0 to 3)
			if(!owner.line_of_sight(target))
				to_chat(owner, "<span class='warning'>We can't focus properly without a clear line of sight!</span>")
				return FALSE
		if(4 to INFINITY)
			if(!silent)
				to_chat(owner, "<span class='warning'>Too far, our mind power does not reach it...</span>")
			return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			to_chat(owner, "<span class='warning'>It's too late. This sister won't be coming back.</span>")
		return FALSE


/datum/action/xeno_action/activable/psychic_cure/use_ability(atom/target)
	if(owner.action_busy)
		return FALSE

	if(!do_mob(owner, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE

	GLOB.round_statistics.psychic_cures++
	owner.visible_message("<span class='xenowarning'>A strange psychic aura is suddenly emitted from \the [owner]!</span>", \
	"<span class='xenowarning'>We cure [target] with the power of our mind!</span>")
	target.visible_message("<span class='xenowarning'>[target] suddenly shimmers in a chill light.</span>", \
	"<span class='xenowarning'>We feel a sudden soothing chill.</span>")

	playsound(target,'sound/effects/magic.ogg', 75, 1)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	patient.heal_wounds(SHRIKE_CURE_HEAL_MULTIPLIER)
	if(patient.health > 0) //If they are not in crit after the heal, let's remove evil debuffs.
		patient.SetKnockedout(0)
		patient.SetStunned(0)
		patient.SetKnockeddown(0)
		patient.SetStagger(0)
		patient.SetSlowdown(0)
	patient.updatehealth()

	owner.changeNext_move(CLICK_CD_RANGE)

	log_combat(owner, patient, "psychically cured")
	msg_admin_attack("[key_name(owner)] psychically cured [key_name(patient)]" )

	succeed_activate()
	add_cooldown()