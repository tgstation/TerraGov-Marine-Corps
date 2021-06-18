/obj/item/storage/pouch
	name = "abstract pouch"
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "small_drop"
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
	max_w_class = 2
	flags_equip_slot = ITEM_SLOT_POCKET
	storage_slots = 1
	flags_storage = STORAGE_FLAG_DRAWMODE_ALLOWED

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

/obj/item/storage/pouch/general/medium
	name = "medium general pouch"
	storage_slots = 2
	icon_state = "medium_drop"

/obj/item/storage/pouch/general/large
	name = "general pouch"
	storage_slots = null
	max_storage_space = 6
	icon_state = "large_drop"

/obj/item/storage/pouch/general/large/command
	spawns_with = list(
		/obj/item/binoculars/tactical,
		/obj/item/megaphone,
		/obj/item/pinpointer/pool,
	)

/obj/item/storage/pouch/general/som
	name = "mining general pouch"
	desc = "A general purpose pouch used to carry small items used during mining."
	icon_state = "general_som"

/obj/item/storage/pouch/bayonet
	name = "bayonet sheath"
	desc = "A pouch for your knives."
	can_hold = list(
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/throwing_knife,
		/obj/item/attachable/bayonet,
	)
	icon_state = "bayonet"
	storage_slots = 3

/obj/item/storage/pouch/bayonet/full
	spawns_with = list(/obj/item/weapon/combat_knife)

/obj/item/storage/pouch/bayonet/upp
	spawns_with = list(/obj/item/weapon/combat_knife/upp)

/obj/item/storage/pouch/survival
	name = "survival pouch"
	desc = "It can contain flashlights, a pill, a crowbar, metal sheets, and some bandages."
	icon_state = "survival"
	storage_slots = 6
	max_w_class = 3
	can_hold = list(
		/obj/item/flashlight,
		/obj/item/reagent_containers/pill,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/plasteel,
		/obj/item/tool/weldingtool,
	)

/obj/item/storage/pouch/survival/full
	spawns_with = list(
		/obj/item/flashlight,
		/obj/item/reagent_containers/pill/tramadol,
		/obj/item/tool/weldingtool,
	)

/obj/item/storage/pouch/survival/full/PopulateContents()
	. = ..()
	new /obj/item/stack/medical/bruise_pack(src, 3)
	new /obj/item/stack/sheet/metal(src, 40)
	new /obj/item/stack/sheet/plasteel(src, 15)

/obj/item/storage/pouch/firstaid
	name = "first-aid pouch"
	desc = "Standard marine first-aid pouch. It can contain autoinjectors, ointments, and bandages."
	icon_state = "firstaid"
	storage_slots = 5
	can_hold = list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/storage/pill_bottle/packet/tricordrazine,
		/obj/item/stack/medical/splint,
	)

/obj/item/storage/pouch/firstaid/full
	desc = "Standard marine first-aid pouch. Contains a painkiller autoinjector, a soothing pill packet, splints, some ointment, and some bandages."
	spawns_with = list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/autoinjector/tramadol,
		/obj/item/storage/pill_bottle/packet/tricordrazine,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/splint,
	)

/obj/item/storage/pouch/firstaid/injectors
	name = "combat injector pouch"
	desc = "Standard marine first-aid combat injector pouch. Specialized to store only autoinjectors."
	icon_state = "firstaid_injector"
	can_hold = list(/obj/item/reagent_containers/hypospray/autoinjector)

/obj/item/storage/pouch/firstaid/injectors/full
	desc = "Standard marine first-aid combat injector pouch. Specialized to store only autoinjectors. Contains 3 combat autoinjectors, an oxycodone injector, and a stimulant injector."
	spawns_with = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat,
		/obj/item/reagent_containers/hypospray/autoinjector/combat,
		/obj/item/reagent_containers/hypospray/autoinjector/combat,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red,
	)

/obj/item/storage/pouch/firstaid/som
	name = "mining first aid pouch"
	desc = "A basic first aid pouch used by miners due to dangerous working conditions on the mining colonies."
	icon_state = "firstaid_som"
	storage_slots = 5
	can_hold = list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/storage/pill_bottle/packet/tricordrazine,
		/obj/item/stack/medical/splint,
	)

/obj/item/storage/pouch/firstaid/som/full
	desc = "A basic first aid pouch used by miners due to dangerous working conditions on the mining colonies. Contains the necessary items already."
	spawns_with = list(
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/hypospray/autoinjector/tramadol,
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/splint,
	)

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

/obj/item/storage/pouch/pistol/vp70
	spawns_with = list(/obj/item/weapon/gun/pistol/vp70)

/obj/item/storage/pouch/pistol/rt3
	spawns_with = list(/obj/item/weapon/gun/pistol/rt3)

//// MAGAZINE POUCHES /////

/obj/item/storage/pouch/magazine
	name = "magazine pouch"
	desc = "It can contain ammo magazines."
	icon_state = "medium_ammo_mag"
	max_w_class = 3
	storage_slots = 2
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
	spawns_with = list(/obj/item/ammo_magazine/smg/standard_machinepistol, /obj/item/ammo_magazine/smg/standard_machinepistol)

/obj/item/storage/pouch/magazine/large
	name = "magazine pouch"
	desc = "This pouch can contain three ammo magazines."
	icon_state = "large_ammo_mag"
	storage_slots = 3

/obj/item/storage/pouch/magazine/large/tx8full
	spawns_with = list(/obj/item/ammo_magazine/rifle/tx8, /obj/item/ammo_magazine/rifle/tx8, /obj/item/ammo_magazine/rifle/tx8)

/obj/item/storage/pouch/magazine/large/t19full
	spawns_with = list(/obj/item/ammo_magazine/smg/standard_smg, /obj/item/ammo_magazine/smg/standard_smg, /obj/item/ammo_magazine/smg/standard_smg)

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
	)

/obj/item/storage/pouch/magazine/pistol/large
	name = "pistol magazine pouch"
	desc = "This pouch can contain six pistol and revolver ammo magazines."
	storage_slots = 6
	icon_state = "large_pistol_mag"

/obj/item/storage/pouch/magazine/pistol/large/full
	spawns_with = list(/obj/item/ammo_magazine/pistol, /obj/item/ammo_magazine/pistol, /obj/item/ammo_magazine/pistol, /obj/item/ammo_magazine/pistol, /obj/item/ammo_magazine/pistol, /obj/item/ammo_magazine/pistol)

/obj/item/storage/pouch/magazine/pistol/pmc_mateba
	spawns_with = list(/obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba)

/obj/item/storage/pouch/magazine/pistol/large/mateba
	spawns_with = list(/obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba, /obj/item/ammo_magazine/revolver/mateba)

/obj/item/storage/pouch/magazine/pistol/vp70
	spawns_with = list(/obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70)

/obj/item/storage/pouch/magazine/pistol/pmc_vp78
	spawns_with = list(/obj/item/ammo_magazine/pistol/vp78, /obj/item/ammo_magazine/pistol/vp78, /obj/item/ammo_magazine/pistol/vp78)

/obj/item/storage/pouch/magazine/upp
	spawns_with = list(/obj/item/ammo_magazine/rifle/type71, /obj/item/ammo_magazine/rifle/type71)

/obj/item/storage/pouch/magazine/large/upp
	spawns_with = list(/obj/item/ammo_magazine/rifle/type71, /obj/item/ammo_magazine/rifle/type71, /obj/item/ammo_magazine/rifle/type71)

/obj/item/storage/pouch/magazine/upp_smg
	spawns_with = list(/obj/item/ammo_magazine/smg/skorpion, /obj/item/ammo_magazine/smg/skorpion)

/obj/item/storage/pouch/magazine/large/pmc_m25
	spawns_with = list(/obj/item/ammo_magazine/smg/m25/ap, /obj/item/ammo_magazine/smg/m25/ap, /obj/item/ammo_magazine/smg/m25/ap)

/obj/item/storage/pouch/magazine/large/pmc_famas
	spawns_with = list(/obj/item/ammo_magazine/rifle/famas, /obj/item/ammo_magazine/rifle/famas, /obj/item/ammo_magazine/rifle/famas)

/obj/item/storage/pouch/magazine/large/pmc_lmg
	spawns_with = list(/obj/item/ammo_magazine/standard_lmg, /obj/item/ammo_magazine/standard_lmg, /obj/item/ammo_magazine/standard_lmg)

/obj/item/storage/pouch/magazine/large/pmc_sniper
	spawns_with = list(/obj/item/ammo_magazine/sniper/elite, /obj/item/ammo_magazine/sniper/elite, /obj/item/ammo_magazine/sniper/elite)

/obj/item/storage/pouch/magazine/large/pmc_rifle
	spawns_with = list(/obj/item/ammo_magazine/rifle/ap, /obj/item/ammo_magazine/rifle/ap, /obj/item/ammo_magazine/rifle/ap)

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
	spawns_with = list(/obj/item/explosive/grenade/frag = 4)

/obj/item/storage/pouch/explosive/detpack
	spawns_with = list(
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/assembly/signaler,
	)

/obj/item/storage/pouch/explosive/razorburn
	spawns_with = list(
		/obj/item/explosive/grenade/chem_grenade/razorburn_smol = 3,
		/obj/item/explosive/grenade/chem_grenade/razorburn_large = 1,
	)

/obj/item/storage/pouch/explosive/upp
	spawns_with = list(/obj/item/explosive/grenade/frag/upp = 4)

/obj/item/storage/pouch/grenade
	name = "Grenade pouch"
	desc = "It can contain grenades."
	icon_state = "explosive"
	storage_slots = 6
	can_hold = list(
		/obj/item/explosive/grenade,
	)

/obj/item/storage/pouch/grenade/slightlyfull
	spawns_with = list(/obj/item/explosive/grenade/frag = 4)

/obj/item/storage/pouch/medical
	name = "medical pouch"
	desc = "It can contain small medical supplies."
	icon_state = "medical"
	storage_slots = 3

	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/reagent_containers/hypospray,
	)

/obj/item/storage/pouch/medical/full
	spawns_with = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/splint,
	)

/obj/item/storage/pouch/medical/equippedcorpsman
	spawns_with = list(
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/healthanalyzer,
	)

/obj/item/storage/pouch/autoinjector
	name = "auto-injector pouch"
	desc = "A pouch specifically for auto-injectors."
	icon_state = "autoinjector"
	storage_slots = 8
	max_storage_space = 14
	can_hold = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
	)

/obj/item/storage/pouch/autoinjector/full //synth autoinjector pouch gets a bunch of specialized chems, considering it's trivial for them to get general healing meds.
	spawns_with = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
		/obj/item/reagent_containers/hypospray/autoinjector/polyhexanide,
		/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin,
	)

/obj/item/storage/pouch/autoinjector/advanced
	name = "auto-injector pouch"
	desc = "A pouch specifically for auto-injectors. This one comes pre-loaded with goodies!"
	icon_state = "autoinjector"
	storage_slots = 8
	max_storage_space = 14
	can_hold = list(
		/obj/item/reagent_containers/hypospray/autoinjector,
	)

/obj/item/storage/pouch/autoinjector/advanced/full
	spawns_with = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic,
		/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
	)

/obj/item/storage/pouch/syringe
	name = "syringe pouch"
	desc = "It can contain syringes."
	icon_state = "syringe"
	storage_slots = 5
	max_storage_space = 10
	can_hold = list(/obj/item/reagent_containers/syringe)

/obj/item/storage/pouch/hypospray
	name = "hypospray pouch"
	desc = "It can contain hyposprays and autoinjectors."
	icon_state = "syringe"
	storage_slots = 3
	can_hold = list(/obj/item/reagent_containers/hypospray)

/obj/item/storage/pouch/hypospray/corps
	name = "Corps hypospray pouch"
	desc = "It can contain hyposprays and autoinjectors, this one has a Terragov corpsman logo on its back."
	icon_state = "syringe"
	storage_slots = 4
	can_hold = list(/obj/item/reagent_containers/hypospray)

/obj/item/storage/pouch/hypospray/corps/full
	spawns_with = list(
		/obj/item/reagent_containers/hypospray/advanced/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
	)

/obj/item/storage/pouch/medkit
	name = "medkit pouch"
	desc = "A standard use medkit pouch that can contain all kinds of stuff."
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
		/obj/item/flashlight/pen,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/reagent_containers/hypospray,
	)

/obj/item/storage/pouch/medkit/full
	spawns_with = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/advanced/bruise_pack = 2,
		/obj/item/stack/medical/advanced/ointment = 2,
		/obj/item/stack/medical/splint = 2,
	)

/obj/item/storage/pouch/medkit/equippedcorpsman
	spawns_with = list(
		/obj/item/healthanalyzer,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/storage/pill_bottle/kelotane,
		/obj/item/storage/pill_bottle/tramadol,
		/obj/item/stack/medical/splint,
	)

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
	desc = "A pouch designed to hold flares. Refillable with a M94 flare pack."
	max_w_class = 2
	storage_slots = 7
	icon_state = "flare"
	can_hold = list(
		/obj/item/flashlight/flare,
		/obj/item/explosive/grenade/flare,
	)

/obj/item/storage/pouch/flare/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/box/m94))
		var/obj/item/storage/box/m94/M = I
		if(!length(M.contents))
			to_chat(user, "<span class='warning'>[M] is empty.</span>")
			return

		if(length(contents) >= storage_slots)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		to_chat(user, "<span class='notice'>You start refilling [src] with [M].</span>")

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
	spawns_with = list(/obj/item/explosive/grenade/flare = 7)

/obj/item/storage/pouch/radio
	name = "radio pouch"
	storage_slots = 2
	icon_state = "radio"
	desc = "It can contain two handheld radios."
	can_hold = list(/obj/item/radio)

/obj/item/storage/pouch/field_pouch
	name = "field utility pouch"
	storage_slots = 5
	max_w_class = 3
	icon_state = "utility"
	desc = "It can contain a motion detector, signaller, beacons, maps, flares, radios and other handy battlefield communication and detection devices."
	can_hold = list(
		/obj/item/motiondetector,
		/obj/item/radio,
		/obj/item/assembly/signaler,
		/obj/item/megaphone,
		/obj/item/flashlight,
		/obj/item/whistle,
		/obj/item/binoculars,
		/obj/item/beacon/supply_beacon,
	)

/obj/item/storage/pouch/field_pouch/full
	spawns_with = list(
		/obj/item/motiondetector,
		/obj/item/whistle,
		/obj/item/radio,
		/obj/item/binoculars/tactical,
	)

/obj/item/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"
	storage_slots = 6
	can_hold = list(
		/obj/item/circuitboard,
		/obj/item/cell,
	)

/obj/item/storage/pouch/electronics/full
	spawns_with = list(
		/obj/item/circuitboard/airlock,
		/obj/item/circuitboard/apc,
		/obj/item/cell/high,
	)

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

/obj/item/storage/pouch/construction/full
	spawns_with = list(
		/obj/item/stack/sandbags_empty/half,
		/obj/item/stack/barbed_wire/small_stack,
		/obj/item/tool/shovel/etool,
	)

/obj/item/storage/pouch/construction/equippedengineer
	spawns_with = list(
		/obj/item/stack/sandbags_empty/half,
		/obj/item/stack/sheet/metal/large_stack,
		/obj/item/stack/sheet/plasteel/medium_stack,
	)

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

/obj/item/storage/pouch/tools/full
	spawns_with = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/multitool,
		/obj/item/tool/wrench,
		/obj/item/tool/crowbar,
	)

/obj/item/storage/pouch/shotgun //New shotgun shell pouch that is actually worth a shit and will be replacing light general in vendors
	name = "shotgun shell pouch"
	desc = "A pouch specialized for holding shotgun ammo."
	icon_state = "shotshells"
	storage_slots = 4
	can_hold = list(/obj/item/ammo_magazine/handful)

/obj/item/storage/pouch/shotgun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/M = I

		if(M.flags_magazine & AMMUNITION_REFILLABLE)
			if(!M.current_rounds)
				to_chat(user, "<span class='warning'>[M] is empty.</span>")
				return

			if(length(contents) >= storage_slots)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
				return

			to_chat(user, "<span class='notice'>You start refilling [src] with [M].</span>")
			if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
				return

			for(var/x in 1 to (storage_slots - length(contents)))
				var/cont = handle_item_insertion(M.create_handful(), 1, user)
				if(!cont)
					break

			playsound(user.loc, "rustle", 15, TRUE, 6)
			to_chat(user, "<span class='notice'>You refill [src] with [M].</span>")
			return TRUE

	return ..()
