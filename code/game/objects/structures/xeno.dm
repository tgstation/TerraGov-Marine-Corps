
/*
* effect/alien
*/
/obj/alien
	name = "alien thing"
	desc = "theres something alien about this"
	icon = 'icons/Xeno/Effects.dmi'
	hit_sound = "alien_resin_break"
	anchored = TRUE
	max_integrity = 1
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	var/on_fire = FALSE
	///Set this to true if this object isn't destroyed when the weeds under it is.
	var/ignore_weed_destruction = FALSE

/obj/alien/Initialize()
	. = ..()
	if(!ignore_weed_destruction)
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, .proc/weed_removed)
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/// Destroy the alien effect when the weed it was on is destroyed
/obj/alien/proc/weed_removed()
	SIGNAL_HANDLER
	obj_destruction(damage_flag = "melee")

/obj/alien/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(user.a_intent == INTENT_HARM) //Already handled at the parent level.
		return

	if(obj_flags & CAN_BE_HIT)
		return I.attack_obj(src, user)


/obj/alien/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(istype(O, /obj/vehicle/multitile/hitbox/cm_armored))
		tank_collision(O)

/obj/alien/flamer_fire_act(burnlevel)
	take_damage(burnlevel * 2, BURN, "fire")

/obj/alien/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500)
		if(EXPLODE_HEAVY)
			take_damage((rand(140, 300)))
		if(EXPLODE_LIGHT)
			take_damage((rand(50, 100)))

/obj/alien/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		take_damage(rand(2, 20) * 0.1)

/*
* Resin
*/
/obj/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE


/obj/alien/resin/attack_hand(mob/living/user)
	balloon_alert(user, "You only scrape at it")
	return TRUE


/obj/alien/resin/sticky
	name = STICKY_RESIN
	desc = "A layer of disgusting sticky slime."
	icon_state = "sticky"
	density = FALSE
	opacity = FALSE
	max_integrity = 36
	layer = RESIN_STRUCTURE_LAYER
	hit_sound = "alien_resin_move"
	var/slow_amt = 8

	ignore_weed_destruction = TRUE

/obj/alien/resin/sticky/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/slow_down_crosser
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/alien/resin/sticky/proc/slow_down_crosser(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER
	if(crosser.throwing || crosser.buckled)
		return

	if(isvehicle(crosser))
		var/obj/vehicle/vehicle = crosser
		vehicle.last_move_time += slow_amt
		return

	if(!ishuman(crosser))
		return

	if(CHECK_MULTIPLE_BITFIELDS(crosser.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += slow_amt

/obj/alien/resin/sticky/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.a_intent == INTENT_HARM) //Clear it out on hit; no need to double tap.
		X.do_attack_animation(src, ATTACK_EFFECT_CLAW) //SFX
		playsound(src, "alien_resin_break", 25) //SFX
		deconstruct(TRUE)
		return

	return ..()

// Praetorian Sticky Resin spit uses this.
/obj/alien/resin/sticky/thin
	name = "thin sticky resin"
	desc = "A thin layer of disgusting sticky slime."
	max_integrity = 6
	slow_amt = 4

	ignore_weed_destruction = FALSE

//Resin Doors
/obj/structure/mineral_door/resin
	name = RESIN_DOOR
	mineralType = "resin"
	icon = 'icons/Xeno/Effects.dmi'
	hardness = 1.5
	layer = RESIN_STRUCTURE_LAYER
	max_integrity = 100
	smoothing_behavior = CARDINAL_SMOOTHING
	smoothing_groups = SMOOTH_XENO_STRUCTURES
	var/close_delay = 10 SECONDS

/obj/structure/mineral_door/resin/Initialize()
	. = ..()

	if(!locate(/obj/alien/weeds) in loc)
		new /obj/alien/weeds(loc)
	if(locate(/mob/living) in loc)	//If we build a door below ourselves, it starts open.
		Open()

/obj/structure/mineral_door/resin/Cross(atom/movable/mover, turf/target)
	. = ..()
	if(!. && isxeno(mover))
		Open()
		return TRUE


/obj/structure/mineral_door/resin/attack_larva(mob/living/carbon/xenomorph/larva/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE
	TryToSwitchState(M)
	return TRUE

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	var/turf/cur_loc = X.loc
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(X.a_intent != INTENT_HARM)
		TryToSwitchState(X)
		return TRUE

	src.balloon_alert(X, "Destroying...")
	playsound(src, "alien_resin_break", 25)
	if(do_after(X, 4 SECONDS, FALSE, src, BUSY_ICON_HOSTILE))
		src.balloon_alert(X, "Destroyed")
		qdel(src)

/obj/structure/mineral_door/resin/flamer_fire_act(burnlevel)
	take_damage(burnlevel * 2, BURN, "fire")

/turf/closed/wall/resin/fire_act()
	take_damage(50, BURN, "fire")

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isxeno(user))
		return ..()

/obj/structure/mineral_door/resin/Open()
	if(state || !loc)
		return //already open
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]opening",src)
	density = FALSE
	set_opacity(FALSE)
	state = 1
	update_icon()
	addtimer(CALLBACK(src, .proc/Close), close_delay)

/obj/structure/mineral_door/resin/Close()
	if(!state || !loc ||isSwitchingStates)
		return //already closed
	//Can't close if someone is blocking it
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			addtimer(CALLBACK(src, .proc/Close), close_delay)
			return
	isSwitchingStates = TRUE
	playsound(loc, "alien_resin_move", 25)
	flick("[mineralType]closing",src)
	addtimer(CALLBACK(src, .proc/do_close), 1 SECONDS)

/// Change the icon and density of the door
/obj/structure/mineral_door/resin/proc/do_close()
	density = TRUE
	set_opacity(TRUE)
	state = 0
	update_icon()
	isSwitchingStates = 0
	for(var/turf/turf in locs)
		if(locate(/mob/living) in turf)
			Open()
			return

/obj/structure/mineral_door/resin/Dismantle(devastated = 0)
	qdel(src)

/obj/structure/mineral_door/resin/CheckHardness()
	playsound(loc, "alien_resin_move", 25)
	..()

/obj/structure/mineral_door/resin/Destroy()
	var/turf/T
	for(var/i in GLOB.cardinals)
		T = get_step(loc, i)
		if(!istype(T))
			continue
		for(var/obj/structure/mineral_door/resin/R in T)
			INVOKE_NEXT_TICK(R, .proc/check_resin_support)
	return ..()


//do we still have something next to us to support us?
/obj/structure/mineral_door/resin/proc/check_resin_support()
	var/turf/T
	for(var/i in GLOB.cardinals)
		T = get_step(src, i)
		if(T.density)
			. = TRUE
			break
		if(locate(/obj/structure/mineral_door/resin) in T)
			. = TRUE
			break
	if(!.)
		src.balloon_alert_to_viewers("Collapsed")
		qdel(src)

/obj/structure/mineral_door/resin/thick
	max_integrity = 160
	hardness = 2.0

/obj/item/resin_jelly
	name = "resin jelly"
	desc = "A foul, viscous resin jelly that doesnt seem to burn easily."
	icon = 'icons/unused/Marine_Research.dmi'
	icon_state = "biomass"
	soft_armor = list("fire" = 200)
	var/immune_time = 15 SECONDS
	///Holder to ensure only one user per resin jelly.
	var/current_user

/obj/item/resin_jelly/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.xeno_caste.can_flags & CASTE_CAN_HOLD_JELLY)
		return attack_hand(X)
	if(X.do_actions || !isnull(current_user))
		return
	current_user = X
	X.balloon_alert(X, "Applying...")
	if(!do_after(X, RESIN_SELF_TIME, TRUE, X, BUSY_ICON_MEDICAL))
		current_user = null
		return
	activate_jelly(X)

/obj/item/resin_jelly/attack_self(mob/living/carbon/xenomorph/user)
	//Activates if the item itself is clicked in hand.
	if(!isxeno(user))
		return
	if(user.do_actions || !isnull(current_user))
		return
	current_user = user
	user.balloon_alert(user, "Applying...")
	if(!do_after(user, RESIN_SELF_TIME, TRUE, user, BUSY_ICON_MEDICAL))
		current_user = null
		return
	activate_jelly(user)

/obj/item/resin_jelly/attack(mob/living/carbon/xenomorph/M, mob/living/user)
	//Activates if active hand and clicked on mob in game.
	//Can target self so we need to check for that.
	if(!isxeno(user))
		return TRUE
	if(!isxeno(M))
		M.balloon_alert(user, "Cannot apply")
		return FALSE
	if(user.do_actions || !isnull(current_user))
		return FALSE
	current_user = M
	M.balloon_alert(user, "Applying...")
	if(M != user)
		user.balloon_alert(M, "Applying jelly...") //Notify recipient to not move.
	if(!do_after(user, (M == user ? RESIN_SELF_TIME : RESIN_OTHER_TIME), TRUE, M, BUSY_ICON_MEDICAL))
		current_user = null
		return FALSE
	activate_jelly(M)
	user.temporarilyRemoveItemFromInventory(src)
	return FALSE

/obj/item/resin_jelly/proc/activate_jelly(mob/living/carbon/xenomorph/user)
	user.visible_message(span_notice("[user]'s chitin begins to gleam with an unseemly glow..."), span_xenonotice("We feel powerful as we are covered in [src]!"))
	user.emote("roar")
	user.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	qdel(src)

/obj/item/resin_jelly/throw_at(atom/target, range, speed, thrower, spin, flying)
	if(isxenohivelord(thrower))
		RegisterSignal(src, COMSIG_MOVABLE_IMPACT, .proc/jelly_throw_hit)
	. = ..()

/obj/item/resin_jelly/proc/jelly_throw_hit(datum/source, atom/hit_atom)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!isxeno(hit_atom))
		return
	var/mob/living/carbon/xenomorph/X = hit_atom
	if(X.fire_resist_modifier <= -20 || X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	X.visible_message(span_notice("[X] is splattered with jelly!"))
	INVOKE_ASYNC(src, .proc/activate_jelly, X)
