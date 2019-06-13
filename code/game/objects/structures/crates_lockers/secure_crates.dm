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
	else
		icon_state = locked ? icon_locked : icon_unlocked
	if(welded)
		overlays += overlay_welded


/obj/structure/closet/crate/secure/can_open()
	return !locked

/obj/structure/closet/crate/secure/proc/togglelock(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(opened)
		to_chat(user, "<span class='notice'>Close the crate first.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The crate appears to be broken.</span>")
		return
	if(allowed(user))
		locked = !locked
		user.visible_message("<span class='notice'>\the [src] has been [locked ? "" : "un"]locked by [user].</span>", \
							"<span class='notice'>You [locked ? "" : "un"]lock \the [src].</span>", null, 3)
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated())
		return
	togglelock(usr)

/obj/structure/closet/crate/secure/attack_hand(mob/user)
	if(locked)
		togglelock(user)
	else
		toggle(user)

/obj/structure/closet/crate/secure/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(locked && istype(I, /obj/item/card/emag))
		overlays.Cut()
		overlays += emag
		flick(src, sparks)
		playsound(loc, "sparks", 25, 1)
		locked = FALSE
		broken = TRUE
		update_icon()
		to_chat(user, "<span class='notice'>You unlock \the [src].</span>")

	else if(!opened)
		togglelock(user)

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
	icon_state = "secure_locked_nanotrasen"
	icon_opened = "secure_open_nanotrasen"
	icon_locked = "secure_locked_nanotrasen"
	icon_unlocked = "secure_unlocked_nanotrasen"

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

/obj/structure/closet/crate/secure/nanotrasen
	name = "secure Nanotrasen crate"
	desc = "A secure crate with a Nanotrasen insignia on it."
	icon_state = "secure_locked_nanotrasen"
	icon_opened = "secure_open_nanotrasen"
	icon_locked = "secure_locked_nanotrasen"
	icon_unlocked = "secure_unlocked_nanotrasen"
