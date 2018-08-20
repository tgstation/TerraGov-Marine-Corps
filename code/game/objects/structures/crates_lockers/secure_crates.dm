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

/obj/structure/closet/crate/secure/New()
	..()
	update_icon()


/obj/structure/closet/crate/secure/update_icon()
	overlays.Cut()
	if(opened)
		icon_state = icon_opened
	else if(locked)
		icon_state = icon_locked
	else
		icon_state = icon_unlocked
	if(welded)
		overlays += "welded"


/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user as mob)
	if(src.opened)
		to_chat(user, "<span class='notice'>Close the crate first.</span>")
		return
	if(src.broken)
		to_chat(user, "<span class='warning'>The crate appears to be broken.</span>")
		return
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				to_chat(O, "<span class='notice'>The crate has been [locked ? null : "un"]locked by [user].</span>")
		icon_state = locked ? icon_locked : icon_unlocked
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

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
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/crate/secure/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if(locked)
		src.togglelock(user)
	else
		src.toggle(user)

/obj/structure/closet/crate/secure/attackby(obj/item/W as obj, mob/user as mob)
	if(is_type_in_list(W, list(/obj/item/packageWrap, /obj/item/stack/cable_coil, /obj/item/device/radio/electropack, /obj/item/tool/wirecutters, /obj/item/tool/weldingtool)))
		return ..()
	if(locked && istype(W, /obj/item/card/emag))
		overlays.Cut()
		overlays += emag
		overlays += sparks
		spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
		playsound(src.loc, "sparks", 25, 1)
		locked = 0
		broken = 1
		update_icon()
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")
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
			locked = 1
		else
			overlays.Cut()
			overlays += emag
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 25, 1)
			locked = 0
		update_icon()
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			src.req_access = list()
			src.req_access += pick(get_all_accesses())
	..()


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
	icon_state = "secure_locked_weyland"
	icon_opened = "secure_open_weyland"
	icon_locked = "secure_locked_weyland"
	icon_unlocked = "secure_unlocked_weyland"

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
