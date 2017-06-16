// Snow, wood, sandbags, metal, plasteel

/obj/structure/barricade
	icon = 'icons/Marine/barricades.dmi'
	climbable = TRUE
	anchored = TRUE
	density = 1
	throwpass = TRUE //You can throw objects over this, despite its density.
	layer = OBJ_LAYER - 0.1
	var/stack_type //the type of stack the barricade dropped when disassembled if any.
	var/stack_amount = 5 //the amount of stack dropped when disassembled
	var/always_drop_stack = FALSE //whether the amount of stack dropped is independent of the health.
	var/health = 100 //Pretty tough. Changes sprites at 300 and 150
	var/maxhealth = 100 //Basic code functions
	var/crusher_resistant = TRUE //whether a crusher can ram through it.
	var/barricade_resistance = 5 //how much force an item needs to even damage it at all.
	var/barricade_hitsound

	var/barricade_type = "barricade"	//"metal", "plasteel", etc.
	var/can_change_dmg_state = 1
	var/damage_state = 0
	var/closed = 0
	var/can_wire = 0
	var/is_wired = 0
	var/image/wired_overlay

	New()
		..()
		spawn(0)
			update_icon()

	examine(mob/user)
		..()

		var/health_percent = health/maxhealth * 100

		if (health_percent < 25)
			user << "<span class='warning'>It's crumbling apart, just a few more blows will tear it apart.</span>"
		else if (health_percent < 50)
			user << "<span class='warning'>It's quite beat up, but it's holding together.</span>"
		else if (health_percent < 75)
			user << "<span class='warning'>It's slightly damaged, but still very functional.</span>"
		else
			user << "<span class='info'>It appears to be in good shape.</span>"

	Bumped(atom/A)
		..()

		if (istype(A, /mob/living/carbon/Xenomorph/Crusher))

			var/mob/living/carbon/Xenomorph/Crusher/C = A

			if (C.momentum < 25)
				return

			if (crusher_resistant)
				health -= 150
				update_health()

			else if(!C.stat)
				visible_message("<span class='danger'>[C] steamrolls through [src]!</span>")
				destroy()

	CheckExit(atom/movable/O, turf/target)
		if (closed)
			return 1

		var/obj/structure/table/T = locate() in get_turf(O)
		if(T && !T.flipped) //Non-flipped tables let you climb on barricades.
			return 1

		if((flags_atom & ON_BORDER) && get_dir(loc, target) == dir)
			return 0
		else
			return 1

	CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
		if (closed)
			return 1

		var/obj/structure/table/T = locate() in get_turf(mover)
		if(T && !T.flipped) //Non-flipped tables let you climb on barricades.
			return 1

		if(!(flags_atom & ON_BORDER) || get_dir(loc, target) == dir)
			return 0
		else
			return 1

	attackby(obj/item/W as obj, mob/user)
		if (istype(W, /obj/item/barbed_wire))
			var/obj/item/barbed_wire/B = W

			if (can_wire)
				if (!closed)
					wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[src.barricade_type]_wire", dir = src.dir)
				else
					wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[src.barricade_type]_closed_wire", dir = src.dir)

				overlays += wired_overlay
				health += 25
				maxhealth += 25
				can_wire = 0
				is_wired = 1
				climbable = FALSE
				cdel(B)
			return

		if(W.force > barricade_resistance)
			..()
			if(barricade_hitsound)
				playsound(src, barricade_hitsound, 25, 1)
			hit_barricade(W)

	destroy()
		if(stack_type)
			var/stack_amt
			if(always_drop_stack) stack_amt = stack_amount
			else stack_amt = round(stack_amount * (health/maxhealth)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0

			if(stack_amt) new stack_type (loc, stack_amt)
		cdel(src)

	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("<span class='danger'>[src] is blown apart!</span>")
				cdel(src)
				return
			if(2.0)
				health -= rand(33, 66)
			if(3.0)
				health -= rand(10, 33)
		update_health()

	update_icon()
		if(flags_atom & ON_BORDER)
			if (!can_change_dmg_state)
				icon_state = "[barricade_type]"
				if(dir == SOUTH) layer = MOB_LAYER + 1
				else layer = initial(layer)

			if (!closed)
				icon_state = "[barricade_type]_[damage_state]"
				if(dir == SOUTH) layer = MOB_LAYER + 1
				else layer = initial(layer)
			else
				icon_state = "[barricade_type]_closed_[damage_state]"
				layer = MOB_LAYER - 1

/obj/structure/barricade/proc/update_overlay()
	if (!is_wired)
		return

	overlays -= wired_overlay
	if (!closed)
		wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[src.barricade_type]_wire", dir = src.dir, pixel_y = src.pixel_y)
	else
		wired_overlay = image('icons/Marine/barricades.dmi', icon_state = "[src.barricade_type]_closed_wire", dir = src.dir)
	overlays += wired_overlay

/obj/structure/barricade/proc/hit_barricade(obj/item/I)
	health -= I.force * 0.5
	update_health()

/obj/structure/barricade/proc/update_health(nomessage)
	health = Clamp(health, 0, maxhealth)

	if(!health)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroy()
		return

	update_damage_state()
	update_icon()

/obj/structure/barricade/proc/update_damage_state()
	var/health_percent = health/maxhealth * 100

	if (health_percent < 25)
		damage_state = 3
	else if (health_percent < 50)
		damage_state = 2
	else if (health_percent < 75)
		damage_state = 1
	else
		damage_state = 0

/obj/structure/barricade/proc/smoke_damage(var/obj/effect/particle_effect/smoke/S)
	if (istype(S, /obj/effect/particle_effect/smoke/xeno_burn))
		health -= 10
		update_health()

/*----------------------*/
// SNOW
/*----------------------*/

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "It could be worse..."
	icon = 'icons/turf/snowbarricade.dmi'
	icon_state = "barricade_3"
	health = 50 //Actual health depends on snow layer
	maxhealth = 50
	can_change_dmg_state = 0
	can_wire = 0

	//Item Attack
	attackby(obj/item/W as obj, mob/user as mob)
		//Removing the barricades
		if(istype(W, /obj/item/snow_shovel))
			var/obj/item/snow_shovel/S = W
			if(S.mode == 2)
				if(S.working)
					user  << "\red You are already shoveling!"
					return
				user.visible_message("[user.name] starts clearing out \the [src].","You start removing \the [src].")
				S.working = 1
				if(!do_after(user,100, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
					S.working = 0
					return
				user.visible_message("\blue \The [user] clears out \the [src].")
				S.working = 0
				cdel(src)
			return

		. = ..()

	hit_barricade(obj/item/I)
		switch(I.damtype)
			if("fire")
				health -= I.force * 0.6
			if("brute")
				health -= I.force * 0.3

		update_health()
		update_icon()
		return

	bullet_act(var/obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/2) //Not that durable.

		if (istype(P.ammo, /datum/ammo/xeno/boiler_gas))
			health -= 50

		update_health()
		return 1



/*----------------------*/
// WOOD
/*----------------------*/

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon_state = "wooden"
	health = 50
	maxhealth = 50
	layer = OBJ_LAYER
	climbable = FALSE
	throwpass = FALSE
	stack_type = /obj/item/stack/sheet/wood
	stack_amount = 3
	always_drop_stack = TRUE
	barricade_hitsound = "sound/effects/woodhit.ogg"
	can_change_dmg_state = 0
	barricade_type = "wooden"
	can_wire = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/stack/sheet/wood))
			var/obj/item/stack/sheet/wood/D = W
			if (health < maxhealth)
				if (D.get_amount() < 1)
					user << "<span class='warning'>You need one plank of wood to repair [src].</span>"
					return
				visible_message("<span class='notice'>[user] begins to repair [src].</span>")
				if(do_after(user,20, TRUE, 5, BUSY_ICON_CLOCK) && health < maxhealth)
					if (D.use(1))
						health = maxhealth
						visible_message("<span class='notice'>[user] repairs [src].</span>")
			return
		. = ..()

	hit_barricade(obj/item/I)
		switch(I.damtype)
			if("fire")
				health -= I.force * 1
			if("brute")
				health -= I.force * 0.75
		update_health()

	bullet_act(var/obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/2) //Not that durable.

		if (istype(P.ammo, /datum/ammo/xeno/boiler_gas))
			health -= 50

		update_health()
		return 1

/*----------------------*/
// METAL
/*----------------------*/

/obj/structure/barricade/metal
	name = "metal barricade"
	desc = "A solid barricade made of reinforced metal. Use a welding tool to repair it if damaged."
	icon_state = "metal_0"
	flags_atom = ON_BORDER
	health = 100
	maxhealth = 100
	crusher_resistant = TRUE
	barricade_resistance = 10
	stack_type = /obj/item/stack/sheet/metal
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "metal"
	can_wire = 1


	var/build_state = 2 //2 is fully secured, 1 is after screw, 0 is after wrench. Crowbar disassembles
	var/tool_cooldown = 0 //Delay to apply tools to prevent spamming
	var/busy = 0 //Standard busy check

	examine(mob/user)
		..()
		switch(build_state)
			if(2)
				user << "<span class='info'>The protection panel is still tighly screwed in place.</span>"
			if(1)
				user << "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>"
			if(0)
				user << "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>"

	attackby(obj/item/W, mob/user)

		if(iswelder(W))
			if(busy || tool_cooldown > world.time)
				return
			tool_cooldown = world.time + 10
			var/obj/item/weapon/weldingtool/WT = W
			if(health <= maxhealth * 0.3)
				user << "<span class='warning'>[src] has sustained too much structural damage to be repaired.</span>"
				return

			if(health == maxhealth)
				user << "<span class='warning'>[src] doesn't need repairs.</span>"
				return

			if(WT.remove_fuel(0, user))
				user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
				"<span class='notice'>You begin repairing the damage to [src].</span>")
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				busy = 1
				if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
					busy = 0
					user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
					"<span class='notice'>You repair [src].</span>")
					health += 150
					update_health()
					playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				else busy = 0
			return

		switch(build_state)
			if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
				if(isscrewdriver(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",
					"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
					build_state = 1
					return
			if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
				if(isscrewdriver(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
					"<span class='notice'>You set [src]'s protection panel back.</span>")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
					build_state = 2
					return
				if(iswrench(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
					"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					anchored = FALSE
					build_state = 0
					return
			if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
				if(iswrench(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
					"<span class='notice'>You secure [src]'s anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					build_state = 1
					anchored = TRUE
					return
				if(iscrowbar(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
					"<span class='notice'>You start unseating [src]'s panels.</span>")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					busy = 1
					if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
						busy = 0
						user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
						"<span class='notice'>You take [src]'s panels apart.</span>")
						playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
						destroy() //Note : Handles deconstruction too !
					else busy = 0
					return

		. = ..()

	ex_act(severity)
		switch(severity)
			if(1)
				health -= rand(400, 600)
			if(2)
				health -= rand(150, 350)
			if(3)
				health -= rand(50, 100)

		update_health()

	bullet_act(obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/10)

		if (istype(P.ammo, /datum/ammo/xeno/boiler_gas))
			health -= 50

		update_health()
		return 1



/*----------------------*/
// PLASTEEL
/*----------------------*/

/obj/structure/barricade/plasteel
	name = "plasteel barricade"
	desc = "A very strong barricade comprised of pure plasteel."
	icon_state = "plasteel_0"
	flags_atom = ON_BORDER
	health = 500
	maxhealth = 500
	crusher_resistant = TRUE
	barricade_resistance = 20
	stack_type = /obj/item/stack/sheet/plasteel
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "plasteel"
	closed = 1
	can_wire = 1

	var/build_state = 2 //2 is fully secured, 1 is after screw, 0 is after wrench. Crowbar disassembles
	var/tool_cooldown = 0 //Delay to apply tools to prevent spamming
	var/busy = 0 //Standard busy check

	examine(mob/user)
		..()

		switch(build_state)
			if(2)
				user << "<span class='info'>The protection panel is still tighly screwed in place.</span>"
			if(1)
				user << "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>"
			if(0)
				user << "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>"



	attackby(obj/item/W, mob/user)

		if(iswelder(W))
			if(busy || tool_cooldown > world.time)
				return
			tool_cooldown = world.time + 10
			var/obj/item/weapon/weldingtool/WT = W
			if(health <= maxhealth * 0.3)
				user << "<span class='warning'>[src] has sustained too much structural damage to be repaired.</span>"
				return

			if(health == maxhealth)
				user << "<span class='warning'>[src] doesn't need repairs.</span>"
				return

			if(WT.remove_fuel(0, user))
				user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
				"<span class='notice'>You begin repairing the damage to [src].</span>")
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				busy = 1
				if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
					busy = 0
					user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
					"<span class='notice'>You repair [src].</span>")
					health += 150
					update_health()
					playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				else busy = 0
			return

		switch(build_state)
			if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
				if(isscrewdriver(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",
					"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
					build_state = 1
					return

			if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
				if(isscrewdriver(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
					"<span class='notice'>You set [src]'s protection panel back.</span>")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
					build_state = 2
					return
				if(iswrench(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
					"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					anchored = FALSE
					build_state = 0
					return

			if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
				if(iswrench(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
					"<span class='notice'>You secure [src]'s anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					anchored = TRUE
					build_state = 1
					return
				if(iscrowbar(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
					"<span class='notice'>You start unseating [src]'s panels.</span>")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					busy = 1
					if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
						busy = 0
						user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
						"<span class='notice'>You take [src]'s panels apart.</span>")
						playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
						destroy() //Note : Handles deconstruction too !
					else busy = 0
					return

		. = ..()

	attack_hand(mob/user as mob)
		if (isXeno(user))
			return

		if (closed)
			user.visible_message("<span class='notice'>[user] flips the [src] open.</span>",
			"<span class='notice'>You flip the [src] open.</span>")
		else
			user.visible_message("<span class='notice'>[user] flips the [src] closed.</span>",
			"<span class='notice'>You flip the [src] open.</span>")

		playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
		closed = !closed
		update_icon()
		update_overlay()

	ex_act(severity)
		switch(severity)
			if(1)
				health -= rand(400, 600)
			if(2)
				health -= rand(150, 350)
			if(3)
				health -= rand(50, 100)

		update_health()

	bullet_act(obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/10)

		if (istype(P.ammo, /datum/ammo/xeno/boiler_gas))
			health -= 50

		update_health()
		return 1

/*----------------------*/
// SANDBAGS
/*----------------------*/

/obj/structure/barricade/sandbags
	name = "sandbag barricade"
	desc = "Trusted since 1914"
	icon_state = "sandbag_0"
	flags_atom = ON_BORDER
	barricade_resistance = 15
	health = 250
	maxhealth = 250
	stack_type = /obj/item/stack/sandbags
	barricade_hitsound = "sound/weapons/Genhit.ogg"
	barricade_type = "sandbag"
	can_wire = 1

	New()
		..()

		if (dir == NORTH)
			pixel_y = -7

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/weapon/etool) && user.a_intent != "harm")
			var/obj/item/weapon/etool/ET = W
			if(!ET.folded)
				user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
					"<span class='notice'>You start disassembling [src].</span>")
				if(do_after(user, 30, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
						"<span class='notice'>You disassemble [src].</span>")
					destroy()
			return 1
		else
			. = ..()

	bullet_act(obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/10)

		if (istype(P.ammo, /datum/ammo/xeno/boiler_gas))
			health -= 50

		update_health()

		return 1

// Empty sandbags
/obj/item/stack/sandbags_empty
	name = "empty sandbags"
	desc = "Some empty sandbags, best fill them up."
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_stack"
	flags_atom = FPRINT
	w_class = 3.0
	force = 2
	throwforce = 0
	throw_speed = 5
	throw_range = 20
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		if (istype(W, /obj/item/weapon/etool))
			var/obj/item/weapon/etool/ET = W
			if(ET.has_dirt)
				var/obj/item/stack/sandbags/new_bags = new(usr.loc)
				new_bags.add_to_stacks(usr)
				var/obj/item/stack/sandbags_empty/E = src
				src = null
				var/replace = (user.get_inactive_hand()==E)
				E.use(1)
				ET.has_dirt = 0
				ET.update_icon()
				if (!E && replace)
					user.put_in_hands(new_bags)
			return
		..()

//Full sandbags
/obj/item/stack/sandbags
	name = "sandbags"
	desc = "Some bags, filled often for extra protection"
	singular_name = "sandbag"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "sandbag_pile"
	flags_atom = FPRINT
	w_class = 4.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	max_amount = 25
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sandbags/attack_self(mob/user)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if(istype(get_area(usr.loc),/area/sulaco/hangar))  //HANGAR BUILDING
		user << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
		return

	for(var/obj/structure/barricade/B in user.loc)
		if(!(B.flags_atom & ON_BORDER) || user.dir == B.dir)
			user << "<span class='warning'>You can't place more sandbags where a barricade is!</span>"
			return

	if(locate(/obj/structure/table, user.loc) || locate(/obj/structure/rack, user.loc))
		user << "<span class='warning'>You can't place sandbags where other structures are!</span>"
		return

	if(!in_use)
		if(amount < 5)
			user << "<span class='warning'>You need at least five sandbags to do this.</span>"
			return
		user << "<span class='notice'>Assembling sandbag barricade...</span>"
		in_use = 1
		if (!do_after(usr, 20, TRUE, 5, BUSY_ICON_CLOCK))
			in_use = 0
			return
		var/obj/structure/barricade/sandbags/SB = new ( usr.loc )
		user << "<span class='notice'>You assemble a sandbag barricade!</span>"
		SB.dir = usr.dir
		in_use = 0
		SB.add_fingerprint(usr)
		use(5)
	return

/obj/item/barbed_wire
	name = "barbed wire"
	desc = "A spiky length of wire."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "barbed_wire"
	w_class = 1.0
	force = 2.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	attack_verb = list("hit", "whacked", "sliced")