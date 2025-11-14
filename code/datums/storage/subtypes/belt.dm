/datum/storage/belt
	allow_drawing_method = TRUE

/datum/storage/belt/champion
	storage_slots = 1

/datum/storage/belt/champion/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/clothing/mask/luchador,
	))

/datum/storage/belt/utility
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/belt/utility/New(atom/parent)
	. = ..()
	set_holdable(list(
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
	))

/datum/storage/belt/medical_small
	storage_slots = 15
	max_storage_space = 30
	max_w_class = 3

/datum/storage/belt/medical_small/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/pill_bottle/packet,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/dropper,
	))

/datum/storage/belt/lifesaver
	storage_slots = 21 //can hold 3 "rows" of very limited medical equipment, but it *should* give a decent boost to squad medics.
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL

/datum/storage/belt/lifesaver/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/stack/medical,
	))

/datum/storage/belt/rig
	storage_slots = 16
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 42

/datum/storage/belt/rig/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/syringe_case,
		/obj/item/stack/medical,
		/obj/item/bodybag,
		/obj/item/defibrillator,
		/obj/item/tweezers,
		/obj/item/tweezers_advanced,
		/obj/item/roller,
		/obj/item/tool/research,
		/obj/item/tool/soap,
	))

/datum/storage/belt/hypospraybelt
	storage_slots = 21
	max_storage_space = 42
	max_w_class = WEIGHT_CLASS_SMALL

/datum/storage/belt/hypospraybelt/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/storage/syringe_case,
	))

/datum/storage/belt/security
	storage_slots = 7
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 21

/datum/storage/belt/security/New(atom/parent)
	. = ..()
	set_holdable(
		can_hold_list = list(
			/obj/item/explosive/grenade/flashbang,
			/obj/item/explosive/grenade/chem_grenade/teargas,
			/obj/item/reagent_containers/spray/pepper,
			/obj/item/restraints/handcuffs,
			/obj/item/flash,
			/obj/item/clothing/glasses,
			/obj/item/ammo_magazine/pistol,
			/obj/item/ammo_magazine/handful,
			/obj/item/reagent_containers/food/snacks/donut,
			/obj/item/weapon/baton,
			/obj/item/weapon/gun/energy/taser,
			/obj/item/tool/lighter/zippo,
			/obj/item/storage/fancy/cigarettes,
			/obj/item/clothing/glasses/hud/security,
			/obj/item/flashlight,
			/obj/item/radio/headset,
			/obj/item/tool/taperoll/police,
			/obj/item/weapon/telebaton,
		),
		cant_hold_list = list(
			/obj/item/weapon/gun,
		)
	)


/datum/storage/belt/security/tactical
	storage_slots = 9

/datum/storage/belt/marine
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 18

/datum/storage/belt/marine/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
		/obj/item/explosive/grenade/flare/civilian,
		/obj/item/explosive/grenade/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/ammo_magazine/railgun,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_containers/food/snacks,
	))

/datum/storage/belt/marine/sectoid/New(atom/parent)
	. = ..()
	set_holdable(list(
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
		/obj/item/explosive/grenade,
		/obj/item/ammo_magazine/rifle,
		/obj/item/cell/lasgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/tool/crowbar,
	))

/datum/storage/belt/shotgun
	storage_slots = 14
	max_w_class = WEIGHT_CLASS_SMALL
	max_storage_space = 28

/datum/storage/belt/shotgun/New(atom/parent)
	. = ..()
	set_holdable(list(/obj/item/ammo_magazine/handful))

/datum/storage/belt/shotgun/martini
	storage_slots = 12
	max_storage_space = 24
	sprite_slots = 6
	draw_mode = 1

/datum/storage/belt/knifepouch
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_TINY
	max_storage_space = 6
	draw_mode = TRUE

/datum/storage/belt/knifepouch/New(atom/parent)
	. = ..()
	set_holdable(list(/obj/item/stack/throwing_knife))

/datum/storage/belt/grenade
	storage_slots = 9
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 27

/datum/storage/belt/grenade/New(atom/parent)
	. = ..()
	set_holdable(list(/obj/item/explosive/grenade))

/datum/storage/belt/grenade/b17
	storage_slots = 16
	max_storage_space = 48

/datum/storage/belt/sparepouch
	storage_slots = null
	max_storage_space = 9
	max_w_class = WEIGHT_CLASS_NORMAL

/datum/storage/belt/protein_pack
	storage_slots = 20
	max_storage_space = 20
	max_w_class = WEIGHT_CLASS_TINY
	sprite_slots = 4

/datum/storage/belt/protein_pack/New(atom/parent)
	. = ..()
	set_holdable(list(/obj/item/reagent_containers/food/snacks/protein_pack))
