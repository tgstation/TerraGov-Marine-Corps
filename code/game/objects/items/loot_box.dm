/obj/item/loot_box
	name = "Loot box"
	desc = "A box of loot, what could be inside?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lootbox"
	item_state = "lootbox"
	///list of the lowest probability drops
	var/list/legendary_list
	///list of rare propability drops
	var/list/rare_list
	///list of uncommon drops
	var/list/uncommon_list
	///list of common drops
	var/list/common_list
	///the odds of each loot category being picked
	var/list/weight_list = list(legendary_list = 10, rare_list = 20, uncommon_list = 30, common_list = 40)
	///The number of rolls on the table this box has
	var/rolls = 1

/obj/item/loot_box/ex_act()
	qdel(src)

/obj/item/loot_box/attack_self(mob/user)
	var/obj/loot_pick
	while(rolls)
		switch(pickweight(weight_list))
			if("legendary_list")
				loot_pick = pick(legendary_list)
			if("rare_list")
				loot_pick = pick(rare_list)
			if("uncommon_list")
				loot_pick = pick(uncommon_list)
			if("common_list")
				loot_pick = pick(common_list)
		loot_pick = new loot_pick(get_turf(user))
		if(isitem(loot_pick))
			user.put_in_hands(loot_pick)
		if(!iseffect(loot_pick))
			user.visible_message("[user] pulled a [loot_pick.name] out of the [src]!")
		rolls --
	qdel(src)

/obj/item/loot_box/marine
	legendary_list = list(
		/obj/item/weapon/karambit,
		/obj/item/weapon/karambit/fade,
		/obj/item/weapon/karambit/case_hardened,
	)
	rare_list = list(
		/obj/vehicle/unmanned,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/weapon/gun/rifle/tx8,
		/obj/item/weapon/gun/minigun,
		/obj/item/weapon/gun/launcher/rocket/sadar,
		/obj/item/weapon/gun/rifle/railgun,
		/obj/item/weapon/gun/rifle/standard_autosniper,
		/obj/item/weapon/gun/shotgun/zx76,
		/obj/item/storage/belt/champion,
	)
	uncommon_list = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/storage/fancy/crayons,
		/obj/item/weapon/claymore,
		/obj/vehicle/ridden/motorbike,
		/obj/item/weapon/gun/launcher/rocket/oneuse,
		/obj/item/weapon/gun/rifle/m412l1_hpr,
		/obj/item/weapon/gun/shotgun/som,
		/obj/item/loot_box/marine, //reroll time
	)
	common_list = list(
		/obj/item/clothing/head/strawhat,
		/obj/item/storage/bag/trash,
		/obj/item/toy/bikehorn,
		/obj/item/clothing/tie/horrible,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/banhammer,
	)

//Supply drop boxes
/obj/item/loot_box/supply_drop
	name = "Supply drop"
	desc = "A box of valuable military equipment"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lootbox" //to change
	item_state = "lootbox"	//to change
	w_class = WEIGHT_CLASS_GIGANTIC
	rolls = 4

	legendary_list = list(
		/obj/item/weapon/karambit,
		/obj/item/weapon/karambit/fade,
		/obj/item/weapon/karambit/case_hardened,
		/obj/vehicle/ridden/motorbike,
	)
	rare_list = list(
		/obj/effect/supply_drop/heavy_armor,
		/obj/effect/supply_drop/grenadier,
		/obj/effect/supply_drop/minigun,
		/obj/effect/supply_drop/zx_shotgun,
	)
	uncommon_list = list(
		/obj/effect/supply_drop/marine_sentry,
		/obj/effect/supply_drop/recoilless_rifle,
		/obj/effect/supply_drop/scout,
		/obj/effect/supply_drop/oicw,
		/obj/item/storage/belt/lifesaver/quick,
		/obj/item/storage/belt/rig/medical,
		/obj/effect/supply_drop/mmg,
	)
	common_list = list(
		/obj/effect/supply_drop/armor_upgrades,
		/obj/effect/supply_drop/medical_basic,
		/obj/item/storage/pouch/firstaid/combat_patrol,
		/obj/item/storage/pouch/medical_injectors/firstaid,
		/obj/item/storage/pouch/medical_injectors/medic,
		/obj/effect/supply_drop/standard_carbine,
		/obj/effect/supply_drop/standard_rifle,
		/obj/effect/supply_drop/combat_rifle,
		/obj/effect/supply_drop/laser_rifle,
		/obj/effect/supply_drop/standard_shotgun,
	)


//put these somewhere else in a bit
/obj/effect/supply_drop/medical_basic/Initialize()
	. = ..()
	new /obj/item/storage/firstaid/adv(loc)
	new /obj/item/storage/firstaid/regular(loc)
	qdel(src)

/obj/effect/supply_drop/heavy_armor/Initialize()
	. = ..()
	new /obj/item/clothing/head/helmet/marine/specialist(loc)
	new /obj/item/clothing/gloves/marine/specialist(loc)
	new /obj/item/clothing/suit/storage/marine/specialist(loc)
	qdel(src)

/obj/effect/supply_drop/grenadier/Initialize()
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(loc)
	new /obj/item/storage/belt/grenade/b17(loc)
	new /obj/item/clothing/head/helmet/marine/grenadier(loc)
	new /obj/item/clothing/suit/storage/marine/B17(loc)
	qdel(src)

/obj/effect/supply_drop/minigun/Initialize()
	. = ..()
	new /obj/item/weapon/gun/minigun/magharness(loc)
	new /obj/item/ammo_magazine/minigun_powerpack(loc)
	qdel(src)

/obj/effect/supply_drop/zx_shotgun/Initialize()
	. = ..()
	new /obj/item/weapon/gun/shotgun/zx76/standard(loc)
	new /obj/item/storage/belt/shotgun/flechette(loc)
	qdel(src)

/obj/effect/supply_drop/marine_sentry/Initialize()
	. = ..()
	new /obj/item/weapon/gun/sentry/mini/combat_patrol(loc)
	new /obj/item/weapon/gun/sentry/mini/combat_patrol(loc)
	new /obj/item/ammo_magazine/minisentry(loc)
	new /obj/item/ammo_magazine/minisentry(loc)
	qdel(src)

/obj/effect/supply_drop/recoilless_rifle/Initialize()
	. = ..()
	new /obj/item/storage/holster/backholster/rpg/low_impact(loc)
	qdel(src)

/obj/effect/supply_drop/oicw/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/tx55/combat_patrol(loc)
	new /obj/item/storage/belt/marine/oicw(loc)
	qdel(src)

/obj/effect/supply_drop/scout/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/tx8/scout(loc)
	new /obj/item/storage/belt/marine/tx8(loc)
	qdel(src)

/obj/effect/supply_drop/armor_upgrades/Initialize()
	. = ..()
	new /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two(loc)
	new /obj/item/clothing/head/modular/marine/m10x/tyr(loc)
	new /obj/item/weapon/shield/riot/marine(loc)
	qdel(src)

/obj/effect/supply_drop/mmg/Initialize()
	. = ..()
	new /obj/item/weapon/gun/standard_mmg/machinegunner(loc)
	new /obj/item/ammo_magazine/standard_mmg(loc)
	new /obj/item/ammo_magazine/standard_mmg(loc)
	new /obj/item/ammo_magazine/standard_mmg(loc)
	new /obj/item/stack/sandbags/large_stack(loc)
	new /obj/item/stack/barbed_wire/full(loc)
	qdel(src)

/obj/effect/supply_drop/standard_carbine/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_carbine/scout(loc)
	new /obj/item/storage/belt/marine/t18(loc)
	qdel(src)

/obj/effect/supply_drop/standard_rifle/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman(loc)
	new /obj/item/storage/belt/marine/t12(loc)
	qdel(src)

/obj/effect/supply_drop/combat_rifle/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/tx11/standard(loc)
	new /obj/item/storage/belt/marine/combat_rifle(loc)
	qdel(src)

/obj/effect/supply_drop/laser_rifle/Initialize()
	. = ..()
	new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman(loc)
	new /obj/item/storage/belt/marine/te_cells(loc)
	qdel(src)

/obj/effect/supply_drop/standard_shotgun/Initialize()
	. = ..()
	new /obj/item/weapon/gun/shotgun/pump/t35/pointman(loc)
	new /obj/item/storage/belt/shotgun/mixed(loc)
	qdel(src)
