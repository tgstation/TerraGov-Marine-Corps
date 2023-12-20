
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

/obj/alien/Initialize(mapload)
	. = ..()
	if(!ignore_weed_destruction)
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, PROC_REF(weed_removed))

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

/obj/alien/flamer_fire_act(burnlevel)
	take_damage(burnlevel * 2, BURN, FIRE)

/obj/alien/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage((rand(140, 300)), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage((rand(50, 100)), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 50), BRUTE, BOMB)

/obj/alien/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		take_damage(rand(2, 20) * 0.1, BURN, ACID)

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
	/// Does this refund build points when destoryed?
	var/refundable = TRUE

	ignore_weed_destruction = TRUE

/obj/alien/resin/sticky/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(slow_down_crosser)
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

	if(CHECK_MULTIPLE_BITFIELDS(crosser.allow_pass_flags, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += slow_amt

/obj/alien/resin/sticky/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.a_intent == INTENT_HARM) //Clear it out on hit; no need to double tap.
		if(CHECK_BITFIELD(SSticker.mode?.flags_round_type, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active && refundable)
			SSresinshaping.quickbuild_points_by_hive[X.hivenumber]++
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
	refundable = FALSE

//Resin Doors
/obj/structure/mineral_door/resin
	name = RESIN_DOOR
	icon = 'icons/obj/smooth_objects/resin-door.dmi'
	icon_state = "resin-door-1"
	base_icon_state = "resin-door"
	layer = RESIN_STRUCTURE_LAYER
	max_integrity = 100
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_XENO_STRUCTURES)
	canSmoothWith = list(
		SMOOTH_GROUP_XENO_STRUCTURES,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_MINERAL_STRUCTURES,
	)
	soft_armor = list(MELEE = 33, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 15, BIO = 0, FIRE = 0, ACID = 0)
	trigger_sound = "alien_resin_move"
	hit_sound = "alien_resin_move"
	destroy_sound = "alien_resin_move"

	///The delay before the door closes automatically after being open
	var/close_delay = 10 SECONDS
	///The timer that tracks the delay above
	var/closetimer

/obj/structure/mineral_door/resin/smooth_icon()
	. = ..()
	update_icon()

/obj/structure/mineral_door/resin/Initialize(mapload)
	. = ..()
	if(!locate(/obj/alien/weeds) in loc)
		new /obj/alien/weeds(loc)


/obj/structure/mineral_door/resin/Cross(atom/movable/mover, turf/target)
	. = ..()
	if(!. && isxeno(mover) && !open)
		toggle_state()
		return TRUE


/obj/structure/mineral_door/resin/attack_larva(mob/living/carbon/xenomorph/larva/M)
	var/turf/cur_loc = M.loc
	if(!istype(cur_loc))
		return FALSE
	try_toggle_state(M)
	return TRUE

//clicking on resin doors attacks them, or opens them without harm intent
/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	var/turf/cur_loc = X.loc
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(X.a_intent != INTENT_HARM)
		try_toggle_state(X)
		return TRUE
	if(CHECK_BITFIELD(SSticker.mode?.flags_round_type, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		SSresinshaping.quickbuild_points_by_hive[X.hivenumber]++
		qdel(src)
		return TRUE

	src.balloon_alert(X, "Destroying...")
	playsound(src, "alien_resin_break", 25)
	if(do_after(X, 1 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_HOSTILE))
		src.balloon_alert(X, "Destroyed")
		qdel(src)

/obj/structure/mineral_door/resin/flamer_fire_act(burnlevel)
	take_damage(burnlevel * 2, BURN, FIRE)

/obj/structure/mineral_door/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel()
		if(EXPLODE_HEAVY)
			qdel()
		if(EXPLODE_LIGHT)
			take_damage((rand(50, 60)), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(30, BRUTE, BOMB)

/turf/closed/wall/resin/fire_act()
	take_damage(50, BURN, FIRE)

/obj/structure/mineral_door/resin/try_toggle_state(atom/user)
	if(isxeno(user))
		return ..()

/obj/structure/mineral_door/resin/toggle_state()
	. = ..()
	if(open)
		closetimer = addtimer(CALLBACK(src, PROC_REF(do_close)), close_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	else
		deltimer(closetimer)
		closetimer = null

/// Toggle(close) the door. Used for the timer's callback.
/obj/structure/mineral_door/resin/proc/do_close()
	if(locate(/mob/living) in loc) //there is a mob in the door, abort and reschedule the close
		closetimer = addtimer(CALLBACK(src, PROC_REF(do_close)), close_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
		return
	if(!open) //we got closed in the meantime
		return
	flick("[icon_state]-closing", src)
	toggle_state()

/obj/structure/mineral_door/resin/Destroy()
	var/turf/T
	for(var/i in GLOB.cardinals)
		T = get_step(loc, i)
		if(!istype(T))
			continue
		for(var/obj/structure/mineral_door/resin/R in T)
			INVOKE_NEXT_TICK(R, PROC_REF(check_resin_support))
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

/obj/item/resin_jelly
	name = "resin jelly"
	desc = "A foul, viscous resin jelly that doesnt seem to burn easily."
	icon = 'icons/unused/Marine_Research.dmi'
	icon_state = "biomass"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 200, ACID = 0)
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
	if(!do_after(X, RESIN_SELF_TIME, NONE, X, BUSY_ICON_MEDICAL))
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
	if(!do_after(user, RESIN_SELF_TIME, NONE, user, BUSY_ICON_MEDICAL))
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
	if(!do_after(user, (M == user ? RESIN_SELF_TIME : RESIN_OTHER_TIME), NONE, M, BUSY_ICON_MEDICAL))
		current_user = null
		return FALSE
	activate_jelly(M)
	user.temporarilyRemoveItemFromInventory(src)
	return FALSE

/obj/item/resin_jelly/proc/activate_jelly(mob/living/carbon/xenomorph/user)
	user.visible_message(span_notice("[user]'s chitin begins to gleam with an unseemly glow..."), span_xenonotice("We feel powerful as we are covered in [src]!"))
	user.emote("roar")
	user.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	SEND_SIGNAL(user, COMSIG_XENOMORPH_RESIN_JELLY_APPLIED)
	qdel(src)

/obj/item/resin_jelly/throw_at(atom/target, range, speed, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	if(isxenohivelord(thrower))
		RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(jelly_throw_hit))
	. = ..()

/obj/item/resin_jelly/proc/jelly_throw_hit(datum/source, atom/hit_atom)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!isxeno(hit_atom))
		return
	var/mob/living/carbon/xenomorph/X = hit_atom
	if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	X.visible_message(span_notice("[X] is splattered with jelly!"))
	INVOKE_ASYNC(src, PROC_REF(activate_jelly), X)
