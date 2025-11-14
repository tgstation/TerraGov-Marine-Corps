
/datum/action/ability/xeno_action/timestop
	name = "Time stop"
	action_icon_state = "time_stop"
	action_icon = 'icons/Xeno/actions/wraith.dmi'
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
	action_icon = 'icons/Xeno/actions/wraith.dmi'
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

/datum/action/ability/xeno_action/portal/can_use_action(silent, override_flags, selecting)
	if(locate(/obj/effect/wraith_portal) in get_turf(owner))
		if(!silent)
			to_chat(owner, span_xenowarning("There is already a portal here!"))
		return FALSE
	var/area/area = get_area(owner)
	if(area.area_flags & MARINE_BASE)
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
	resistance_flags = UNACIDABLE | CRUSHER_IMMUNE
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

/obj/effect/wraith_portal/ex_act()
	if(linked_portal)
		qdel(linked_portal)
	qdel(src)

/obj/effect/wraith_portal/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!linked_portal)
		return
	user.forceMove(get_turf(linked_portal))

/obj/effect/wraith_portal/lava_act()
	return

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
	if(!linked_portal || !COOLDOWN_FINISHED(src, portal_cooldown) || crosser.anchored || (crosser.resistance_flags & PORTAL_IMMUNE))
		return
	if(isxeno(crosser))
		var/mob/living/carbon/xenomorph/xeno_crosser = crosser
		if(xeno_crosser.m_intent == MOVE_INTENT_WALK)
			return
	COOLDOWN_START(linked_portal, portal_cooldown, 1)
	crosser.remove_pass_flags(PASS_MOB, PORTAL_TRAIT)
	RegisterSignal(crosser, COMSIG_MOVABLE_MOVED, PROC_REF(do_teleport_atom))
	playsound(loc, 'sound/effects/portal.ogg', 20)

/// Signal handler to teleport the crossing atom when its move is done
/obj/effect/wraith_portal/proc/do_teleport_atom(atom/movable/crosser)
	SIGNAL_HANDLER
	for(var/mob/rider AS in crosser.buckled_mobs)
		if(ishuman(rider))
			crosser.unbuckle_mob(rider)
	if(crosser.throwing)
		crosser.throw_source = get_turf(linked_portal)
	crosser.Move(get_turf(linked_portal), crosser.dir)
	UnregisterSignal(crosser, COMSIG_MOVABLE_MOVED)

/// Signal handler for teleporting a crossing bullet
/obj/effect/wraith_portal/proc/teleport_bullet(datum/source, atom/movable/projectile/bullet)
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
	layer = OPEN_DOOR_LAYER
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

/datum/action/ability/activable/xeno/rewind
	name = "Time Shift"
	action_icon_state = "rewind"
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	desc = "Save the location and status of the target. When the time is up, the target location and status are restored, unless the target is dead, unconscious, or changed z-levels."
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
	///Holder for the rewind timer
	var/rewind_timer

/datum/action/ability/activable/xeno/rewind/Destroy()
	cancel_timeshift()
	return ..()

/datum/action/ability/activable/xeno/rewind/can_use_ability(atom/A, silent, override_flags)
	. = ..()

	if(A == owner)
		if(!silent)
			owner.balloon_alert(owner, "Cannot rewind self")
		return FALSE

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
	rewind_timer = addtimer(CALLBACK(src, PROC_REF(start_rewinding)), start_rewinding, TIMER_STOPPABLE)
	RegisterSignal(targeted, COMSIG_MOVABLE_MOVED, PROC_REF(save_move))
	RegisterSignal(targeted, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(cancel_timeshift))
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
	UnregisterSignal(targeted, COMSIG_MOVABLE_Z_CHANGED)
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
		new /obj/effect/temp_visual/after_image(targeted.loc, targeted)

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
		rewind_timer = null
		return

	targeted.Move(loc_b, get_dir(loc_b, loc_a))
	new /obj/effect/temp_visual/after_image(loc_a, targeted)
	INVOKE_NEXT_TICK(src, PROC_REF(rewind))

// Removes all things associated while someone is being timeshifted, effectively stopping it from happening/continuing.
/datum/action/ability/activable/xeno/rewind/proc/cancel_timeshift()
	SIGNAL_HANDLER
	last_target_locs_list = null
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TIMESHIFT_TRAIT)
	if(rewind_timer)
		deltimer(rewind_timer)
	if(!QDELETED(targeted))
		targeted.remove_filter("prerewind_blur")
		targeted.remove_filter("rewind_blur")
		targeted.status_flags &= ~(INCORPOREAL|GODMODE)
		UnregisterSignal(targeted, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(targeted, COMSIG_MOVABLE_Z_CHANGED)
		REMOVE_TRAIT(targeted, TRAIT_TIME_SHIFTED, XENO_TRAIT)
		targeted = null
