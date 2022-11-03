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

/obj/item/loot_box/ex_act()
	qdel(src)

/obj/item/loot_box/attack_self(mob/user)
	var/obj/loot_pick
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
	user.visible_message("[user] pulled a [loot_pick.name] out of the [src]!")
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

	legendary_list = list(
		/obj/item/weapon/karambit,
		/obj/item/weapon/karambit/fade,
		/obj/item/weapon/karambit/case_hardened,
		/obj/vehicle/ridden/motorbike,
	)
	rare_list = list(
		/obj/item/storage/box/supply_drop/heavy_armor,
		/obj/item/storage/box/supply_drop/grenadier,
		/obj/item/storage/box/supply_drop/minigun,
		/obj/item/storage/box/supply_drop/zx_shotgun,
	)
	uncommon_list = list(
		/obj/item/storage/box/supply_drop/marine_sentry,
		/obj/item/storage/box/supply_drop/recoilless_rifle,
		/obj/item/storage/box/supply_drop/oicw,
	)
	common_list = list(
		/obj/item/storage/box/supply_drop/armor_upgrades,
		/obj/item/storage/box/supply_drop/mmg,
		/obj/item/storage/box/supply_drop/scout,
	)


//put these somewhere else in a bit
/obj/item/storage/box/squadmarine/supply_drop //lots of place holder junk for now
	name = "\improper Demolitionist equipment crate"
	desc = "A large case containing light armor, a heavy-caliber antitank missile launcher, missiles, C4, detpacks, and claymore mines. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon_state = "rocket_case"
	storage_slots = 24

/obj/item/storage/box/supply_drop/Initialize(mapload, ...)
	. = ..()
	//add some default med stuff here

/obj/item/storage/box/supply_drop/heavy_armor/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/suit/storage/marine/specialist(src)

/obj/item/storage/box/supply_drop/grenadier/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/grenade_launcher/multinade_launcher(src)
	new /obj/item/storage/belt/grenade/b17(src)
	new /obj/item/clothing/head/helmet/marine/grenadier(src)
	new /obj/item/clothing/suit/storage/marine/B17(src)

/obj/item/storage/box/supply_drop/minigun/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/minigun/magharness(src)
	new /obj/item/weapon/gun/minigun/magharness(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)

/obj/item/storage/box/supply_drop/zx_shotgun/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/shotgun/zx76/standard(src)
	new /obj/item/weapon/gun/shotgun/zx76/standard(src)
	new /obj/item/storage/belt/shotgun/flechette(src)
	new /obj/item/storage/belt/shotgun/flechette(src)

/obj/item/storage/box/supply_drop/marine_sentry/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/sentry/mini/combat_patrol(src)
	new /obj/item/weapon/gun/sentry/mini/combat_patrol(src)
	new /obj/item/ammo_magazine/minisentry(src)
	new /obj/item/ammo_magazine/minisentry(src)

/obj/item/storage/box/supply_drop/recoilless_rifle/Initialize(mapload, ...)
	. = ..()
	new /obj/item/storage/holster/backholster/rpg/low_impact(src)

/obj/item/storage/box/supply_drop/oicw/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/rifle/tx55/combat_patrol(src)
	new /obj/item/weapon/gun/rifle/tx55/combat_patrol(src)
	new /obj/item/ammo_magazine/rifle/tx55(src)
	new /obj/item/ammo_magazine/rifle/tx55(src)
	new /obj/item/ammo_magazine/rifle/tx55(src)
	new /obj/item/ammo_magazine/rifle/tx55(src)
	new /obj/item/ammo_magazine/rifle/tx55(src)
	new /obj/item/ammo_magazine/rifle/tx55(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx54/incendiary(src)

/obj/item/storage/box/supply_drop/scout/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/rifle/tx8/scout(src)
	new /obj/item/weapon/gun/rifle/tx8/scout(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8(src)
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/impact(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)
	new /obj/item/ammo_magazine/rifle/tx8/incendiary(src)

/obj/item/storage/box/supply_drop/armor_upgrades/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two(src)
	new /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two(src)
	new /obj/item/clothing/head/modular/marine/m10x/tyr(src)
	new /obj/item/clothing/head/modular/marine/m10x/tyr(src)
	new /obj/item/weapon/shield/riot/marine(src)
	new /obj/item/weapon/shield/riot/marine(src)

/obj/item/storage/box/supply_drop/mmg/Initialize(mapload, ...)
	. = ..()
	new /obj/item/weapon/gun/standard_mmg/machinegunner(src)
	new /obj/item/weapon/gun/standard_mmg/machinegunner(src)
	new /obj/item/ammo_magazine/standard_mmg(src)
	new /obj/item/ammo_magazine/standard_mmg(src)
	new /obj/item/ammo_magazine/standard_mmg(src)
	new /obj/item/ammo_magazine/standard_mmg(src)
	new /obj/item/ammo_magazine/standard_mmg(src)
	new /obj/item/ammo_magazine/standard_mmg(src)
	new /obj/item/stack/sandbags/large_stack(src)
	new /obj/item/stack/sandbags/large_stack(src)
	new /obj/item/stack/barbed_wire/full(src)
