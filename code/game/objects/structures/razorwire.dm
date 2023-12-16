/obj/structure/razorwire
	name = "razorwire obstacle"
	desc = "A bundle of barbed wire supported by metal rods. Used to deny access to areas under (literal) pain of entanglement and injury. A classic fortification since the 1900s."
	icon = 'icons/obj/structures/barbedwire.dmi'
	icon_state = "barbedwire_x"
	base_icon_state = "barbedwire_x"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	coverage = 5
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_DEFENSIVE_STRUCTURE|PASS_GRILLE|PASSABLE
	var/list/entangled_list
	var/sheet_type = /obj/item/stack/barbed_wire
	var/sheet_type2 = /obj/item/stack/rods
	var/table_prefix = "" //used in update_icon()
	max_integrity = RAZORWIRE_MAX_HEALTH
	var/soak = 5

/obj/structure/razorwire/deconstruct(disassembled = TRUE)
	if(disassembled)
		if(obj_integrity > max_integrity * 0.5)
			new sheet_type(loc)
		var/obj/item/stack/rods/salvage = new sheet_type2(loc)
		salvage.amount = max(1, round(4 * (obj_integrity / max_integrity) ) )
	else
		if(prob(50))
			new sheet_type(loc)
		if(prob(50))
			var/obj/item/stack/rods/salvage = new sheet_type2(loc)
			salvage.amount = rand(1,4)
	return ..()

/obj/structure/razorwire/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit),
	)
	AddElement(/datum/element/connect_loc, connections)
	AddElement(/datum/element/egrill)
	for(var/obj/structure/razorwire/T in loc)
		if(T != src)
			qdel(T)

/obj/structure/razorwire/proc/on_cross(datum/source, atom/movable/O, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!isliving(O))
		return
	if(CHECK_BITFIELD(O.pass_flags, PASS_DEFENSIVE_STRUCTURE))
		return
	var/mob/living/M = O
	if(M.status_flags & INCORPOREAL)
		return
	if(CHECK_BITFIELD(M.restrained_flags, RESTRAINED_RAZORWIRE))
		return
	if(!M.density)
		return
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	var/def_zone = ran_zone()
	M.apply_damage(RAZORWIRE_BASE_DAMAGE, BRUTE, def_zone, MELEE, TRUE, updating_health = TRUE)
	razorwire_tangle(M)

/obj/structure/razorwire/proc/razorwire_tangle(mob/living/entangled, duration = RAZORWIRE_ENTANGLE_DELAY)
	if(QDELETED(src)) //Sanity check so that you can't get entangled if the razorwire is destroyed; this happens apparently.
		CRASH("QDELETED razorwire called razorwire_tangle()")
	TIMER_COOLDOWN_START(entangled, COOLDOWN_ENTANGLE, duration)
	entangled.visible_message(span_danger("[entangled] gets entangled in the barbed wire!"),
	span_danger("You got entangled in the barbed wire! Resist to untangle yourself after [duration * 0.1] seconds since you were entangled!"), null, null, 5)
	do_razorwire_tangle(entangled)


/obj/structure/razorwire/proc/do_razorwire_tangle(mob/living/entangled)
	ADD_TRAIT(entangled, TRAIT_IMMOBILE, type)
	ENABLE_BITFIELD(entangled.restrained_flags, RESTRAINED_RAZORWIRE)
	LAZYADD(entangled_list, entangled) //Add the entangled person to the trapped list.
	RegisterSignal(entangled, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against))
	RegisterSignal(entangled, COMSIG_QDELETING, PROC_REF(do_razorwire_untangle))
	RegisterSignal(entangled, COMSIG_MOVABLE_PULL_MOVED, PROC_REF(razorwire_untangle))


/obj/structure/razorwire/resisted_against(datum/source)
	var/mob/living/entangled = source
	if(TIMER_COOLDOWN_CHECK(entangled, COOLDOWN_ENTANGLE))
		entangled.visible_message(span_danger("[entangled] attempts to disentangle itself from [src] but is unsuccessful!"),
		span_warning("You fail to disentangle yourself!"))
		return FALSE
	return razorwire_untangle(entangled)

/obj/structure/razorwire/proc/razorwire_untangle(mob/living/entangled)
	SIGNAL_HANDLER
	if((entangled.pass_flags & PASS_DEFENSIVE_STRUCTURE) || entangled.status_flags & INCORPOREAL)
		return
	do_razorwire_untangle(entangled)
	visible_message(span_danger("[entangled] disentangles from [src]!"))
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, TRUE)
	var/def_zone = ran_zone()
	entangled.apply_damage(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, BRUTE, def_zone, MELEE, TRUE, updating_health = TRUE) //Apply damage as we tear free
	return TRUE


///This proc is used for signals, so if you plan on adding a second argument, or making it return a value, then change those RegisterSignal's referncing it first.
/obj/structure/razorwire/proc/do_razorwire_untangle(mob/living/entangled)
	SIGNAL_HANDLER
	UnregisterSignal(entangled, list(COMSIG_QDELETING, COMSIG_LIVING_DO_RESIST, COMSIG_MOVABLE_PULL_MOVED))
	LAZYREMOVE(entangled_list, entangled)
	DISABLE_BITFIELD(entangled.restrained_flags, RESTRAINED_RAZORWIRE)
	REMOVE_TRAIT(entangled, TRAIT_IMMOBILE, type)


/obj/structure/razorwire/proc/on_exited(datum/source, atom/movable/AM, direction)
	if(!isliving(AM))
		return
	var/mob/living/crossing_mob = AM
	if(CHECK_BITFIELD(crossing_mob.restrained_flags, RESTRAINED_RAZORWIRE))
		razorwire_untangle(AM)

/obj/structure/razorwire/Destroy()
	for(var/i in entangled_list)
		do_razorwire_untangle(i)
	return ..()


/obj/structure/razorwire/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal_sheets = I

		visible_message(span_notice("[user] begins to repair  \the [src]."))

		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!metal_sheets.use(1))
			return

		repair_damage(max_integrity * 0.30, user)
		visible_message(span_notice("[user] repairs \the [src]."))
		update_icon()
		return

	if(!istype(I, /obj/item/grab))
		return
	if(isxeno(user))//I am very tempted to remove this >:)
		return

	var/obj/item/grab/G = I
	if(!isliving(G.grabbed_thing))
		return

	var/mob/living/M = G.grabbed_thing
	if(user.a_intent == INTENT_HARM)
		if(user.grab_state <= GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return

		var/def_zone = ran_zone()
		M.apply_damage(RAZORWIRE_BASE_DAMAGE, BRUTE, def_zone, MELEE, TRUE, updating_health = TRUE)
		user.visible_message(span_danger("[user] spartas [M]'s into [src]!"),
		span_danger("You sparta [M]'s against [src]!"))
		log_combat(user, M, "spartaed", "", "against \the [src]")
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

	else if(user.grab_state >= GRAB_AGGRESSIVE)
		M.forceMove(loc)
		M.Paralyze(10 SECONDS)
		user.visible_message(span_danger("[user] throws [M] on [src]."),
		span_danger("You throw [M] on [src]."))

/obj/structure/razorwire/wirecutter_act(mob/living/user, obj/item/I)
	user.visible_message(span_notice("[user] starts disassembling [src]."),
	span_notice("You start disassembling [src]."))
	var/delay_disassembly = SKILL_TASK_AVERAGE - (0.5 SECONDS + user.skills.getRating(SKILL_ENGINEER))

	if(!do_after(user, delay_disassembly, NONE, src, BUSY_ICON_BUILD))
		return TRUE

	user.visible_message(span_notice("[user] disassembles [src]."),
	span_notice("You disassemble [src]."))
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	deconstruct(TRUE)
	return TRUE

/obj/structure/razorwire/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	X.apply_damage(RAZORWIRE_BASE_DAMAGE, blocked = MELEE, updating_health = TRUE) //About a third as damaging as actually entering
	update_icon()
	return ..()

/obj/structure/razorwire/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			visible_message(span_danger("[src] is blown apart!"))
			deconstruct(FALSE)
			return
		if(EXPLODE_HEAVY)
			take_damage(rand(33, 66), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 33), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(10, BRUTE, BOMB)
	update_icon()


/obj/structure/razorwire/CanAllowThrough(atom/movable/mover, turf/target)
	if(mover.throwing && ismob(mover) && !(mover.pass_flags & PASS_DEFENSIVE_STRUCTURE))
		return FALSE

	return ..()

/obj/structure/razorwire/update_icon_state()
	var/health_percent = round(obj_integrity/max_integrity * 100)
	var/remaining = CEILING(health_percent, 25)
	icon_state = "[base_icon_state]_[remaining]"

/obj/structure/razorwire/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(2 * S.strength, BURN, ACID)
