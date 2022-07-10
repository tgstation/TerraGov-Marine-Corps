//Some debug variables. Uncomment in order to see the related debug messages. Helpful when testing out formulas.
//#ifdef TESTING
//	#define DEBUG_HIVELORD_ABILITIES
//#endif

// ***************************************
// *********** Resin building
// ***************************************
/datum/action/xeno_action/activable/secrete_resin/ranged
	plasma_cost = 100
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating/thick,
		/obj/effect/alien/resin/sticky,
		/obj/structure/mineral_door/resin/thick,
	)
	///the maximum range of the ability
	var/max_range = 1

/datum/action/xeno_action/activable/secrete_resin/ranged/use_ability(atom/A)
	if(get_dist(owner, A) > max_range)
		return ..()

	return build_resin(get_turf(A))

// ***************************************
// *********** Resin walker
// ***************************************
/datum/action/xeno_action/toggle_speed
	name = "Resin Walker"
	action_icon_state = "toggle_speed"
	mechanics_text = "Move faster on resin."
	plasma_cost = 50
	keybind_signal = COMSIG_XENOABILITY_RESIN_WALKER
	use_state_flags = XACT_USE_LYING
	var/speed_activated = FALSE
	var/speed_bonus_active = FALSE

/datum/action/xeno_action/toggle_speed/remove_action()
	resinwalk_off(TRUE) // Ensure we remove the movespeed
	return ..()

/datum/action/xeno_action/toggle_speed/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(speed_activated)
		return TRUE

/datum/action/xeno_action/toggle_speed/action_activate()
	if(speed_activated)
		resinwalk_off()
		return fail_activate()
	resinwalk_on()
	succeed_activate()


/datum/action/xeno_action/toggle_speed/proc/resinwalk_on(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	speed_activated = TRUE
	if(!silent)
		owner.balloon_alert(owner, "Resin walk active")
	if(walker.loc_weeds_type)
		speed_bonus_active = TRUE
		walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/resinwalk_on_moved)


/datum/action/xeno_action/toggle_speed/proc/resinwalk_off(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	if(!silent)
		owner.balloon_alert(owner, "Resin walk ended")
	if(speed_bonus_active)
		walker.remove_movespeed_modifier(type)
		speed_bonus_active = FALSE
	speed_activated = FALSE
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)


/datum/action/xeno_action/toggle_speed/proc/resinwalk_on_moved(datum/source, atom/oldloc, direction, Forced = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/walker = owner
	if(!isturf(walker.loc) || walker.plasma_stored < 10)
		owner.balloon_alert(owner, "Resin walk ended, no plasma")
		resinwalk_off(TRUE)
		return
	if(walker.loc_weeds_type)
		if(!speed_bonus_active)
			speed_bonus_active = TRUE
			walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
		walker.use_plasma(10)
		return
	if(!speed_bonus_active)
		return
	speed_bonus_active = FALSE
	walker.remove_movespeed_modifier(type)


// ***************************************
// *********** Tunnel
// ***************************************
/datum/action/xeno_action/build_tunnel
	name = "Dig Tunnel"
	action_icon_state = "build_tunnel"
	mechanics_text = "Create a tunnel entrance. Use again to create the tunnel exit."
	plasma_cost = 200
	cooldown_timer = 120 SECONDS
	keybind_signal = COMSIG_XENOABILITY_BUILD_TUNNEL

/datum/action/xeno_action/build_tunnel/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(owner)
	if(locate(/obj/structure/xeno/tunnel) in T)
		if(!silent)
			T.balloon_alert(owner, "Tunnel already here")
		return
	if(!T.can_dig_xeno_tunnel())
		if(!silent)
			T.balloon_alert(owner, "Cannot dig, bad terrain")
		return FALSE
	if(owner.get_active_held_item())
		if(!silent)
			owner.balloon_alert(owner, "Cannot dig, needs empty hand")
		return FALSE

/datum/action/xeno_action/build_tunnel/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We are ready to dig a tunnel again."))
	return ..()

/datum/action/xeno_action/build_tunnel/action_activate()
	var/turf/T = get_turf(owner)
	var/mob/living/carbon/xenomorph/hivelord/X = owner

	X.balloon_alert(X, "Digging...")
	X.visible_message(span_xenonotice("[X] begins digging out a tunnel entrance."), \
	span_xenonotice("We begin digging out a tunnel entrance."), null, 5)
	if(!do_after(X, HIVELORD_TUNNEL_DIG_TIME, TRUE, T, BUSY_ICON_BUILD))
		X.balloon_alert(X, "Digging aborted")
		return fail_activate()

	if(!can_use_action(TRUE))
		return fail_activate()

	T.balloon_alert(X, "Tunnel dug")
	X.visible_message(span_xenonotice("\The [X] digs out a tunnel entrance."), \
	span_xenonotice("We dig out a tunnel, connecting it to our network."), null, 5)
	var/obj/structure/xeno/tunnel/newt = new(T)

	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)

	newt.hivenumber = X.hivenumber //Set our structure's hivenumber for alerts/lists
	newt.creator = X
	newt.RegisterSignal(X, COMSIG_PARENT_QDELETING, /obj/structure/xeno/tunnel.proc/clear_creator)

	X.tunnels.Add(newt)

	add_cooldown()

	to_chat(X, span_xenonotice("We now have <b>[LAZYLEN(X.tunnels)] of [HIVELORD_TUNNEL_SET_LIMIT]</b> tunnels."))

	var/msg = stripped_input(X, "Give your tunnel a descriptive name:", "Tunnel Name")
	newt.tunnel_desc = "[get_area(newt)] (X: [newt.x], Y: [newt.y])"
	newt.name += " [msg]"

	xeno_message("[X.name] has built a new tunnel named [newt.name] at [newt.tunnel_desc]!", "xenoannounce", 5, X.hivenumber)

	if(LAZYLEN(X.tunnels) > HIVELORD_TUNNEL_SET_LIMIT) //if we exceed the limit, delete the oldest tunnel set.
		var/obj/structure/xeno/tunnel/old_tunnel = X.tunnels[1]
		old_tunnel.deconstruct(FALSE)
		to_chat(X, span_xenodanger("Having exceeding our tunnel limit, our oldest tunnel has collapsed."))

	succeed_activate()
	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)



// ***************************************
// *********** plasma transfer
// ***************************************
/datum/action/xeno_action/activable/transfer_plasma/improved
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 4
	transfer_delay = 0.5 SECONDS
	max_range = 7


/datum/action/xeno_action/place_jelly_pod
	name = "Place Resin Jelly pod"
	action_icon_state = "haunt"
	mechanics_text = "Place down a dispenser that allows xenos to retrieve fireproof jelly."
	plasma_cost = 500
	cooldown_timer = 1 MINUTES
	keybind_signal = COMSIG_XENOABILITY_PLACE_JELLY_POD

/datum/action/xeno_action/place_jelly_pod/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			T.balloon_alert(owner, "Cannot place pod")
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(!owner_xeno.loc_weeds_type)
		if(!silent)
			T.balloon_alert(owner, "Cannot place pod, no weeds")
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

	if(!T.check_alien_construction(owner, silent))
		return FALSE

/datum/action/xeno_action/place_jelly_pod/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(T, "alien_resin_build", 25)
	var/obj/structure/xeno/resin_jelly_pod/pod = new(T)
	to_chat(owner, span_xenonotice("We shape some resin into \a [pod]."))
	add_cooldown()

/datum/action/xeno_action/create_jelly
	name = "Create Resin Jelly"
	action_icon_state = "gut"
	mechanics_text = "Create a fireproof jelly."
	plasma_cost = 100
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_CREATE_JELLY

/datum/action/xeno_action/create_jelly/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(owner.l_hand || owner.r_hand)
		if(!silent)
			owner.balloon_alert(owner, "Cannot jelly, need empty hands")
		return FALSE

/datum/action/xeno_action/create_jelly/action_activate()
	var/obj/item/resin_jelly/jelly = new(owner.loc)
	owner.put_in_hands(jelly)
	to_chat(owner, span_xenonotice("We create a globule of resin from our ovipostor.")) // Ewww...
	add_cooldown()
	succeed_activate()

// ***************************************
// *********** Healing Infusion
// ***************************************
/datum/action/xeno_action/activable/healing_infusion
	name = "Healing Infusion"
	action_icon_state = "healing_infusion"
	mechanics_text = "Psychically infuses a friendly xeno with regenerative energies, greatly improving its natural healing. Doesn't work if the target can't naturally heal."
	cooldown_timer = 12.5 SECONDS
	plasma_cost = 200
	keybind_signal = COMSIG_XENOABILITY_HEALING_INFUSION
	use_state_flags = XACT_USE_LYING
	target_flags = XABB_MOB_TARGET
	var/heal_range = HIVELORD_HEAL_RANGE

/datum/action/xeno_action/activable/healing_infusion/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!isxeno(target))
		if(!silent)
			target.balloon_alert(owner, "Cannot heal, only xenos")
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target

	if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			target.balloon_alert(owner, "Cannot heal, dead")
		return FALSE

	if(!check_distance(target, silent))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_HEALING_INFUSION))
		if(!silent)
			target.balloon_alert(owner, "Cannot heal, already infused")
		return FALSE


/datum/action/xeno_action/activable/healing_infusion/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > heal_range)
		if(!silent)
			target.balloon_alert(owner, "Cannot reach")
			to_chat(owner, span_warning("Too far for our reach... We need to be [dist - heal_range] steps closer!"))
		return FALSE
	else if(!line_of_sight(owner, target))
		if(!silent)
			target.balloon_alert(owner, "Cannot heal, no line of sight")
		return FALSE
	return TRUE


/datum/action/xeno_action/activable/healing_infusion/use_ability(atom/target)
	if(owner.do_actions)
		return FALSE

	owner.face_atom(target) //Face the target so we don't look stupid

	owner.visible_message(span_xenodanger("\the [owner] infuses [target] with mysterious energy!"), \
	span_xenodanger("We empower [target] with our [src]!"))

	playsound(target, 'sound/effects/magic.ogg', 25) //Cool SFX
	playsound(owner, 'sound/effects/magic.ogg', 25) //Cool SFX
	owner.beam(target, "medbeam", time = 1 SECONDS, maxdistance = 10)
	new /obj/effect/temp_visual/telekinesis(get_turf(owner))
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	to_chat(target, span_xenodanger("Our wounds begin to knit and heal rapidly as [owner]'s healing energies infuse us.")) //Let the target know.

	var/mob/living/carbon/xenomorph/patient = target

	patient.apply_status_effect(/datum/status_effect/healing_infusion, HIVELORD_HEALING_INFUSION_DURATION, HIVELORD_HEALING_INFUSION_TICKS) //per debuffs.dm

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.hivelord_healing_infusions++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivelord_healing_infusions")
