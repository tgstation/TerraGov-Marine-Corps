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
	var/list/entangled_list = list()
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
	for(var/obj/structure/razorwire/T in loc)
		if(T != src)
			qdel(T)

/obj/structure/razorwire/Crossed(atom/movable/O)
	. = ..()
	if(!isliving(O))
		return
	var/mob/living/M = O
	if(CHECK_BITFIELD(M.restrained_flags, RESTRAINED_RAZORWIRE))
		return
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	var/armor_block = null
	var/def_zone = ran_zone()
	armor_block = M.run_armor_check(def_zone, "melee")
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, TRUE)
	razorwire_tangle(M)

/obj/structure/razorwire/proc/razorwire_tangle(mob/living/M, duration = RAZORWIRE_ENTANGLE_DELAY)
	if(QDELETED(src)) //Sanity check so that you can't get entangled if the razorwire is destroyed; this happens apparently.
		return
	M.cooldowns[COOLDOWN_ENTANGLE] = addtimer(VARSET_LIST_CALLBACK(M.cooldowns, COOLDOWN_ENTANGLE, null), duration)
	M.visible_message("<span class='danger'>[M] gets entangled in the barbed wire!</span>",
	"<span class='danger'>You got entangled in the barbed wire! Resist to untangle yourself after [duration * 0.1] seconds since you were entangled!</span>", null, null, 5)
	M.set_frozen(TRUE)
	entangled_list += M //Add the entangled person to the trapped list.
	M.entangled_by = src
	ENABLE_BITFIELD(M.restrained_flags, RESTRAINED_RAZORWIRE)
	RegisterSignal(M, COMSIG_LIVING_DO_RESIST, .proc/resisted_against)


/obj/structure/razorwire/resisted_against(datum/source, mob/living/entangled)
	if(entangled.cooldowns[COOLDOWN_ENTANGLE])
		entangled.visible_message("<span class='danger'>[entangled] attempts to disentangle itself from [src] but is unsuccessful!</span>",
		"<span class='warning'>You fail to disentangle yourself!</span>")
		return FALSE
	return razorwire_untangle(entangled)


/obj/structure/razorwire/proc/razorwire_untangle(mob/living/M)
	var/armor_block = null
	var/def_zone = ran_zone()
	armor_block = M.run_armor_check(def_zone, "melee")
	visible_message("<span class='danger'>[M] disentangles from [src]!</span>")
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	entangled_list -= M
	M.entangled_by = null
	M.cooldowns[COOLDOWN_ENTANGLE] = FALSE
	M.set_frozen(FALSE)
	M.update_canmove()
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, TRUE) //Apply damage as we tear free
	M.next_move_slowdown += RAZORWIRE_SLOWDOWN //big slowdown
	DISABLE_BITFIELD(M.restrained_flags, RESTRAINED_RAZORWIRE)
	UnregisterSignal(M, COMSIG_LIVING_DO_RESIST)
	return TRUE


/obj/structure/razorwire/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(isliving(O))
		var/mob/living/M = O
		if(M.entangled_by)
			razorwire_untangle(M)
	return ..()

/obj/structure/razorwire/Destroy()
	for(var/i in entangled_list)
		var/mob/living/L = i
		L.set_frozen(FALSE)
		L.update_canmove()
		if(L.entangled_by == src)
			L.entangled_by = null
			L.cooldowns[COOLDOWN_ENTANGLE] = FALSE
	entangled_list.Cut()
	return ..()

/obj/structure/razorwire/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab))
		if(isxeno(user))
			return

		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		if(user.a_intent == INTENT_HARM)
			if(user.grab_level <= GRAB_AGGRESSIVE)
				to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
				return

			var/armor_block = null
			var/def_zone = ran_zone()
			M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, TRUE)
			user.visible_message("<span class='danger'>[user] spartas [M]'s into [src]!</span>",
			"<span class='danger'>You sparta [M]'s against [src]!</span>")
			log_combat(user, M, "spartaed", "", "against \the [src]")
			msg_admin_attack("[key_name(usr)] spartaed [key_name(M)] against \the [src].")
			playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

		else if(user.grab_level >= GRAB_AGGRESSIVE)
			M.forceMove(loc)
			M.knock_down(5)
			user.visible_message("<span class='danger'>[user] throws [M] on [src].</span>",
			"<span class='danger'>You throw [M] on [src].</span>")
		return

	else if(iswirecutter(I))
		user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
		"<span class='notice'>You start disassembling [src].</span>")
		var/delay_disassembly = SKILL_TASK_AVERAGE
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer) //Higher skill lowers the delay.
			delay_disassembly -= 5 + user.mind.cm_skills.engineer * 5

		if(!do_after(user, delay_disassembly, TRUE, src, BUSY_ICON_BUILD))
			return

		user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
		"<span class='notice'>You disassemble [src].</span>")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		deconstruct(TRUE)

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(0, user))
			return

		var/delay = SKILL_TASK_TOUGH
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer) //Higher skill lowers the delay.
			delay -= 10 + user.mind.cm_skills.engineer * 5
		user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
		"<span class='notice'>You begin repairing the damage to [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		var/old_loc = loc
		if(!do_after(user, delay, TRUE, src, BUSY_ICON_FRIENDLY) || old_loc != loc)
			return

		user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		repair_damage(100)
		update_icon()
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)


/obj/structure/razorwire/attack_alien(mob/living/carbon/xenomorph/M)
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_LOW, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_LOW)) //About a third as damaging as actually entering
	update_icon()
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_RAZORWIRE)
	return ..()

/obj/structure/razorwire/ex_act(severity)
	switch(severity)
		if(1)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			deconstruct(FALSE)
			return
		if(2)
			take_damage(rand(33, 66))
		if(3)
			take_damage(rand(10, 33))
	update_icon()


/obj/structure/razorwire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGRILLE))
		return TRUE
	if(mover.throwing && istype(mover,/obj/item))
		return TRUE
	if(istype(mover, /obj/vehicle/multitile))
		visible_message("<span class='danger'>[mover] drives over and destroys [src]!</span>")
		deconstruct(FALSE)
		return TRUE

/obj/structure/razorwire/update_icon()
	var/health_percent = round(obj_integrity/max_integrity * 100)
	var/remaining = CEILING(health_percent, 25)
	icon_state = "[base_icon_state]_[remaining]"

/obj/structure/razorwire/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(2 * S.strength)
