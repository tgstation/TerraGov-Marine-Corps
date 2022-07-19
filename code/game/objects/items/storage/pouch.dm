/obj/item/storage/pouch
	name = "abstract pouch"
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "small_drop"
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
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
	. = ..()
	. += "Can be worn by attaching it to a pocket."


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

	bypass_w_limit = list(/obj/item/ammo_magazine/packet)

/obj/item/storage/pouch/general/medium
	name = "medium general pouch"
	storage_slots = 2
	icon_state = "medium_drop"
	draw_mode = 0

/obj/item/storage/pouch/general/large
	name = "general pouch"
	storage_slots = null
	max_storage_space = 6
	icon_state = "large_drop"
	draw_mode = 0

/obj/item/storage/pouch/general/large/command/Initialize()
	. = ..()
	new /obj/item/binoculars/tactical(src)
	new /obj/item/megaphone(src)
	new /obj/item/pinpointer(src)


/obj/item/storage/pouch/general/som
	name = "mining general pouch"
	desc = "A general purpose pouch used to carry small items used during mining."
	icon_state = "general_som"
	draw_mode = 1


/obj/item/storage/pouch/bayonet
	name = "bayonet sheath"
	desc = "A pouch for your knives."
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/stack/throwing_knife,
		/obj/item/attachable/bayonet,
	)
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
		/obj/item/flashlight,
		/obj/item/reagent_containers/pill,
		/obj/item/stack/medical/heal_pack/gauze,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/plasteel,
		/obj/item/tool/weldingtool,
	)

/obj/item/storage/pouch/survival/full/Initialize()
	. = ..()
	new /obj/item/flashlight(src)
	new /obj/item/reagent_containers/pill/tramadol(src)
	new /obj/item/stack/medical/heal_pack/gauze(src, 3)
	new /obj/item/stack/sheet/metal(src, 40)
	new /obj/item/stack/sheet/plasteel(src, 15)
	new /obj/item/tool/weldingtool(src)

/obj/item/storage/pouch/pistol
	name = "sidearm pouch"
	desc = "It can contain a pistol or revolver. Useful for emergencies."
	icon_state = "pistol"
	max_w_class = 3
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/weapon/gun/revolver,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
	)
	draw_mode = 1

/obj/item/storage/pouch/pistol/vp70/Initialize()
	. = ..()
	new /obj/item/weapon/gun/pistol/vp70(src)

/obj/item/storage/pouch/pistol/rt3/Initialize()
	. = ..()
	new /obj/item/weapon/gun/pistol/rt3(src)

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
		/obj/item/cell/lasgun,
	)

/obj/item/storage/pouch/magazine/smgfull
	fill_type = /obj/item/ammo_magazine/smg/standard_machinepistol
	fill_number = 2

/obj/item/storage/pouch/magazine/large
	name = "magazine pouch"
	desc = "This pouch can contain three ammo magazines."
	icon_state = "large_ammo_mag"
	storage_slots = 3

/obj/item/storage/pouch/magazine/large/tx8full
	fill_type = /obj/item/ammo_magazine/rifle/tx8
	fill_number = 3

/obj/item/storage/pouch/magazine/large/t19full
	fill_type = /obj/item/ammo_magazine/smg/standard_smg
	fill_number = 3

/obj/item/storage/pouch/magazine/pistol
	name = "pistol magazine pouch"
	desc = "It can contain pistol and revolver ammo magazines."
	max_w_class = 2
	icon_state = "pistol_mag"
	storage_slots = 3

	can_hold = list(
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini,
	)

/obj/item/storage/pouch/magazine/pistol/large
	name = "pistol magazine pouch"
	desc = "This pouch can contain six pistol and revolver ammo magazines."
	storage_slots = 6
	icon_state = "large_pistol_mag"

/obj/item/storage/pouch/magazine/pistol/large/full
	fill_type = /obj/item/ammo_magazine/pistol
	fill_number = 6

/obj/item/storage/pouch/magazine/pistol/pmc_mateba
	fill_type = /obj/item/ammo_magazine/revolver/mateba
	fill_number = 3

/obj/item/storage/pouch/magazine/pistol/large/mateba
	fill_type = /obj/item/ammo_magazine/revolver/mateba
	fill_number = 6

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

/obj/item/storage/pouch/magazine/large/pmc_m25
	fill_type = /obj/item/ammo_magazine/smg/m25/ap
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_famas
	fill_type = /obj/item/ammo_magazine/rifle/famas
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_lmg
	fill_type = /obj/item/ammo_magazine/standard_lmg
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_sniper
	fill_type = /obj/item/ammo_magazine/sniper/elite
	fill_number = 3

/obj/item/storage/pouch/magazine/large/pmc_rifle
	fill_type = /obj/item/ammo_magazine/rifle/ap
	fill_number = 3

/obj/item/storage/pouch/magazine/drum
	name = "drum magazine pouch"
	desc = "It can contain one drum magazine."
	icon_state = "large_ammo_drum"
	storage_slots = 1
	can_hold = list(
		/obj/item/ammo_magazine/standard_smartmachinegun,
	)


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
		/obj/item/detpack,
		/obj/item/assembly/signaler,
	)

/obj/item/storage/pouch/explosive/full
	fill_type = /obj/item/explosive/grenade
	fill_number = 4

/obj/item/storage/pouch/explosive/detpack/Initialize()
	. = ..()
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/assembly/signaler(src)

/obj/item/storage/pouch/explosive/razorburn/Initialize()
	. = ..()
	new /obj/item/explosive/grenade/chem_grenade/razorburn_smol(src)
	new /obj/item/explosive/grenade/chem_grenade/razorburn_smol(src)
	new /obj/item/explosive/grenade/chem_grenade/razorburn_smol(src)
	new /obj/item/explosive/grenade/chem_grenade/razorburn_large(src)

/obj/item/storage/pouch/explosive/upp
	fill_type = /obj/item/explosive/grenade/upp
	fill_number = 4

/obj/item/storage/pouch/grenade
	name = "Grenade pouch"
	desc = "It can contain grenades."
	icon_state = "explosive"
	storage_slots = 6
	can_hold = list(
		/obj/item/explosive/grenade,
	)

/obj/item/storage/pouch/grenade/slightlyfull
	fill_type = /obj/item/explosive/grenade
	fill_number = 4

/obj/item/storage/pouch/medkit
	name = "medkit pouch"
	desc = "A standard use medkit pouch that can contain all kinds of medical supplies and equipment."
	icon_state = "medkit"
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
	max_w_class = 4
	storage_slots = 7
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/reagent_containers/hypospray,
	)

/obj/item/storage/pouch/medkit/firstaid
	desc = "Standard marine first-aid pouch. Contains basic pills, splints, and a stabilizing injector."

/obj/item/storage/pouch/medkit/firstaid/Initialize()
	. = ..()
	new /obj/item/storage/pill_bottle/packet/bicaridine(src)
	new /obj/item/storage/pill_bottle/packet/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/storage/pill_bottle/packet/dylovene(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)

/obj/item/storage/pouch/medkit/medic/Initialize()
	. = ..()
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/reagent_containers/hypospray/advanced/meraderm(src)

/obj/item/storage/pouch/medical_injectors
	name = "medical injector pouch"
	desc = "A specialized medical pouch that can only hold auto-injectors."
	icon_state = "firstaid_injector"
	storage_slots = 8
	max_storage_space = 14
	can_hold = list(/obj/item/reagent_containers/hypospray/autoinjector)

/obj/item/storage/pouch/medical_injectors/firstaid
	desc = "Standard marine first-aid injector pouch. Specialized to store only auto-injectors. Contains basic injectors, a stabilizing injector, stimulant injector, and an emergency injector."

/obj/item/storage/pouch/medical_injectors/firstaid/Initialize()
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tramadol (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dylovene (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/russian_red (src)

/obj/item/storage/pouch/medical_injectors/som
	name = "mining first aid pouch"
	desc = "A basic first aid pouch originally used by miners due to dangerous working conditions on the mining colonies. This one is marked as belonging to the SOM."
	icon_state = "firstaid_som"

/obj/item/storage/pouch/medical_injectors/som/Initialize()
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tramadol (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dylovene (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/russian_red (src)

/obj/item/storage/pouch/medical_injectors/medic/Initialize() //corpsman autoinjector pouch gets upgraded, but more general chems.
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus(src)

/obj/item/storage/pouch/med_lolipops
	name = "medical lolipop pouch"
	desc = "A small medical pouch with three seperate pockets to sort your medical lollipops."
	icon_state = "medlolly"
	storage_slots = 3

	can_hold = list(/obj/item/storage/box/combat_lolipop,)

/obj/item/storage/pouch/med_lolipops/Initialize()
	. = ..()
	new /obj/item/storage/box/combat_lolipop(src)
	new /obj/item/storage/box/combat_lolipop/tricord(src)
	new /obj/item/storage/box/combat_lolipop/tramadol(src)

/obj/item/storage/pouch/surgery
	name = "surgery tools pouch"
	desc = "An eye catching white medical pouch capable of holding all your surgical tools."
	icon_state = "surgery"
	storage_slots = 12
	max_storage_space = 24
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/tweezers,
	)

/obj/item/storage/pouch/surgery/Initialize()
	. = ..()
	new /obj/item/tool/surgery/scalpel/manager(src)
	new /obj/item/tool/surgery/scalpel(src)
	new /obj/item/tool/surgery/hemostat(src)
	new /obj/item/tool/surgery/retractor(src)
	new /obj/item/tool/surgery/cautery(src)
	new /obj/item/tool/surgery/circular_saw(src)
	new /obj/item/tool/surgery/surgical_membrane(src)
	new /obj/item/tool/surgery/bonegel(src)
	new /obj/item/tool/surgery/bonesetter(src)
	new /obj/item/tool/surgery/FixOVein(src)
	new /obj/item/tool/surgery/suture(src)

/obj/item/storage/pouch/document
	name = "document pouch"
	desc = "It can contain papers and clipboards."
	icon_state = "document"
	storage_slots = 7
	can_hold = list(
		/obj/item/paper,
		/obj/item/clipboard,
	)


/obj/item/storage/pouch/flare
	name = "flare pouch"
	desc = "A pouch designed to hold flares and a single flaregun. Refillable with a M94 flare pack."
	max_w_class = 2
	storage_slots = 7
	draw_mode = 1
	icon_state = "flare"
	storage_type_limits = list(/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1)

	can_hold = list(
		/obj/item/flashlight/flare,
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare,
		/obj/item/explosive/grenade/flare,
	)


/obj/item/storage/pouch/flare/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/box/m94))
		var/obj/item/storage/box/m94/M = I
		if(!length(M.contents))
			to_chat(user, span_warning("[M] is empty."))
			return

		if(length(contents) >= storage_slots)
			to_chat(user, span_warning("[src] is full."))
			return

		to_chat(user, span_notice("You start refilling [src] with [M]."))

		if(!do_after(user, 15, TRUE, src, BUSY_ICON_GENERIC))
			return

		for(var/obj/item/IM in M)
			if(length(contents) >= storage_slots)
				break

			M.remove_from_storage(IM)
			handle_item_insertion(IM, TRUE, user)

		playsound(user.loc, "rustle", 15, 1, 6)
		return TRUE
	else
		return ..()

/obj/item/storage/pouch/flare/full
	fill_type = /obj/item/explosive/grenade/flare
	fill_number = 7

/obj/item/storage/pouch/radio
	name = "radio pouch"
	storage_slots = 2
	icon_state = "radio"
	draw_mode = 1
	desc = "It can contain two handheld radios."
	can_hold = list(/obj/item/radio)


/obj/item/storage/pouch/field_pouch
	name = "field utility pouch"
	storage_slots = 5
	max_w_class = 3
	icon_state = "utility"
	draw_mode = 1
	desc = "It can contain a motion detector, signaller, beacons, maps, flares, radios and other handy battlefield communication and detection devices."
	can_hold = list(
		/obj/item/attachable/motiondetector,
		/obj/item/radio,
		/obj/item/assembly/signaler,
		/obj/item/megaphone,
		/obj/item/flashlight,
		/obj/item/whistle,
		/obj/item/binoculars,
		/obj/item/beacon/supply_beacon,
	)

/obj/item/storage/pouch/field_pouch/full/Initialize()
	. = ..()
	new /obj/item/attachable/motiondetector (src)
	new /obj/item/whistle (src)
	new /obj/item/radio (src)
	new /obj/item/binoculars/tactical (src)


/obj/item/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"
	storage_slots = 6
	can_hold = list(
		/obj/item/circuitboard,
		/obj/item/cell,
	)

/obj/item/storage/pouch/electronics/full/Initialize()
	. = ..()
	new /obj/item/circuitboard/airlock (src)
	new /obj/item/circuitboard/apc (src)
	new /obj/item/cell/high (src)


/obj/item/storage/pouch/construction
	name = "construction pouch"
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has a hook for an entrenching tool."
	storage_slots = 4
	max_w_class = 3
	icon_state = "construction"
	can_hold = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/sandbags_empty,
		/obj/item/stack/sandbags,
	)

/obj/item/storage/pouch/construction/full/Initialize()
	. = ..()
	new /obj/item/stack/sandbags_empty/half (src)
	new /obj/item/stack/barbed_wire/small_stack (src)
	new /obj/item/tool/shovel/etool (src)

/obj/item/storage/pouch/construction/equippedengineer/Initialize()
	. = ..()
	new /obj/item/stack/sandbags_empty/half (src)
	new /obj/item/stack/sheet/metal/large_stack (src)
	new /obj/item/stack/sheet/plasteel/medium_stack (src)

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
		/obj/item/multitool,
		/obj/item/tool/wrench,
		/obj/item/stack/cable_coil,
		/obj/item/tool/extinguisher/mini,
	)

/obj/item/storage/pouch/tools/full/Initialize()
	. = ..()
	new /obj/item/tool/screwdriver (src)
	new /obj/item/tool/wirecutters (src)
	new /obj/item/tool/weldingtool (src)
	new /obj/item/tool/wrench (src)
	new /obj/item/tool/crowbar (src)

/obj/item/storage/pouch/shotgun //New shotgun shell pouch that is actually worth a shit and will be replacing light general in vendors
	name = "shotgun shell pouch"
	desc = "A pouch specialized for holding shotgun ammo."
	icon_state = "shotshells"
	storage_slots = 4
	draw_mode = 0
	can_hold = list(/obj/item/ammo_magazine/handful)


/obj/item/storage/pouch/shotgun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/M = I
		if(CHECK_BITFIELD(M.flags_magazine, MAGAZINE_HANDFUL))
			return ..()
		if(M.flags_magazine & MAGAZINE_REFILLABLE)
			if(!M.current_rounds)
				to_chat(user, span_warning("[M] is empty."))
				return

			if(length(contents) >= storage_slots)
				to_chat(user, span_warning("[src] is full."))
				return


			to_chat(user, span_notice("You start refilling [src] with [M]."))
			if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
				return

			for(var/x in 1 to (storage_slots - length(contents)))
				var/cont = handle_item_insertion(M.create_handful(), 1, user)
				if(!cont)
					break

			playsound(user.loc, "rustle", 15, TRUE, 6)
			to_chat(user, span_notice("You refill [src] with [M]."))
			return TRUE

	return ..()
