
/*
* effect/alien
*/
/obj/effect/alien
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

/obj/effect/alien/Initialize()
	. = ..()
	if(!ignore_weed_destruction)
		RegisterSignal(loc, COMSIG_TURF_WEED_REMOVED, .proc/weed_removed)

/// Destroy the alien effect when the weed it was on is destroyed
/obj/effect/alien/proc/weed_removed()
	SIGNAL_HANDLER
	obj_destruction(damage_flag = "melee")

/obj/effect/alien/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(user.a_intent == INTENT_HARM) //Already handled at the parent level.
		return

	if(obj_flags & CAN_BE_HIT)
		return I.attack_obj(src, user)


/obj/effect/alien/Crossed(atom/movable/O)
	. = ..()
	if(!QDELETED(src) && istype(O, /obj/vehicle/multitile/hitbox/cm_armored))
		tank_collision(O)

/obj/effect/alien/flamer_fire_act()
	take_damage(50, BURN, "fire")

/obj/effect/alien/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500)
		if(EXPLODE_HEAVY)
			take_damage((rand(140, 300)))
		if(EXPLODE_LIGHT)
			take_damage((rand(50, 100)))

/obj/effect/alien/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_BLISTERING))
		take_damage(rand(2, 20) * 0.1)

/*
* Resin
*/
/obj/effect/alien/resin
	name = "resin"
	desc = "Looks like some kind of slimy growth."
	icon_state = "Resin1"
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE


/obj/effect/alien/resin/attack_hand(mob/living/user)
	to_chat(usr, span_warning("You scrape ineffectively at \the [src]."))
	return TRUE


/obj/effect/alien/resin/sticky
	name = "sticky resin"
	desc = "A layer of disgusting sticky slime."
	icon_state = "sticky"
	density = FALSE
	opacity = FALSE
	max_integrity = 36
	layer = RESIN_STRUCTURE_LAYER
	hit_sound = "alien_resin_move"
	var/slow_amt = 8

	ignore_weed_destruction = TRUE

/obj/effect/alien/resin/sticky/Initialize()
	. = ..()
	AddElement(/datum/element/slowing_on_crossed, slow_amt)

/obj/effect/alien/resin/sticky/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.a_intent == INTENT_HARM) //Clear it out on hit; no need to double tap.
		X.do_attack_animation(src, ATTACK_EFFECT_CLAW) //SFX
		playsound(src, "alien_resin_break", 25) //SFX
		deconstruct(TRUE)
		return

	return ..()

// Praetorian Sticky Resin spit uses this.
/obj/effect/alien/resin/sticky/thin
	name = "thin sticky resin"
	desc = "A thin layer of disgusting sticky slime."
	max_integrity = 6
	slow_amt = 4

	ignore_weed_destruction = FALSE

//Resin Doors
/obj/structure/mineral_door/resin
	name = "resin door"
	mineralType = "resin"
	icon = 'icons/Xeno/Effects.dmi'
	hardness = 1.5
	layer = RESIN_STRUCTURE_LAYER
	max_integrity = 50
	var/close_delay = 10 SECONDS

	tiles_with = list(/turf/closed, /obj/structure/mineral_door/resin)

/obj/structure/mineral_door/resin/Initialize()
	. = ..()

	relativewall()
	relativewall_neighbours()
	if(!locate(/obj/effect/alien/weeds) in loc)
		new /obj/effect/alien/weeds(loc)

/obj/structure/mineral_door/resin/CanAllowThrough(atom/movable/mover, turf/target)
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

	X.visible_message(span_warning("\The [X] digs into \the [src] and begins ripping it down."), \
	span_warning("We dig into \the [src] and begin ripping it down."), null, 5)
	playsound(src, "alien_resin_break", 25)
	if(do_after(X, 4 SECONDS, FALSE, src, BUSY_ICON_HOSTILE))
		X.visible_message(span_danger("[X] rips down \the [src]!"), \
		span_danger("We rip down \the [src]!"), null, 5)
		qdel(src)

/obj/structure/mineral_door/resin/flamer_fire_act()
	take_damage(50, BURN, "fire")

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
	opacity = FALSE
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
	opacity = TRUE
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
	relativewall_neighbours()
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
		visible_message("<span class = 'notice'>[src] collapses from the lack of support.</span>")
		qdel(src)

/obj/structure/mineral_door/resin/thick
	name = "thick resin door"
	max_integrity = 160
	hardness = 2.0

/obj/item/resin_jelly
	name = "resin jelly"
	desc = "A foul, viscous resin jelly that doesnt seem to burn easily."
	icon = 'icons/unused/Marine_Research.dmi'
	icon_state = "biomass"
	soft_armor = list("fire" = 200)
	var/immune_time = 15 SECONDS

/obj/item/resin_jelly/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(X.xeno_caste.caste_flags & CASTE_CAN_HOLD_JELLY)
		return attack_hand(X)
	if(X.do_actions)
		return
	X.visible_message(span_notice("[X] starts to cover themselves in a foul substance..."), span_xenonotice("We begin to cover ourselves in a foul substance..."))
	if(!do_after(X, 2 SECONDS, TRUE, X, BUSY_ICON_MEDICAL))
		return
	activate_jelly(X)

/obj/item/resin_jelly/attack_self(mob/living/carbon/xenomorph/user)
	if(!isxeno(user))
		return
	if(user.do_actions)
		return
	user.visible_message(span_notice("[user] starts to cover themselves in a foul substance..."), span_xenonotice("We begin to cover ourselves in a foul substance..."))
	if(!do_after(user, 2 SECONDS, TRUE, user, BUSY_ICON_MEDICAL))
		return
	activate_jelly(user)

/obj/item/resin_jelly/attack(mob/living/carbon/xenomorph/M, mob/living/user)
	if(!isxeno(user))
		return TRUE
	if(!isxeno(M))
		to_chat(user, span_xenonotice("We cannot apply the [src] to this creature."))
		return FALSE
	if(user.do_actions)
		return FALSE
	if(!do_after(user, 1 SECONDS, TRUE, M, BUSY_ICON_MEDICAL))
		return FALSE
	user.visible_message(span_notice("[user] smears a viscous substance on [M]."),span_xenonotice("We carefully smear [src] onto [user]."))
	activate_jelly(M)
	user.temporarilyRemoveItemFromInventory(src)
	return FALSE

/obj/item/resin_jelly/proc/activate_jelly(mob/living/carbon/xenomorph/user)
	user.visible_message(span_notice("[user]'s chitin begins to gleam with an unseemly glow..."), span_xenonotice("We feel powerful as we are covered in [src]!"))
	user.emote("roar")
	user.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	qdel(src)

/obj/item/resin_jelly/throw_at(atom/target, range, speed, thrower, spin, flying)
	. = ..()
	if(isxenohivelord(thrower))
		RegisterSignal(src, COMSIG_MOVABLE_IMPACT, .proc/jelly_throw_hit)

/obj/item/resin_jelly/proc/jelly_throw_hit(datum/source, atom/hit_atom)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!isxeno(hit_atom))
		return
	var/mob/living/carbon/xenomorph/X = hit_atom
	if(X.fire_resist_modifier <= -20)
		return
	X.visible_message(span_notice("[X] is splattered with jelly!"))
	INVOKE_ASYNC(src, .proc/activate_jelly, X)
