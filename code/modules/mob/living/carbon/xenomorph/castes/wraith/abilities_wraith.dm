GLOBAL_LIST_INIT(wraith_banish_very_short_duration_list, typecacheof(list(
	/obj/vehicle/sealed,
	/obj/structure/barricade,
)))

// ***************************************
// *********** Blink
// ***************************************
/datum/action/ability/activable/xeno/blink
	name = "Blink"
	action_icon_state = "blink"
	desc = "We teleport ourselves a short distance to a location within line of sight."
	use_state_flags = ABILITY_TURF_TARGET
	ability_cost = 30
	cooldown_duration = 0.5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BLINK,
	)

///Check target Blink turf to see if it can be blinked to
/datum/action/ability/activable/xeno/blink/proc/check_blink_tile(turf/T, ignore_blocker = FALSE, silent = FALSE)
	if(isclosedturf(T) || isspaceturf(T) || isspacearea(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We cannot blink here!"))
		return FALSE

	if(!line_of_sight(owner, T)) //Needs to be in line of sight.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink without line of sight to our destination!"))
		return FALSE

	if(IS_OPAQUE_TURF(T))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink into this space without vision!"))
		return FALSE

	if(ignore_blocker) //If we don't care about objects occupying the target square, return TRUE; used for checking pathing through transparents
		return TRUE

	if(turf_block_check(owner, T, FALSE, TRUE, TRUE, TRUE, TRUE)) //Check if there's anything that blocks us; we only care about Canpass here
		if(!silent)
			to_chat(owner, span_xenowarning("We can't blink here!"))
		return FALSE

	var/area/A = get_area(src)
	if(isspacearea(A))
		if(!silent)
			to_chat(owner, span_xenowarning("We cannot blink here!"))
		return FALSE


	return TRUE

///Check for whether the target turf has dense objects inside
/datum/action/ability/activable/xeno/blink/proc/check_blink_target_turf_density(turf/T, silent = FALSE)
	for(var/atom/blocker AS in T)
		if(!blocker.CanPass(owner, T))
			if(!silent)
				to_chat(owner, span_xenowarning("We can't blink into a solid object!"))
			return FALSE

	return TRUE

/datum/action/ability/activable/xeno/blink/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/X = owner
	var/turf/T = X.loc
	var/turf/temp_turf = X.loc
	var/check_distance = min(X.xeno_caste.wraith_blink_range, get_dist(X,A))
	var/list/fully_legal_turfs = list()

	for (var/x = 1 to check_distance)
		temp_turf = get_step(T, get_dir(T, A))
		if (!temp_turf)
			break
		if(!check_blink_tile(temp_turf, TRUE, TRUE)) //Verify that the turf is legal; if not we cancel out. We ignore transparent dense objects like windows here for now
			break
		if(check_blink_target_turf_density(temp_turf, TRUE)) //If we could ultimately teleport to this square, it is fully legal; add it to the list
			fully_legal_turfs += temp_turf
		T = temp_turf

	check_distance = min(length(fully_legal_turfs), check_distance) //Cap the check distance to the number of fully legal turfs
	T = X.loc //Reset T to be our initial position
	if(check_distance)
		T = fully_legal_turfs[check_distance]

	X.face_atom(T) //Face the target so we don't look like an ass

	var/cooldown_mod = 1
	var/mob/pulled_target = owner.pulling
	if(pulled_target) //bring the pulled target with us if applicable but at the cost of sharply increasing the next cooldown

		if(pulled_target.issamexenohive(X))
			cooldown_mod = X.xeno_caste.wraith_blink_drag_friendly_multiplier
		else
			if(!do_after(owner, 0.5 SECONDS, NONE, owner, BUSY_ICON_HOSTILE)) //Grap-porting hostiles has a slight wind up
				return fail_activate()
			cooldown_mod = X.xeno_caste.wraith_blink_drag_nonfriendly_living_multiplier
			if(ishuman(pulled_target))
				var/mob/living/carbon/human/H = pulled_target
				if(H.stat == UNCONSCIOUS) //Apply critdrag damage as if they were quickly pulled the same distance
					var/critdamage = HUMAN_CRITDRAG_OXYLOSS * get_dist(H.loc, T)
					if(!H.adjustOxyLoss(critdamage))
						H.adjustBruteLoss(critdamage)

		to_chat(X, span_xenodanger("We bring [pulled_target] with us. We won't be ready to blink again for [cooldown_duration * cooldown_mod * 0.1] seconds due to the strain of doing so."))

	teleport_debuff_aoe(X) //Debuff when we vanish

	if(pulled_target) //Yes, duplicate check because otherwise we end up with the initial teleport debuff AoE happening prior to the wind up which looks really bad and is actually exploitable via deliberate do after cancels
		pulled_target.forceMove(T) //Teleport to our target turf

	X.forceMove(T) //Teleport to our target turf
	teleport_debuff_aoe(X) //Debuff when we reappear

	succeed_activate()
	add_cooldown(cooldown_duration * cooldown_mod)

	GLOB.round_statistics.wraith_blinks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_blinks") //Statistics

///Called by many of the Wraith's teleportation effects
/datum/action/ability/activable/xeno/proc/teleport_debuff_aoe(atom/movable/teleporter, silent = FALSE)
	var/mob/living/carbon/xenomorph/ghost = owner

	if(!silent) //Sound effects
		playsound(teleporter, 'sound/effects/EMPulse.ogg', 25, 1) //Sound at the location we are arriving at

	new /obj/effect/temp_visual/blink_portal(get_turf(teleporter))

	new /obj/effect/temp_visual/wraith_warp(get_turf(teleporter))

	for(var/mob/living/living_target in range(1, teleporter.loc))

		if(living_target.stat == DEAD)
			continue

		if(isxeno(living_target))
			var/mob/living/carbon/xenomorph/X = living_target
			if(X.issamexenohive(ghost)) //No friendly fire
				continue

		living_target.adjust_stagger(WRAITH_TELEPORT_DEBUFF_STAGGER_STACKS)
		living_target.add_slowdown(WRAITH_TELEPORT_DEBUFF_SLOWDOWN_STACKS)
		to_chat(living_target, span_warning("You feel nauseous as reality warps around you!"))

/datum/action/ability/activable/xeno/blink/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to blink again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Banish
// ***************************************
/datum/action/ability/activable/xeno/banish
	name = "Banish"
	action_icon_state = "Banish"
	desc = "We banish a target object or creature within line of sight to nullspace for a short duration. Can target onself and allies. Non-friendlies are banished for half as long."
	use_state_flags = ABILITY_TARGET_SELF
	ability_cost = 50
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANISH,
	)
	///Target we've banished
	var/atom/movable/banishment_target = null
	///SFX indicating the banished target's position
	var/obj/effect/temp_visual/banishment_portal/portal = null
	///Backup coordinates to teleport the banished to, in case the portal gets destroyed (shuttles!!)
	var/list/backup_coordinates = list(0,0,0)
	/// living mobs in the banished object so we can check they didnt get ejected
	var/list/mob/living/contained_living = list()
	///The timer ID of any Banish currently active
	var/banish_duration_timer_id
	///Phantom zone reserved area
	var/datum/turf_reservation/reserved_area
	/// How far can you banish
	var/range = 3

/datum/action/ability/activable/xeno/banish/Destroy()
	QDEL_NULL(reserved_area) //clean up
	return ..()

/datum/action/ability/activable/xeno/banish/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()

	if(!ismovableatom(A) || iseffect(A) || istype(A, /obj/alien) || CHECK_BITFIELD(A.resistance_flags, INDESTRUCTIBLE) || CHECK_BITFIELD(A.resistance_flags, BANISH_IMMUNE)) //Cannot banish non-movables/things that are supposed to be invul; also we ignore effects
		if(!silent)
			to_chat(owner, span_xenowarning("We cannot banish this!"))
		return FALSE

	if(HAS_TRAIT(A, TRAIT_TIME_SHIFTED))
		to_chat(owner, span_xenowarning("That target is already affected by a time manipulation effect!"))
		return

	var/distance = get_dist(owner, A)
	if(distance > range) //Needs to be in range.
		if(!silent)
			to_chat(owner, span_xenowarning("Our target is too far away! It must be [distance - range] tiles closer!"))
		return FALSE

	if(!line_of_sight(owner, A, ignore_target_opacity = TRUE)) //Needs to be in line of sight.
		if(!silent)
			to_chat(owner, span_xenowarning("We can't banish without line of sight to our target!"))
		return FALSE


/datum/action/ability/activable/xeno/banish/use_ability(atom/movable/A)
	. = ..()
	var/mob/living/carbon/xenomorph/wraith/ghost = owner
	var/banished_turf = get_turf(A) //Set the banishment turf.
	banishment_target = A //Set the banishment target
	backup_coordinates[1] = banishment_target.x //Set up backup coordinates in case banish portal gets destroyed
	backup_coordinates[2] = banishment_target.y
	backup_coordinates[3] = banishment_target.z

	ghost.face_atom(A) //Face the target so we don't look like an ass

	teleport_debuff_aoe(banishment_target) //Debuff when we disappear
	portal = new /obj/effect/temp_visual/banishment_portal(banished_turf)
	banishment_target.resistance_flags = RESIST_ALL

	if(isliving(A))
		var/mob/living/stasis_target = banishment_target
		stasis_target.apply_status_effect(/datum/status_effect/incapacitating/unconscious) //Force the target to KO
		stasis_target.notransform = TRUE //Stasis
		stasis_target.overlay_fullscreen("banish", /atom/movable/screen/fullscreen/blind) //Force the blind overlay

	if(!reserved_area) //If we don't have a reserved area, set one
		reserved_area = SSmapping.RequestBlockReservation(3,3, SSmapping.transit.z_value, /datum/turf_reservation/banish)
		if(!reserved_area) //If we *still* don't have a reserved area we've got a problem
			CRASH("failed to reserve an area for [owner]'s Banish.")

	var/turf/target_turf = reserved_area.reserved_turfs[5]
	new /area/arrival(target_turf) //So we don't get instagibbed from the space area

	if(isxeno(banishment_target)) //If we're a xeno, disgorge all vored contents
		var/mob/living/carbon/xenomorph/xeno_target = banishment_target
		xeno_target.eject_victim()

	for(var/mob/living/living_contents in banishment_target.GetAllContents()) //Safety measure so living mobs inside the target don't get lost in Brazilspace forever
		contained_living += living_contents
		living_contents.apply_status_effect(/datum/status_effect/incapacitating/unconscious)
		living_contents.notransform = TRUE
		living_contents.overlay_fullscreen("banish", /atom/movable/screen/fullscreen/blind)

	banishment_target.forceMove(target_turf)

	var/duration = ghost.xeno_caste.wraith_banish_base_duration //Set the duration

	portal.add_filter("banish_portal_1", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	portal.add_filter("banish_portal_2", 3, list("type" = "motion_blur", 0, 0)) //Cool filter appear
	animate(portal.get_filter("banish_portal_1"), x = 20*rand() - 10, y = 20*rand() - 10, time = 0.5 SECONDS, loop = -1)
	animate(portal.get_filter("banish_portal_2"), x = 20*rand() - 10, y = 20*rand() - 10, time = 0.5 SECONDS, loop = -1)

	var/cooldown_mod = 1
	var/plasma_mod = 1
	if(isliving(banishment_target) && !(banishment_target.issamexenohive(ghost))) //We halve the max duration for living non-allies
		duration *= WRAITH_BANISH_NONFRIENDLY_LIVING_MULTIPLIER
	else if(is_type_in_typecache(banishment_target, GLOB.wraith_banish_very_short_duration_list)) //Barricades should only be gone long enough to admit an infiltrator xeno or two; one way.
		duration *= WRAITH_BANISH_VERY_SHORT_MULTIPLIER
	else
		cooldown_mod = 0.6 //40% cooldown reduction if used on non-hostile, non-blacklisted targets.
		plasma_mod = 0.4 //60% plasma cost reduction if used on non-hostile, non-blacklisted targets.

	banishment_target.visible_message(span_warning("Space abruptly twists and warps around [banishment_target] as it suddenly vanishes!"), \
	span_highdanger("The world around you reels, reality seeming to twist and tear until you find yourself trapped in a forsaken void beyond space and time."))
	playsound(banished_turf, 'sound/weapons/emitter2.ogg', 50, 1) //this isn't quiet

	to_chat(ghost,span_xenodanger("We have banished [banishment_target] to nullspace for [duration * 0.1] seconds."))
	log_attack("[key_name(ghost)] has banished [key_name(banishment_target)] for [duration * 0.1] seconds at [AREACOORD(banishment_target)]")

	addtimer(CALLBACK(src, PROC_REF(banish_warning)), duration * 0.7) //Warn when Banish is about to end
	banish_duration_timer_id = addtimer(CALLBACK(src, PROC_REF(banish_deactivate)), duration, TIMER_STOPPABLE) //store the timer ID

	succeed_activate(ability_cost * plasma_mod)
	add_cooldown(cooldown_duration * cooldown_mod)

	GLOB.round_statistics.wraith_banishes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "wraith_banishes") //Statistics

///Warns the user when Banish's duration is about to lapse.
/datum/action/ability/activable/xeno/banish/proc/banish_warning()

	if(!banishment_target)
		return

	to_chat(owner,span_highdanger("Our banishment target [banishment_target.name] is about to return to reality at [AREACOORD_NO_Z(portal)]!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Ends the effect of the Banish ability
/datum/action/ability/activable/xeno/banish/proc/banish_deactivate()
	SIGNAL_HANDLER
	if(QDELETED(banishment_target))
		return
	var/turf/return_turf = get_turf(portal)
	if(!return_turf)
		return_turf = locate(backup_coordinates[1], backup_coordinates[2], backup_coordinates[3])
	if(banishment_target.density)
		var/list/cards = GLOB.cardinals.Copy()
		for(var/mob/living/displacing in return_turf)
			if(displacing.stat == DEAD) //no.
				continue
			shuffle(cards) //direction should vary.
			for(var/card AS in cards)
				if(step(displacing, card))
					to_chat(displacing, span_warning("A sudden force pushes you away from [return_turf]!"))
					break
	banishment_target.resistance_flags = initial(banishment_target.resistance_flags)
	banishment_target.status_flags = initial(banishment_target.status_flags) //Remove stasis and temp invulerability
	banishment_target.forceMove(return_turf)

	var/list/all_contents = banishment_target.GetAllContents()
	for(var/mob/living/living_contents AS in contained_living)
		if(QDELETED(living_contents))
			continue
		living_contents.remove_status_effect(/datum/status_effect/incapacitating/unconscious)
		living_contents.notransform = initial(living_contents.notransform)
		living_contents.clear_fullscreen("banish")
		if(living_contents in all_contents)
			continue //if it is still inside then it is not stranded and we dont care
		living_contents.forceMove(return_turf)
	contained_living.Cut()

	teleport_debuff_aoe(banishment_target)
	banishment_target.add_filter("wraith_banishment_filter", 3, list("type" = "blur", 5))
	addtimer(CALLBACK(banishment_target, TYPE_PROC_REF(/atom, remove_filter), "wraith_banishment_filter"), 1 SECONDS)

	if(isliving(banishment_target))
		var/mob/living/living_target = banishment_target
		living_target = banishment_target
		living_target.remove_status_effect(/datum/status_effect/incapacitating/unconscious)
		living_target.notransform = initial(living_target.notransform)
		living_target.clear_fullscreen("banish")

	banishment_target.visible_message(span_warning("[banishment_target.name] abruptly reappears!"), \
	span_warning("You suddenly reappear back in what you believe to be reality."))

	to_chat(owner, span_highdanger("Our target [banishment_target] has returned to reality at [AREACOORD_NO_Z(banishment_target)]")) //Always alert the Wraith
	log_attack("[key_name(owner)] has unbanished [key_name(banishment_target)] at [AREACOORD(banishment_target)]")

	QDEL_NULL(portal) //Eliminate the Brazil portal if we need to

	banishment_target = null

	return TRUE //For the recall sub-ability

/datum/action/ability/activable/xeno/banish/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to banish again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

// ***************************************
// *********** Recall
// ***************************************
/datum/action/ability/xeno_action/recall
	name = "Recall"
	action_icon_state = "Recall"
	desc = "We recall a target we've banished back from the depths of nullspace."
	use_state_flags = ABILITY_USE_NOTTURF|ABILITY_USE_CLOSEDTURF|ABILITY_USE_STAGGERED|ABILITY_USE_INCAP|ABILITY_USE_LYING //So we can recall ourselves from nether Brazil
	cooldown_duration = 1 SECONDS //Token for anti-spam
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RECALL,
	)

/datum/action/ability/xeno_action/recall/can_use_action(silent = FALSE, override_flags)
	. = ..()

	var/datum/action/ability/activable/xeno/banish/banish_check = owner.actions_by_path[/datum/action/ability/activable/xeno/banish]
	if(!banish_check) //Mainly for when we transition on upgrading
		return FALSE

	if(!banish_check.banishment_target)
		if(!silent)
			to_chat(owner,span_xenodanger("We have no targets banished!"))
		return FALSE


/datum/action/ability/xeno_action/recall/action_activate()
	. = ..()
	var/datum/action/ability/activable/xeno/banish/banish_check = owner.actions_by_path[/datum/action/ability/activable/xeno/banish]
	banish_check.banish_deactivate()
	succeed_activate()
	add_cooldown()

///Return TRUE if we have a block, return FALSE otherwise
/proc/turf_block_check(atom/subject, atom/target, ignore_can_pass = FALSE, ignore_density = FALSE, ignore_closed_turf = FALSE, ignore_invulnerable = FALSE, ignore_objects = FALSE, ignore_mobs = FALSE, ignore_space = FALSE)
	var/turf/T = get_turf(target)
	if(isspaceturf(T) && !ignore_space)
		return TRUE
	if(isclosedturf(T) && !ignore_closed_turf) //If we care about closed turfs
		return TRUE
	for(var/atom/blocker AS in T)
		if((blocker.flags_atom & ON_BORDER) || blocker == subject) //If they're a border entity or our subject, we don't care
			continue
		if(!blocker.CanPass(subject, T) && !ignore_can_pass) //If the subject atom can't pass and we care about that, we have a block
			return TRUE
		if(!blocker.density) //Check if we're dense
			continue
		if(!ignore_density) //If we care about all dense atoms or only certain types of dense atoms
			return TRUE
		if((blocker.resistance_flags & INDESTRUCTIBLE) && !ignore_invulnerable) //If we care about dense invulnerable objects
			return TRUE
		if(isobj(blocker) && !ignore_objects) //If we care about dense objects
			var/obj/obj_blocker = blocker
			if(!isstructure(obj_blocker)) //If it's not a structure and we care about objects, we have a block
				return TRUE
			var/obj/structure/blocker_structure = obj_blocker
			if(!blocker_structure.climbable) //If it's a structure and can't be climbed, we have a block
				return TRUE
		if(ismob(blocker) && !ignore_mobs) //If we care about mobs
			return TRUE

	return FALSE

/datum/action/ability/xeno_action/timestop
	name = "Time stop"
	action_icon_state = "time_stop"
	desc = "Freezes bullets in their course, and they will start to move again only after a certain time"
	ability_cost = 100
	cooldown_duration = 1 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TIMESTOP,
	)
	///The range of the ability
	var/range = 1
	///How long is the bullet freeze staying
	var/duration = 7 SECONDS

/datum/action/ability/xeno_action/timestop/action_activate()
	. = ..()
	var/list/turf/turfs_affected = list()
	var/turf/central_turf = get_turf(owner)
	for(var/turf/affected_turf in view(range, central_turf))
		ADD_TRAIT(affected_turf, TRAIT_TURF_BULLET_MANIPULATION, REF(src))
		turfs_affected += affected_turf
		affected_turf.add_filter("wraith_magic", 2, drop_shadow_filter(color = "#04080FAA", size = -10))
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE)
	succeed_activate()
	add_cooldown()
	new /obj/effect/overlay/temp/timestop_effect(central_turf, duration)
	addtimer(CALLBACK(src, PROC_REF(remove_bullet_freeze), turfs_affected, central_turf), duration)
	addtimer(CALLBACK(src, PROC_REF(play_sound_stop)), duration - 3 SECONDS)

///Remove the bullet freeze effect on affected turfs
/datum/action/ability/xeno_action/timestop/proc/remove_bullet_freeze(list/turf/turfs_affected, turf/central_turfA)
	for(var/turf/affected_turf AS in turfs_affected)
		REMOVE_TRAIT(affected_turf, TRAIT_TURF_BULLET_MANIPULATION, REF(src))
		if(HAS_TRAIT(affected_turf, TRAIT_TURF_BULLET_MANIPULATION))
			continue
		SEND_SIGNAL(affected_turf, COMSIG_TURF_RESUME_PROJECTILE_MOVE)
		affected_turf.remove_filter("wraith_magic")

///Play the end ability sound
/datum/action/ability/xeno_action/timestop/proc/play_sound_stop()
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE, frequency = -1)

/datum/action/ability/xeno_action/portal
	name = "Portal"
	action_icon_state = "portal"
	desc = "Place a portal on your location. You can travel from portal to portal. Left click to create portal one, right click to create portal two"
	ability_cost = 50
	cooldown_duration = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PORTAL,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_PORTAL_ALTERNATE,
	)
	/// How far can you link two portals
	var/range = 20
	/// The first portal
	var/obj/effect/wraith_portal/portal_one
	/// The second portal
	var/obj/effect/wraith_portal/portal_two

/datum/action/ability/xeno_action/portal/remove_action(mob/M)
	clean_portals()
	return ..()

/// Destroy the portals when the wraith is no longer supporting them
/datum/action/ability/xeno_action/portal/proc/clean_portals()
	SIGNAL_HANDLER

	QDEL_NULL(portal_one)
	QDEL_NULL(portal_two)

/datum/action/ability/xeno_action/portal/give_action(mob/M)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(clean_portals))

/datum/action/ability/xeno_action/portal/can_use_action(silent, override_flags)
	if(locate(/obj/effect/wraith_portal) in get_turf(owner))
		if(!silent)
			to_chat(owner, span_xenowarning("There is already a portal here!"))
		return FALSE
	var/area/area = get_area(owner)
	if(area.flags_area & MARINE_BASE)
		if(!silent)
			to_chat(owner, span_xenowarning("You cannot portal here!"))
		return FALSE
	return ..()

/datum/action/ability/xeno_action/portal/action_activate()
	. = ..()
	qdel(portal_one)
	portal_one = new(get_turf(owner))
	succeed_activate()
	add_cooldown()
	playsound(owner.loc, 'sound/effects/portal_opening.ogg', 20)
	if(portal_two)
		link_portals()

/datum/action/ability/xeno_action/portal/alternate_action_activate()
	if(!can_use_action())
		return
	qdel(portal_two)
	portal_two = new(get_turf(owner), TRUE)
	succeed_activate()
	add_cooldown()
	playsound(owner.loc, 'sound/effects/portal_opening.ogg', 20)
	if(portal_one)
		link_portals()

/// Link the two portals if possible
/datum/action/ability/xeno_action/portal/proc/link_portals()
	if(get_dist(portal_one, portal_two) > range || portal_one.z != portal_two.z)
		to_chat(owner, span_xenowarning("The other portal is too far away, they cannot link!"))
		return
	portal_two.link_portal(portal_one)
	portal_one.link_portal(portal_two)

/obj/effect/wraith_portal
	icon_state = "portal"
	anchored = TRUE
	opacity = FALSE
	vis_flags = VIS_HIDE
	resistance_flags = UNACIDABLE | CRUSHER_IMMUNE | BANISH_IMMUNE
	/// Visual object for handling the viscontents
	var/obj/effect/portal_effect/portal_visuals
	/// The linked portal
	var/obj/effect/wraith_portal/linked_portal
	COOLDOWN_DECLARE(portal_cooldown)

/obj/effect/wraith_portal/Initialize(mapload, portal_is_yellow = FALSE)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(teleport_atom)
	)
	if(portal_is_yellow)
		icon_state = "portal1"
	AddElement(/datum/element/connect_loc, connections)
	portal_visuals = new
	portal_visuals.layer = layer + 0.01
	vis_contents += portal_visuals
	add_filter("border_smoother", 1, gauss_blur_filter(1))

/obj/effect/wraith_portal/Destroy()
	linked_portal?.unlink()
	linked_portal = null
	REMOVE_TRAIT(loc, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT)
	vis_contents -= portal_visuals
	QDEL_NULL(portal_visuals)
	return ..()

/obj/effect/wraith_portal/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!linked_portal)
		return
	user.forceMove(get_turf(linked_portal))

/// Link two portals
/obj/effect/wraith_portal/proc/link_portal(obj/effect/wraith_portal/portal_to_link)
	linked_portal = portal_to_link
	ADD_TRAIT(loc, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT)
	RegisterSignal(loc, COMSIG_TURF_PROJECTILE_MANIPULATED, PROC_REF(teleport_bullet))
	portal_visuals.setup_visuals(portal_to_link)

/// Unlink the portal
/obj/effect/wraith_portal/proc/unlink()
	linked_portal = null
	REMOVE_TRAIT(loc, TRAIT_TURF_BULLET_MANIPULATION, PORTAL_TRAIT)
	UnregisterSignal(loc, COMSIG_TURF_PROJECTILE_MANIPULATED)
	portal_visuals.reset_visuals()

/// Signal handler teleporting crossing atoms
/obj/effect/wraith_portal/proc/teleport_atom/(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER
	if(!linked_portal || !COOLDOWN_CHECK(src, portal_cooldown) || crosser.anchored || (crosser.resistance_flags & PORTAL_IMMUNE))
		return
	COOLDOWN_START(linked_portal, portal_cooldown, 1)
	crosser.pass_flags &= ~PASS_MOB
	RegisterSignal(crosser, COMSIG_MOVABLE_MOVED, PROC_REF(do_teleport_atom))
	playsound(loc, 'sound/effects/portal.ogg', 20)

/// Signal handler to teleport the crossing atom when its move is done
/obj/effect/wraith_portal/proc/do_teleport_atom(atom/movable/crosser)
	SIGNAL_HANDLER
	for(var/mob/rider AS in crosser.buckled_mobs)
		if(ishuman(rider))
			crosser.unbuckle_mob(rider)
	crosser.Move(get_turf(linked_portal), crosser.dir)
	UnregisterSignal(crosser, COMSIG_MOVABLE_MOVED)

/// Signal handler for teleporting a crossing bullet
/obj/effect/wraith_portal/proc/teleport_bullet(datum/source, obj/projectile/bullet)
	SIGNAL_HANDLER
	playsound(loc, 'sound/effects/portal.ogg', 20)
	var/new_range = bullet.proj_max_range - bullet.distance_travelled
	if(new_range <= 0)
		bullet.loc = get_turf(linked_portal)
		bullet.ammo.do_at_max_range(bullet)
		qdel(bullet)
		return
	if(!linked_portal) // A lot of racing conditions here
		return
	bullet.fire_at(shooter = bullet.firer, range = max(bullet.proj_max_range - bullet.distance_travelled, 0), angle = bullet.dir_angle, recursivity = TRUE, loc_override = get_turf(linked_portal))

/obj/effect/portal_effect
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_ID
	layer = DOOR_OPEN_LAYER
	///turf destination to display
	var/turf/our_destination

/obj/effect/portal_effect/proc/setup_visuals(atom/target)
	our_destination = get_turf(target)
	update_portal_filters()

/obj/effect/portal_effect/proc/reset_visuals()
	our_destination = null
	update_portal_filters()

/obj/effect/portal_effect/proc/update_portal_filters()
	clear_filters()
	vis_contents = null

	if(!our_destination)
		return
	var/static/icon/portal_mask = icon('icons/effects/effects.dmi', "portal_mask")
	add_filter("portal_alpha", 1, list("type" = "alpha", "icon" = portal_mask))
	add_filter("portal_blur", 1, list("type" = "blur", "size" = 0.5))
	add_filter("portal_ripple", 1, list("type" = "ripple", "size" = 2, "radius" = 1, "falloff" = 1, "y" = 7))

	animate(get_filter("portal_ripple"), time = 1.3 SECONDS, loop = -1, easing = LINEAR_EASING, radius = 32)

	vis_contents += our_destination
/obj/effect/wraith_portal/ex_act()
	qdel(src)

/datum/action/ability/activable/xeno/rewind
	name = "Time Shift"
	action_icon_state = "rewind"
	desc = "Save the location and status of the target. When the time is up, the target location and status are restored, unless the target is dead or unconscious."
	ability_cost = 100
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REWIND,
	)
	use_state_flags = ABILITY_TARGET_SELF
	/// How long till the time rewinds
	var/start_rewinding = 5 SECONDS
	/// The targeted atom
	var/mob/living/targeted
	/// List of locations the atom took since it was last saved
	var/list/turf/last_target_locs_list = list()
	/// Initial burn damage of the target
	var/target_initial_burn_damage = 0
	/// Initial brute damage of the target
	var/target_initial_brute_damage = 0
	/// Initial sunder of the target
	var/target_initial_sunder = 0
	/// Initial fire stacks of the target
	var/target_initial_fire_stacks = 0
	/// Initial on_fire value
	var/target_initial_on_fire = FALSE
	/// How far can you rewind someone
	var/range = 5


/datum/action/ability/activable/xeno/rewind/can_use_ability(atom/A, silent, override_flags)
	. = ..()

	var/distance = get_dist(owner, A)
	if(distance > range) //Needs to be in range.
		if(!silent)
			to_chat(owner, span_xenowarning("Our target is too far away! It must be [distance - range] tiles closer!"))
		return FALSE

	if(HAS_TRAIT(A, TRAIT_TIME_SHIFTED))
		to_chat(owner, span_xenowarning("That target is already affected by a time manipulation effect!"))
		return FALSE

	if(!isliving(A))
		to_chat(owner, span_xenowarning("We cannot target that!"))
		return FALSE


	var/mob/living/living_target = A
	if(living_target.stat != CONSCIOUS)
		to_chat(owner, span_xenowarning("The target is not in good enough shape!"))

/datum/action/ability/activable/xeno/rewind/use_ability(atom/A)
	targeted = A
	last_target_locs_list = list(get_turf(A))
	target_initial_brute_damage = targeted.getBruteLoss()
	target_initial_burn_damage = targeted.getFireLoss()
	target_initial_fire_stacks = targeted.fire_stacks
	target_initial_on_fire = targeted.on_fire
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/xeno_target = targeted
		target_initial_sunder = xeno_target.sunder
	addtimer(CALLBACK(src, PROC_REF(start_rewinding)), start_rewinding)
	RegisterSignal(targeted, COMSIG_MOVABLE_MOVED, PROC_REF(save_move))
	targeted.add_filter("prerewind_blur", 1, radial_blur_filter(0.04))
	targeted.balloon_alert(targeted, "You feel anchored to the past!")
	ADD_TRAIT(targeted, TRAIT_TIME_SHIFTED, XENO_TRAIT)
	add_cooldown()
	succeed_activate()
	return

/// Signal handler
/datum/action/ability/activable/xeno/rewind/proc/save_move(atom/movable/source, oldloc)
	SIGNAL_HANDLER
	last_target_locs_list += get_turf(oldloc)

/// Start the reset process
/datum/action/ability/activable/xeno/rewind/proc/start_rewinding()
	targeted.remove_filter("prerewind_blur")
	UnregisterSignal(targeted, COMSIG_MOVABLE_MOVED)
	if(QDELETED(targeted) || targeted.stat != CONSCIOUS)
		REMOVE_TRAIT(targeted, TRAIT_TIME_SHIFTED, XENO_TRAIT)
		targeted = null
		return
	targeted.add_filter("rewind_blur", 1, radial_blur_filter(0.3))
	targeted.status_flags |= (INCORPOREAL|GODMODE)
	INVOKE_NEXT_TICK(src, PROC_REF(rewind))
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TIMESHIFT_TRAIT)
	playsound(targeted, 'sound/effects/woosh_swoosh.ogg', 50)

/// Move the target two tiles per tick
/datum/action/ability/activable/xeno/rewind/proc/rewind()
	var/turf/loc_a = pop(last_target_locs_list)
	if(loc_a)
		new /obj/effect/temp_visual/xenomorph/afterimage(targeted.loc, targeted)

	var/turf/loc_b = pop(last_target_locs_list)
	if(!loc_b)
		targeted.status_flags &= ~(INCORPOREAL|GODMODE)
		REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TIMESHIFT_TRAIT)
		targeted.heal_overall_damage(targeted.getBruteLoss() - target_initial_brute_damage, targeted.getFireLoss() - target_initial_burn_damage, updating_health = TRUE)
		if(target_initial_on_fire && target_initial_fire_stacks >= 0)
			targeted.fire_stacks = target_initial_fire_stacks
			targeted.IgniteMob()
		else
			targeted.ExtinguishMob()
		if(isxeno(targeted))
			var/mob/living/carbon/xenomorph/xeno_target = targeted
			xeno_target.sunder = target_initial_sunder
		targeted.remove_filter("rewind_blur")
		REMOVE_TRAIT(targeted, TRAIT_TIME_SHIFTED, XENO_TRAIT)
		targeted = null
		return

	targeted.Move(loc_b, get_dir(loc_b, loc_a))
	new /obj/effect/temp_visual/xenomorph/afterimage(loc_a, targeted)
	INVOKE_NEXT_TICK(src, PROC_REF(rewind))
