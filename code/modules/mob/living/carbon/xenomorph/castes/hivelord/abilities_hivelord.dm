//Some debug variables. Uncomment in order to see the related debug messages. Helpful when testing out formulas.
//#ifdef TESTING
//	#define DEBUG_HIVELORD_ABILITIES
//#endif

// ***************************************
// *********** Recycle
// ***************************************
/datum/action/ability/activable/xeno/recycle
	name = "Recycle"
	action_icon_state = "recycle"
	action_icon = 'icons/Xeno/actions/drone.dmi'
	desc = "We deconstruct the body of a fellow fallen xenomorph to avoid marines from harvesting our sisters in arms."
	use_state_flags = ABILITY_USE_STAGGERED //can't use while staggered, defender fortified or crest down
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RECYCLE,
	)
	ability_cost = 750
	gamemode_flags = ABILITY_NUCLEARWAR

/datum/action/ability/activable/xeno/recycle/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/victim = target
	if(!.)
		return FALSE
	if(!xeno_owner.Adjacent(victim))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "too far!")
		return FALSE
	if(xeno_owner.on_fire)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "not while on fire!")
		return FALSE
	if(!isxeno(target))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "can't recycle non-xenos!")
		return FALSE
	if(victim.stat != DEAD)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "she isn't dead!")
		return FALSE

/datum/action/ability/activable/xeno/recycle/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/recycled_xeno = target
	xeno_owner.face_atom(recycled_xeno) //Face towards the target so we don't look silly
	xeno_owner.visible_message(span_warning("\The [xeno_owner] starts breaking apart \the [recycled_xeno]'s carcass."), \
	span_danger("We slowly deconstruct upon \the [recycled_xeno]'s carcass!"), null, 20)
	if(!do_after(owner, 7 SECONDS, IGNORE_HELD_ITEM, recycled_xeno, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, TRUE, ABILITY_USE_BUSY)))
		return

	xeno_owner.record_recycle_points(recycled_xeno)

	recycled_xeno.gib()

	playsound(xeno_owner, 'sound/effects/alien/recycler.ogg', 40)
	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] brushes xenomorphs' bits off its claws."), \
	span_danger("We brush xenomorphs' bits off of our claws."), null, 20)
	return succeed_activate() //dew it

// ***************************************
// *********** Resin building
// ***************************************
/datum/action/ability/activable/xeno/secrete_resin/hivelord
	ability_cost = 100
	buildable_structures = list(
		/turf/closed/wall/resin/regenerating/thick,
		/turf/closed/wall/resin/regenerating/special/bulletproof,
		/turf/closed/wall/resin/regenerating/special/fireproof,
		/turf/closed/wall/resin/regenerating/special/hardy,
		/obj/alien/resin/sticky,
		/obj/structure/mineral_door/resin/thick,
	)

// ***************************************
// *********** Resin walker
// ***************************************
/datum/action/ability/xeno_action/toggle_speed
	name = "Resin Walker"
	action_icon_state = "toggle_speed"
	action_icon = 'icons/Xeno/actions/hivelord.dmi'
	desc = "Move faster on resin."
	ability_cost = 50
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RESIN_WALKER,
	)
	use_state_flags = ABILITY_USE_LYING
	action_type = ACTION_TOGGLE
	/// Is the ability active?
	var/speed_activated = FALSE
	/// Should the owner be able to regenerate plasma while the ability is active?
	var/can_plasma_regenerate = TRUE
	/// How much armor should be given while the ability is active?
	var/armor_amount = 0
	/// The attached armor that been given, if any.
	var/datum/armor/attached_armor
	/// Has the speed bonus been given yet?
	var/speed_bonus_active = FALSE
	/// Should weeds be created as they move? If so, how much plasma to consume?
	var/weeding_cost = 0

/datum/action/ability/xeno_action/toggle_speed/remove_action()
	resinwalk_off(TRUE) // Ensure we remove the movespeed
	return ..()

/datum/action/ability/xeno_action/toggle_speed/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(speed_activated)
		return TRUE

/datum/action/ability/xeno_action/toggle_speed/action_activate()
	if(speed_activated)
		resinwalk_off()
		return fail_activate()
	resinwalk_on()
	succeed_activate()

/datum/action/ability/xeno_action/toggle_speed/proc/resinwalk_on(silent = FALSE)
	speed_activated = TRUE
	if(!silent)
		owner.balloon_alert(owner, "resin walk active")
	if(xeno_owner.loc_weeds_type)
		speed_bonus_active = TRUE
		xeno_owner.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
	if(!can_plasma_regenerate)
		ADD_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, HIVELORD_ABILITY_TRAIT)
	if(armor_amount)
		attached_armor = getArmor(armor_amount, armor_amount, armor_amount, armor_amount, armor_amount, armor_amount, armor_amount, armor_amount)
		xeno_owner.soft_armor = xeno_owner.soft_armor.attachArmor(attached_armor)
	set_toggle(TRUE)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(resinwalk_on_moved))

/datum/action/ability/xeno_action/toggle_speed/proc/resinwalk_off(silent = FALSE)
	if(!silent)
		owner.balloon_alert(owner, "resin walk ended")
	if(speed_bonus_active)
		xeno_owner.remove_movespeed_modifier(type)
		speed_bonus_active = FALSE
	speed_activated = FALSE
	if(!can_plasma_regenerate)
		REMOVE_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, HIVELORD_ABILITY_TRAIT)
	if(attached_armor)
		xeno_owner.soft_armor = xeno_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
	set_toggle(FALSE)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/action/ability/xeno_action/toggle_speed/proc/resinwalk_on_moved(datum/source, atom/oldloc, direction, Forced = FALSE)
	SIGNAL_HANDLER
	if(!isturf(xeno_owner.loc) || xeno_owner.plasma_stored < 10)
		owner.balloon_alert(owner, "resin walk ended, no plasma")
		resinwalk_off(TRUE)
		return
	if(!xeno_owner.loc_weeds_type && weeding_cost > 0 && xeno_owner.plasma_stored >= weeding_cost)
		var/obj/alien/weeds/created_weeds = new(xeno_owner.loc)
		SSweeds_decay.decaying_list += created_weeds // Check if it should go away (no nearby node) or stick around (nearby node).
		xeno_owner.handle_weeds_on_movement() // loc_weeds_type is changed here.
		xeno_owner.use_plasma(weeding_cost)
	if(xeno_owner.loc_weeds_type)
		if(!speed_bonus_active)
			speed_bonus_active = TRUE
			xeno_owner.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
		xeno_owner.use_plasma(10)
		return
	if(!speed_bonus_active)
		return
	speed_bonus_active = FALSE
	xeno_owner.remove_movespeed_modifier(type)

/// Sets the `can_plasma_regenerate` variable and handles plasma regeneration accordingly.
/datum/action/ability/xeno_action/toggle_speed/proc/set_plasma(new_plasma_regeneration)
	if(can_plasma_regenerate == new_plasma_regeneration)
		return
	if(speed_activated)
		if(can_plasma_regenerate && !new_plasma_regeneration)
			ADD_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, HIVELORD_ABILITY_TRAIT)
		if(!can_plasma_regenerate && new_plasma_regeneration)
			REMOVE_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, HIVELORD_ABILITY_TRAIT)
	can_plasma_regenerate = new_plasma_regeneration

/// Sets the `armor_amount` variable and changes attached armor accordingly.
/datum/action/ability/xeno_action/toggle_speed/proc/set_armor(new_armor_amount)
	if(armor_amount == new_armor_amount)
		return
	if(speed_activated)
		if(armor_amount && !new_armor_amount)
			xeno_owner.soft_armor = xeno_owner.soft_armor.detachArmor(attached_armor)
			attached_armor = null
		else if(!armor_amount && new_armor_amount)
			attached_armor = new(new_armor_amount, armor_amount, new_armor_amount, new_armor_amount, new_armor_amount, new_armor_amount, new_armor_amount, new_armor_amount)
			xeno_owner.soft_armor = xeno_owner.soft_armor.attachArmor(attached_armor)
		else
			var/diff = new_armor_amount - armor_amount
			xeno_owner.soft_armor = xeno_owner.soft_armor.modifyAllRatings(diff)
			attached_armor = attached_armor.modifyAllRatings(diff)
	armor_amount = new_armor_amount

// ***************************************
// *********** Tunnel
// ***************************************
/datum/action/ability/xeno_action/build_tunnel
	name = "Dig Tunnel"
	action_icon_state = "build_tunnel"
	action_icon = 'icons/Xeno/actions/hivelord.dmi'
	desc = "Create a tunnel entrance. Use again to create the tunnel exit."
	ability_cost = 200
	cooldown_duration = 120 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BUILD_TUNNEL,
	)

/datum/action/ability/xeno_action/build_tunnel/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(owner)
	if(locate(/obj/structure/xeno/tunnel) in T)
		if(!silent)
			T.balloon_alert(owner, "tunnel already here!")
		return
	if(!T.can_dig_xeno_tunnel())
		if(!silent)
			T.balloon_alert(owner, "bad terrain!")
		return FALSE
	if(owner.get_active_held_item())
		if(!silent)
			owner.balloon_alert(owner, "need an empty hand!")
		return FALSE

/datum/action/ability/xeno_action/build_tunnel/on_cooldown_finish()
	to_chat(xeno_owner, span_notice("We are ready to dig a tunnel again."))
	return ..()

/datum/action/ability/xeno_action/build_tunnel/action_activate()
	var/turf/T = get_turf(owner)

	xeno_owner.balloon_alert(xeno_owner, "digging...")
	xeno_owner.visible_message(span_xenonotice("[xeno_owner] begins digging out a tunnel entrance."), \
	span_xenonotice("We begin digging out a tunnel entrance."), null, 5)
	if(!do_after(xeno_owner, HIVELORD_TUNNEL_DIG_TIME, NONE, T, BUSY_ICON_BUILD))
		xeno_owner.balloon_alert(xeno_owner, "digging aborted")
		return fail_activate()

	if(!can_use_action(TRUE))
		return fail_activate()

	T.balloon_alert(xeno_owner, "tunnel dug")
	xeno_owner.visible_message(span_xenonotice("\The [xeno_owner] digs out a tunnel entrance."), \
	span_xenonotice("We dig out a tunnel, connecting it to our network."), null, 5)
	var/obj/structure/xeno/tunnel/newt = new(T, xeno_owner.get_xeno_hivenumber())

	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)

	newt.creator = xeno_owner
	newt.RegisterSignal(xeno_owner, COMSIG_QDELETING, TYPE_PROC_REF(/obj/structure/xeno/tunnel, clear_creator))

	xeno_owner.tunnels.Add(newt)

	add_cooldown()

	to_chat(xeno_owner, span_xenonotice("We now have <b>[LAZYLEN(xeno_owner.tunnels)] of [HIVELORD_TUNNEL_SET_LIMIT]</b> tunnels."))

	newt.tunnel_desc = "[get_area(newt)] (X: [newt.x], Y: [newt.y])"

	xeno_message("[xeno_owner.name] has built a new tunnel at [newt.tunnel_desc]!", "xenoannounce", 5, xeno_owner.hivenumber)

	if(LAZYLEN(xeno_owner.tunnels) > HIVELORD_TUNNEL_SET_LIMIT) //if we exceed the limit, delete the oldest tunnel set.
		var/obj/structure/xeno/tunnel/old_tunnel = xeno_owner.tunnels[1]
		old_tunnel.deconstruct(FALSE)
		to_chat(xeno_owner, span_xenodanger("Having exceeding our tunnel limit, our oldest tunnel has collapsed."))

	succeed_activate()
	playsound(T, 'sound/weapons/pierce.ogg', 25, 1)



// ***************************************
// *********** plasma transfer
// ***************************************
/datum/action/ability/activable/xeno/transfer_plasma/improved
	plasma_transfer_amount = PLASMA_TRANSFER_AMOUNT * 4
	transfer_delay = 0.5 SECONDS
	max_range = 7


/datum/action/ability/xeno_action/place_jelly_pod
	name = "Place Resin Jelly pod"
	action_icon_state = "resin_jelly_pod"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Place down a dispenser that allows xenos to retrieve fireproof jelly."
	ability_cost = 500
	cooldown_duration = 1 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_JELLY_POD,
	)
	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/place_jelly_pod/can_use_action(silent, override_flags, selecting)
	. = ..()
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			T.balloon_alert(owner, "can't place a pod here!")
		return FALSE

	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			T.balloon_alert(owner, "need weeds!")
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

	if(!T.check_alien_construction(owner, silent, /obj/structure/xeno/resin_jelly_pod))
		return FALSE

/datum/action/ability/xeno_action/place_jelly_pod/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(owner, SFX_ALIEN_RESIN_BUILD, 25)
	var/obj/structure/xeno/resin_jelly_pod/pod = new(T, owner.get_xeno_hivenumber())
	to_chat(owner, span_xenonotice("We shape some resin into \a [pod]."))
	add_cooldown()

/datum/action/ability/xeno_action/create_jelly
	name = "Create Resin Jelly"
	action_icon_state = "resin_jelly"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Create a fireproof jelly."
	ability_cost = 100
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE_JELLY,
	)
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED

/datum/action/ability/xeno_action/create_jelly/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(owner.l_hand || owner.r_hand)
		if(!silent)
			owner.balloon_alert(owner, "need both hands to be empty!")
		return FALSE

/datum/action/ability/xeno_action/create_jelly/action_activate()
	var/obj/item/resin_jelly/jelly = new(owner.loc)
	owner.put_in_hands(jelly)
	to_chat(owner, span_xenonotice("We create a globule of resin from our ovipositor.")) // Ewww...
	add_cooldown()
	succeed_activate()

// ***************************************
// *********** Healing Infusion
// ***************************************
/datum/action/ability/activable/xeno/healing_infusion
	name = "Healing Infusion"
	action_icon_state = "healing_infusion"
	action_icon = 'icons/Xeno/actions/hivelord.dmi'
	desc = "Psychically infuses a friendly xeno with regenerative energies, greatly improving its natural healing. Doesn't work if the target can't naturally heal."
	cooldown_duration = 12.5 SECONDS
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HEALING_INFUSION,
	)
	use_state_flags = ABILITY_USE_LYING
	target_flags = ABILITY_MOB_TARGET
	/// The range in which this ability can be used.
	var/heal_range = HIVELORD_HEAL_RANGE
	/// The length of deciseconds that the Resin Jelly Coating status effect will be applied.
	var/resin_jelly_duration = 0 SECONDS
	/// Should the Healing Infusion status effect also give the TRAIT_INNATE_HEALING trait?
	var/innate_healing = FALSE
	/// The amount to multiply the duration, including the amount of healing ticks, of Healing Infusion status effect by. Intervals of 0.1 only to keep duration as a whole number.
	var/status_multiplier = 1

/datum/action/ability/activable/xeno/healing_infusion/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!isxeno(target))
		if(!silent)
			target.balloon_alert(owner, "can only heal xenos!")
		return FALSE
	var/mob/living/carbon/xenomorph/patient = target

	if(!CHECK_BITFIELD(use_state_flags|override_flags, ABILITY_IGNORE_DEAD_TARGET) && patient.stat == DEAD)
		if(!silent)
			target.balloon_alert(owner, "she's dead!")
		return FALSE

	if(!check_distance(target, silent))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_HEALING_INFUSION))
		if(!silent)
			target.balloon_alert(owner, "already infused!")
		return FALSE


/datum/action/ability/activable/xeno/healing_infusion/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > heal_range)
		if(!silent)
			target.balloon_alert(owner, "unreachable!")
			to_chat(owner, span_warning("Too far for our reach... We need to be [dist - heal_range] steps closer!"))
		return FALSE
	else if(!line_of_sight(owner, target))
		if(!silent)
			target.balloon_alert(owner, "no line of sight!")
		return FALSE
	return TRUE


/datum/action/ability/activable/xeno/healing_infusion/use_ability(atom/target)
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

	patient.apply_status_effect(STATUS_EFFECT_HEALING_INFUSION, HIVELORD_HEALING_INFUSION_DURATION * status_multiplier, HIVELORD_HEALING_INFUSION_TICKS * status_multiplier, innate_healing) //per debuffs.dm
	if(resin_jelly_duration)
		patient.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING, resin_jelly_duration)
	succeed_activate()
	add_cooldown()

	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.heals++
	GLOB.round_statistics.hivelord_healing_infusions++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hivelord_healing_infusions")

// ***************************************
// *********** Sow
// ***************************************
/datum/action/ability/xeno_action/sow
	name = "Sow"
	action_icon_state = "place_trap"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Sow the seeds of an alien plant."
	ability_cost = 200
	cooldown_duration = 45 SECONDS
	use_state_flags = ABILITY_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DROP_PLANT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_CHOOSE_PLANT,
	)

/datum/action/ability/xeno_action/sow/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			owner.balloon_alert(owner, "no weeds!")
		return FALSE

	var/turf/T = get_turf(owner)
	if(!T.check_alien_construction(owner, silent, xeno_owner.selected_plant))
		return FALSE

/datum/action/ability/xeno_action/sow/action_activate()
	if(!xeno_owner.selected_plant)
		return FALSE

	playsound(src, SFX_ALIEN_RESIN_BUILD, 25)
	new xeno_owner.selected_plant(get_turf(owner))
	add_cooldown()
	return succeed_activate()

/datum/action/ability/xeno_action/sow/update_button_icon()
	button.overlays.Cut()
	button.overlays += image('icons/Xeno/actions/construction.dmi', button, initial(xeno_owner.selected_plant.name))
	return ..()

///Shows a radial menu to pick the plant they wish to put down when they use the ability
/datum/action/ability/xeno_action/sow/proc/choose_plant()
	var/plant_choice = show_radial_menu(owner, owner, GLOB.plant_images_list, radius = 48)
	if(!plant_choice)
		return
	for(var/obj/structure/xeno/plant/current_plant AS in GLOB.plant_type_list)
		if(initial(current_plant.name) == plant_choice)
			xeno_owner.selected_plant = current_plant
			break
	xeno_owner.balloon_alert(xeno_owner, "[lowertext(plant_choice)]")
	update_button_icon()

/datum/action/ability/xeno_action/sow/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(choose_plant))
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/place_recovery_pylon
	name = "Place Recovery Pylon"
	action_icon_state = "recovery_pylon"
	action_icon = 'icons/Xeno/actions/construction.dmi'
	desc = "Place down a recovery pylon that increases the amount of regeneration power restored."
	ability_cost = 500
	cooldown_duration = 1 MINUTES
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_RECOVERY_PYLON,
	)
	use_state_flags = ABILITY_USE_LYING
	/// How far as a radius will the Recovery Pylon cover? 0 = 1x1, 1 = 3x3, 2 = 5x5, 3 = 7x7, etc.
	var/radius = 1
	/// Should the Recovery Pylon apply a damage modifier instead? If so, how much?
	var/damage_modifier = 0

/datum/action/ability/xeno_action/place_recovery_pylon/can_use_action(silent, override_flags, selecting)
	. = ..()
	var/turf/current_turf = get_turf(owner)
	if(!current_turf || !current_turf.is_weedable() || current_turf.density)
		if(!silent)
			current_turf.balloon_alert(owner, "can't place a pylon here!")
		return FALSE
	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			current_turf.balloon_alert(owner, "no weeds here!")
		return FALSE
	if(!current_turf.check_disallow_alien_fortification(owner, silent))
		return FALSE
	if(!current_turf.check_alien_construction(owner, silent, /obj/structure/xeno/recovery_pylon))
		return FALSE
	var/list/turf/affected_turfs = RANGE_TURFS(1 + radius, xeno_owner) // This prevents overlapping & allows one free space between.
	for(var/turf/affected_turf AS in affected_turfs)
		if(!HAS_TRAIT(affected_turf, TRAIT_RECOVERY_PYLON_TURF))
			continue
		if(!silent)
			current_turf.balloon_alert(owner, "nearby recovery pylon already!")
		return FALSE
	if(LAZYLEN(GLOB.hive_datums[xeno_owner.hivenumber].recovery_pylons) >= HIVELORD_RECOVERY_PYLON_SET_LIMIT)
		if(!silent)
			current_turf.balloon_alert(owner, "maximum recovery pylons made!")
		return FALSE

/datum/action/ability/xeno_action/place_recovery_pylon/action_activate()
	var/obj/structure/xeno/recovery_pylon/recovery_pylon = new(get_turf(xeno_owner), xeno_owner.get_xeno_hivenumber(), radius, damage_modifier)
	to_chat(xeno_owner, span_xenonotice("We shape some resin into \a [recovery_pylon]."))
	playsound(xeno_owner, SFX_ALIEN_RESIN_BUILD, 25)
	succeed_activate()
	add_cooldown()
