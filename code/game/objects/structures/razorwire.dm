/obj/structure/razorwire
	name = "razorwire obstacle"
	desc = "A bundle of barbed wire supported by metal rods. Used to deny access to areas under (literal) pain of entanglement and injury. A classic fortification since the 1900s."
	icon = 'icons/obj/structures/barbedwire.dmi'
	icon_state = "barbedwire_x"
	var/base_icon_state = "barbedwire_x"
	density = TRUE
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER
	throwpass = TRUE	//You can throw objects over this
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
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
		salvage.amount = min(1, round(4 * (obj_integrity / max_integrity) ) )
	else
		if(prob(50))
			new sheet_type(loc)
		if(prob(50))
			var/obj/item/stack/rods/salvage = new sheet_type2(loc)
			salvage.amount = rand(1,4)
	return ..()

/obj/structure/razorwire/Initialize()
	. = ..()
	AddElement(/datum/element/egrill)
	for(var/obj/structure/razorwire/T in loc)
		if(T != src)
			qdel(T)

/obj/structure/razorwire/Crossed(atom/movable/O)
	. = ..()
	if(!isliving(O))
		return
	if(CHECK_BITFIELD(O.flags_pass, PASSSMALLSTRUCT))
		return
	var/mob/living/M = O
	if(CHECK_BITFIELD(M.restrained_flags, RESTRAINED_RAZORWIRE))
		return
	if(!M.density)
		return
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	var/armor_block = null
	var/def_zone = ran_zone()
	armor_block = M.run_armor_check(def_zone, "melee")
	M.apply_damage(RAZORWIRE_BASE_DAMAGE, BRUTE, def_zone, armor_block, TRUE, updating_health = TRUE)
	razorwire_tangle(M)

/obj/structure/razorwire/CheckExit(atom/movable/mover, turf/target)
	. = ..()
	if(CHECK_BITFIELD(mover.flags_pass, PASSSMALLSTRUCT))
		return TRUE

/obj/structure/razorwire/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(CHECK_BITFIELD(mover.flags_pass, PASSSMALLSTRUCT))
		return TRUE

/obj/structure/razorwire/proc/razorwire_tangle(mob/living/entangled, duration = RAZORWIRE_ENTANGLE_DELAY)
	if(QDELETED(src)) //Sanity check so that you can't get entangled if the razorwire is destroyed; this happens apparently.
		CRASH("QDELETED razorwire called razorwire_tangle()")
	TIMER_COOLDOWN_START(entangled, COOLDOWN_ENTANGLE, duration)
	entangled.visible_message("<span class='danger'>[entangled] gets entangled in the barbed wire!</span>",
	"<span class='danger'>You got entangled in the barbed wire! Resist to untangle yourself after [duration * 0.1] seconds since you were entangled!</span>", null, null, 5)
	do_razorwire_tangle(entangled)


/obj/structure/razorwire/proc/do_razorwire_tangle(mob/living/entangled)
	ADD_TRAIT(entangled, TRAIT_IMMOBILE, type)
	ENABLE_BITFIELD(entangled.restrained_flags, RESTRAINED_RAZORWIRE)
	LAZYADD(entangled_list, entangled) //Add the entangled person to the trapped list.
	RegisterSignal(entangled, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
	RegisterSignal(entangled, COMSIG_PARENT_QDELETING, .proc/do_razorwire_untangle)
	RegisterSignal(entangled, COMSIG_MOVABLE_UNCROSS, .proc/on_entangled_uncross)
	RegisterSignal(entangled, COMSIG_MOVABLE_PULL_MOVED, .proc/razorwire_untangle)


/obj/structure/razorwire/resisted_against(datum/source)
	var/mob/living/entangled = source
	if(TIMER_COOLDOWN_CHECK(entangled, COOLDOWN_ENTANGLE))
		entangled.visible_message("<span class='danger'>[entangled] attempts to disentangle itself from [src] but is unsuccessful!</span>",
		"<span class='warning'>You fail to disentangle yourself!</span>")
		return FALSE
	return razorwire_untangle(entangled)

/obj/structure/razorwire/proc/razorwire_untangle(mob/living/entangled)
	SIGNAL_HANDLER
	entangled.next_move_slowdown += RAZORWIRE_SLOWDOWN //big slowdown
	do_razorwire_untangle(entangled)
	visible_message("<span class='danger'>[entangled] disentangles from [src]!</span>")
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, TRUE)
	var/def_zone = ran_zone()
	var/armor_block = entangled.run_armor_check(def_zone, "melee")
	entangled.apply_damage(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, BRUTE, def_zone, armor_block, TRUE, updating_health = TRUE) //Apply damage as we tear free
	return TRUE


///This proc is used for signals, so if you plan on adding a second argument, or making it return a value, then change those RegisterSignal's referncing it first.
/obj/structure/razorwire/proc/do_razorwire_untangle(mob/living/entangled)
	SIGNAL_HANDLER
	UnregisterSignal(entangled, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DO_RESIST, COMSIG_MOVABLE_UNCROSS, COMSIG_MOVABLE_PULL_MOVED))
	LAZYREMOVE(entangled_list, entangled)
	DISABLE_BITFIELD(entangled.restrained_flags, RESTRAINED_RAZORWIRE)
	REMOVE_TRAIT(entangled, TRAIT_IMMOBILE, type)


/obj/structure/razorwire/proc/on_entangled_uncross(datum/source, atom/movable/uncrosser)
	SIGNAL_HANDLER
	razorwire_untangle(uncrosser)


/obj/structure/razorwire/Destroy()
	for(var/i in entangled_list)
		do_razorwire_untangle(i)
	return ..()


/obj/structure/razorwire/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal_sheets = I

		visible_message("<span class='notice'>[user] begins to repair  \the [src].</span>")

		if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!metal_sheets.use(1))
			return

		repair_damage(max_integrity * 0.30)
		visible_message("<span class='notice'>[user] repairs \the [src].</span>")
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
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return

		var/armor_block = null
		var/def_zone = ran_zone()
		M.apply_damage(RAZORWIRE_BASE_DAMAGE, BRUTE, def_zone, armor_block, TRUE, updating_health = TRUE)
		user.visible_message("<span class='danger'>[user] spartas [M]'s into [src]!</span>",
		"<span class='danger'>You sparta [M]'s against [src]!</span>")
		log_combat(user, M, "spartaed", "", "against \the [src]")
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

	else if(user.grab_state >= GRAB_AGGRESSIVE)
		M.forceMove(loc)
		M.Paralyze(10 SECONDS)
		user.visible_message("<span class='danger'>[user] throws [M] on [src].</span>",
		"<span class='danger'>You throw [M] on [src].</span>")

/obj/structure/razorwire/wirecutter_act(mob/living/user, obj/item/I)
	user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
	"<span class='notice'>You start disassembling [src].</span>")
	var/delay_disassembly = SKILL_TASK_AVERAGE - (0.5 SECONDS + user.skills.getRating("engineer"))

	if(!do_after(user, delay_disassembly, TRUE, src, BUSY_ICON_BUILD))
		return TRUE

	user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
	"<span class='notice'>You disassemble [src].</span>")
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	deconstruct(TRUE)
	return TRUE

/obj/structure/razorwire/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	X.apply_damage(RAZORWIRE_BASE_DAMAGE * 0.7, updating_health = TRUE) //About a third as damaging as actually entering
	update_icon()
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_RAZORWIRE)
	return ..()

/obj/structure/razorwire/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			deconstruct(FALSE)
			return
		if(EXPLODE_HEAVY)
			take_damage(rand(33, 66))
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 33))
	update_icon()


/obj/structure/razorwire/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGRILLE))
		return TRUE
	if(mover.throwing && istype(mover,/obj/item))
		return TRUE
	if(istype(mover, /obj/vehicle/multitile))
		visible_message("<span class='danger'>[mover] drives over and destroys [src]!</span>")
		deconstruct(FALSE)
		return TRUE

/obj/structure/razorwire/update_icon_state()
	var/health_percent = round(obj_integrity/max_integrity * 100)
	var/remaining = CEILING(health_percent, 25)
	icon_state = "[base_icon_state]_[remaining]"

/obj/structure/razorwire/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(2 * S.strength)
