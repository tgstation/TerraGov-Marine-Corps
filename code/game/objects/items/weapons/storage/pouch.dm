
/obj/item/weapon/storage/pouch
	name = "abstract pouch"
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "small_drop"
	w_class = 4 //does not fit in backpack
	max_w_class = 2
	flags_equip_slot = SLOT_STORE
	storage_slots = 1
	var/draw_mode = 0

/obj/item/weapon/storage/pouch/verb/toggle_draw_mode()
	set name = "Switch Pouch Drawing Method"
	set category = "Object"
	draw_mode = !draw_mode
	if(draw_mode)
		usr << "Clicking [src] with an empty hand now puts the last stored item in your hand."
	else
		usr << "Clicking [src] with an empty hand now opens the pouch storage menu."


/obj/item/weapon/storage/pouch/attack_hand(mob/user)
	if(draw_mode && ishuman(user) && contents.len && loc == user)
		var/obj/item/I = contents[contents.len]
		I.attack_hand(user)
	else
		..()

/obj/item/weapon/storage/pouch/examine(mob/user)
	..()
	user << "Can be worn by attaching it to a pocket."


/obj/item/weapon/storage/pouch/equipped(mob/user, slot)
	if(slot == WEAR_L_STORE || slot == WEAR_R_STORE)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/weapon/storage/pouch/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()




/obj/item/weapon/storage/pouch/general
	name = "light general pouch"
	desc = "A general purpose pouch used to carry small items and ammo magazines."
	icon_state = "small_drop"
	draw_mode = 1
	bypass_w_limit = list("/obj/item/ammo_magazine/rifle",
					"/obj/item/ammo_magazine/smg",
					"/obj/item/ammo_magazine/pistol",
					"/obj/item/ammo_magazine/revolver",
					"/obj/item/ammo_magazine/sniper",
					)

/obj/item/weapon/storage/pouch/general/medium
	name = "medium general pouch"
	storage_slots = 2
	icon_state = "medium_drop"
	draw_mode = 0

/obj/item/weapon/storage/pouch/general/large
	name = "large general pouch"
	storage_slots = 3
	icon_state = "large_drop"
	draw_mode = 0


/obj/item/weapon/storage/pouch/bayonet
	name = "bayonet sheath"
	desc = "A pouch for your knives."
	can_hold = list("/obj/item/weapon/combat_knife", "/obj/item/weapon/throwing_knife", "/obj/item/attachable/bayonet")
	icon_state = "bayonet"
	storage_slots = 3
	draw_mode = 1

/obj/item/weapon/storage/pouch/bayonet/full/New()
	..()
	new /obj/item/weapon/combat_knife(src)


/obj/item/weapon/storage/pouch/bayonet/upp/New()
	..()
	new /obj/item/weapon/combat_knife/upp (src)

/obj/item/weapon/storage/pouch/survival
	name = "survival pouch"
	desc = "It can contain a flare, a pill, a crowbar, and some bandages."
	icon_state = "survival"
	storage_slots = 4
	can_hold = list(
					"/obj/item/device/flashlight/flare",
					"/obj/item/weapon/crowbar",
					"/obj/item/weapon/reagent_containers/pill",
					"/obj/item/stack/medical/bruise_pack"
					)

/obj/item/weapon/storage/pouch/survival/full/New()
	..()
	new /obj/item/device/flashlight/flare (src)
	new /obj/item/weapon/crowbar/red (src)
	new /obj/item/weapon/reagent_containers/pill/tramadol (src)
	new /obj/item/stack/medical/bruise_pack (src, 3)




/obj/item/weapon/storage/pouch/firstaid
	name = "firstaid pouch"
	desc = "It can contain autoinjectors, ointments, and bandages."
	icon_state = "firstaid"
	storage_slots = 3
	can_hold = list(
					"/obj/item/stack/medical/ointment",
					"/obj/item/weapon/reagent_containers/hypospray/autoinjector",
					"/obj/item/stack/medical/bruise_pack"
					)

/obj/item/weapon/storage/pouch/firstaid/full
	desc = "Contains a tricordrazine autoinjector, some ointment, and some bandages."

/obj/item/weapon/storage/pouch/firstaid/full/New()
	..()
	new /obj/item/stack/medical/ointment (src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord (src)
	new /obj/item/stack/medical/bruise_pack (src)


/obj/item/weapon/storage/pouch/pistol
	name = "sidearm pouch"
	desc = "It can contain a pistol or revolver. Useful for emergencies."
	icon_state = "pistol"
	max_w_class = 3
	can_hold = list("/obj/item/weapon/gun/pistol", "/obj/item/weapon/gun/revolver")
	draw_mode = 1



//// MAGAZINE POUCHES /////

/obj/item/weapon/storage/pouch/magazine
	name = "magazine pouch"
	desc = "It can contain ammo magazines."
	icon_state = "medium_ammo_mag"
	max_w_class = 3
	storage_slots = 2
	draw_mode = 0
	can_hold = list("/obj/item/ammo_magazine/rifle",
					"/obj/item/ammo_magazine/smg",
					"/obj/item/ammo_magazine/pistol",
					"/obj/item/ammo_magazine/revolver",
					"/obj/item/ammo_magazine/sniper",
					)


/obj/item/weapon/storage/pouch/magazine/large
	name = "large magazine pouch"
	icon_state = "large_ammo_mag"
	storage_slots = 3



/obj/item/weapon/storage/pouch/magazine/pistol
	name = "pistol magazine pouch"
	desc = "It can contain pistol and revolver ammo magazines."
	max_w_class = 2
	icon_state = "pistol_mag"
	storage_slots = 2

	can_hold = list(
					"/obj/item/ammo_magazine/pistol",
					"/obj/item/ammo_magazine/revolver"
					)

/obj/item/weapon/storage/pouch/magazine/pistol/large
	name = "large pistol magazine pouch"
	storage_slots = 4
	icon_state = "large_pistol_mag"


/obj/item/weapon/storage/pouch/magazine/pistol/pmc_mateba/New()
	..()
	new /obj/item/ammo_magazine/revolver/mateba (src)
	new /obj/item/ammo_magazine/revolver/mateba (src)

/obj/item/weapon/storage/pouch/magazine/pistol/pmc_vp70/New()
	..()
	new /obj/item/ammo_magazine/pistol/vp70 (src)
	new /obj/item/ammo_magazine/pistol/vp70 (src)

/obj/item/weapon/storage/pouch/magazine/pistol/pmc_vp78/New()
	..()
	new /obj/item/ammo_magazine/pistol/vp78 (src)
	new /obj/item/ammo_magazine/pistol/vp78 (src)


/obj/item/weapon/storage/pouch/magazine/upp/New()
	..()
	new /obj/item/ammo_magazine/rifle/type71 (src)
	new /obj/item/ammo_magazine/rifle/type71 (src)

/obj/item/weapon/storage/pouch/magazine/large/upp/New()
	..()
	new /obj/item/ammo_magazine/rifle/type71 (src)
	new /obj/item/ammo_magazine/rifle/type71 (src)
	new /obj/item/ammo_magazine/rifle/type71 (src)

/obj/item/weapon/storage/pouch/magazine/upp_smg/New()
	..()
	new /obj/item/ammo_magazine/smg/skorpion (src)
	new /obj/item/ammo_magazine/smg/skorpion (src)

/obj/item/weapon/storage/pouch/magazine/large/pmc_m39/New()
	..()
	new /obj/item/ammo_magazine/smg/m39/ap (src)
	new /obj/item/ammo_magazine/smg/m39/ap (src)
	new /obj/item/ammo_magazine/smg/m39/ap (src)

/obj/item/weapon/storage/pouch/magazine/large/pmc_p90/New()
	..()
	new /obj/item/ammo_magazine/smg/p90 (src)
	new /obj/item/ammo_magazine/smg/p90 (src)
	new /obj/item/ammo_magazine/smg/p90 (src)

/obj/item/weapon/storage/pouch/magazine/large/pmc_lmg/New()
	..()
	new /obj/item/ammo_magazine/rifle/lmg (src)
	new /obj/item/ammo_magazine/rifle/lmg (src)
	new /obj/item/ammo_magazine/rifle/lmg (src)

/obj/item/weapon/storage/pouch/magazine/large/pmc_sniper/New()
	..()
	new /obj/item/ammo_magazine/sniper/elite (src)
	new /obj/item/ammo_magazine/sniper/elite (src)
	new /obj/item/ammo_magazine/sniper/elite (src)

/obj/item/weapon/storage/pouch/magazine/large/pmc_rifle/New()
	..()
	new /obj/item/ammo_magazine/rifle/ap (src)
	new /obj/item/ammo_magazine/rifle/ap (src)
	new /obj/item/ammo_magazine/rifle/ap (src)



/obj/item/weapon/storage/pouch/explosive
	name = "explosive pouch"
	desc = "It can contain grenades, and other explosives."
	icon_state = "large_explosive"
	storage_slots = 3
	can_hold = list(
					"/obj/item/weapon/plastique",
					"/obj/item/device/mine",
					"/obj/item/weapon/grenade"
					)

/obj/item/weapon/storage/pouch/explosive/full/New()
	..()
	new /obj/item/weapon/grenade/explosive (src)
	new /obj/item/weapon/grenade/explosive (src)
	new /obj/item/weapon/grenade/explosive (src)


/obj/item/weapon/storage/pouch/explosive/upp/New()
	..()
	new /obj/item/weapon/plastique(src)
	new /obj/item/weapon/plastique(src)
	new /obj/item/weapon/plastique(src)

/obj/item/weapon/storage/pouch/medical
	name = "medical pouch"
	desc = "It can contain small medical supplies."
	icon_state = "medical"
	storage_slots = 3

	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
	    "/obj/item/weapon/reagent_containers/hypospray"
	)


/obj/item/weapon/storage/pouch/syringe
	name = "syringe pouch"
	desc = "It can contain syringes."
	icon_state = "syringe"
	storage_slots = 6
	can_hold = list("/obj/item/weapon/reagent_containers/syringe")


/obj/item/weapon/storage/pouch/medkit
	name = "medkit pouch"
	max_w_class = 3
	draw_mode = 1
	icon_state = "medkit"
	desc = "It's specifically made to hold a medkit."
	can_hold = list("/obj/item/weapon/storage/firstaid")


/obj/item/weapon/storage/pouch/medkit/full/New()
	..()
	new /obj/item/weapon/storage/firstaid/regular(src)

/obj/item/weapon/storage/pouch/document
	name = "document pouch"
	desc = "It can contain papers and clipboards."
	icon_state = "document"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/paper", "/obj/item/weapon/clipboard")


/obj/item/weapon/storage/pouch/flare
	name = "flare pouch"
	desc = "A pouch designed to hold flares. Refillable with a M94 flare pack."
	max_w_class = 2
	storage_slots = 5
	draw_mode = 1
	icon_state = "flare"
	can_hold = list("/obj/item/device/flashlight/flare")

/obj/item/weapon/storage/pouch/flare/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/storage/box/m94))
		var/obj/item/weapon/storage/box/m94/M = W
		if(M.contents.len)
			if(contents.len < storage_slots)
				user << "<span class='notice'>You start refilling [src] with [M].</span>"
				if(!do_after(user, 15, TRUE, 5, BUSY_ICON_CLOCK)) return
				for(var/obj/item/I in M)
					if(contents.len < storage_slots)
						M.remove_from_storage(I)
						handle_item_insertion(I, 1) //quiet insertion
					else
						break
				playsound(user.loc, "rustle", 15, 1, 6)
			else
				user << "<span class='warning'>[src] is full.</span>"
		else
			user << "<span class='warning'>[M] is empty.</span>"
		return TRUE
	else
		return ..()
/obj/item/weapon/storage/pouch/flare/full/New()
	..()
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/flare(src)




/obj/item/weapon/storage/pouch/radio
	name = "radio pouch"
	storage_slots = 2
	icon_state = "radio"
	draw_mode = 1
	desc = "It can contain two handheld radios."
	can_hold = list("/obj/item/device/radio")


/obj/item/weapon/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"
	storage_slots = 5
	can_hold = list(
					"/obj/item/weapon/airalarm_electronics",
					"/obj/item/weapon/firealarm_electronics",
					"/obj/item/weapon/airlock_electronics",
					"/obj/item/weapon/circuitboard",
					"/obj/item/weapon/module/power_control",
					"/obj/item/weapon/cell"
					)


/obj/item/weapon/storage/pouch/construction
	name = "contruction pouch"
	desc = "It's designed to hold construction materials."
	storage_slots = 3
	max_w_class = 3
	icon_state = "construction"
	can_hold = list(
					"/obj/item/barbed_wire",
					"/obj/item/stack/sheet",
					"/obj/item/stack/sandbags_empty"
					)
