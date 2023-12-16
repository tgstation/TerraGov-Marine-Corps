/obj/item/storage/pouch
	name = "abstract pouch"
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "small_drop"
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
	max_w_class = WEIGHT_CLASS_SMALL
	flags_equip_slot = ITEM_SLOT_POCKET
	storage_slots = 1
	draw_mode = 0
	allow_drawing_method = TRUE
	var/fill_type
	var/fill_number = 0

/obj/item/storage/pouch/Initialize(mapload)
	. = ..()
	if(fill_number && fill_type)
		for(var/i in 1 to fill_number)
			new fill_type(src)
	return INITIALIZE_HINT_LATELOAD

/obj/item/storage/pouch/LateInitialize()
	. = ..()
	update_icon()

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

/obj/item/storage/pouch/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

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
	sprite_slots = 2
	draw_mode = 0

/obj/item/storage/pouch/general/large
	name = "general pouch"
	storage_slots = null
	max_storage_space = 6
	icon_state = "large_drop"
	sprite_slots = 3
	draw_mode = 0

/obj/item/storage/pouch/general/large/command/Initialize(mapload)
	. = ..()
	new /obj/item/binoculars/tactical(src)
	new /obj/item/megaphone(src)
	new /obj/item/pinpointer(src)


/obj/item/storage/pouch/general/som
	name = "mining general pouch"
	desc = "A general purpose pouch used to carry small items used during mining."
	icon_state = "general_som"
	sprite_slots = null
	draw_mode = 1

/obj/item/storage/pouch/general/large/som
	desc = "A general purpose pouch used to carry small items used during mining."
	icon_state = "large_drop_som"
	sprite_slots = null

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
	sprite_slots = 1
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/flashlight,
		/obj/item/reagent_containers/pill,
		/obj/item/stack/medical/heal_pack/gauze,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/plasteel,
		/obj/item/tool/weldingtool,
	)

/obj/item/storage/pouch/survival/full/Initialize(mapload)
	. = ..()
	new /obj/item/flashlight(src)
	new /obj/item/reagent_containers/pill/tramadol(src)
	new /obj/item/stack/medical/heal_pack/gauze(src, 3)
	new /obj/item/stack/sheet/metal(src, 40)
	new /obj/item/stack/sheet/plasteel(src, 15)
	new /obj/item/tool/weldingtool(src)

/obj/item/storage/pouch/firstaid
	name = "first-aid pouch"
	desc = "Standard marine first-aid pouch. It can contain most common medical supplies."
	icon_state = "firstaid"
	sprite_slots = 3
	storage_slots = 6
	can_hold = list(
		/obj/item/reagent_containers/hypospray,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle,
	)

/obj/item/storage/pouch/firstaid/combat_patrol/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)

/obj/item/storage/pouch/firstaid/basic/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/packet/bicaridine(src)
	new /obj/item/storage/pill_bottle/packet/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)

/obj/item/storage/pouch/firstaid/combat_patrol_leader/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/packet/bicaridine(src)
	new /obj/item/storage/pill_bottle/packet/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/advanced/inaprovaline(src)

/obj/item/storage/pouch/firstaid/som
	name = "mining first aid pouch"
	desc = "A basic first aid pouch originally used by miners due to dangerous working conditions on the mining colonies. This one is marked as belonging to the SOM."
	icon_state = "firstaid_som"
	sprite_slots = null

/obj/item/storage/pouch/firstaid/som/full/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/packet/bicaridine(src)
	new /obj/item/storage/pill_bottle/packet/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)

/obj/item/storage/pouch/firstaid/som/combat_patrol/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)

/obj/item/storage/pouch/firstaid/som/combat_patrol_leader/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/packet/bicaridine(src)
	new /obj/item/storage/pill_bottle/packet/kelotane(src)
	new /obj/item/storage/pill_bottle/packet/tramadol(src)
	new /obj/item/storage/pill_bottle/packet/tricordrazine(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/advanced/inaprovaline(src)

/obj/item/storage/pouch/pistol
	name = "sidearm pouch"
	desc = "It can contain a pistol or revolver. Useful for emergencies."
	icon_state = "pistol"
	sprite_slots = 1
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/weapon/gun/pistol,
		/obj/item/weapon/gun/revolver,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/pistol,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta,
	)
	draw_mode = 1

/obj/item/storage/pouch/pistol/vp70/Initialize(mapload)
	. = ..()
	new /obj/item/weapon/gun/pistol/vp70(src)

/obj/item/storage/pouch/pistol/rt3/Initialize(mapload)
	. = ..()
	new /obj/item/weapon/gun/pistol/rt3(src)

/obj/item/storage/pouch/pistol/som
	desc = "It can contain a pistol or revolver. Useful for emergencies, and made out of stylish leather in the old SOM tradition."
	icon_state = "pistol_som"
	sprite_slots = null

/obj/item/storage/pouch/pistol/icc
	desc = "It can contain a pistol or revolver. Useful for emergencies, and made is out of a syntheic tan fabric."
	icon_state = "pistol_icc"
	sprite_slots = null

//// MAGAZINE POUCHES /////

/obj/item/storage/pouch/magazine
	name = "magazine pouch"
	desc = "It can contain ammo magazines."
	icon_state = "medium_ammo_mag"
	sprite_slots = 2
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 2
	draw_mode = 0
	can_hold = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/ammo_magazine/railgun,
		/obj/item/cell/lasgun,
	)

/obj/item/storage/pouch/magazine/smgfull
	fill_type = /obj/item/ammo_magazine/smg/standard_machinepistol
	fill_number = 2

/obj/item/storage/pouch/magazine/large
	name = "magazine pouch"
	desc = "This pouch can contain three ammo magazines."
	icon_state = "large_ammo_mag"
	sprite_slots = 3
	storage_slots = 3

/obj/item/storage/pouch/magazine/large/tx8full
	fill_type = /obj/item/ammo_magazine/rifle/tx8
	fill_number = 3

/obj/item/storage/pouch/magazine/large/t19full
	fill_type = /obj/item/ammo_magazine/smg/standard_smg
	fill_number = 3

/obj/item/storage/pouch/magazine/large/som
	desc = "This pouch can contain three ammo magazines. Made with traditional SOM leather."
	icon_state = "mag_som"
	sprite_slots = null

/obj/item/storage/pouch/magazine/large/icc
	desc = "This pouch can contain three ammo magazines, appears to be made with a synthetic tan fiber."
	icon_state = "mag_icc"
	sprite_slots = null

/obj/item/storage/pouch/magazine/pistol
	name = "pistol magazine pouch"
	desc = "It can contain pistol and revolver ammo magazines."
	max_w_class = WEIGHT_CLASS_SMALL
	icon_state = "pistol_mag"
	sprite_slots = 3
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
	sprite_slots = 5

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
	desc = "It can contain four drum magazines."
	icon_state = "large_ammo_drum"
	storage_slots = 4
	sprite_slots = null
	can_hold = list(
		/obj/item/ammo_magazine/,
	)


/obj/item/storage/pouch/explosive
	name = "explosive pouch"
	desc = "It can contain grenades, plastiques, mine boxes, and other explosives."
	icon_state = "explosive"
	sprite_slots = 2
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_NORMAL
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

/obj/item/storage/pouch/explosive/detpack/Initialize(mapload)
	. = ..()
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/detpack(src)
	new /obj/item/assembly/signaler(src)

/obj/item/storage/pouch/explosive/razorburn/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/chem_grenade/razorburn_smol(src)
	new /obj/item/explosive/grenade/chem_grenade/razorburn_smol(src)
	new /obj/item/explosive/grenade/chem_grenade/razorburn_smol(src)
	new /obj/item/explosive/grenade/chem_grenade/razorburn_large(src)

/obj/item/storage/pouch/explosive/upp
	fill_type = /obj/item/explosive/grenade/upp
	fill_number = 4

/obj/item/storage/pouch/explosive/som
	name = "\improper S26 explosive pouch"
	desc = "A leather pouch for storing grenades, rockets, mine boxes, and other explosives."
	icon_state = "explosive_som"
	sprite_slots = null

/obj/item/storage/pouch/explosive/icc
	desc = "It can contain grenades, plastiques, mine boxes, and other explosives. Clearly made from with a synthetic tan fiber."
	icon_state = "large_explosive_icc"
	sprite_slots = null

/obj/item/storage/pouch/grenade
	name = "grenade pouch"
	desc = "It can contain grenades."
	icon_state = "grenade"
	sprite_slots = 6
	storage_slots = 6
	can_hold = list(
		/obj/item/explosive/grenade,
	)

/obj/item/storage/pouch/grenade/slightlyfull
	fill_type = /obj/item/explosive/grenade
	fill_number = 4

/obj/item/storage/pouch/grenade/combat_patrol/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/smokebomb(src)
	new /obj/item/explosive/grenade/smokebomb(src)
	new /obj/item/explosive/grenade/smokebomb/acid(src)
	new /obj/item/explosive/grenade/smokebomb/neuro(src)
	new /obj/item/explosive/grenade/flashbang/stun(src)
	new /obj/item/explosive/grenade/flashbang/stun(src)

/obj/item/storage/pouch/grenade/som
	desc = "It can contain grenades. This one looks to be made out of traditional SOM leather."
	icon_state = "grenade_som"
	sprite_slots = null

/obj/item/storage/pouch/grenade/som/combat_patrol/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/smokebomb/som(src)
	new /obj/item/explosive/grenade/smokebomb/som(src)
	new /obj/item/explosive/grenade/smokebomb/satrapine(src)
	new /obj/item/explosive/grenade/smokebomb/satrapine(src)
	new /obj/item/explosive/grenade/flashbang/stun(src)
	new /obj/item/explosive/grenade/flashbang/stun(src)

/obj/item/storage/pouch/grenade/som/ert/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/smokebomb/som(src)
	new /obj/item/explosive/grenade/smokebomb/som(src)
	new /obj/item/explosive/grenade/smokebomb/satrapine(src)
	new /obj/item/explosive/grenade/smokebomb/satrapine(src)
	new /obj/item/explosive/grenade/som(src)
	new /obj/item/explosive/grenade/som(src)

/obj/item/storage/pouch/medkit
	name = "medkit pouch"
	desc = "A standard use medkit pouch that can contain all kinds of medical supplies and equipment."
	icon_state = "medkit"
	sprite_slots = 1
	w_class = WEIGHT_CLASS_BULKY //does not fit in backpack
	max_w_class = WEIGHT_CLASS_BULKY
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

/obj/item/storage/pouch/medkit/firstaid/Initialize(mapload)
	. = ..()
	new /obj/item/storage/pill_bottle/bicaridine(src)
	new /obj/item/storage/pill_bottle/kelotane(src)
	new /obj/item/storage/pill_bottle/tramadol(src)
	new /obj/item/storage/pill_bottle/tricordrazine(src)
	new /obj/item/storage/pill_bottle/dylovene(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)

/obj/item/storage/pouch/medkit/medic/Initialize(mapload)
	. = ..()
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/burn_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/stack/medical/heal_pack/advanced/bruise_pack(src)
	new /obj/item/reagent_containers/hypospray/advanced/meraderm(src)

/obj/item/storage/pouch/medkit/som
	desc = "A standard use medkit pouch that can contain all kinds of medical supplies and equipment. Made with traditional SOM leather."
	icon_state = "medkit_som"
	sprite_slots = null

/obj/item/storage/pouch/medical_injectors
	name = "medical injector pouch"
	desc = "A specialized medical pouch that can only hold auto-injectors."
	icon_state = "firstaid_injector"
	sprite_slots = 5
	storage_slots = 8
	max_storage_space = 14
	can_hold = list(/obj/item/reagent_containers/hypospray/autoinjector)

/obj/item/storage/pouch/medical_injectors/firstaid
	desc = "Standard marine first-aid injector pouch. Specialized to store only auto-injectors. Contains basic injectors, a stabilizing injector, stimulant injector, and an emergency injector."

/obj/item/storage/pouch/medical_injectors/firstaid/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tramadol (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dylovene (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/russian_red (src)

/obj/item/storage/pouch/medical_injectors/medic/Initialize(mapload) //corpsman autoinjector pouch gets upgraded, but more general chems.
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus(src)

/obj/item/storage/pouch/medical_injectors/som
	desc = "A specialized medical pouch that can only hold auto-injectors. This one looks to be made out of traditional SOM leather."
	icon_state = "firstaid_injector_som"
	sprite_slots = null

/obj/item/storage/pouch/medical_injectors/som/firstaid/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tramadol (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dylovene (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/russian_red (src)

/obj/item/storage/pouch/medical_injectors/som/medic/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus(src)

/obj/item/storage/pouch/medical_injectors/icc
	desc = "A specialized medical pouch that can only hold auto-injectors. This one looks to be made out of a synthetic tan fabric."
	icon_state = "firstaid_injector_icc"
	sprite_slots = null

/obj/item/storage/pouch/medical_injectors/icc/firstaid/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/kelotane (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tramadol (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/dylovene (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine (src)
	new /obj/item/reagent_containers/hypospray/autoinjector/russian_red (src)


/obj/item/storage/pouch/med_lolipops
	name = "medical lolipop pouch"
	desc = "A small medical pouch with three seperate pockets to sort your medical lollipops."
	icon_state = "medlolly"
	sprite_slots = 3
	storage_slots = 3

	can_hold = list(/obj/item/storage/box/combat_lolipop)

/obj/item/storage/pouch/med_lolipops/Initialize(mapload)
	. = ..()
	new /obj/item/storage/box/combat_lolipop(src)
	new /obj/item/storage/box/combat_lolipop/tricord(src)
	new /obj/item/storage/box/combat_lolipop/tramadol(src)

/obj/item/storage/pouch/berrypouch
	name = "berry bar pouch"
	desc = "A pouch containing all of your berry needs."
	icon_state = "barpouch"
	sprite_slots = 3
	storage_slots = 6
	can_hold = list(/obj/item/reagent_containers/food/snacks/wrapped/berrybar)

/obj/item/storage/pouch/berrypouch/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/food/snacks/wrapped/berrybar(src)
	new /obj/item/reagent_containers/food/snacks/wrapped/berrybar(src)
	new /obj/item/reagent_containers/food/snacks/wrapped/berrybar(src)
	new /obj/item/reagent_containers/food/snacks/wrapped/berrybar(src)
	new /obj/item/reagent_containers/food/snacks/wrapped/berrybar(src)
	new /obj/item/reagent_containers/food/snacks/wrapped/berrybar(src)

/obj/item/storage/pouch/surgery

	name = "surgery tools pouch"
	desc = "An eye catching white medical pouch capable of holding all your surgical tools."
	icon_state = "surgery"
	sprite_slots = 1
	storage_slots = 12
	max_storage_space = 24
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/nanopaste,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
	)

/obj/item/storage/pouch/surgery/Initialize(mapload)
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
/obj/item/storage/pouch/field_pouch
	name = "field utility pouch"
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_NORMAL
	icon_state = "utility"
	sprite_slots = 4
	draw_mode = 1
	desc = "It can contain a motion detector, signaller, beacons, map tablets, radios, papers and other handy battlefield communication, navigation, and detection devices."
	can_hold = list(
		/obj/item/attachable/motiondetector,
		/obj/item/radio,
		/obj/item/assembly/signaler,
		/obj/item/megaphone,
		/obj/item/flashlight,
		/obj/item/whistle,
		/obj/item/binoculars,
		/obj/item/beacon/supply_beacon,
		/obj/item/compass,
		/obj/item/deployable_camera,
		/obj/item/hud_tablet,
		/obj/item/squad_transfer_tablet,
		/obj/item/minimap_tablet,
		/obj/item/supplytablet,
		/obj/item/megaphone,
		/obj/item/tool/hand_labeler,
		/obj/item/toy/deck,
		/obj/item/paper,
		/obj/item/clipboard,
	)

/obj/item/storage/pouch/field_pouch/full/Initialize(mapload)
	. = ..()
	new /obj/item/attachable/motiondetector (src)
	new /obj/item/whistle (src)
	new /obj/item/radio (src)
	new /obj/item/binoculars/tactical (src)


/obj/item/storage/pouch/electronics
	name = "electronics pouch"
	desc = "It is designed to hold most electronics, power cells and circuitboards."
	icon_state = "electronics"
	sprite_slots = 1
	storage_slots = 6
	can_hold = list(
		/obj/item/circuitboard,
		/obj/item/cell,
	)

/obj/item/storage/pouch/electronics/full/Initialize(mapload)
	. = ..()
	new /obj/item/circuitboard/airlock (src)
	new /obj/item/circuitboard/apc (src)
	new /obj/item/cell/high (src)


/obj/item/storage/pouch/construction
	name = "construction pouch"
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has a hook for an entrenching tool."
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_NORMAL
	icon_state = "construction"
	sprite_slots = 1
	can_hold = list(
		/obj/item/stack/barbed_wire,
		/obj/item/stack/sheet,
		/obj/item/stack/rods,
		/obj/item/stack/cable_coil,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/sandbags_empty,
		/obj/item/stack/sandbags,
	)

/obj/item/storage/pouch/construction/full/Initialize(mapload)
	. = ..()
	new /obj/item/stack/sandbags_empty/half (src)
	new /obj/item/stack/barbed_wire/small_stack (src)
	new /obj/item/tool/shovel/etool (src)

/obj/item/storage/pouch/construction/equippedengineer/Initialize(mapload)
	. = ..()
	new /obj/item/stack/sandbags_empty/half (src)
	new /obj/item/stack/sheet/metal/large_stack (src)
	new /obj/item/stack/sheet/plasteel/medium_stack (src)

/obj/item/storage/pouch/construction/som
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has a hook for an entrenching tool. Made with traditional SOM leather."
	icon_state = "construction_som"
	sprite_slots = null

/obj/item/storage/pouch/construction/icc
	desc = "It's designed to hold construction materials - glass/metal sheets, metal rods, barbed wire, cable coil, and empty sandbags. It also has a hook for an entrenching tool. Made with synthetic tan."
	icon_state = "construction_icc"
	sprite_slots = null

/obj/item/storage/pouch/construction/icc/full/Initialize(mapload)
	. = ..()
	new /obj/item/stack/sheet/metal/large_stack (src)
	new /obj/item/stack/sheet/metal/large_stack (src)
	new /obj/item/stack/sheet/plasteel/medium_stack (src)

/obj/item/storage/pouch/tools
	name = "tools pouch"
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool."
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_NORMAL
	icon_state = "tools"
	sprite_slots = 1
	can_hold = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/tool/weldingtool,
		/obj/item/tool/wrench,
		/obj/item/tool/crowbar,
		/obj/item/stack/cable_coil,
		/obj/item/tool/multitool,
		/obj/item/flashlight,
		/obj/item/t_scanner,
		/obj/item/tool/analyzer,
		/obj/item/tool/taperoll/engineering,
		/obj/item/tool/extinguisher/mini,
		/obj/item/tool/shovel/etool,
	)

/obj/item/storage/pouch/tools/full/Initialize(mapload)
	. = ..()
	new /obj/item/tool/screwdriver (src)
	new /obj/item/tool/wirecutters (src)
	new /obj/item/tool/weldingtool (src)
	new /obj/item/tool/wrench (src)
	new /obj/item/tool/crowbar (src)

/obj/item/storage/pouch/tools/som
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool. Made with traditional SOM leather."
	icon_state = "tools_som"
	sprite_slots = null

/obj/item/storage/pouch/tools/som/full/Initialize(mapload)
	. = ..()
	new /obj/item/tool/screwdriver (src)
	new /obj/item/tool/wirecutters (src)
	new /obj/item/tool/weldingtool (src)
	new /obj/item/tool/wrench (src)
	new /obj/item/tool/crowbar (src)

/obj/item/storage/pouch/tools/icc
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool. Made with a synthetic tan fiber."
	icon_state = "tools_icc"
	sprite_slots = null

/obj/item/storage/pouch/tools/icc/full/Initialize(mapload)
	. = ..()
	new /obj/item/tool/screwdriver (src)
	new /obj/item/tool/wirecutters (src)
	new /obj/item/tool/weldingtool (src)
	new /obj/item/tool/wrench (src)
	new /obj/item/tool/crowbar (src)

/obj/item/storage/pouch/shotgun
	name = "shotgun shell pouch"
	desc = "A pouch specialized for holding shotgun ammo."
	icon_state = "shotshells"
	sprite_slots = 4
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
			if(!do_after(user, 1.5 SECONDS, NONE, src, BUSY_ICON_GENERIC))
				return

			for(var/x in 1 to (storage_slots - length(contents)))
				var/cont = handle_item_insertion(M.create_handful(), 1, user)
				if(!cont)
					break

			playsound(user.loc, "rustle", 15, TRUE, 6)
			to_chat(user, span_notice("You refill [src] with [M]."))
			return TRUE

	return ..()

/obj/item/storage/pouch/shotgun/som
	desc = "A pouch specialized for holding shotgun ammo. Made with traditional SOM leather."
	icon_state = "shotshells_som"
	sprite_slots = null

/obj/item/storage/pouch/protein_pack
	name = "\improper protein pack pouch"
	desc = "A storage pouch designed to hold a moderate amount of protein packs."
	icon_state = "p_pouch"
	item_state = "survival"
	storage_slots = 10
	max_storage_space = 10
	sprite_slots = 1
	max_w_class = WEIGHT_CLASS_TINY
	can_hold = list(/obj/item/reagent_containers/food/snacks/protein_pack)

/obj/item/storage/pouch/protein_pack/Initialize(mapload)
	. = ..()
	for(var/i in 1 to storage_slots)
		new /obj/item/reagent_containers/food/snacks/protein_pack(src)
