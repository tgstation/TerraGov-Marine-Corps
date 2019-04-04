

/obj/structure/reagent_dispensers
	name = "dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	container_type = AMOUNT_VISIBLE
	var/tank_volume = 1000
	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

/obj/structure/reagent_dispensers/attackby(obj/item/W as obj, mob/user as mob)
	if(W.is_refillable())
		return FALSE //so we can refill them via their afterattack.
	else
		return ..()

/obj/structure/reagent_dispensers/New()
	. = ..()
	create_reagents(tank_volume)
	if (!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
	add_initial_reagents()

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/particle_effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/particle_effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return !density



//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	list_reagents = list("water" = 1000)



/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	list_reagents = list("fuel" = 1000)
	var/modded = FALSE
	var/obj/item/device/assembly_holder/rig = null
	var/exploding = FALSE


/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	. = ..()
	if(user != loc)

		return
	if(modded)
		to_chat(user, "<span class='warning'> Fuel faucet is wrenched open, leaking the fuel!</span>")
	if(rig)
		to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")

/obj/structure/reagent_dispensers/fueltank/attack_hand()
	if (rig)
		usr.visible_message("[usr] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]...")
		if(do_after(usr, 20, TRUE, 5, BUSY_ICON_BUILD))
			usr.visible_message("<span class='notice'>[usr] detaches [rig] from \the [src].</span>", "<span class='notice'>You detach [rig] from \the [src].</span>")
			rig.loc = get_turf(usr)
			rig = null
			overlays = new/list()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/user)
	add_fingerprint(user)
	if(iswrench(I))
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
		"You wrench [src]'s faucet [modded ? "closed" : "open"]")
		modded = !modded
		if(modded)
			message_admins("[ADMIN_TPMONTY(usr)] opened fueltank at [ADMIN_VERBOSEJMP(loc)], leaking fuel.")
			log_game("[key_name(usr)] opened fueltank at [AREACOORD(loc)], leaking fuel.")
			leak_fuel(amount_per_transfer_from_this)
		return
	if(istype(I,/obj/item/device/assembly_holder))
		if(rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return
		user.visible_message("[user] begins rigging [I] to \the [src].", "You begin rigging [I] to \the [src]")
		if(do_after(user, 20, TRUE, 5, BUSY_ICON_HOSTILE) && !rig)
			user.visible_message("<span class='notice'>[user] rigs [I] to \the [src].</span>", "<span class='notice'>You rig [I] to \the [src].</span>")
			var/obj/item/device/assembly_holder/H = I
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[ADMIN_TPMONTY(usr)] rigged fueltank at [ADMIN_VERBOSEJMP(loc)] for explosion.")
				log_game("[key_name(user)] rigged fueltank at [AREACOORD(loc)] for explosion.")
			rig = I
			user.transferItemToLoc(I, src)

			var/icon/test = getFlatIcon(I)
			test.Shift(NORTH,1)
			test.Shift(EAST,6)
			overlays += test
			return

	if(iswelder(I))
		var/obj/item/tool/weldingtool/W = I
		if(!W.welding)
			if(W.reagents.has_reagent("welding_fuel", W.max_fuel))
				to_chat(user, "<span class='warning'>Your [W.name] is already full!</span>")
				return
			reagents.trans_to(W, W.max_fuel)
			W.weld_tick = 0
			user.visible_message("<span class='notice'>[user] refills [W].</span>", "<span class='notice'>You refill [W].</span>")
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		else
			log_game("[key_name(user)] triggered a fueltank explosion with a blowtorch at [AREACOORD(src.loc)].")
			message_admins("[ADMIN_TPMONTY(user)] triggered a fueltank explosion with a blowtorch.")
			log_explosion("[key_name(user)] triggered a fueltank explosion with a blowtorch at [AREACOORD(user.loc)].")
			var/self_message = user.a_intent != INTENT_HARM ? "<span class='danger'>You begin welding on the fueltank, and in a last moment of lucidity realize this might not have been the smartest thing you've ever done.</span>" : "<span class='danger'>[src] catastrophically explodes in a wave of flames as you begin to weld it.</span>"
			user.visible_message("<span class='warning'>[user] catastrophically fails at refilling \his [W.name]!</span>", self_message)
			explode()
		return

	return ..()

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/Proj)
	if(exploding)
		return FALSE

	. = ..()

	if(Proj.damage > 10 && prob(60) && (Proj.ammo.damage_type in list(BRUTE, BURN)))
		if(ismob(Proj.firer))
			var/mob/shooter = Proj.firer
			if(shooter.client)
				message_admins("[ADMIN_TPMONTY(shooter)] shot a fueltank at [ADMIN_VERBOSEJMP(loc)], setting it off.")
				log_game("[key_name(shooter)] shot a fueltank at [AREACOORD(loc)], setting it off.")
		explode()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/proc/explode()
	log_explosion("[key_name(usr)] triggered a fueltank explosion at [AREACOORD(loc)].")
	if(exploding)
		return
	exploding = TRUE
	if (reagents.total_volume > 500)
		explosion(src.loc,0,0,3, flame_range = 4)
	else if (reagents.total_volume > 100)
		explosion(src.loc,0,0,2, flame_range = 3)
	else
		explosion(src.loc,0,0,1, flame_range = 2)
	if(src)
		qdel(src)

/obj/structure/reagent_dispensers/fueltank/fire_act(temperature, volume)
	if(temperature > T0C+500)
		explode()
	return ..()

/obj/structure/reagent_dispensers/fueltank/Move()
	if (..() && modded)
		leak_fuel(amount_per_transfer_from_this/10.0)

/obj/structure/reagent_dispensers/fueltank/proc/leak_fuel(amount)
	if (reagents.total_volume == 0)
		return

	amount = min(amount, reagents.total_volume)
	reagents.remove_reagent("fuel",amount)
	new /obj/effect/decal/cleanable/liquid_fuel(src.loc, amount,1)

/obj/structure/reagent_dispensers/fueltank/flamer_fire_act()
	explode()

/obj/structure/reagent_dispensers/water_cooler
	name = "water cooler"
	desc = "A machine that dispenses water to drink."
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = TRUE
	tank_volume = 500
	list_reagents = list("water" = 500)


/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	list_reagents = list("beer" = 1000)


/obj/structure/reagent_dispensers/wallmounted
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "generic_tank"
	anchored = TRUE
	density = FALSE

/obj/structure/reagent_dispensers/wallmounted/Initialize(mapload, ndir)
	. = ..()
	if(ndir)
		dir = ndir
	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

/obj/structure/reagent_dispensers/wallmounted/peppertank
	name = "pepper spray refiller"
	desc = "Refill pepper spray canisters."
	icon_state = "peppertank"
	amount_per_transfer_from_this = 45
	list_reagents = list("condensedcapsaicin" = 1000)

/obj/structure/reagent_dispensers/wallmounted/peppertank/New()
	. = ..()
	if(prob(1))
		desc = "IT'S PEPPER TIME, BITCH!"

/obj/structure/reagent_dispensers/wallmounted/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of virus food."
	icon_state = "virusfoodtank"
	list_reagents = list("virusfood" = 1000)
