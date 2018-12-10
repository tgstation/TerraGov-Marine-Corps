/obj/structure/razorwire
	name = "razorwire obstacle"
	desc = "A bundle of barbed wire supported by metal rods. Used to deny access to areas under (literal) pain of entanglement and injury. A classic fortification since the 1900s."
	icon = 'icons/obj/structures/barbedwire.dmi'
	icon_state = "barbedwire_x"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	throwpass = TRUE	//You can throw objects over this
	climbable = TRUE
	breakable = TRUE
	var/list/trapped = list()
	var/sheet_type = /obj/item/stack/barbed_wire
	var/sheet_type2 = /obj/item/stack/rods
	var/table_prefix = "" //used in update_icon()
	var/health = RAZORWIRE_MAX_HEALTH
	var/soak = 5

/obj/structure/razorwire/destroy(deconstruct)
	if(deconstruct)
		new sheet_type(src)
		var/obj/item/stack/rods/salvage = new sheet_type2(src)
		salvage.amount = 4
	else
		if(prob(50))
			new sheet_type(src)
		var/obj/item/stack/rods/salvage = new sheet_type2(src)
		salvage.amount = rand(0,4)
	cdel(src)

/obj/structure/razorwire/New()
	..()
	for(var/obj/structure/razorwire/T in src.loc)
		if(T != src)
			cdel(T)

/obj/structure/razorwire/Crossed(atom/movable/O)
	..()
	if(!isliving(O))
		return
	var/mob/living/M = O
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	if(M.mob_size == MOB_SIZE_BIG) //in big mobs we trust, all others get entangled
		M.next_move_slowdown += RAZORWIRE_SLOWDOWN //big slowdown
		visible_message("<span class='danger'>[O] powers through [src]!</span>")
	else
		visible_message("<span class='danger'>[O] gets entangled in [src]!</span>")
		M.frozen += 1
		trapped += M //Add the entangled person to the trapped list.
		var/armor_block = null
		var/def_zone = ran_zone()
		armor_block = M.run_armor_check(def_zone, "melee")
		M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, null, 1)
		razorwire_tangle(M, def_zone, armor_block)

/obj/structure/razorwire/proc/razorwire_tangle(mob/living/M, def_zone = null, armor_block = null, duration = RAZORWIRE_ENTANGLE_DELAY)
	spawn(duration)
		if(src) //Check if we still exist
			visible_message("<span class='danger'>[M] manages to break free from [src]!</span>")
			playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
			M.frozen = FALSE
			M.update_canmove()
			M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, armor_block, null, 1) //Apply damage as we tear free
			M.next_move_slowdown += RAZORWIRE_SLOWDOWN //big slowdown


/obj/structure/razorwire/Dispose()
	. = ..()
	for(var/mob/M in trapped)
		M.frozen = FALSE
		M.update_canmove()
	trapped = list()


/obj/structure/razorwire/attack_tk() // no telehulk sorry
	return


/obj/structure/razorwire/attackby(obj/item/W, mob/user)
	if(!W)
		return
	if(istype(W, /obj/item/grab) && get_dist(src, user) <= 1)
		if(isXeno(user))
			return
		var/obj/item/grab/G = W
		if(istype(G.grabbed_thing, /mob/living))
			var/mob/living/M = G.grabbed_thing
			if(user.a_intent == "hurt")
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

	if(istype(W, /obj/item/tool/wirecutters))
		user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
		"<span class='notice'>You start disassembling [src].</span>")
		if(do_after(user,50, TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
			"<span class='notice'>You disassemble [src].</span>")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 25, 1)
			destroy(1)
		return

	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/delay = SKILL_TASK_TOUGH
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer) //Higher skill lowers the delay.
				delay -= 10 + user.mind.cm_skills.engineer * 5
			user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
			"<span class='notice'>You begin repairing the damage to [src].</span>")
			playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
			var/old_loc = loc
			if(do_after(user, delay, TRUE, 5, BUSY_ICON_FRIENDLY) && old_loc == loc)
				user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
				"<span class='notice'>You repair [src].</span>")
				health = min(health + 100, RAZORWIRE_MAX_HEALTH)
				update_health()
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)

	if(istype(W, /obj/item/tool/pickaxe/plasmacutter))
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD))
			if(do_after(user, P.calc_delay(user) * PLASMACUTTER_LOW_MOD, TRUE, 5, BUSY_ICON_HOSTILE) && P && src) //Barbed wire requires half the normal time
				P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD) //Barbed wire requires half the normal power
				destroy()
		return

	if((W.flags_item & ITEM_ABSTRACT) || isrobot(user))
		return

	var/damage = W.force
	if(!W.sharp)
		damage *= 0.25
	damage = max(damage - soak,0)
	if(damage)
		..()
		health -= damage
		update_health()

	if(isliving(user))
		var/mob/living/M = user
		var/armor_block = null
		var/def_zone = ran_zone()
		armor_block = M.run_armor_check(def_zone, "melee")
		M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.3, RAZORWIRE_BASE_DAMAGE * 0.4), BRUTE, def_zone, armor_block, null, 1)
		M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

/obj/structure/razorwire/proc/update_health(nomessage)
	health = CLAMP(health, 0, RAZORWIRE_MAX_HEALTH)

	if(!health)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroy()
		return

	update_icon()

/obj/structure/razorwire/update_icon()
	var/health_percent = round(health/RAZORWIRE_MAX_HEALTH * 100)
	if(health_percent < 50)
		icon_state = "barbedwire_damaged"

/obj/structure/razorwire/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	health -= rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper)
	playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	if(health <= 0)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
	"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
	M.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.3, RAZORWIRE_BASE_DAMAGE * 0.4)) //About a third as damaging as actually entering
	update_health(TRUE)

/obj/structure/razorwire/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			destroy()
			return
		if(2.0)
			health -= rand(33, 66)
		if(3.0)
			health -= rand(10, 33)
	update_health()

/obj/structure/razorwire/Bumped(atom/A)
	..()

	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))

		var/mob/living/carbon/Xenomorph/Crusher/C = A

		if(C.charge_speed < C.charge_speed_max/2)
			return

		health -= 150 * round(C.charge_speed / max(1, C.charge_speed_max),0.01)
		update_health()

		var/def_zone = ran_zone()
		if(src) //If we didn't destroy the barbed wire, we get tangled up.
			C.visible_message("<span class='danger'>[C] gets tangled in the barbed wire!</span>",
			"<span class='danger'>You get tangled in the barbed wire!</span>", null, 5)
			razorwire_tangle(C, def_zone, null, RAZORWIRE_ENTANGLE_DELAY * 0.5)

		C.apply_damage(rand(RAZORWIRE_BASE_DAMAGE * 0.8, RAZORWIRE_BASE_DAMAGE * 1.2), BRUTE, def_zone, null, null, 1)
		C.visible_message("<span class='danger'>The barbed wire slices into [C]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		playsound(src, 'sound/effects/barbed_wire_movement.ogg', 25, 1)

/obj/structure/razorwire/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	health -= round(P.damage * 0.1)

	if(istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		health -= 50

	update_health()
	return TRUE
