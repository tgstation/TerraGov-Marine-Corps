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
	var/list/entangled_list = list()
	var/sheet_type = /obj/item/stack/barbed_wire
	var/sheet_type2 = /obj/item/stack/rods
	var/table_prefix = "" //used in update_icon()
	max_integrity = RAZORWIRE_MAX_HEALTH
	var/soak = 5

/obj/structure/razorwire/proc/destroyed(deconstruct = FALSE)
	if(deconstruct)
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
	qdel(src)

/obj/structure/razorwire/New()
	..()
	for(var/obj/structure/razorwire/T in loc)
		if(T != src)
			qdel(T)

/obj/structure/razorwire/Crossed(atom/movable/O)
	. = ..()
	if(!isliving(O))
		return
	var/mob/living/M = O
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	var/armor_block = null
	var/def_zone = ran_zone()
	armor_block = M.run_armor_check(def_zone, "melee")
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, null, 1)
	razorwire_tangle(M)

/obj/structure/razorwire/proc/razorwire_tangle(mob/living/M, duration = RAZORWIRE_ENTANGLE_DELAY)
	if(QDELETED(src) || obj_integrity <= 0) //Sanity check so that you can't get entangled if the razorwire is destroyed; this happens apparently.
		return
	M.entangle_delay = world.time + duration
	M.visible_message("<span class='danger'>[M] gets entangled in the barbed wire!</span>",
	"<span class='danger'>You got entangled in the barbed wire! Resist to untangle yourself after [(M.entangle_delay - world.time) * 0.1] seconds!</span>", null, 5)
	M.set_frozen(TRUE)
	entangled_list += M //Add the entangled person to the trapped list.
	M.entangled_by = src

/obj/structure/razorwire/proc/razorwire_untangle(mob/living/M)
	var/armor_block = null
	var/def_zone = ran_zone()
	armor_block = M.run_armor_check(def_zone, "melee")
	visible_message("<span class='danger'>[M] disentangles from [src]!</span>")
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	entangled_list -= M
	M.entangled_by = null
	M.entangle_delay = null
	M.set_frozen(FALSE)
	M.update_canmove()
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, null, 1) //Apply damage as we tear free
	M.next_move_slowdown += RAZORWIRE_SLOWDOWN //big slowdown

/obj/structure/razorwire/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(isliving(O))
		var/mob/living/M = O
		if(M.entangled_by)
			razorwire_untangle(M)
	. = ..()

/obj/structure/razorwire/Destroy()
	. = ..()
	for(var/mob/living/M in entangled_list)
		M.set_frozen(FALSE)
		M.update_canmove()
		if(M.entangled_by == src)
			M.entangled_by = null
			M.entangle_delay = null
	entangled_list = list()


/obj/structure/razorwire/attack_tk() // no telehulk sorry
	return


/obj/structure/razorwire/attackby(obj/item/W, mob/user)
	if(!W)
		return
	if(istype(W, /obj/item/grab))
		if(isxeno(user))
			return
		var/obj/item/grab/G = W
		if(isliving(G.grabbed_thing))
			var/mob/living/M = G.grabbed_thing
			if(user.a_intent == INTENT_HARM)
				if(user.grab_level > GRAB_AGGRESSIVE)
					var/armor_block = null
					var/def_zone = ran_zone()
					M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, null, 1)
					user.visible_message("<span class='danger'>[user] spartas [M]'s into [src]!</span>",
					"<span class='danger'>You sparta [M]'s against [src]!</span>")
					log_admin("[key_name(usr)] spartaed [key_name(M)]'s against \the [src].")
					log_combat(user, M, "spartaed", "", "against \the [src]")
					msg_admin_attack("[key_name(usr)] spartaed [key_name(M)] against \the [src].")
					playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
				else
					to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
					return
			else if(user.grab_level >= GRAB_AGGRESSIVE)
				M.forceMove(loc)
				M.KnockDown(5)
				user.visible_message("<span class='danger'>[user] throws [M] on [src].</span>",
				"<span class='danger'>You throw [M] on [src].</span>")
		return

	if(iswirecutter(W))
		user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
		"<span class='notice'>You start disassembling [src].</span>")
		var/delay_disassembly = SKILL_TASK_AVERAGE
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer) //Higher skill lowers the delay.
			delay_disassembly -= 5 + user.mind.cm_skills.engineer * 5
		if(do_after(user,delay_disassembly, TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
			"<span class='notice'>You disassemble [src].</span>")
			playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
			destroyed(TRUE)
		return

	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/delay = SKILL_TASK_TOUGH
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer) //Higher skill lowers the delay.
				delay -= 10 + user.mind.cm_skills.engineer * 5
			user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
			"<span class='notice'>You begin repairing the damage to [src].</span>")
			playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
			var/old_loc = loc
			if(do_after(user, delay, TRUE, 5, BUSY_ICON_FRIENDLY) && old_loc == loc)
				user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
				"<span class='notice'>You repair [src].</span>")
				obj_integrity = min(obj_integrity + 100, max_integrity)
				update_health()
				playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
		return

	if(istype(W, /obj/item/tool/pickaxe/plasmacutter))
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD))
			if(do_after(user, P.calc_delay(user) * PLASMACUTTER_LOW_MOD, TRUE, 5, BUSY_ICON_HOSTILE) && P && src) //Barbed wire requires half the normal time
				P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD) //Barbed wire requires half the normal power
				destroyed()
		return

	if((W.flags_item & ITEM_ABSTRACT) || iscyborg(user))
		return

	var/damage = W.force
	if(!W.sharp)
		damage *= 0.25
	damage = max(damage - soak,0)
	if(damage)
		. = ..()
		obj_integrity -= damage
		update_health()

	if(isliving(user))
		var/mob/living/M = user
		var/armor_block = null
		var/def_zone = ran_zone()
		armor_block = M.run_armor_check(def_zone, "melee")
		M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_LOW, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_LOW), BRUTE, def_zone, armor_block, null, 1)
		M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

/obj/structure/razorwire/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	obj_integrity -= rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper)
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	if(obj_integrity <= 0)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
	"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_LOW, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_LOW)) //About a third as damaging as actually entering
	update_health(TRUE)
	if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
		M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

/obj/structure/razorwire/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			destroyed()
			return
		if(2.0)
			obj_integrity -= rand(33, 66)
		if(3.0)
			obj_integrity -= rand(10, 33)
	update_health()

/obj/structure/razorwire/Bumped(atom/A)
	. = ..()

	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))

		var/mob/living/carbon/Xenomorph/Crusher/C = A

		if(C.charge_speed < CHARGE_SPEED_MAX * 0.5)
			return

		obj_integrity -= C.charge_speed * CRUSHER_CHARGE_RAZORWIRE_MULTI


		var/def_zone = ran_zone()
		if(C.charge_speed >= CHARGE_SPEED_MAX)
			C.visible_message("<span class='danger'>[C] plows through the barbed wire!</span>",
			"<span class='danger'>You plow through the barbed wire!</span>", null, 5)

		else if(obj_integrity > 0) //If we didn't destroy the barbed wire, we get tangled up.
			C.stop_momentum(C.charge_dir)
			razorwire_tangle(C, RAZORWIRE_ENTANGLE_DELAY * 0.5) //entangled for only half as long

		C.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_MED), BRUTE, def_zone, null, null, 1)
		C.visible_message("<span class='danger'>The barbed wire slices into [C]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
		update_health()



/obj/structure/razorwire/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	obj_integrity -= round(P.damage * 0.1)

	if(istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		obj_integrity -= 50

	update_health()
	return TRUE

/obj/structure/razorwire/hitby(atom/movable/AM)
	if(AM.throwing)
		if(isliving(AM))
			var/mob/living/C = AM
			C.visible_message("<span class='danger'>The barbed wire slices into [C]!</span>",
			"<span class='danger'>The barbed wire slices into you!</span>")
			C.loc = loc
			var/armor_block = null
			var/def_zone = ran_zone()
			armor_block = C.run_armor_check(def_zone, "melee")
			C.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_HIGH, RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MAX_DAMAGE_MULT_HIGH), BRUTE, def_zone, armor_block, null, 1) //pouncing into razor wire is especially ouchy
			C.KnockDown(1)
			razorwire_tangle(C)
	return ..()

/obj/structure/razorwire/update_health(nomessage)
	obj_integrity = CLAMP(obj_integrity, 0, max_integrity)

	if(!obj_integrity)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroyed()
		return

	update_icon()

/obj/structure/razorwire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return TRUE
	if(mover.throwing && istype(mover,/obj/item))
		return TRUE
	if(istype(mover, /obj/vehicle/multitile))
		visible_message("<span class='danger'>[mover] drives over and destroys [src]!</span>")
		destroyed()
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
		obj_integrity -= 2 * S.strength
		update_health()
