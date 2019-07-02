// Snow, wood, sandbags, metal, plasteel

/obj/structure/barricade
	icon = 'icons/Marine/barricades.dmi'
	climbable = TRUE
	anchored = TRUE
	density = TRUE
	throwpass = TRUE //You can throw objects over this, despite its density.
	layer = BELOW_OBJ_LAYER
	flags_atom = ON_BORDER
	climb_delay = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	var/stack_type //The type of stack the barricade dropped when disassembled if any.
	var/stack_amount = 5 //The amount of stack dropped when disassembled at full health
	var/destroyed_stack_amount //to specify a non-zero amount of stack to drop when destroyed
	max_integrity = 100 //Pretty tough. Changes sprites at 300 and 150
	var/crusher_resistant = TRUE //Whether a crusher can ram through it.
	var/base_acid_damage = 2
	var/barricade_resistance = 5 //How much force an item needs to even damage it at all.
	var/barricade_hitsound

	var/barricade_type = "barricade" //"metal", "plasteel", etc.
	var/can_change_dmg_state = TRUE
	var/damage_state = 0
	var/closed = FALSE
	var/can_wire = FALSE
	var/is_wired = FALSE
	var/image/wired_overlay
	flags_barrier = HANDLE_BARRIER_CHANCE

/obj/structure/barricade/Initialize()
	. = ..()
	update_icon()

/obj/structure/barricade/handle_barrier_chance(mob/living/M)
	return prob(max(30,(100.0*obj_integrity)/max_integrity))

/obj/structure/barricade/examine(mob/user)
	..()

	if(is_wired)
		to_chat(user, "<span class='info'>There is a length of wire strewn across the top of this barricade.</span>")
	switch(damage_state)
		if(0) to_chat(user, "<span class='info'>It appears to be in good shape.</span>")
		if(1) to_chat(user, "<span class='warning'>It's slightly damaged, but still very functional.</span>")
		if(2) to_chat(user, "<span class='warning'>It's quite beat up, but it's holding together.</span>")
		if(3) to_chat(user, "<span class='warning'>It's crumbling apart, just a few more blows will tear it apart.</span>")

/obj/structure/barricade/hitby(atom/movable/AM)
	if(AM.throwing && is_wired)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.visible_message("<span class='danger'>The barbed wire slices into [C]!</span>",
			"<span class='danger'>The barbed wire slices into you!</span>")
			C.apply_damage(10)
			C.KnockDown(2) //Leaping into barbed wire is VERY bad
	..()



/obj/structure/barricade/Bumped(atom/A)
	..()

	if(istype(A, /mob/living/carbon/xenomorph/crusher))

		var/mob/living/carbon/xenomorph/crusher/C = A

		if(C.charge_speed < CHARGE_SPEED_MAX * 0.5)
			return

		if(crusher_resistant)
			obj_integrity -= C.charge_speed * CRUSHER_CHARGE_BARRICADE_MULTI
			update_health()

		else if(!C.stat)
			visible_message("<span class='danger'>[C] smashes through [src]!</span>")
			destroy_structure()

/obj/structure/barricade/CheckExit(atom/movable/O, turf/target)
	if(closed)
		return TRUE

	if(O.throwing)
		if(is_wired && iscarbon(O)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target)
	if(closed)
		return TRUE

	if(mover && mover.throwing)
		if(is_wired && iscarbon(mover)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(istype(mover, /obj/vehicle/multitile))
		visible_message("<span class='danger'>[mover] drives over and destroys [src]!</span>")
		destroy_structure(0)
		return FALSE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/barricade/attack_animal(mob/user as mob)
	return attack_alien(user)

/obj/structure/barricade/attack_alien(mob/living/carbon/xenomorph/M)
	M.animation_attack_on(src)
	obj_integrity -= rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper)
	if(barricade_hitsound)
		playsound(src, barricade_hitsound, 25, 1)
	if(obj_integrity <= 0)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>", \
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>You slash [src]!</span>", null, 5)
	if(is_wired)
		M.visible_message("<span class='danger'>The barbed wire slices into [M]!</span>",
		"<span class='danger'>The barbed wire slices into you!</span>", null, 5)
		M.apply_damage(10)
	update_health(TRUE)
	SEND_SIGNAL(M, COMSIG_XENOMORPH_ATTACK_BARRICADE)

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/stack/barbed_wire))
		var/obj/item/stack/barbed_wire/B = I
		if(!can_wire)
			return

		user.visible_message("<span class='notice'>[user] starts setting up [I] on [src].</span>",
		"<span class='notice'>You start setting up [I] on [src].</span>")
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || !can_wire)
			return

		playsound(loc, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] sets up [I] on [src].</span>",
		"<span class='notice'>You set up [I] on [src].</span>")

		if(!closed)
			wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[barricade_type]_wire")
		else
			wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[barricade_type]_closed_wire")

		B.use(1)
		overlays += wired_overlay
		max_integrity += 50
		obj_integrity += 50
		update_health()
		can_wire = FALSE
		is_wired = TRUE
		climbable = FALSE

	else if(iswirecutter(I))
		if(!is_wired)
			return

		user.visible_message("<span class='notice'>[user] begin removing the barbed wire on [src].</span>",
		"<span class='notice'>You begin removing the barbed wire on [src].</span>")

		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] removes the barbed wire on [src].</span>",
		"<span class='notice'>You remove the barbed wire on [src].</span>")
		overlays -= wired_overlay
		max_integrity -= 50
		obj_integrity -= 50
		update_health()
		can_wire = TRUE
		is_wired = FALSE
		climbable = TRUE
		new /obj/item/stack/barbed_wire(loc)

	else if(I.force > barricade_resistance && user.a_intent != INTENT_HELP)
		if(barricade_hitsound)
			playsound(src, barricade_hitsound, 25, 1)
		hit_barricade(I)


/obj/structure/barricade/destroy_structure(deconstruct)
	if(deconstruct && is_wired)
		new /obj/item/stack/barbed_wire(loc)
	if(stack_type)
		var/stack_amt
		if(!deconstruct && destroyed_stack_amount)
			stack_amt = destroyed_stack_amount
		else
			stack_amt = round(stack_amount * (obj_integrity/max_integrity)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0

		if(stack_amt)
			new stack_type (loc, stack_amt)
	qdel(src)

/obj/structure/barricade/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>[src] is blown apart!</span>")
			qdel(src)
			return
		if(2.0)
			obj_integrity -= rand(33, 66)
		if(3.0)
			obj_integrity -= rand(10, 33)
	update_health()

/obj/structure/barricade/setDir(newdir)
	. = ..()
	update_icon()

/obj/structure/barricade/update_icon()
	if(!closed)
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_[damage_state]"
		else
			icon_state = "[barricade_type]"
		switch(dir)
			if(SOUTH)
				layer = ABOVE_MOB_LAYER
			if(NORTH)
				layer = initial(layer) - 0.01
			else
				layer = initial(layer)
		if(!anchored)
			layer = initial(layer)
	else
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_closed_[damage_state]"
		else
			icon_state = "[barricade_type]_closed"
		layer = OBJ_LAYER

/obj/structure/barricade/proc/update_overlay()
	if(!is_wired)
		return

	overlays -= wired_overlay
	if(!closed)
		wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[src.barricade_type]_wire")
	else
		wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[src.barricade_type]_closed_wire")
	overlays += wired_overlay

/obj/structure/barricade/proc/hit_barricade(obj/item/I)
	obj_integrity -= I.force * 0.5
	update_health()

/obj/structure/barricade/update_health(nomessage)
	obj_integrity = CLAMP(obj_integrity, 0, max_integrity)

	if(!obj_integrity)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroy_structure()
		return

	update_damage_state()
	update_icon()

/obj/structure/barricade/proc/update_damage_state()
	var/health_percent = round(obj_integrity/max_integrity * 100)
	switch(health_percent)
		if(0 to 25) damage_state = 3
		if(25 to 50) damage_state = 2
		if(50 to 75) damage_state = 1
		if(75 to INFINITY) damage_state = 0


/obj/structure/barricade/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		obj_integrity -= base_acid_damage * S.strength
		update_health()


/obj/structure/barricade/verb/rotate()
	set name = "Rotate Barricade Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 90))
	return

/obj/structure/barricade/verb/revrotate()
	set name = "Rotate Barricade Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor, you can't rotate it!</span>")
		return FALSE

	setDir(turn(dir, 270))
	return


/*----------------------*/
// SNOW
/*----------------------*/

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "A mound of snow shaped into a sloped wall. Statistically better than thin air as cover."
	icon_state = "snow_0"
	barricade_type = "snow"
	max_integrity = 75
	stack_type = /obj/item/stack/snow
	stack_amount = 3
	destroyed_stack_amount = 0
	can_wire = FALSE



//Item Attack
/obj/structure/barricade/snow/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	//Removing the barricades
	if(istype(I, /obj/item/tool/shovel) && user.a_intent != INTENT_HARM)
		var/obj/item/tool/shovel/ET = I

		if(ET.folded)
			return

		if(user.action_busy)
			to_chat(user, "<span class='warning'> You are already shoveling!</span>")
			return

		user.visible_message("[user] starts clearing out \the [src].", "You start removing \the [src].")

		if(!do_after(user, ET.shovelspeed, TRUE, src, BUSY_ICON_BUILD))
			return

		if(!ET.folded)
			user.visible_message("<span class='notice'> \The [user] removes \the [src].</span>")
			destroy_structure(TRUE)


/obj/structure/barricade/snow/hit_barricade(obj/item/I)
	switch(I.damtype)
		if("fire")
			obj_integrity -= I.force * 0.6
		if("brute")
			obj_integrity -= I.force * 0.3

	update_health()
	update_icon()
	return

/obj/structure/barricade/snow/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	obj_integrity -= round(P.damage/2) //Not that durable.

	if (istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		obj_integrity -= 50

	update_health()
	return TRUE

/*----------------------*/
// WOOD
/*----------------------*/

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "A wall made out of wooden planks nailed together. Not very sturdy, but can provide some concealment."
	icon_state = "wooden"
	max_integrity = 100
	layer = OBJ_LAYER
	climbable = FALSE
	throwpass = FALSE
	stack_type = /obj/item/stack/sheet/wood
	stack_amount = 5
	destroyed_stack_amount = 3
	barricade_hitsound = "sound/effects/woodhit.ogg"
	can_change_dmg_state = FALSE
	barricade_type = "wooden"
	can_wire = FALSE

/obj/structure/barricade/wooden/lv_snowflake
	desc = "A reinforced wooden barricade. Pretty good at keeping neighbours away from your lawn."
	max_integrity = 400

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/D = I
		if(obj_integrity >= max_integrity)
			return

		if(D.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one plank of wood to repair [src].</span>")
			return

		visible_message("<span class='notice'>[user] begins to repair [src].</span>")

		if(!do_after(user,20, TRUE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity)
			return

		if(!D.use(1))
			return

		obj_integrity = max_integrity
		visible_message("<span class='notice'>[user] repairs [src].</span>")

/obj/structure/barricade/wooden/hit_barricade(obj/item/I)
	switch(I.damtype)
		if("fire")
			obj_integrity -= I.force * 1.5
		if("brute")
			obj_integrity -= I.force * 0.75
	update_health()

/obj/structure/barricade/wooden/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	obj_integrity -= round(P.damage/2) //Not that durable.

	if(istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		obj_integrity -= 50

	update_health()
	return TRUE


/*----------------------*/
// METAL
/*----------------------*/

/obj/structure/barricade/metal
	name = "metal barricade"
	desc = "A sturdy and easily assembled barricade made of metal plates, often used for quick fortifications. Use a blowtorch to repair."
	icon_state = "metal_0"
	max_integrity = 200
	crusher_resistant = TRUE
	barricade_resistance = 10
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = 4
	destroyed_stack_amount = 2
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "metal"
	can_wire = TRUE
	var/build_state = 2 //2 is fully secured, 1 is after screw, 0 is after wrench. Crowbar disassembles

/obj/structure/barricade/metal/examine(mob/user)
	..()
	switch(build_state)
		if(2)
			to_chat(user, "<span class='info'>The protection panel is still tighly screwed in place.</span>")
		if(1)
			to_chat(user, "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>")
		if(0)
			to_chat(user, "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>")

/obj/structure/barricade/metal/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(iswelder(I))
		if(user.action_busy)
			return

		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_METAL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
			"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_METAL - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
				return

		var/obj/item/tool/weldingtool/WT = I
		if(obj_integrity <= max_integrity * 0.3)
			to_chat(user, "<span class='warning'>[src] has sustained too much structural damage to be repaired.</span>")
			return

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
			return

		if(!WT.remove_fuel(0, user))
			return

		user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
		"<span class='notice'>You begin repairing the damage to [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

		var/old_loc = loc
		if(!do_after(user, 50, TRUE, src, BUSY_ICON_FRIENDLY) || old_loc != loc)
			return

		user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		obj_integrity += 150
		update_health()
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

	switch(build_state)
		if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(isscrewdriver(I))
				if(user.action_busy)
					return

				if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_METAL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_CONSTRUCTION_METAL - user.mind.cm_skills.construction )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)

				if(!do_after(user, 10, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",
				"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
				build_state = 1
		if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(isscrewdriver(I))
				if(user.action_busy)
					return
				if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_METAL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_CONSTRUCTION_METAL - user.mind.cm_skills.construction )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				if(!do_after(user, 10, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
				"<span class='notice'>You set [src]'s protection panel back.</span>")
				build_state = 2

			else if(iswrench(I))
				if(user.action_busy)
					return

				if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_METAL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_CONSTRUCTION_METAL - user.mind.cm_skills.construction )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 10, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
				"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
				anchored = FALSE
				build_state = 0
				update_icon() //unanchored changes layer
		if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
			if(iswrench(I))
				if(user.action_busy)
					return

				if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_METAL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_CONSTRUCTION_METAL - user.mind.cm_skills.construction )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				for(var/obj/structure/barricade/B in loc)
					if(B != src && B.dir == dir)
						to_chat(user, "<span class='warning'>There's already a barricade here.</span>")
						return

				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				if(!do_after(user, 10, TRUE, src, BUSY_ICON_BUILD))
					return
					
				user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
				"<span class='notice'>You secure [src]'s anchor bolts.</span>")
				build_state = 1
				anchored = TRUE
				update_icon() //unanchored changes layer

			else if(iscrowbar(I))
				if(user.action_busy)
					return

				if(user.mind?.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_METAL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 50 * ( SKILL_CONSTRUCTION_METAL - user.mind.cm_skills.construction )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
				"<span class='notice'>You start unseating [src]'s panels.</span>")

				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
				"<span class='notice'>You take [src]'s panels apart.</span>")
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				destroy_structure(TRUE) //Note : Handles deconstruction too !


/obj/structure/barricade/metal/ex_act(severity)
	switch(severity)
		if(1)
			obj_integrity -= rand(400, 600)
		if(2)
			obj_integrity -= rand(150, 350)
		if(3)
			obj_integrity -= rand(50, 100)

	update_health()

/obj/structure/barricade/metal/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	obj_integrity -= round(P.damage/10)

	if(istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		obj_integrity -= 50

	update_health()
	return TRUE

/*----------------------*/
// PLASTEEL
/*----------------------*/

/obj/structure/barricade/plasteel
	name = "plasteel barricade"
	desc = "A very sturdy barricade made out of plasteel panels, the pinnacle of strongpoints. Use a blowtorch to repair. Can be flipped down to create a path."
	icon_state = "plasteel_closed_0"
	max_integrity = 600
	crusher_resistant = TRUE
	barricade_resistance = 20
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = 5
	destroyed_stack_amount = 2
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "plasteel"
	density = FALSE
	closed = TRUE
	can_wire = TRUE

	var/build_state = 2 //2 is fully secured, 1 is after screw, 0 is after wrench. Crowbar disassembles
	var/tool_cooldown = 0 //Delay to apply tools to prevent spamming
	var/busy = FALSE //Standard busy check

/obj/structure/barricade/plasteel/handle_barrier_chance(mob/living/M)
	if(closed)
		return ..()
	else
		return FALSE

/obj/structure/barricade/plasteel/examine(mob/user)
	..()

	switch(build_state)
		if(2)
			to_chat(user, "<span class='info'>The protection panel is still tighly screwed in place.</span>")
		if(1)
			to_chat(user, "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>")
		if(0)
			to_chat(user, "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>")

/obj/structure/barricade/plasteel/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(busy || tool_cooldown > world.time)
			return

		tool_cooldown = world.time + 10

		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_PLASTEEL)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
			"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_PLASTEEL - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				return

		if(obj_integrity <= max_integrity * 0.3)
			to_chat(user, "<span class='warning'>[src] has sustained too much structural damage to be repaired.</span>")
			return

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
			return

		if(!WT.remove_fuel(0, user))
			return FALSE


		user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
		"<span class='notice'>You begin repairing the damage to [src].</span>")
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		busy = TRUE

		if(!do_after(user, 50, TRUE, src, BUSY_ICON_FRIENDLY))
			busy = FALSE
			return

		busy = FALSE
		user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
		"<span class='notice'>You repair [src].</span>")
		obj_integrity += 150
		update_health()
		playsound(loc, 'sound/items/welder2.ogg', 25, 1)

	switch(build_state)
		if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(isscrewdriver(I))
				if(busy || tool_cooldown > world.time || user.action_busy)
					return
				tool_cooldown = world.time + 10
				if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_ENGINEER_PLASTEEL - user.mind.cm_skills.engineer )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return

				for(var/obj/structure/barricade/B in loc)
					if(B != src && B.dir == dir)
						to_chat(user, "<span class='warning'>There's already a barricade here.</span>")
						return

				if(!do_after(user, 1, TRUE, src, BUSY_ICON_BUILD))
					return

				user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",

				"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				build_state = 1
		if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(isscrewdriver(I))
				if(busy || tool_cooldown > world.time || user.action_busy)
					return
				tool_cooldown = world.time + 10
				if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_ENGINEER_PLASTEEL - user.mind.cm_skills.engineer )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
				"<span class='notice'>You set [src]'s protection panel back.</span>")
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				build_state = 2

			else if(iswrench(I))
				if(busy || tool_cooldown > world.time || user.action_busy)
					return
				tool_cooldown = world.time + 10
				if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_ENGINEER_PLASTEEL - user.mind.cm_skills.engineer )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
				"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				anchored = FALSE
				build_state = 0
				update_icon() //unanchored changes layer
		if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
			if(iswrench(I))
				if(busy || tool_cooldown > world.time || user.action_busy)
					return
				tool_cooldown = world.time + 10
				if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to assemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to assemble [src].</span>")
					var/fumbling_time = 10 * ( SKILL_ENGINEER_PLASTEEL - user.mind.cm_skills.engineer )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
				"<span class='notice'>You secure [src]'s anchor bolts.</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				anchored = TRUE
				build_state = 1
				update_icon() //unanchored changes layer

			else if(iscrowbar(I))
				if(busy || tool_cooldown > world.time)
					return
				tool_cooldown = world.time + 10
				if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_PLASTEEL)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out how to disassemble [src].</span>",
					"<span class='notice'>You fumble around figuring out how to disassemble [src].</span>")
					var/fumbling_time = 50 * ( SKILL_ENGINEER_PLASTEEL - user.mind.cm_skills.engineer )
					if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
				"<span class='notice'>You start unseating [src]'s panels.</span>")
				playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
				busy = TRUE

				if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
					busy = FALSE
					return

				busy = FALSE
				user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
				"<span class='notice'>You take [src]'s panels apart.</span>")
				playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
				destroy_structure(TRUE) //Note : Handles deconstruction too !


/obj/structure/barricade/plasteel/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(isxeno(user))
		return

	playsound(src.loc, 'sound/items/ratchet.ogg', 25, 1)
	closed = !closed
	density = !density

	if(closed)
		user.visible_message("<span class='notice'>[user] flips [src] open.</span>",
		"<span class='notice'>You flip [src] open.</span>")
	else
		user.visible_message("<span class='notice'>[user] flips [src] closed.</span>",
		"<span class='notice'>You flip [src] closed.</span>")

	update_icon()
	update_overlay()

/obj/structure/barricade/plasteel/ex_act(severity)
	switch(severity)
		if(1)
			obj_integrity -= rand(450, 650)
		if(2)
			obj_integrity -= rand(200, 400)
		if(3)
			obj_integrity -= rand(50, 150)

	update_health()

/obj/structure/barricade/plasteel/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	obj_integrity -= round(P.damage/10)

	if(istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		obj_integrity -= 50

	update_health()
	return TRUE

/*----------------------*/
// SANDBAGS
/*----------------------*/

/obj/structure/barricade/sandbags
	name = "sandbag barricade"
	desc = "A bunch of bags filled with sand, stacked into a small wall. Surprisingly sturdy, albeit labour intensive to set up. Trusted to do the job since 1914."
	icon_state = "sandbag_0"
	barricade_resistance = 15
	max_integrity = 400
	stack_type = /obj/item/stack/sandbags
	barricade_hitsound = "sound/weapons/genhit.ogg"
	barricade_type = "sandbag"
	can_wire = TRUE

/obj/structure/barricade/sandbags/update_icon()
	. = ..()
	if(dir == SOUTH)
		pixel_y = -7
	else if(dir == NORTH)
		pixel_y = 7
	else
		pixel_y = 0


/obj/structure/barricade/sandbags/attackby(obj/item/I, mob/user, params)
	. = ..()

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	if(istype(I, /obj/item/tool/shovel) && user.a_intent != INTENT_HARM)
		var/obj/item/tool/shovel/ET = I
		if(!ET.folded)
			user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
			"<span class='notice'>You start disassembling [src].</span>")
			if(do_after(user, ET.shovelspeed, TRUE, src, BUSY_ICON_BUILD))
				user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
				"<span class='notice'>You disassemble [src].</span>")
				destroy_structure(TRUE)
		return TRUE

	if(istype(I, /obj/item/stack/sandbags) )
		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] isn't in need of repairs!</span>")
			return
		var/obj/item/stack/sandbags/D = I
		if(D.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need a sandbag to repair [src].</span>")
			return
		visible_message("<span class='notice'>[user] begins to replace [src]'s damaged sandbags...</span>")

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD) || obj_integrity >= max_integrity)
			return

		if(!D.use(1))
			return

		obj_integrity = min(obj_integrity + (max_integrity * 0.2), max_integrity) //Each sandbag restores 20% of max health as 5 sandbags = 1 sandbag barricade.
		user.visible_message("<span class='notice'>[user] replaces a damaged sandbag, repairing [src].</span>",
		"<span class='notice'>You replace a damaged sandbag, repairing it [src].</span>")

/obj/structure/barricade/sandbags/bullet_act(obj/item/projectile/P)
	bullet_ping(P)
	obj_integrity -= round(P.damage/10)

	if(istype(P.ammo, /datum/ammo/xeno/boiler_gas))
		obj_integrity -= 50

	update_health()

	return TRUE
