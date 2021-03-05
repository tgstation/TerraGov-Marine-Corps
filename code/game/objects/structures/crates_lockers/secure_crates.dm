/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "Secure crate"
	icon_state = "secure_locked_basic"
	icon_opened = "secure_open_basic"
	icon_closed = "secure_locked_basic"
	closet_flags = CLOSET_ALLOW_OBJS|CLOSET_ALLOW_DENSE_OBJ|CLOSET_IS_SECURE
	var/icon_locked = "secure_locked_basic"
	var/icon_unlocked = "secure_unlocked_basic"
	var/sparks = "securecratesparks"
	locked = TRUE
	max_integrity = 500
	soft_armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)


/obj/structure/closet/crate/secure/Initialize(mapload, ...)
	. = ..()
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


/obj/structure/closet/crate/secure/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated())
		return
	togglelock(usr)


/obj/structure/closet/crate/secure/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken && !opened  && prob(50/severity))
		if(!locked)
			locked = 1
		else
			overlays.Cut()
			overlays += sparks
			spawn(6) overlays -= sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
			playsound(src.loc, 'sound/effects/sparks4.ogg', 25, 1)
			locked = 0
		update_icon()
	if(!opened && prob(20/severity))
		if(!locked)
			open()
		else
			req_access = list()
			req_access += pick(ALL_ACCESS)
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

/obj/structure/closet/crate/secure/construction
	name = "secured construction crate"
	desc = "A secure construction crate."
	icon_state = "secure_locked_construction"
	icon_opened = "secure_open_construction"
	icon_locked = "secure_locked_construction"
	icon_unlocked = "secure_unlocked_construction"
	req_access = list(ACCESS_MARINE_ENGINEERING)

/obj/structure/closet/crate/secure/construction/full 
	name = "prepared construction crate"

/obj/structure/closet/crate/secure/construction/full/Initialize()
	. = ..()
	new /obj/item/storage/belt/utility(src)
	new /obj/item/clothing/glasses/welding(src)
	new /obj/item/tool/pickaxe/plasmacutter(src)
	new /obj/item/tool/pickaxe/plasmacutter(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/high(src)
	new /obj/item/cell/super(src)
	new /obj/item/stack/sheet/metal(src, 50)
	new /obj/item/stack/sheet/metal(src, 50)
	new /obj/item/stack/sheet/plasteel(src, 30)
	new /obj/item/stack/sheet/mineral/phoron(src, 50)
	new /obj/item/stack/sheet/mineral/phoron(src, 50)
	new	/obj/item/storage/box/sentry(src)
	new	/obj/item/storage/box/sentry(src)
	new	/obj/item/storage/box/sentry(src)
	new	/obj/item/storage/box/sentry(src)
	new	/obj/item/storage/box/standard_hmg(src)
	new /obj/item/lightreplacer(src)


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

/obj/structure/closet/crate/secure/surgery/full
	name = "prepared surgery crate"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/structure/closet/crate/secure/surgery/full/Initialize()
	. = ..()
	new /obj/item/storage/surgical_tray(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/reagent_containers/blood/OMinus(src)
	new /obj/item/reagent_containers/blood/OMinus(src)
	new /obj/item/reagent_containers/blood/OMinus(src)
	new /obj/machinery/iv_drip(src)
	new	/obj/item/roller(src)
	new	/obj/item/roller(src)
	new	/obj/item/roller(src)
	new /obj/item/storage/briefcase/inflatable(src)
	new /obj/item/healthanalyzer(src)
	new	/obj/item/clothing/mask/surgical(src)
	new	/obj/item/clothing/gloves/latex(src)
	new	/obj/item/bodybag(src)
	new	/obj/item/bodybag(src)
	new	/obj/item/bodybag(src)
	new /obj/item/bodybag/cryobag(src)
	new /obj/item/bodybag/cryobag(src)
	new /obj/item/bodybag/cryobag(src)
	new /obj/item/storage/pill_bottle/polyhexanide(src)
	new /obj/item/storage/pill_bottle/polyhexanide(src)

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
