/obj/item/storage/pouch
	name = "abstract pouch"
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "small_drop"
	w_class = 4 //does not fit in backpack
	max_w_class = 2
	flags_equip_slot = ITEM_SLOT_POCKET
	storage_slots = 1
	draw_mode = 0
	allow_drawing_method = TRUE
	var/fill_type
	var/fill_number = 0

/obj/item/storage/pouch/Initialize()
	. = ..()
	if(fill_number && fill_type)
		for(var/i in 1 to fill_number)
			new fill_type(src)

/obj/item/storage/pouch/examine(mob/user)
	..()
	to_chat(user, "Can be worn by attaching it to a pocket.")


/obj/item/storage/pouch/equipped(mob/user, slot)
	if(slot == SLOT_L_STORE || slot == SLOT_R_STORE)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
	..()

/obj/item/storage/pouch/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()




/obj/item/storage/pouch/general
	name = "light general pouch"
	desc = "A general purpose pouch used to carry small items."
	icon_state = "small_drop"
	draw_mode = 1

/obj/item/storage/pouch/general/medium
	name = "medium general pouch"
	storage_slots = 2
	icon_state = "medium_drop"
	draw_mode = 0

/obj/item/storage/pouch/general/large
	name = "large general pouch"
	storage_slots = 3
	icon_state = "large_drop"
	draw_mode = 0

/obj/item/storage/pouch/general/large/command
	fill_type = /obj/item/device/binoculars/tactical
	fill_number = 1

/obj/item/storage/pouch/bayonet
	name = "bayonet sheath"
	desc = "A pouch for your knives."
	can_hold = list(
		/obj/item/weapon/combat_knife, 
		/obj/item/weapon/throwing_knife, 
		/obj/item/attachable/bayonet)
	icon_state = "bayonet"
	storage_slots = 3
	draw_mode = 1

/obj/item/storage/pouch/bayonet/full
	fill_type = /obj/item/weapon/combat_knife
	fill_number = 1

/obj/item/storage/pouch/bayonet/upp
	fill_type = /obj/item/weapon/combat_knife/upp
	fill_number = 1

/obj/item/storage/pouch/survival
	name = "survival pouch"
	desc = "It can contain flashlights, a pill, a crowbar, metal sheets, and some bandages."
	icon_state = "survival"
	storage_slots = 6
	max_w_class = 3
	can_hold = list(
		/obj/item/device/flashlight,
		/obj/item/reagent_container/pill,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/plasteel,
		/obj/item/tool/weldingtool)

/obj/item/storage/pouch/survival/full/Initialize()
	. = ..()
	new /obj/item/device/flashlight(src)
	new /obj/item/reagent_container/pill/tramadol(src)
	new /obj/item/stack/medical/bruise_pack(src, 3)
	new /obj/item/stack/sheet/metal(src, 40)
	new /obj/item/stack/sheet/plasteel(src, 15)
	new /obj/item/tool/weldingtool(src)




/obj/item/storage/pouch/firstaid
	name = "first-aid pouch"
	desc = "It can contain autoinjectors, ointments, and bandages."
	icon_state = "firstaid"
	storage_slots = 5
	can_hold = list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_container/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/splint)

/obj/item/storage/pouch/firstaid/full
	desc = "Contains a painkiller autoinjector, first-aid autoinjector, splints, some ointment, and some bandages."

/obj/item/storage/pouch/firstaid/full/Initialize()
	. = ..()
	new /obj/item/stack/medical/ointment (src)
	new /obj/item/reagent_container/hypospray/autoinjector/tramadol (src)
	new /obj/item/reagent_container/hypospray/autoinjector/tricordrazine (src)
	new /obj/item/stack/medical/bruise_pack (src)
	new /obj/item/stack/medical/splint (src)

/obj/item/storage/pouch/pistol
	name = "sidearm pouch"
	desc = "It can contain a pistol. Useful for emergencies."
	icon_state = "pistol"
	max_w_class = 3
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/weapon/gun/revolver)
	draw_mode = 1



//// MAGAZINE POUCHES /////

/obj/item/storage/pouch/magazine
	name = "magazine pouch"
	desc = "It can contain ammo magazines."
	icon_state = "medium_ammo_mag"
	max_w_class = 3
	storage_slots = 2
	draw_mode = 0
	can_hold = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/cell/lasgun)

/obj/item/storage/pouch/magazine/large
	name = "large magazine pouch"
	icon_state = "large_ammo_mag"
	storage_slots = 3



/obj/item/storage/pouch/magazine/pistol
	name = "pistol magazine pouch"
	desc = "It can contain pistol and revolver ammo magazines."
	max_w_class = 2
	icon_state = "pistol_mag"
	storage_slots = 3

	can_hold = list(
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver)

/obj/item/storage/pouch/magazine/pistol/large
	name = "large pistol magazine pouch"
	storage_slots = 6
	icon_state = "large_pistol_mag"

/obj/item/storage/pouch/magazine/pistol/large/full
	fill_type = /obj/item/ammo_magazine/pistol
	fill_number = 6

/obj/item/storage/pouch/magazine/pistol/pmc_mateba
	fill_type = /obj/item/ammo_magazine/revolver/mateba
	fill_number = 3

/obj/item/storage/pouch/magazine/pistol/vp70
	fill_type = /obj/item/ammo_magazine/pistol/vp70
	fill_number = 3

/obj/item/storage/pouch/magazine/pistol/pmc_vp78
	fill_type = /obj/item/ammo_magazine/pistol/vp78
	fill_number = 3

/obj/item/storage/pouch/magazine/upp
	fill_type = /obj/item/ammo_magazine/rifle/type71
	fill_number = 2

/obj/item/storage/pouch/magazine/large/upp
	fill_type = /obj/item/ammo_magazine/rifle/type71
	fill_number = 3

/obj/item/storage/pouch/magazine/upp_smg
	fill_type = /obj/item/ammo_magazine/smg/skorpion
	fill_number = 2

/obj/item/storage/pouch/magazine/large/pmc_m39
	fill_type = /obj/item/ammo_magazine/smg/m39/ap
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_p90
	fill_type = /obj/item/ammo_magazine/smg/p90
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_lmg
	fill_type = /obj/item/ammo_magazine/rifle/lmg
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_sniper
	fill_type = /obj/item/ammo_magazine/sniper/elite
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_rifle
	fill_type = /obj/item/ammo_magazine/rifle/ap
	fill_number = 3




/obj/item/storage/pouch/explosive
	name = "explosive pouch"
	desc = "It can contain grenades, plastiques, mine boxes, and other explosives."
	icon_state = "large_explosive"
	storage_slots = 4
	max_w_class = 3
	can_hold = list(
		/obj/item/explosive/plastique,
		/obj/item/explosive/mine,
		/obj/item/explosive/grenade,
		/obj/item/storage/box/explosive_mines,
		/obj/item/ammo_magazine/rocket,
		/obj/item/device/radio/detpack,
		/obj/item/device/assembly/signaler)

/obj/item/storage/pouch/explosive/full
	fill_type = /obj/item/explosive/grenade/frag
	fill_number = 3

/obj/item/storage/pouch/explosive/upp
	fill_type = /obj/item/explosive/plastique
	fill_number = 3

/obj/item/storage/pouch/medical
	name = "medical pouch"
	desc = "It can contain small medical supplies."
	icon_state = "medical"
	storage_slots = 3

	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/reagent_container/dropper,
		/obj/item/reagent_container/pill,
		/obj/item/reagent_container/glass/bottle,
		/obj/item/reagent_container/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/device/flashlight/pen,
	    /obj/item/reagent_container/hypospray)

/obj/item/storage/pouch/medical/full/Initialize()
	. = ..()
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)

/obj/item/storage/pouch/autoinjector
	name = "auto-injector pouch"
	desc = "A pouch specifically for auto-injectors."
	icon_state = "autoinjector"
	storage_slots = 7
	max_storage_space = 14
	can_hold = list(
	    /obj/item/reagent_container/hypospray/autoinjector
	)


/obj/item/storage/pouch/syringe
	name = "syringe pouch"
	desc = "It can contain syringes."
	icon_state = "syringe"
	storage_slots = 5
	max_storage_space = 10
	can_hold = list(/obj/item/reagent_container/syringe)


/obj/item/storage/pouch/medkit
	name = "medkit pouch"
	w_class = 4.1 //does not fit in backpack
	max_w_class = 4
	draw_mode = 1
	icon_state = "medkit"
	desc = "It's specifically made to hold a medkit."
	can_hold = list(/obj/item/storage/firstaid)
	bypass_w_limit = list(/obj/item/storage/firstaid)


/obj/item/storage/pouch/medkit/full
	fill_type = /obj/item/storage/firstaid/regular
	fill_number = 1

/obj/item/storage/pouch/document
	name = "document pouch"
	desc = "It can contain papers and clipboards."
	icon_state = "document"
	storage_slots = 7
	can_hold = list(
		/obj/item/paper, 
		/obj/item/clipboard)


/obj/item/storage/pouch/flare
	name = "flare pouch"
	desc = "A pouch designed to hold flares. Refillable with a M94 flare pack."
	max_w_class = 2
	storage_slots = 5
	draw_mode = 1
	icon_state = "flare"
	can_hold = list(
		/obj/item/device/flashlight/flare,
		/obj/item/explosive/grenade/flare)

/obj/item/storage/pouch/flare/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/storage/box/m94))
		var/obj/item/storage/box/m94/M = W
		if(M.contents.len)
			if(contents.len < storage_slots)
				to_chat(user, "<span class='notice'>You start refilling [src] with [M].</span>")
				if(!do_after(user, 15, TRUE, 5, BUSY_ICON_GENERIC))
					return
				for(var/obj/item/I in M)
					if(contents.len < storage_slots)
						M.remove_from_storage(I)
						handle_item_insertion(I, 1, user) //quiet insertion
					else
						break
				playsound(user.loc, "rustle", 15, 1, 6)
			else
				to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			to_chat(user, "<span class='warning'>[M] is empty.</span>")
		return TRUE
	else
		return ..()

/obj/item/storage/pouch/flare/full
	fill_type = /obj/item/explosive/grenade/flare
	fill_number = 5

/obj/item/storage/pouch/radio
	name = "radio pouch"
	storage_slots = 2
	icon_state = "radio"
	draw_mode = 1
	desc = "It can contain two handheld radios."
	can_hold = list(/obj/item/device/radio)


/obj/item/storage/pouch/field_pouch
	name = "field utility pouch"
	storage_slots = 5
	max_w_class = 3
	icon_state = "radio"
	draw_mode = 1
	desc = "It can contain a motion detector, signaller, beacons, maps, flares, radios and other handy battlefield communication and detection devices."
	can_hold = list(
		/obj/item/device/motiondetector,
		/obj/item/device/radio,
		/obj/item/device/assembly/signaler,
		/obj/item/device/megaphone,
		/obj/item/device/flashlight,
		/obj/item/device/whistle,
		/obj/item/device/binoculars,
		/obj/item/map/current_map,
		/obj/item/device/squad_beacon)

/obj/item/storage/pouch/field_pouch/full/Initialize()
	. = ..()
	new /obj/item/device/motiondetector (src)
	new /obj/item/device/whistle (src)
	new /obj/item/device/radio (src)
	new /obj/item/map/current_map (src)
	new /obj/item/device/binoculars/tactical (src)


/obj/item/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"
	storage_slots = 5
	can_hold = list(
		/obj/item/circuitboard,
		/obj/item/cell)

/obj/item/storage/pouch/electronics/full/Initialize()
	. = ..()
	new /obj/item/circuitboard/airlock (src)
	new /obj/item/circuitboard/apc (src)
	new /obj/item/cell/high (src)


/obj/item/storage/pouch/construction
	name = "construction pouch"
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has a hook for an entrenching tool."
	storage_slots = 3
	max_w_class = 3
	icon_state = "construction"
	can_hold = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/sandbags_empty)

/obj/item/storage/pouch/construction/full/Initialize()
	. = ..()
	new /obj/item/stack/sandbags_empty/half (src)
	new /obj/item/stack/barbed_wire/small_stack (src)
	new /obj/item/tool/shovel/etool (src)

/obj/item/storage/pouch/tools
	name = "tools pouch"
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool."
	storage_slots = 5
	max_w_class = 3
	icon_state = "tools"
	can_hold = list(
		/obj/item/tool/wirecutters,
		/obj/item/tool/shovel/etool,
		/obj/item/tool/screwdriver,
		/obj/item/tool/crowbar,
		/obj/item/tool/weldingtool,
		/obj/item/device/multitool,
		/obj/item/tool/wrench,
		/obj/item/stack/cable_coil,
		/obj/item/tool/extinguisher/mini)

/obj/item/storage/pouch/tools/full/Initialize()
	. = ..()
	new /obj/item/tool/screwdriver (src)
	new /obj/item/tool/wirecutters (src)
	new /obj/item/device/multitool (src)
	new /obj/item/tool/wrench (src)
	new /obj/item/tool/crowbar (src)

/obj/item/storage/pouch/shotgun //New shotgun shell pouch that is actually worth a shit and will be replacing light general in vendors
	name = "shotgun shell pouch"
	desc = "A pouch specialized for holding shotgun ammo."
	icon_state = "small_drop"
	storage_slots = 4
	draw_mode = 0
	can_hold = list(/obj/item/ammo_magazine/handful)

/obj/item/storage/pouch/shotgun/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/ammo_magazine/shotgun))
		var/obj/item/ammo_magazine/shotgun/M = W
		if(M.current_rounds)
			if(contents.len < storage_slots)
				to_chat(user, "<span class='notice'>You start refilling [src] with [M].</span>")
				if(!do_after(user, 15, TRUE, 5, BUSY_ICON_GENERIC))
					return
				for(var/x = 1 to (storage_slots - contents.len))
					var/cont = handle_item_insertion(M.create_handful(), 1, user)
					if(!cont)
						break
				playsound(user.loc, "rustle", 15, 1, 6)
				to_chat(user, "<span class='notice'>You refill [src] with [M].</span>")
			else
				to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			to_chat(user, "<span class='warning'>[M] is empty.</span>")
		return TRUE
	else
		return ..()