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
	use_state_flags = XACT_USE_LYING


/datum/action/xeno_action/call_of_the_burrowed/action_activate()
	var/mob/living/carbon/xenomorph/shrike/caller = owner
	if(!isnormalhive(caller.hive))
		to_chat(caller, "<span class='warning'>Burrowed larva? What a strange concept... It's not for our hive.</span>")
		return FALSE
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	if(!stored_larva)
		to_chat(caller, "<span class='warning'>Our hive currently has no burrowed to call forth!</span>")
		return FALSE

	playsound(caller,'sound/magic/invoke_general.ogg', 75, TRUE)
	new /obj/effect/temp_visual/telekinesis(get_turf(caller))
	caller.visible_message("<span class='xenowarning'>A strange buzzing hum starts to emanate from \the [caller]!</span>", \
	"<span class='xenodanger'>We call forth the larvas to rise from their slumber!</span>")

	if(stored_larva)
		RegisterSignal(caller.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK), .proc/is_burrowed_larva_host)
		caller.hive.give_larva_to_next_in_queue()
		notify_ghosts("\The <b>[caller]</b> is calling for the burrowed larvas to wake up!", enter_link = "join_larva=1", enter_text = "Join as Larva", source = caller, action = NOTIFY_JOIN_AS_LARVA)
		addtimer(CALLBACK(src, .proc/calling_larvas_end, caller), CALLING_BURROWED_DURATION)

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/call_of_the_burrowed/proc/calling_larvas_end(mob/living/carbon/xenomorph/shrike/caller)
	UnregisterSignal(caller.hive, list(COMSIG_HIVE_XENO_MOTHER_PRE_CHECK, COMSIG_HIVE_XENO_MOTHER_CHECK))


/datum/action/xeno_action/call_of_the_burrowed/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos) //Should only register while a viable candidate.
	SIGNAL_HANDLER
	if(!owner.incapacitated())
		mothers += owner //Adding them to the list.


// ***************************************
// *********** Psychic Fling
// ***************************************
/datum/action/xeno_action/activable/psychic_fling
	name = "Psychic Fling"
	action_icon_state = "fling"
	mechanics_text = "Sends an enemy or an item flying. A close ranged ability."
	cooldown_timer = 12 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_FLING
	target_flags = XABB_MOB_TARGET


/datum/action/xeno_action/activable/psychic_fling/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to fling something again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_fling/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!isitem(target) && !ishuman(target))	//only items and mobs can be flung.
		return FALSE
	var/max_dist = 3 //the distance only goes to 3 now, since this is more of a utility then an attack.
	if(!owner.line_of_sight(target, max_dist))
		if(!silent)
			to_chat(owner, "<span class='warning'>We must get closer to fling, our mind cannot reach this far.</span>")
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(isnestedhost(victim))
			return FALSE
		if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && victim.stat == DEAD)
			return FALSE


/datum/action/xeno_action/activable/psychic_fling/use_ability(atom/target)
	var/mob/living/victim = target
	GLOB.round_statistics.psychic_flings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_flings")

	owner.visible_message("<span class='xenowarning'>A strange and violent psychic aura is suddenly emitted from \the [owner]!</span>", \
	"<span class='xenowarning'>We violently fling [victim] with the power of our mind!</span>")
	victim.visible_message("<span class='xenowarning'>[victim] is violently flung away by an unseen force!</span>", \
	"<span class='xenowarning'>You are violently flung to the side by an unseen force!</span>")
	playsound(owner,'sound/effects/magic.ogg', 75, 1)
	playsound(victim,'sound/weapons/alien_claw_block.ogg', 75, 1)

		//Held facehuggers get killed for balance reasons
	if(istype(owner.r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = owner.r_hand
		if(FH.stat != DEAD)
			FH.kill_hugger()

	if(istype(owner.l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = owner.l_hand
		if(FH.stat != DEAD)
			FH.kill_hugger()

	succeed_activate()
	add_cooldown()
	if(ishuman(victim))
		victim.apply_effects(1, 0.1) 	// The fling stuns you enough to remove your gun, otherwise the marine effectively isn't stunned for long.
		shake_camera(victim, 2, 1)

	var/facing = get_dir(owner, victim)
	var/fling_distance = (isitem(victim)) ? 4 : 3 //Objects get flung further away.
	var/turf/T = victim.loc
	var/turf/temp

	for(var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if(!temp)
			break
		T = temp
	victim.throw_at(T, fling_distance, 1, owner, TRUE)


// ***************************************
// *********** Unrelenting Force
// ***************************************
/datum/action/xeno_action/activable/unrelenting_force
	name = "Unrelenting Force"
	action_icon_state = "screech"
	mechanics_text = "Unleashes our raw psychic power, pushing aside anyone who stands in our path."
	cooldown_timer = 50 SECONDS
	plasma_cost = 300
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_UNRELENTING_FORCE
	alternate_keybind_signal = COMSIG_XENOABILITY_UNRELENTING_FORCE_SELECT


/datum/action/xeno_action/activable/unrelenting_force/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>Our mind is ready to unleash another blast of force.</span>")
	return ..()


/datum/action/xeno_action/activable/unrelenting_force/use_ability(atom/target)
	succeed_activate()
	add_cooldown()
	addtimer(CALLBACK(owner, /mob.proc/update_icons), 1 SECONDS)
	owner.icon_state = "Shrike Screeching"
	if(target) // Keybind use doesn't have a target
		owner.face_atom(target)

	var/turf/lower_left
	var/turf/upper_right
	switch(owner.dir)
		if(NORTH)
			lower_left = locate(owner.x - 1, owner.y + 1, owner.z)
			upper_right = locate(owner.x + 1, owner.y + 3, owner.z)
		if(SOUTH)
			lower_left = locate(owner.x - 1, owner.y - 3, owner.z)
			upper_right = locate(owner.x + 1, owner.y - 1, owner.z)
		if(WEST)
			lower_left = locate(owner.x - 3, owner.y - 1, owner.z)
			upper_right = locate(owner.x - 1, owner.y + 1, owner.z)
		if(EAST)
			lower_left = locate(owner.x + 1, owner.y - 1, owner.z)
			upper_right = locate(owner.x + 3, owner.y + 1, owner.z)

	for(var/turf/affected_tile in block(lower_left, upper_right)) //everything in the 2x3 block is found.
		affected_tile.Shake(4, 4, 2 SECONDS)
		for(var/i in affected_tile)
			var/atom/movable/affected = i
			if(!ishuman(affected) && !istype(affected, /obj/item))
				affected.Shake(4, 4, 20)
				continue
			if(ishuman(affected)) //if they're human, they also should get knocked off their feet from the blast.
				var/mob/living/carbon/human/H = affected
				if(H.stat == DEAD) //unless they are dead, then the blast mysteriously ignores them.
					continue
				H.apply_effects(1, 1) 	// Stun
				shake_camera(H, 2, 1)
			var/throwlocation = affected.loc //first we get the target's location
			for(var/x in 1 to 6)
				throwlocation = get_step(throwlocation, owner.dir) //then we find where they're being thrown to, checking tile by tile.
			affected.throw_at(throwlocation, 6, 1, owner, TRUE)

	owner.visible_message("<span class='xenowarning'>[owner] sends out a huge blast of psychic energy!</span>", \
	"<span class='xenowarning'>We send out a huge blast of psychic energy!</span>")

	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, "alien_roar", 50)

			//Held facehuggers get killed for balance reasons
	if(istype(owner.r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = owner.r_hand
		if(FH.stat != DEAD)
			FH.kill_hugger()

	if(istype(owner.l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = owner.l_hand
		if(FH.stat != DEAD)
			FH.kill_hugger()



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
	var/heal_range = SHRIKE_HEAL_RANGE
	target_flags = XABB_MOB_TARGET


/datum/action/xeno_action/activable/psychic_cure/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough mental strength to cure sisters again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_cure/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!check_distance(target, silent))
		return FALSE
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target
	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			to_chat(owner, "<span class='warning'>It's too late. This sister won't be coming back.</span>")
		return FALSE


/datum/action/xeno_action/activable/psychic_cure/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > heal_range)
		to_chat(owner, "<span class='warning'>Too far for our reach... We need to be [dist - heal_range] steps closer!</span>")
		return FALSE
	else if(!owner.line_of_sight(target))
		to_chat(owner, "<span class='warning'>We can't focus properly without a clear line of sight!</span>")
		return FALSE
	return TRUE


/datum/action/xeno_action/activable/psychic_cure/use_ability(atom/target)
	if(owner.do_actions)
		return FALSE

	if(!do_mob(owner, target, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE

	GLOB.round_statistics.psychic_cures++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_cures")
	owner.visible_message("<span class='xenowarning'>A strange psychic aura is suddenly emitted from \the [owner]!</span>", \
	"<span class='xenowarning'>We cure [target] with the power of our mind!</span>")
	target.visible_message("<span class='xenowarning'>[target] suddenly shimmers in a chill light.</span>", \
	"<span class='xenowarning'>We feel a sudden soothing chill.</span>")

	playsound(target,'sound/effects/magic.ogg', 75, 1)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/mob/living/carbon/xenomorph/patient = target
	patient.heal_wounds(SHRIKE_CURE_HEAL_MULTIPLIER)
	if(patient.health > 0) //If they are not in crit after the heal, let's remove evil debuffs.
		patient.SetUnconscious(0)
		patient.SetStun(0)
		patient.SetParalyzed(0)
		patient.set_stagger(0)
		patient.set_slowdown(0)
	patient.updatehealth()

	owner.changeNext_move(CLICK_CD_RANGE)

	log_combat(owner, patient, "psychically cured")

	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Construct Acid Well
// ***************************************
/datum/action/xeno_action/place_acidwell
	name = "Place acid well"
	action_icon_state = "place_trap"
	mechanics_text = "Place an acid well that can put out fires."
	plasma_cost = 500
	cooldown_timer = 2 MINUTES

/datum/action/xeno_action/place_acidwell/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			to_chat(owner, "<span class='warning'>We can't do that here.</span>")
		return FALSE

	if(!(locate(/obj/effect/alien/weeds) in T))
		if(!silent)
			to_chat(owner, "<span class='warning'>We can only shape on weeds. We must find some resin before we start building!</span>")
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

/datum/action/xeno_action/place_acidwell/action_activate()
	var/turf/T = get_turf(owner)
	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	var/obj/structure/xeno/acidwell/AC = new /obj/structure/xeno/acidwell(T, owner)
	AC.creator = owner

	to_chat(owner, "<span class='xenonotice'>We place an acid well; it can be filled with more acid.</span>")
	GLOB.round_statistics.xeno_acid_wells++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_acid_wells")
