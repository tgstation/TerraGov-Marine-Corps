

/obj/structure/reagent_dispensers
	name = "dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = TRUE
	anchored = FALSE
	///maximum tank capacity used to set reagents in initialize
	var/tank_volume = 1000
	///Current amount we will transfer every time we click on this
	var/amount_per_transfer_from_this = 10
	///list of possible transer amounts for this reagent dispenser
	var/possible_transfer_amounts = list(10,25,50,100)
	///List of reagents this dispenser will start with
	var/list/list_reagents

/obj/structure/reagent_dispensers/attackby(obj/item/I, mob/user, params)
	if(I.is_refillable())
		return FALSE //Handled in reagent code, which refills the item
	return ..()

/obj/structure/reagent_dispensers/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!possible_transfer_amounts)
		return
	var/result = tgui_input_list(user, "Amount per transfer from this:","[src]", possible_transfer_amounts)
	if(result)
		amount_per_transfer_from_this = result

/obj/structure/reagent_dispensers/Initialize()
	. = ..()
	create_reagents(tank_volume, AMOUNT_VISIBLE|DRAINABLE, list_reagents)

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				new /obj/effect/particle_effect/water(loc)
				qdel(src)
		if(EXPLODE_LIGHT)
			if (prob(5))
				new /obj/effect/particle_effect/water(loc)
				qdel(src)


/obj/structure/reagent_dispensers/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE

//Dispensers
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/water = 1000)



/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	list_reagents = list(/datum/reagent/fuel = 1000)
	///Whether this tank is modded to drip fuel when its moved
	var/modded = FALSE
	///Rig we attached to this fuel tank
	var/obj/item/assembly_holder/rig
	//Whether the tank is already exploding to prevent chain explosions
	var/exploding = FALSE

/obj/structure/reagent_dispensers/fueltank/Destroy()
	. = ..()
	QDEL_NULL(rig)

/obj/structure/reagent_dispensers/fueltank/examine(mob/user)
	. = ..()
	if(user != loc)

		return
	if(modded)
		to_chat(user, "<span class='warning'> Fuel faucet is wrenched open, leaking the fuel!</span>")
	if(rig)
		to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")

/obj/structure/reagent_dispensers/fueltank/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!rig)
		return
	user.visible_message("[user] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]...")
	if(!do_after(user, 2 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return
	user.visible_message("<span class='notice'>[user] detaches [rig] from \the [src].</span>", "<span class='notice'>You detach [rig] from \the [src].</span>")
	rig.forceMove(get_turf(user))
	rig = null
	cut_overlays()


/obj/structure/reagent_dispensers/fueltank/wrench_act(mob/living/user, obj/item/I)
	user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
	"You wrench [src]'s faucet [modded ? "closed" : "open"]")
	modded = !modded
	log_attack("[key_name(user)] has wrenched [src] [modded ? "closed" : "open"] in [AREACOORD(user)]")
	if(modded)
		leak_fuel(amount_per_transfer_from_this)
	return TRUE

/obj/structure/reagent_dispensers/fueltank/welder_act(mob/living/user, obj/item/I)
	var/obj/item/tool/weldingtool/W = I
	if(!W.welding)
		if(W.reagents.has_reagent(/datum/reagent/fuel, W.max_fuel))
			to_chat(user, "<span class='warning'>Your [W.name] is already full!</span>")
			return
		reagents.trans_to(W, W.max_fuel)
		W.weld_tick = 0
		user.visible_message("<span class='notice'>[user] refills [W].</span>", "<span class='notice'>You refill [W].</span>")
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	log_explosion("[key_name(user)] triggered a fueltank explosion with a blowtorch at [AREACOORD(user.loc)].")
	var/self_message = user.a_intent != INTENT_HARM ? "<span class='danger'>You begin welding on the fueltank, and in a last moment of lucidity realize this might not have been the smartest thing you've ever done.</span>" : "<span class='danger'>[src] catastrophically explodes in a wave of flames as you begin to weld it.</span>"
	user.visible_message("<span class='warning'>[user] catastrophically fails at refilling \his [W.name]!</span>", self_message)
	explode()
	return TRUE


/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/assembly_holder))
		return
	if(rig)
		to_chat(user, "<span class='warning'>There is another device in the way.</span>")
		return

	user.visible_message("[user] begins rigging [I] to \the [src].", "You begin rigging [I] to \the [src]")
	if(!do_after(user, 20, TRUE, src, BUSY_ICON_HOSTILE) || rig)
		return

	user.visible_message("<span class='notice'>[user] rigs [I] to \the [src].</span>", "<span class='notice'>You rig [I] to \the [src].</span>")
	rig = I
	user.transferItemToLoc(I, src)

	var/mutable_appearance/overlay = new()
	overlay.appearance = I.appearance
	overlay.pixel_x = 1
	overlay.pixel_y = 6
	add_overlay(overlay)


/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/projectile/Proj)
	if(exploding)
		return FALSE

	. = ..()

	if(Proj.damage > 10 && prob(60) && (Proj.ammo.damage_type in list(BRUTE, BURN)))
		explode()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

///Does what it says on the tin, blows up the fueltank with radius depending on fuel left
/obj/structure/reagent_dispensers/fueltank/proc/explode()
	log_explosion("[key_name(usr)] triggered a fueltank explosion at [AREACOORD(loc)].")
	if(exploding)
		return
	exploding = TRUE
	if (reagents.total_volume > 500)
		explosion(loc, light_impact_range = 4, flame_range = 4, small_animation = TRUE)
	else if (reagents.total_volume > 100)
		explosion(loc, light_impact_range = 3, flame_range = 3, small_animation = TRUE)
	else
		explosion(loc, light_impact_range = 2, flame_range = 2, small_animation = TRUE)
	qdel(src)

/obj/structure/reagent_dispensers/fueltank/fire_act(temperature, volume)
	if(temperature > T0C+500)
		explode()
	return ..()

/obj/structure/reagent_dispensers/fueltank/Move()
	. = ..()
	if (. && modded)
		leak_fuel(amount_per_transfer_from_this/10.0)

///Leaks fuel when the valve is opened, leaving behind burnable splotches
/obj/structure/reagent_dispensers/fueltank/proc/leak_fuel(amount)
	if(reagents.total_volume <= 0)
		return

	amount = min(amount, reagents.total_volume)
	reagents.remove_reagent(/datum/reagent/fuel,amount)
	new /obj/effect/decal/cleanable/liquid_fuel(loc, amount, FALSE)

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
	list_reagents = list(/datum/reagent/water = 500)


/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 1000)


/obj/structure/reagent_dispensers/wallmounted
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "generic_tank"
	pixel_x = -16
	pixel_y = -16
	anchored = TRUE
	density = FALSE

/obj/structure/reagent_dispensers/wallmounted/Initialize(mapload, ndir)
	. = ..()
	if(ndir)
		setDir(ndir)
	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32

/obj/structure/reagent_dispensers/wallmounted/peppertank
	name = "pepper spray refiller"
	desc = "Refill pepper spray canisters."
	icon_state = "peppertank"
	amount_per_transfer_from_this = 45
	list_reagents = list(/datum/reagent/consumable/capsaicin/condensed = 1000)

/obj/structure/reagent_dispensers/wallmounted/milk
	name = "milk dispenser"
	desc = "Custom addition by your predecessor... why"
	icon_state = "milktank"
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/consumable/drink/milk = 5000)

/obj/structure/reagent_dispensers/wallmounted/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of virus food."
	icon_state = "virusfoodtank"
	list_reagents = list(/datum/reagent/consumable/virus_food = 1000)
