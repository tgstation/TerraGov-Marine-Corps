//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "closed_basic"
	icon_opened = "open_basic"
	icon_closed = "closed_basic"
	climbable = 1
//	mouse_drag_pointer = MOUSE_ACTIVE_POINTER	//???
	anchored = 0
	var/rigged = 0


/obj/structure/closet/crate/can_open()
	return 1

/obj/structure/closet/crate/can_close()
	return 1


/obj/structure/closet/crate/open()
	if(src.opened)
		return 0
	if(!src.can_open())
		return 0

	if(rigged && locate(/obj/item/device/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return 2

	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	for(var/obj/O in src)
		O.loc = get_turf(src)
	icon_state = icon_opened
	src.opened = 1

	if(climbable)
		structure_shaken()
	return 1

/obj/structure/closet/crate/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	var/itemcount = 0
	for(var/obj/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || istype(O,/obj/structure/closet))
			continue
		if(istype(O, /obj/structure/stool/bed)) //This is only necessary because of rollerbeds and swivel chairs.
			var/obj/structure/stool/bed/B = O
			if(B.buckled_mob)
				continue
		O.loc = src
		itemcount++

	icon_state = icon_closed
	src.opened = 0
	return 1

/obj/structure/closet/crate/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(opened)
		if(isrobot(user))
			return
		user.drop_inv_item_to_loc(W, loc)
	else if(istype(W, /obj/item/weapon/packageWrap))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(rigged)
			user << "<span class='notice'>[src] is already rigged!</span>"
			return
		if (C.use(1))
			user  << "<span class='notice'>You rig [src].</span>"
			rigged = 1
			return
	else if(istype(W, /obj/item/device/radio/electropack))
		if(rigged)
			user  << "<span class='notice'>You attach [W] to [src].</span>"
			user.drop_held_item()
			W.loc = src
			return
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(rigged)
			user  << "<span class='notice'>You cut away the wiring.</span>"
			playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
			rigged = 0
			return
	else return attack_hand(user)

/obj/structure/closet/crate/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/O in src.contents)
				del(O)
			del(src)
			return
		if(2.0)
			for(var/obj/O in src.contents)
				if(prob(50))
					del(O)
			del(src)
			return
		if(3.0)
			if (prob(50))
				del(src)
			return
		else
	return

/* Old Code
/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/redlight = "securecrater"
	var/greenlight = "securecrateg"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	var/broken = 0
	var/locked = 1
*/

/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "secure_locked_basic"
	icon_opened = "secure_open_basic"
	icon_closed = "secure_locked_basic"
	var/icon_locked = "secure_locked_basic"
	var/icon_unlocked = "secure_unlocked_basic"
	var/sparks = "securecratesparks"
	var/emag = "securecrateemag"
	var/broken = 0
	var/locked = 1

/* Old overlay system
/obj/structure/closet/crate/secure/New()
	..()
	if(locked)
		overlays.Cut()
		overlays += redlight
	else
		overlays.Cut()
		overlays += greenlight

/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user as mob)
	if(src.opened)
		user << "<span class='notice'>Close the crate first.</span>"
		return
	if(src.broken)
		user << "<span class='warning'>The crate appears to be broken.</span>"
		return
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				O << "<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>"
		overlays.Cut()
		overlays += locked ? redlight : greenlight
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(!usr.canmove || usr.stat || usr.is_mob_restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.togglelock(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if(locked)
		src.togglelock(user)
	else
		src.toggle(user)

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_type_in_list(W, list(/obj/item/weapon/packageWrap, /obj/item/stack/cable_coil, /obj/item/device/radio/electropack, /obj/item/weapon/wirecutters, /obj/item/weapon/weldingtool)))
		return ..()
	if(locked && (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)))
		overlays.Cut()
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 60, 1)
		src.locked = 0
		src.broken = 1
		user << "<span class='notice'>You unlock \the [src].</span>"
		return
	if(!opened)
		src.togglelock(user)
		return
	return ..()

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			overlays.Cut()
			overlays += redlight
		else
			overlays.Cut()
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()
*/

/obj/structure/closet/crate/secure/New()
	..()
	if(locked)
		icon_state = icon_locked
	else
		icon_state = icon_unlocked

/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user as mob)
	if(src.opened)
		user << "<span class='notice'>Close the crate first.</span>"
		return
	if(src.broken)
		user << "<span class='warning'>The crate appears to be broken.</span>"
		return
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				O << "<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>"
		icon_state = locked ? icon_locked : icon_unlocked
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(!usr.canmove || usr.stat || usr.is_mob_restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.togglelock(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if(locked)
		src.togglelock(user)
	else
		src.toggle(user)

/obj/structure/closet/crate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(is_type_in_list(W, list(/obj/item/weapon/packageWrap, /obj/item/stack/cable_coil, /obj/item/device/radio/electropack, /obj/item/weapon/wirecutters, /obj/item/weapon/weldingtool)))
		return ..()
	if(locked && (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)))
		overlays.Cut()
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 25, 1)
		src.locked = 0
		src.broken = 1
		user << "<span class='notice'>You unlock \the [src].</span>"
		return
	if(!opened)
		src.togglelock(user)
		return
	return ..()

/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			src.locked = 1
			icon_state = icon_unlocked
		else
			overlays.Cut()
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 25, 1)
			src.locked = 0
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/crate/alpha
	name = "alpha squad crate"
	desc = "A crate with alpha squad's symbol on it. "
	icon_state = "closed_alpha"
	icon_opened = "open_alpha"
	icon_closed = "closed_alpha"

/obj/structure/closet/crate/ammo
	name = "ammunitions crate"
	desc = "A ammunitions crate"
	icon_state = "closed_ammo"
	icon_opened = "open_ammo"
	icon_closed = "closed_ammo"

/obj/structure/closet/crate/bravo
	name = "bravo squad crate"
	desc = "A crate with bravo squad's symbol on it. "
	icon_state = "closed_bravo"
	icon_opened = "open_bravo"
	icon_closed = "closed_bravo"

/obj/structure/closet/crate/charlie
	name = "charlie squad crate"
	desc = "A crate with charlie squad's symbol on it. "
	icon_state = "closed_charlie"
	icon_opened = "open_charlie"
	icon_closed = "closed_charlie"

/obj/structure/closet/crate/construction
	name = "construction crate"
	desc = "A construction crate"
	icon_state = "closed_construction"
	icon_opened = "open_construction"
	icon_closed = "closed_construction"

/obj/structure/closet/crate/delta
	name = "delta squad crate"
	desc = "A crate with delta squad's symbol on it. "
	icon_state = "closed_delta"
	icon_opened = "open_delta"
	icon_closed = "closed_delta"

/obj/structure/closet/crate/explosives
	name = "explosives crate"
	desc = "A explosives crate"
	icon_state = "closed_explosives"
	icon_opened = "open_explosives"
	icon_closed = "closed_explosives"

/obj/structure/closet/crate/freezer
	name = "freezer crate"
	desc = "A freezer crate."
	icon_state = "closed_freezer"
	icon_opened = "open_freezer"
	icon_closed = "closed_freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

	return_air()
		var/datum/gas_mixture/gas = (..())
		if(!gas)	return null
		var/datum/gas_mixture/newgas = new/datum/gas_mixture()
		newgas.copy_from(gas)
		if(newgas.temperature <= target_temp)	return

		if((newgas.temperature - cooling_power) > target_temp)
			newgas.temperature -= cooling_power
		else
			newgas.temperature = target_temp
		return newgas

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "closed_hydro"
	icon_opened = "open_hydro"
	icon_closed = "closed_hydro"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

	New()
		..()
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new /obj/item/weapon/reagent_containers/spray/plantbgone(src)
		new /obj/item/weapon/minihoe(src)
//		new /obj/item/weapon/weedspray(src)
//		new /obj/item/weapon/weedspray(src)
//		new /obj/item/weapon/pestspray(src)
//		new /obj/item/weapon/pestspray(src)
//		new /obj/item/weapon/pestspray(src)

/obj/structure/closet/crate/internals
	name = "internals crate"
	desc = "A internals crate."
	icon_state = "closed_oxygen"
	icon_opened = "open_oxygen"
	icon_closed = "closed_oxygen"

/obj/structure/closet/crate/medical
	name = "medical crate"
	desc = "A medical crate."
	icon_state = "closed_medical"
	icon_opened = "open_medical"
	icon_closed = "closed_medical"

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "closed_plastic"
	icon_opened = "open_plastic"
	icon_closed = "closed_plastic"

/* These aren't needed anymore
/obj/structure/closet/crate/hat
	desc = "A crate filled with Valuable Collector's Hats!."
	name = "Hat Crate"
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"

/obj/structure/closet/crate/contraband
	name = "Poster crate"
	desc = "A random assortment of posters manufactured by providers NOT listed under Nanotrasen's whitelist."
	icon_state = "crate"
	icon_opened = "crateopen"
	icon_closed = "crate"
*/

/obj/structure/closet/crate/rcd
	name = "RCD crate"
	desc = "A crate for the storage of the RCD."

/obj/structure/closet/crate/rcd/New()
	..()
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)

/obj/structure/closet/crate/solar
	name = "Solar Pack crate"

/obj/structure/closet/crate/solar/New()
	..()
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/solar_assembly(src)
	new /obj/item/weapon/circuitboard/solar_control(src)
	new /obj/item/weapon/tracker_electronics(src)
	new /obj/item/weapon/paper/solar(src)

/obj/structure/closet/crate/freezer/rations //Fpr use in the escape shuttle
	desc = "A crate of emergency rations."
	name = "Emergency Rations"

/obj/structure/closet/crate/freezer/rations/New()
	..()
	new /obj/item/weapon/storage/box/donkpockets(src)
	new /obj/item/weapon/storage/box/donkpockets(src)

/* CM doesn't use this.
/obj/structure/closet/crate/bin
	desc = "A large bin."
	name = "Large bin"
	icon_state = "largebin"
	icon_opened = "largebinopen"
	icon_closed = "largebin"
*/

/obj/structure/closet/crate/radiation
	name = "radioactive gear crate"
	desc = "A crate with a radiation sign on it."
	icon_state = "closed_radioactive"
	icon_opened = "open_radioactive"
	icon_closed = "closed_radioactive"

/obj/structure/closet/crate/radiation/New()
	..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "closed_science"
	icon_opened = "open_science"
	icon_closed = "closed_science"

/obj/structure/closet/crate/supply
	name = "supply crate"
	desc = "A supply crate."
	icon_state = "closed_supply"
	icon_opened = "open_supply"
	icon_closed = "closed_supply"

/obj/structure/closet/crate/trashcart
	name = "Trash Cart"
	desc = "A heavy, metal trashcart with wheels."
	icon_state = "closed_trashcart"
	icon_opened = "open_trashcart"
	icon_closed = "closed_trashcart"

/obj/structure/closet/crate/wayland
	name = "Wayland crate"
	desc = "A crate with a Wayland insignia on it."
	icon_state = "closed_wayland"
	icon_opened = "open_wayland"
	icon_closed = "closed_wayland"

/obj/structure/closet/crate/weapon
	name = "weapons crate"
	desc = "A weapons crate."
	icon_state = "closed_weapons"
	icon_opened = "open_weapons"
	icon_closed = "closed_weapons"

//------------------------------------
//			Secure Crates
//------------------------------------

/obj/structure/closet/crate/secure/ammo
	name = "secure ammunitions crate"
	desc = "A secure ammunitions crate"
	icon_state = "secure_locked_ammo"
	icon_opened = "secure_open_ammo"
	icon_locked = "secure_locked_ammo"
	icon_unlocked = "secure_unlocked_ammo"

/obj/structure/closet/crate/secure/explosives
	name = "explosives crate"
	desc = "A explosives crate"
	icon_state = "secure_locked_explosives"
	icon_opened = "secure_open_explosives"
	icon_locked = "secure_locked_explosives"
	icon_unlocked = "secure_unlocked_explosives"

// Needs to be converted to new system that does not use overlays
// using default secure crate for now
/obj/structure/closet/crate/secure/phoron
	name = "phoron crate"
	desc = "A secure phoron crate."

// Needs to be converted to new system that does not use overlays
// using Wayland crate for now
/obj/structure/closet/crate/secure/gear
	name = "gear crate"
	desc = "A secure gear crate."
	icon_state = "secure_locked_wayland"
	icon_opened = "secure_open_wayland"
	icon_locked = "secure_locked_wayland"
	icon_unlocked = "secure_unlocked_wayland"

/obj/structure/closet/crate/secure/hydrosec
	name = "secure hydroponics crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	icon_state = "secure_locked_hydro"
	icon_opened = "secure_open_hydro"
	icon_locked = "secure_locked_hydro"
	icon_unlocked = "secure_unlocked_hydro"

/obj/structure/closet/crate/secure/surgery
	name = "surgery crate"
	desc = "A surgery crate."
	icon_state = "secure_locked_surgery"
	icon_opened = "secure_open_surgery"
	icon_locked = "secure_locked_surgery"
	icon_unlocked = "secure_unlocked_surgery"

/obj/structure/closet/crate/secure/weapon
	name = "weapons crate"
	desc = "A secure weapons crate."
	icon_state = "secure_locked_weapons"
	icon_opened = "secure_open_weapons"
	icon_locked = "secure_locked_weapons"
	icon_unlocked = "secure_unlocked_weapons"

/obj/structure/closet/crate/secure/weyland
	name = "secure Weyland-Armat crate"
	desc = "A secure crate with a Weyland-Armat insignia on it."
	icon_state = "secure_locked_weyland"
	icon_opened = "secure_open_weyland"
	icon_locked = "secure_locked_weyland"
	icon_unlocked = "secure_unlocked_weyland"

/* CM does not use these
/obj/structure/closet/crate/secure/bin
	desc = "A secure bin."
	name = "Secure bin"
	icon_state = "largebins"
	icon_opened = "largebinsopen"
	icon_closed = "largebins"
	redlight = "largebinr"
	greenlight = "largebing"
	sparks = "largebinsparks"
	emag = "largebinemag"
*/

/* Needs to be converted to new system that does not use overlays
/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty metal crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"

/obj/structure/closet/crate/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.loc = src
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.loc = src
					break
	return

/obj/structure/closet/crate/secure/large
	name = "large crate"
	desc = "A hefty metal crate with an electronic locking system."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largemetal"
	icon_opened = "largemetalopen"
	icon_closed = "largemetal"
	redlight = "largemetalr"
	greenlight = "largemetalg"

/obj/structure/closet/crate/secure/large/close()
	. = ..()
	if (.)//we can hold up to one large item
		var/found = 0
		for(var/obj/structure/S in src.loc)
			if(S == src)
				continue
			if(!S.anchored)
				found = 1
				S.loc = src
				break
		if(!found)
			for(var/obj/machinery/M in src.loc)
				if(!M.anchored)
					M.loc = src
					break
	return

//fluff variant
/obj/structure/closet/crate/secure/large/reinforced
	desc = "A hefty, reinforced metal crate with an electronic locking system."
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"
*/