/obj/machinery/vending/weapon
	name = "\improper Automated Weapons Rack"
	desc = "A automated weapon rack hooked up to a colossal storage of standard-issue weapons."
	icon_state = "marinearmory"
	icon_vend = "marinearmory-vend"
	icon_deny = "marinearmory"
	wrenchable = FALSE
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	isshared = TRUE

	products = list(
		"Rifles" = list(
			/obj/item/weapon/gun/rifle/standard_assaultrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle = -1,
			/obj/item/weapon/gun/rifle/standard_carbine = -1,
			/obj/item/ammo_magazine/rifle/standard_carbine = -1,
			/obj/item/weapon/gun/rifle/standard_skirmishrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle = -1,
			/obj/item/weapon/gun/rifle/tx11 = -1,
			/obj/item/ammo_magazine/rifle/tx11 = -1,
			/obj/item/weapon/gun/shotgun/pump/lever/repeater = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
		),
		"Energy Weapons" = list(
			/obj/item/cell/lasgun/lasrifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla = 2,
		),
		"SMGs" = list(
			/obj/item/weapon/gun/smg/standard_smg = -1,
			/obj/item/ammo_magazine/smg/standard_smg = -1,
			/obj/item/weapon/gun/smg/standard_machinepistol = -1,
			/obj/item/ammo_magazine/smg/standard_machinepistol = -1,
		),
		"Marksman" = list(
			/obj/item/weapon/gun/rifle/standard_dmr = -1,
			/obj/item/ammo_magazine/rifle/standard_dmr = -1,
			/obj/item/weapon/gun/rifle/standard_br = -1,
			/obj/item/ammo_magazine/rifle/standard_br = -1,
			/obj/item/weapon/gun/rifle/chambered = -1,
			/obj/item/ammo_magazine/rifle/chamberedrifle = -1,
			/obj/item/weapon/gun/shotgun/pump/bolt = -1,
			/obj/item/ammo_magazine/rifle/bolt = -1,
			/obj/item/weapon/gun/shotgun/double/martini = -1,
			/obj/item/ammo_magazine/rifle/martini = -1,
		),
		"Shotgun" = list(
			/obj/item/weapon/gun/shotgun/pump/t35 = -1,
			/obj/item/weapon/gun/shotgun/combat/standardmarine = -1,
			/obj/item/weapon/gun/shotgun/double/marine = -1,
			/obj/item/storage/belt/gun/ts34/full = -1,
			/obj/item/ammo_magazine/shotgun = -1,
			/obj/item/ammo_magazine/shotgun/buckshot = -1,
			/obj/item/ammo_magazine/shotgun/flechette = -1,
			/obj/item/weapon/gun/rifle/standard_autoshotgun = -1,
			/obj/item/ammo_magazine/rifle/tx15_flechette = -1,
			/obj/item/ammo_magazine/rifle/tx15_slug = -1,
		),
		"Machinegun" = list(
			/obj/item/weapon/gun/rifle/standard_lmg = -1,
			/obj/item/ammo_magazine/standard_lmg = -1,
			/obj/item/weapon/gun/rifle/standard_gpmg = -1,
			/obj/item/ammo_magazine/standard_gpmg = -1,
			/obj/item/weapon/gun/standard_mmg = 5,
			/obj/item/ammo_magazine/standard_mmg = -1,
		),
		"Melee" = list(
			/obj/item/weapon/combat_knife = -1,
			/obj/item/attachable/bayonetknife = -1,
			/obj/item/stack/throwing_knife = -1,
			/obj/item/storage/belt/knifepouch = -1,
			/obj/item/storage/holster/blade/machete/full = -1,
			/obj/item/storage/holster/blade/machete/full_harvester = -1,
			/obj/item/weapon/twohanded/spear/tactical = -1,
			/obj/item/weapon/twohanded/spear/tactical/harvester = -1,
			/obj/item/weapon/powerfist = -1,
			/obj/item/weapon/shield/riot/marine = 6,
		),
		"Sidearm" = list(
			/obj/item/weapon/gun/pistol/standard_pistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pistol = -1,
			/obj/item/weapon/gun/pistol/standard_heavypistol = -1,
			/obj/item/ammo_magazine/pistol/standard_heavypistol = -1,
			/obj/item/weapon/gun/revolver/standard_revolver = -1,
			/obj/item/ammo_magazine/revolver/standard_revolver = -1,
			/obj/item/weapon/gun/pistol/standard_pocketpistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol = -1,
			/obj/item/weapon/gun/pistol/vp70 = -1,
			/obj/item/ammo_magazine/pistol/vp70 = -1,
			/obj/item/weapon/gun/pistol/plasma_pistol = -1,
			/obj/item/ammo_magazine/pistol/plasma_pistol = -1,
			/obj/item/weapon/gun/shotgun/double/derringer = 10,
			/obj/item/ammo_magazine/pistol/derringer = 15,
		),
		"Grenades" = list(
			/obj/item/weapon/gun/grenade_launcher/single_shot = -1,
			/obj/item/weapon/gun/grenade_launcher/multinade_launcher = -1,
			/obj/item/weapon/gun/rifle/tx54 = 2,
			/obj/item/ammo_magazine/rifle/tx54 = 10,
			/obj/item/ammo_magazine/rifle/tx54/incendiary = 4,
			/obj/item/explosive/grenade = 600,
			/obj/item/explosive/grenade/m15 = 30,
			/obj/item/explosive/grenade/sticky = 125,
			/obj/item/explosive/grenade/incendiary = 50,
			/obj/item/explosive/grenade/smokebomb/cloak = 25,
			/obj/item/explosive/grenade/smokebomb/drain = 10,
			/obj/item/explosive/grenade/mirage = 100,
			/obj/item/storage/box/m94 = 200,
			/obj/item/storage/box/m94/cas = 30,
		),
		"Specialized" = list(
			/obj/item/weapon/gun/rifle/pepperball = 4,
			/obj/item/ammo_magazine/rifle/pepperball = 40,
			/obj/item/weapon/gun/flamer/big_flamer/marinestandard = 4,
			/obj/item/ammo_magazine/flamer_tank/large = 30,
			/obj/item/ammo_magazine/flamer_tank/backtank = 4,
			/obj/item/storage/holster/backholster/rpg/full = 2,
			/obj/item/jetpack_marine = 3,
		),
		"Deployables" = list(
			/obj/structure/closet/crate/mortar_ammo/mortar_kit = 1,
			/obj/structure/closet/crate/mortar_ammo/howitzer_kit = 1,
			/obj/structure/largecrate/supply/weapons/standard_atgun = 1,
			/obj/item/weapon/gun/tl102 = 1,
			/obj/item/ammo_magazine/tl102 = 2,
			/obj/item/weapon/gun/heavymachinegun = 1,
			/obj/item/ammo_magazine/heavymachinegun = 10,
		),
		"Attachments" = list(
			/obj/item/attachable/bayonet = -1,
			/obj/item/attachable/compensator = -1,
			/obj/item/attachable/extended_barrel = -1,
			/obj/item/attachable/suppressor = -1,
			/obj/item/attachable/heavy_barrel = -1,
			/obj/item/attachable/lace = -1,
			/obj/item/attachable/flashlight = -1,
			/obj/item/attachable/magnetic_harness = -1,
			/obj/item/attachable/reddot = -1,
			/obj/item/attachable/motiondetector = -1,
			/obj/item/attachable/scope/marine = -1,
			/obj/item/attachable/scope/mini = -1,
			/obj/item/attachable/angledgrip = -1,
			/obj/item/attachable/verticalgrip = -1,
			/obj/item/attachable/bipod = -1,
			/obj/item/attachable/gyro = -1,
			/obj/item/attachable/lasersight = -1,
			/obj/item/attachable/burstfire_assembly = -1,
			/obj/item/weapon/gun/shotgun/combat/masterkey = -1,
			/obj/item/weapon/gun/grenade_launcher/underslung = -1,
			/obj/item/weapon/gun/flamer/mini_flamer = -1,
			/obj/item/ammo_magazine/flamer_tank/mini = -1,
			/obj/item/weapon/gun/rifle/pepperball/pepperball_mini = -1,
			/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini = -1,
			/obj/item/attachable/flamer_nozzle = -1,
			/obj/item/attachable/flamer_nozzle/wide = -1,
			/obj/item/attachable/flamer_nozzle/long = -1,
			/obj/item/attachable/stock/t19stock = -1,
			/obj/item/attachable/stock/t35stock = -1,
		),
		"Boxes" = list(
			/obj/item/ammo_magazine/packet/p9mm = -1,
			/obj/item/ammo_magazine/packet/acp = -1,
			/obj/item/ammo_magazine/packet/magnum = -1,
			/obj/item/ammo_magazine/packet/p10x20mm = -1,
			/obj/item/ammo_magazine/packet/p10x24mm = -1,
			/obj/item/ammo_magazine/packet/p10x25mm = -1,
			/obj/item/ammo_magazine/packet/p10x26mm = -1,
			/obj/item/ammo_magazine/packet/p10x265mm = -1,
			/obj/item/ammo_magazine/packet/p10x27mm = -1,
			/obj/item/ammo_magazine/packet/p492x34mm = -1,
			/obj/item/ammo_magazine/packet/p86x70mm = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
			/obj/item/storage/box/visual/magazine = -1,
			/obj/item/storage/box/visual/grenade = -1,
		),
		"Utility" = list(
			/obj/item/flashlight/combat = -1,
			/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine = -1,
			/obj/item/tool/shovel/etool = -1,
			/obj/item/tool/extinguisher = -1,
			/obj/item/tool/extinguisher/mini = -1,
			/obj/item/assembly/signaler = -1,
			/obj/item/binoculars = -1,
			/obj/item/compass = -1,
		),
	)

	seasonal_items = list(
		SEASONAL_GUNS = "Seasonal",
	)

/obj/machinery/vending/weapon/crash

products = list(
		"Rifles" = list(
			/obj/item/weapon/gun/rifle/standard_assaultrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle = -1,
			/obj/item/weapon/gun/rifle/standard_carbine = -1,
			/obj/item/ammo_magazine/rifle/standard_carbine = -1,
			/obj/item/weapon/gun/rifle/standard_skirmishrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle = -1,
			/obj/item/weapon/gun/rifle/tx11 = -1,
			/obj/item/ammo_magazine/rifle/tx11 = -1,
			/obj/item/weapon/gun/shotgun/pump/lever/repeater = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
		),
		"Energy Weapons" = list(
			/obj/item/cell/lasgun/lasrifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla = 2,
		),
		"SMGs" = list(
			/obj/item/weapon/gun/smg/standard_smg = -1,
			/obj/item/ammo_magazine/smg/standard_smg = -1,
			/obj/item/weapon/gun/smg/standard_machinepistol = -1,
			/obj/item/ammo_magazine/smg/standard_machinepistol = -1,
		),
		"Marksman" = list(
			/obj/item/weapon/gun/rifle/standard_dmr = -1,
			/obj/item/ammo_magazine/rifle/standard_dmr = -1,
			/obj/item/weapon/gun/rifle/standard_br = -1,
			/obj/item/ammo_magazine/rifle/standard_br = -1,
			/obj/item/weapon/gun/rifle/chambered = -1,
			/obj/item/ammo_magazine/rifle/chamberedrifle = -1,
			/obj/item/weapon/gun/shotgun/pump/bolt = -1,
			/obj/item/ammo_magazine/rifle/bolt = -1,
			/obj/item/weapon/gun/shotgun/double/martini = -1,
			/obj/item/ammo_magazine/rifle/martini = -1,
		),
		"Shotgun" = list(
			/obj/item/weapon/gun/shotgun/pump/t35 = -1,
			/obj/item/weapon/gun/shotgun/combat/standardmarine = -1,
			/obj/item/weapon/gun/shotgun/double/marine = -1,
			/obj/item/storage/belt/gun/ts34/full = -1,
			/obj/item/ammo_magazine/shotgun = -1,
			/obj/item/ammo_magazine/shotgun/buckshot = -1,
			/obj/item/ammo_magazine/shotgun/flechette = -1,
			/obj/item/weapon/gun/rifle/standard_autoshotgun = -1,
			/obj/item/ammo_magazine/rifle/tx15_flechette = -1,
			/obj/item/ammo_magazine/rifle/tx15_slug = -1,
		),
		"Machinegun" = list(
			/obj/item/weapon/gun/rifle/standard_lmg = -1,
			/obj/item/ammo_magazine/standard_lmg = -1,
			/obj/item/weapon/gun/rifle/standard_gpmg = -1,
			/obj/item/ammo_magazine/standard_gpmg = -1,
			/obj/item/weapon/gun/standard_mmg = 5,
			/obj/item/ammo_magazine/standard_mmg = -1,
		),
		"Melee" = list(
			/obj/item/weapon/combat_knife = -1,
			/obj/item/attachable/bayonetknife = -1,
			/obj/item/stack/throwing_knife = -1,
			/obj/item/storage/belt/knifepouch = -1,
			/obj/item/storage/holster/blade/machete/full = -1,
			/obj/item/storage/holster/blade/machete/full_harvester = -1,
			/obj/item/weapon/twohanded/spear/tactical = -1,
			/obj/item/weapon/twohanded/spear/tactical/harvester = -1,
			/obj/item/weapon/powerfist = -1,
			/obj/item/weapon/shield/riot/marine = 6,
		),
		"Sidearm" = list(
			/obj/item/weapon/gun/pistol/standard_pistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pistol = -1,
			/obj/item/weapon/gun/pistol/standard_heavypistol = -1,
			/obj/item/ammo_magazine/pistol/standard_heavypistol = -1,
			/obj/item/weapon/gun/revolver/standard_revolver = -1,
			/obj/item/ammo_magazine/revolver/standard_revolver = -1,
			/obj/item/weapon/gun/pistol/standard_pocketpistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol = -1,
			/obj/item/weapon/gun/pistol/vp70 = -1,
			/obj/item/ammo_magazine/pistol/vp70 = -1,
			/obj/item/weapon/gun/pistol/plasma_pistol = -1,
			/obj/item/ammo_magazine/pistol/plasma_pistol = -1,
			/obj/item/weapon/gun/shotgun/double/derringer = 10,
			/obj/item/ammo_magazine/pistol/derringer = 15,
		),
		"Grenades" = list(
			/obj/item/weapon/gun/grenade_launcher/single_shot = -1,
			/obj/item/weapon/gun/grenade_launcher/multinade_launcher = -1,
			/obj/item/explosive/grenade = 600,
			/obj/item/explosive/grenade/m15 = 30,
			/obj/item/explosive/grenade/sticky = 125,
			/obj/item/explosive/grenade/incendiary = 50,
			/obj/item/explosive/grenade/smokebomb/cloak = 25,
			/obj/item/explosive/grenade/smokebomb/drain = 10,
			/obj/item/explosive/grenade/mirage = 100,
			/obj/item/storage/box/m94 = 200,
			/obj/item/storage/box/m94/cas = 30,
		),
		"Specialized" = list(
			/obj/item/weapon/gun/rifle/pepperball = 4,
			/obj/item/ammo_magazine/rifle/pepperball = 40,
			/obj/item/weapon/gun/flamer/big_flamer/marinestandard = 4,
			/obj/item/ammo_magazine/flamer_tank/large = 30,
			/obj/item/ammo_magazine/flamer_tank/backtank = 4,
			/obj/item/jetpack_marine = 3,
		),
		"Attachments" = list(
			/obj/item/attachable/bayonet = -1,
			/obj/item/attachable/compensator = -1,
			/obj/item/attachable/extended_barrel = -1,
			/obj/item/attachable/suppressor = -1,
			/obj/item/attachable/heavy_barrel = -1,
			/obj/item/attachable/lace = -1,
			/obj/item/attachable/flashlight = -1,
			/obj/item/attachable/magnetic_harness = -1,
			/obj/item/attachable/reddot = -1,
			/obj/item/attachable/motiondetector = -1,
			/obj/item/attachable/scope/marine = -1,
			/obj/item/attachable/scope/mini = -1,
			/obj/item/attachable/angledgrip = -1,
			/obj/item/attachable/verticalgrip = -1,
			/obj/item/attachable/bipod = -1,
			/obj/item/attachable/gyro = -1,
			/obj/item/attachable/lasersight = -1,
			/obj/item/attachable/burstfire_assembly = -1,
			/obj/item/weapon/gun/shotgun/combat/masterkey = -1,
			/obj/item/weapon/gun/grenade_launcher/underslung = -1,
			/obj/item/weapon/gun/flamer/mini_flamer = -1,
			/obj/item/ammo_magazine/flamer_tank/mini = -1,
			/obj/item/weapon/gun/rifle/pepperball/pepperball_mini = -1,
			/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini = -1,
			/obj/item/attachable/flamer_nozzle = -1,
			/obj/item/attachable/flamer_nozzle/wide = -1,
			/obj/item/attachable/flamer_nozzle/long = -1,
			/obj/item/attachable/stock/t19stock = -1,
			/obj/item/attachable/stock/t35stock = -1,
		),
		"Boxes" = list(
			/obj/item/ammo_magazine/packet/p9mm = -1,
			/obj/item/ammo_magazine/packet/acp = -1,
			/obj/item/ammo_magazine/packet/magnum = -1,
			/obj/item/ammo_magazine/packet/p10x20mm = -1,
			/obj/item/ammo_magazine/packet/p10x24mm = -1,
			/obj/item/ammo_magazine/packet/p10x25mm = -1,
			/obj/item/ammo_magazine/packet/p10x26mm = -1,
			/obj/item/ammo_magazine/packet/p10x265mm = -1,
			/obj/item/ammo_magazine/packet/p10x27mm = -1,
			/obj/item/ammo_magazine/packet/p492x34mm = -1,
			/obj/item/ammo_magazine/packet/p86x70mm = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
			/obj/item/storage/box/visual/magazine = -1,
			/obj/item/storage/box/visual/grenade = -1,
		),
		"Utility" = list(
			/obj/item/flashlight/combat = -1,
			/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine = -1,
			/obj/item/tool/shovel/etool = -1,
			/obj/item/tool/extinguisher = -1,
			/obj/item/tool/extinguisher/mini = -1,
			/obj/item/assembly/signaler = -1,
			/obj/item/binoculars = -1,
			/obj/item/compass = -1,
		),
	)

	seasonal_items = list(
		SEASONAL_GUNS = "Seasonal",
	)

/obj/machinery/vending/weapon/hvh

products = list(
		"Rifles" = list(
			/obj/item/weapon/gun/rifle/standard_assaultrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle = -1,
			/obj/item/weapon/gun/rifle/standard_carbine = -1,
			/obj/item/ammo_magazine/rifle/standard_carbine = -1,
			/obj/item/weapon/gun/rifle/standard_skirmishrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle = -1,
			/obj/item/weapon/gun/rifle/tx11 = -1,
			/obj/item/ammo_magazine/rifle/tx11 = -1,
			/obj/item/weapon/gun/shotgun/pump/lever/repeater = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
		),
		"Energy Weapons" = list(
			/obj/item/cell/lasgun/lasrifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = -1,
		),
		"SMGs" = list(
			/obj/item/weapon/gun/smg/standard_smg = -1,
			/obj/item/ammo_magazine/smg/standard_smg = -1,
			/obj/item/weapon/gun/smg/standard_machinepistol = -1,
			/obj/item/ammo_magazine/smg/standard_machinepistol = -1,
		),
		"Marksman" = list(
			/obj/item/weapon/gun/rifle/standard_dmr = -1,
			/obj/item/ammo_magazine/rifle/standard_dmr = -1,
			/obj/item/weapon/gun/rifle/standard_br = -1,
			/obj/item/ammo_magazine/rifle/standard_br = -1,
			/obj/item/weapon/gun/rifle/chambered = -1,
			/obj/item/ammo_magazine/rifle/chamberedrifle = -1,
			/obj/item/weapon/gun/shotgun/pump/bolt = -1,
			/obj/item/ammo_magazine/rifle/bolt = -1,
			/obj/item/weapon/gun/shotgun/double/martini = -1,
			/obj/item/ammo_magazine/rifle/martini = -1,
		),
		"Shotgun" = list(
			/obj/item/weapon/gun/shotgun/pump/t35 = -1,
			/obj/item/weapon/gun/shotgun/combat/standardmarine = -1,
			/obj/item/weapon/gun/shotgun/double/marine = -1,
			/obj/item/storage/belt/gun/ts34/full = -1,
			/obj/item/ammo_magazine/shotgun = -1,
			/obj/item/ammo_magazine/shotgun/buckshot = -1,
			/obj/item/ammo_magazine/shotgun/flechette = -1,
			/obj/item/weapon/gun/rifle/standard_autoshotgun = -1,
			/obj/item/ammo_magazine/rifle/tx15_flechette = -1,
			/obj/item/ammo_magazine/rifle/tx15_slug = -1,
		),
		"Machinegun" = list(
			/obj/item/weapon/gun/rifle/standard_lmg = -1,
			/obj/item/ammo_magazine/standard_lmg = -1,
			/obj/item/weapon/gun/rifle/standard_gpmg = -1,
			/obj/item/ammo_magazine/standard_gpmg = -1,
			/obj/item/weapon/gun/standard_mmg = 5,
			/obj/item/ammo_magazine/standard_mmg = -1,
		),
		"Melee" = list(
			/obj/item/weapon/combat_knife = -1,
			/obj/item/attachable/bayonetknife = -1,
			/obj/item/stack/throwing_knife = -1,
			/obj/item/storage/belt/knifepouch = -1,
			/obj/item/storage/holster/blade/machete/full = -1,
			/obj/item/storage/holster/blade/machete/full_harvester = -1,
			/obj/item/weapon/twohanded/spear/tactical = -1,
			/obj/item/weapon/twohanded/spear/tactical/harvester = -1,
			/obj/item/weapon/powerfist = -1,
			/obj/item/weapon/shield/riot/marine = 6,
		),
		"Sidearm" = list(
			/obj/item/weapon/gun/pistol/standard_pistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pistol = -1,
			/obj/item/weapon/gun/pistol/standard_heavypistol = -1,
			/obj/item/ammo_magazine/pistol/standard_heavypistol = -1,
			/obj/item/weapon/gun/revolver/standard_revolver = -1,
			/obj/item/ammo_magazine/revolver/standard_revolver = -1,
			/obj/item/weapon/gun/pistol/standard_pocketpistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol = -1,
			/obj/item/weapon/gun/pistol/vp70 = -1,
			/obj/item/ammo_magazine/pistol/vp70 = -1,
			/obj/item/weapon/gun/pistol/plasma_pistol = -1,
			/obj/item/ammo_magazine/pistol/plasma_pistol = -1,
			/obj/item/weapon/gun/shotgun/double/derringer = 10,
			/obj/item/ammo_magazine/pistol/derringer = 15,
		),
		"Grenades" = list(
			/obj/item/weapon/gun/grenade_launcher/single_shot = -1,
			/obj/item/weapon/gun/grenade_launcher/multinade_launcher = -1,
			/obj/item/explosive/grenade = 600,
			/obj/item/explosive/grenade/m15 = 30,
			/obj/item/explosive/grenade/sticky = 125,
			/obj/item/explosive/grenade/incendiary = 50,
			/obj/item/explosive/grenade/smokebomb/cloak = 25,
			/obj/item/explosive/grenade/mirage = 100,
			/obj/item/storage/box/m94 = 200,
			/obj/item/storage/box/m94/cas = 30,
		),
		"Specialized" = list(
			/obj/item/weapon/gun/flamer/big_flamer/marinestandard = 4,
			/obj/item/ammo_magazine/flamer_tank/large = 30,
			/obj/item/ammo_magazine/flamer_tank/backtank = 4,
			/obj/item/jetpack_marine = 3,
		),
		"Attachments" = list(
			/obj/item/attachable/bayonet = -1,
			/obj/item/attachable/compensator = -1,
			/obj/item/attachable/extended_barrel = -1,
			/obj/item/attachable/suppressor = -1,
			/obj/item/attachable/heavy_barrel = -1,
			/obj/item/attachable/lace = -1,
			/obj/item/attachable/flashlight = -1,
			/obj/item/attachable/magnetic_harness = -1,
			/obj/item/attachable/reddot = -1,
			/obj/item/attachable/motiondetector = -1,
			/obj/item/attachable/scope/marine = -1,
			/obj/item/attachable/scope/mini = -1,
			/obj/item/attachable/angledgrip = -1,
			/obj/item/attachable/verticalgrip = -1,
			/obj/item/attachable/bipod = -1,
			/obj/item/attachable/gyro = -1,
			/obj/item/attachable/lasersight = -1,
			/obj/item/attachable/burstfire_assembly = -1,
			/obj/item/weapon/gun/shotgun/combat/masterkey = -1,
			/obj/item/weapon/gun/grenade_launcher/underslung = -1,
			/obj/item/weapon/gun/flamer/mini_flamer = -1,
			/obj/item/ammo_magazine/flamer_tank/mini = -1,
			/obj/item/attachable/flamer_nozzle = -1,
			/obj/item/attachable/flamer_nozzle/wide = -1,
			/obj/item/attachable/flamer_nozzle/long = -1,
			/obj/item/attachable/stock/t19stock = -1,
			/obj/item/attachable/stock/t35stock = -1,
		),
		"Boxes" = list(
			/obj/item/ammo_magazine/packet/p9mm = -1,
			/obj/item/ammo_magazine/packet/acp = -1,
			/obj/item/ammo_magazine/packet/magnum = -1,
			/obj/item/ammo_magazine/packet/p10x20mm = -1,
			/obj/item/ammo_magazine/packet/p10x24mm = -1,
			/obj/item/ammo_magazine/packet/p10x25mm = -1,
			/obj/item/ammo_magazine/packet/p10x26mm = -1,
			/obj/item/ammo_magazine/packet/p10x265mm = -1,
			/obj/item/ammo_magazine/packet/p10x27mm = -1,
			/obj/item/ammo_magazine/packet/p492x34mm = -1,
			/obj/item/ammo_magazine/packet/p86x70mm = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
			/obj/item/storage/box/visual/magazine = -1,
			/obj/item/storage/box/visual/grenade = -1,
		),
		"Utility" = list(
			/obj/item/flashlight/combat = -1,
			/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine = -1,
			/obj/item/tool/shovel/etool = -1,
			/obj/item/tool/extinguisher = -1,
			/obj/item/tool/extinguisher/mini = -1,
			/obj/item/assembly/signaler = -1,
			/obj/item/binoculars = -1,
			/obj/item/compass = -1,
		),
	)

	seasonal_items = list(
		SEASONAL_GUNS = "Seasonal",
	)

/obj/machinery/vending/weapon/hvh/team_one

/obj/machinery/vending/weapon/hvh/team_two

/obj/machinery/vending/weapon/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		"Rifles" = list(
			/obj/item/weapon/gun/rifle/standard_assaultrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle = -1,
			/obj/item/weapon/gun/rifle/standard_carbine = -1,
			/obj/item/ammo_magazine/rifle/standard_carbine = -1,
			/obj/item/weapon/gun/rifle/standard_skirmishrifle = -1,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle = -1,
			/obj/item/weapon/gun/rifle/tx11 = -1,
			/obj/item/ammo_magazine/rifle/tx11 = -1,
			/obj/item/weapon/gun/shotgun/pump/lever/repeater = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
		),
		"Energy Weapons" = list(
			/obj/item/cell/lasgun/lasrifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla = -1,
		),
		"SMGs" = list(
			/obj/item/weapon/gun/smg/standard_smg = -1,
			/obj/item/ammo_magazine/smg/standard_smg = -1,
			/obj/item/weapon/gun/smg/standard_machinepistol = -1,
			/obj/item/ammo_magazine/smg/standard_machinepistol = -1,
		),
		"Marksman" = list(
			/obj/item/weapon/gun/rifle/standard_dmr = -1,
			/obj/item/ammo_magazine/rifle/standard_dmr = -1,
			/obj/item/weapon/gun/rifle/standard_br = -1,
			/obj/item/ammo_magazine/rifle/standard_br = -1,
			/obj/item/weapon/gun/rifle/chambered = -1,
			/obj/item/ammo_magazine/rifle/chamberedrifle = -1,
			/obj/item/weapon/gun/shotgun/pump/bolt = -1,
			/obj/item/ammo_magazine/rifle/bolt = -1,
			/obj/item/weapon/gun/shotgun/double/martini = -1,
			/obj/item/ammo_magazine/rifle/martini = -1,
		),
		"Shotgun" = list(
			/obj/item/weapon/gun/shotgun/pump/t35 = -1,
			/obj/item/weapon/gun/shotgun/combat/standardmarine = -1,
			/obj/item/weapon/gun/shotgun/double/marine = -1,
			/obj/item/storage/belt/gun/ts34/full = -1,
			/obj/item/ammo_magazine/shotgun = -1,
			/obj/item/ammo_magazine/shotgun/buckshot = -1,
			/obj/item/ammo_magazine/shotgun/flechette = -1,
			/obj/item/weapon/gun/rifle/standard_autoshotgun = -1,
			/obj/item/ammo_magazine/rifle/tx15_flechette = -1,
			/obj/item/ammo_magazine/rifle/tx15_slug = -1,
		),
		"Machinegun" = list(
			/obj/item/weapon/gun/rifle/standard_lmg = -1,
			/obj/item/ammo_magazine/standard_lmg = -1,
			/obj/item/weapon/gun/rifle/standard_gpmg = -1,
			/obj/item/ammo_magazine/standard_gpmg = -1,
			/obj/item/weapon/gun/standard_mmg = -1,
			/obj/item/ammo_magazine/standard_mmg = -1,
		),
		"Melee" = list(
			/obj/item/weapon/combat_knife = -1,
			/obj/item/attachable/bayonetknife = -1,
			/obj/item/stack/throwing_knife = -1,
			/obj/item/storage/belt/knifepouch = -1,
			/obj/item/storage/holster/blade/machete/full = -1,
			/obj/item/storage/holster/blade/machete/full_harvester = -1,
			/obj/item/weapon/twohanded/spear/tactical = -1,
			/obj/item/weapon/twohanded/spear/tactical/harvester = -1,
			/obj/item/weapon/powerfist = -1,
			/obj/item/weapon/shield/riot/marine = -1,
		),
		"Sidearm" = list(
			/obj/item/weapon/gun/pistol/standard_pistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pistol = -1,
			/obj/item/weapon/gun/pistol/standard_heavypistol = -1,
			/obj/item/ammo_magazine/pistol/standard_heavypistol = -1,
			/obj/item/weapon/gun/revolver/standard_revolver = -1,
			/obj/item/ammo_magazine/revolver/standard_revolver = -1,
			/obj/item/weapon/gun/pistol/standard_pocketpistol = -1,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol = -1,
			/obj/item/weapon/gun/pistol/vp70 = -1,
			/obj/item/ammo_magazine/pistol/vp70 = -1,
			/obj/item/weapon/gun/pistol/plasma_pistol = -1,
			/obj/item/ammo_magazine/pistol/plasma_pistol = -1,
			/obj/item/weapon/gun/shotgun/double/derringer = -1,
			/obj/item/ammo_magazine/pistol/derringer = -1,
		),
		"Grenades" = list(
			/obj/item/weapon/gun/grenade_launcher/single_shot = -1,
			/obj/item/weapon/gun/grenade_launcher/multinade_launcher = -1,
			/obj/item/weapon/gun/rifle/tx54 = -1,
			/obj/item/ammo_magazine/rifle/tx54 = -1,
			/obj/item/ammo_magazine/rifle/tx54/incendiary = -1,
			/obj/item/explosive/grenade = -1,
			/obj/item/explosive/grenade/m15 = -1,
			/obj/item/explosive/grenade/sticky = -1,
			/obj/item/explosive/grenade/incendiary = -1,
			/obj/item/explosive/grenade/smokebomb/cloak = -1,
			/obj/item/explosive/grenade/smokebomb/drain = -1,
			/obj/item/explosive/grenade/mirage = -1,
			/obj/item/storage/box/m94 = -1,
			/obj/item/storage/box/m94/cas = -1,
		),
		"Specialized" = list(
			/obj/item/weapon/gun/rifle/pepperball = -1,
			/obj/item/ammo_magazine/rifle/pepperball = -1,
			/obj/item/weapon/gun/flamer/big_flamer/marinestandard = -1,
			/obj/item/ammo_magazine/flamer_tank/large = -1,
			/obj/item/ammo_magazine/flamer_tank/backtank = -1,
			/obj/item/storage/holster/backholster/rpg/full = -1,
			/obj/item/jetpack_marine = -1,
		),
		"Deployables" = list(
			/obj/structure/closet/crate/mortar_ammo/mortar_kit = -1,
			/obj/structure/closet/crate/mortar_ammo/howitzer_kit = -1,
			/obj/structure/largecrate/supply/weapons/standard_atgun = -1,
			/obj/item/weapon/gun/tl102 = -1,
			/obj/item/ammo_magazine/tl102 = -1,
			/obj/item/weapon/gun/heavymachinegun = -1,
			/obj/item/ammo_magazine/heavymachinegun = -1,
		),
		"Attachments" = list(
			/obj/item/attachable/bayonet = -1,
			/obj/item/attachable/compensator = -1,
			/obj/item/attachable/extended_barrel = -1,
			/obj/item/attachable/suppressor = -1,
			/obj/item/attachable/heavy_barrel = -1,
			/obj/item/attachable/lace = -1,
			/obj/item/attachable/flashlight = -1,
			/obj/item/attachable/magnetic_harness = -1,
			/obj/item/attachable/reddot = -1,
			/obj/item/attachable/motiondetector = -1,
			/obj/item/attachable/scope/marine = -1,
			/obj/item/attachable/scope/mini = -1,
			/obj/item/attachable/angledgrip = -1,
			/obj/item/attachable/verticalgrip = -1,
			/obj/item/attachable/bipod = -1,
			/obj/item/attachable/gyro = -1,
			/obj/item/attachable/lasersight = -1,
			/obj/item/attachable/burstfire_assembly = -1,
			/obj/item/weapon/gun/shotgun/combat/masterkey = -1,
			/obj/item/weapon/gun/grenade_launcher/underslung = -1,
			/obj/item/weapon/gun/flamer/mini_flamer = -1,
			/obj/item/ammo_magazine/flamer_tank/mini = -1,
			/obj/item/weapon/gun/rifle/pepperball/pepperball_mini = -1,
			/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini = -1,
			/obj/item/attachable/flamer_nozzle = -1,
			/obj/item/attachable/flamer_nozzle/wide = -1,
			/obj/item/attachable/flamer_nozzle/long = -1,
			/obj/item/attachable/stock/t19stock = -1,
			/obj/item/attachable/stock/t35stock = -1,
		),
		"Boxes" = list(
			/obj/item/ammo_magazine/packet/p9mm = -1,
			/obj/item/ammo_magazine/packet/acp = -1,
			/obj/item/ammo_magazine/packet/magnum = -1,
			/obj/item/ammo_magazine/packet/p10x20mm = -1,
			/obj/item/ammo_magazine/packet/p10x24mm = -1,
			/obj/item/ammo_magazine/packet/p10x25mm = -1,
			/obj/item/ammo_magazine/packet/p10x26mm = -1,
			/obj/item/ammo_magazine/packet/p10x265mm = -1,
			/obj/item/ammo_magazine/packet/p10x27mm = -1,
			/obj/item/ammo_magazine/packet/p492x34mm = -1,
			/obj/item/ammo_magazine/packet/p86x70mm = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
			/obj/item/storage/box/visual/magazine = -1,
			/obj/item/storage/box/visual/grenade = -1,
		),
		"Utility" = list(
			/obj/item/flashlight/combat = -1,
			/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine = -1,
			/obj/item/tool/shovel/etool = -1,
			/obj/item/tool/extinguisher = -1,
			/obj/item/tool/extinguisher/mini = -1,
			/obj/item/assembly/signaler = -1,
			/obj/item/binoculars = -1,
			/obj/item/compass = -1,
		),
	)

/obj/machinery/vending/cigarette
	name = "cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "A specialized vending machine designed to contribute to your slow and uncomfortable death."
	product_slogans = "There's no better time to start smokin'.;\
		Smoke now, and win the adoration of your peers.;\
		They beat cancer centuries ago, so smoke away.;\
		If you're not smoking, you must be joking."
	product_ads = "Probably not bad for you!;\
		Don't believe the scientists!;\
		It's good for you!;\
		Don't quit, buy more!;\
		Smoke!;\
		Nicotine heaven.;\
		Best cigarettes since 2150.;\
		Don't be so hard on yourself, kid. Smoke a Lucky Star!;\
		Professionals. Better cigarettes for better people. Yes, better people."
	vend_delay = 14
	icon_state = "cigs"
	icon_vend = null
	icon_deny = null
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		/obj/item/storage/fancy/cigarettes/luckystars = -1,
		/obj/item/storage/fancy/chemrettes = -1,
		/obj/item/storage/box/matches = -1,
		/obj/item/tool/lighter/random = -1,
		/obj/item/tool/lighter/zippo = -1,
		/obj/item/clothing/mask/cigarette/cigar/havana = 5
	)

	premium = list(/obj/item/storage/fancy/cigar = 25)
	seasonal_items = list()

/obj/machinery/vending/cigarette/colony
	product_slogans = "Koorlander Gold, for the refined palate.;Lady Fingers, for the dainty smoker.;Lady Fingers, treat your palete with pink!;The big blue K means a cool fresh day!;For the taste that cools your mood, look for the big blue K!;Refined smokers go for Gold!;Lady Fingers are preferred by women who appreciate a cool smoke.;Lady Fingers are the number one cigarette this side of Gateway!;The tobacco connoisseur prefers Koorlander Gold.;For the cool, filtered feel, Lady Finger Cigarettes provide the smoothest draw of any cigarette on the market.;For the man who knows his place is at the top, Koorlander Gold shows the world that you're the best and no-one can say otherwise.;The Colonial Administration Bureau would like to remind you that smoking kills."
	product_ads = "For the taste that cools your mood, look for the big blue K!;Refined smokers go for Gold!;Lady Fingers are preferred by women who appreciate a cool smoke.;Lady Fingers are the number one cigarette this side of Gateway!;The tobacco connoisseur prefers Koorlander Gold.;For the cool, filtered feel, Lady Finger Cigarettes provide the smoothest draw of any cigarette on the market.;For the man who knows his place is at the top, Koorlander Gold shows the world that you're the best and no-one can say otherwise.;The Colonial Administration Bureau would like to remind you that smoking kills."
	products = list(
		/obj/item/storage/fancy/cigarettes/kpack = 15,
		/obj/item/storage/fancy/cigarettes/lady_finger = 15,
		/obj/item/storage/box/matches = 10,
		/obj/item/tool/lighter/random = 20,
	)

/obj/machinery/vending/cigarette/nopower
	use_power = NO_POWER_USE

/obj/machinery/vending/cargo_supply
	name = "\improper Operational Supplies Vendor"
	desc = "A large vendor for dispensing specialty and bulk supplies. Restricted to cargo personnel only."
	icon_state = "requisitionop"
	icon_vend = "requisitionop-vend"
	icon_deny = "requisitionop-deny"
	wrenchable = FALSE
	req_one_access = list(ACCESS_MARINE_CARGO, ACCESS_MARINE_LOGISTICS)
	products = list(
		"Surplus Special Equipment" = list(
			/obj/item/beacon/supply_beacon = 1,
			/obj/item/ammo_magazine/rifle/autosniper = 3,
			/obj/item/ammo_magazine/rifle/tx8 = 3,
			/obj/item/ammo_magazine/rocket/sadar = 3,
			/obj/item/ammo_magazine/minigun_powerpack = 2,
			/obj/item/ammo_magazine/shotgun/mbx900 = 2,
			/obj/item/bodybag/tarp = 2,
			/obj/item/explosive/plastique = 5,
			/obj/item/fulton_extraction_pack = 2,
			/obj/item/clothing/suit/storage/marine/harness/boomvest = 20,
			/obj/item/radio/headset/mainship/marine/alpha = -1,
			/obj/item/radio/headset/mainship/marine/bravo = -1,
			/obj/item/radio/headset/mainship/marine/charlie = -1,
			/obj/item/radio/headset/mainship/marine/delta = -1,
		),
		"Mining Equipment" = list(
			/obj/item/minerupgrade/automatic = 1,
			/obj/item/minerupgrade/reinforcement = 1,
			/obj/item/minerupgrade/overclock = 1,
		),
		"Reqtorio Basics" = list(
			/obj/item/paper/factoryhowto = -1,
			/obj/machinery/factory/cutter = 1,
			/obj/machinery/factory/heater = 1,
			/obj/machinery/factory/flatter = 1,
			/obj/machinery/factory/former = 1,
			/obj/machinery/factory/reconstructor = 1,
			/obj/machinery/outputter = 1,
		),
		"Grenade Boxes" = list(
			/obj/item/storage/box/visual/grenade/frag = 2,
			/obj/item/storage/box/visual/grenade/incendiary = 2,
			/obj/item/storage/box/visual/grenade/M15 = 2,
			/obj/item/storage/box/visual/grenade/cloak = 1,
		),
		"Ammo Boxes" = list(
			/obj/item/big_ammo_box = 1,
			/obj/item/shotgunbox = 1,
			/obj/item/shotgunbox/buckshot = 1,
			/obj/item/shotgunbox/flechette = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_pistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_heavypistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_revolver/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_pocketpistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/vp70/full = 1,
			/obj/item/storage/box/visual/magazine/compact/plasma_pistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_smg/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_machinepistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_assaultrifle/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_carbine/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_skirmishrifle/full = 1,
			/obj/item/storage/box/visual/magazine/compact/martini/full = 1,
			/obj/item/storage/box/visual/magazine/compact/tx11/full = 1,
			/obj/item/storage/box/visual/magazine/compact/lasrifle/marine/full = 1,
			/obj/item/storage/box/visual/magazine/compact/tx15/flechette/full = 1,
			/obj/item/storage/box/visual/magazine/compact/tx15/slug/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_dmr/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_br/full = 1,
			/obj/item/storage/box/visual/magazine/compact/chamberedrifle/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_lmg/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_gpmg/full = 1,
		)
	)

/obj/machinery/vending/cargo_supply/hvh
	products = list(
		"Surplus Special Equipment" = list(
			/obj/item/bodybag/tarp = 2,
			/obj/item/explosive/plastique = 5,
			/obj/item/minerupgrade/automatic = 3,
			/obj/item/radio/headset/mainship/marine/alpha = -1,
			/obj/item/radio/headset/mainship/marine/bravo = -1,
			/obj/item/radio/headset/mainship/marine/charlie = -1,
			/obj/item/radio/headset/mainship/marine/delta = -1,
		),
		"Grenade Boxes" = list(
			/obj/item/storage/box/visual/grenade/frag = 2,
			/obj/item/storage/box/visual/grenade/incendiary = 2,
			/obj/item/storage/box/visual/grenade/M15 = 2,
			/obj/item/storage/box/visual/grenade/drain = 1,
			/obj/item/storage/box/visual/grenade/cloak = 1,
		),
		"Ammo Boxes" = list(
			/obj/item/big_ammo_box = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_pistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_heavypistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_pocketpistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/vp70/full = 1,
			/obj/item/storage/box/visual/magazine/compact/plasma_pistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_smg/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_machinepistol/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_assaultrifle/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_carbine/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_skirmishrifle/full = 1,
			/obj/item/storage/box/visual/magazine/compact/tx11/full = 1,
			/obj/item/storage/box/visual/magazine/compact/lasrifle/marine/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_dmr/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_br/full = 1,
			/obj/item/storage/box/visual/magazine/compact/chamberedrifle/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_lmg/full = 1,
			/obj/item/storage/box/visual/magazine/compact/standard_gpmg/full = 1,
		)
	)

/obj/machinery/vending/cargo_supply/hvh/rebel
	req_one_access = list(ACCESS_MARINE_CARGO_REBEL, ACCESS_MARINE_LOGISTICS_REBEL)

/obj/machinery/vending/lasgun
	name = "\improper Terra Experimental cell field charger"
	desc = "An automated power cell dispenser and charger. Used to recharge energy weapon power cells, including in the field. Has an internal battery that charges off the power grid when wrenched down."
	icon_state = "lascharger"
	icon_vend = "lascharger-vend"
	icon_deny = "lascharger-denied"
	wrenchable = TRUE
	drag_delay = FALSE
	anchored = FALSE
	idle_power_usage = 1
	active_power_usage = 50
	machine_current_charge = 50000 //integrated battery for recharging energy weapons. Normally 10000.
	machine_max_charge = 50000

	product_ads = "Power cell running low? Recharge here!;Need a charge?;Power up!;Electrifying!;Empower yourself!"
	products = list(
		/obj/item/cell/lasgun/lasrifle = 10,
	)


	prices = list()

/obj/machinery/vending/lasgun/Initialize()
	. = ..()
	update_icon()

/obj/machinery/vending/lasgun/update_icon()
	if(machine_max_charge)
		switch(machine_current_charge / max(1,machine_max_charge))
			if(0)
				icon_state = "lascharger-off"
			if(1 to 0.76)
				icon_state = "lascharger"
			if(0.75 to 0.51)
				icon_state = "lascharger_75"
			if(0.50 to 0.26)
				icon_state = "lascharger_50"
			if(0.25 to 0.01)
				icon_state = "lascharger_25"

/obj/machinery/vending/lasgun/examine(mob/user)
	. = ..()
	. += "<b>It has [machine_current_charge] of [machine_max_charge] charge remaining.</b>"


/obj/machinery/vending/lasgun/MouseDrop_T(atom/movable/A, mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(user.stat || user.restrained() || user.lying_angle)
		return

	if(get_dist(user, src) > 1 || get_dist(src, A) > 1)
		return

	var/obj/item/I = A
	if(istype(I, /obj/item/cell/lasgun))
		stock(I, user, TRUE)
	else
		stock(I, user)

/obj/machinery/vending/lasgun/stock(obj/item/item_to_stock, mob/user, recharge = FALSE)
	//More accurate comparison between absolute paths.
	for(var/datum/vending_product/R AS in (product_records + coin_records ))
		if(item_to_stock.type == R.product_path && !istype(item_to_stock,/obj/item/storage)) //Nice try, specialists/engis
			if(istype(item_to_stock, /obj/item/cell/lasgun) && recharge)
				if(!recharge_lasguncell(item_to_stock, user))
					return //Can't recharge so cancel out

			if(item_to_stock.loc == user) //Inside the mob's inventory
				if(item_to_stock.flags_item & WIELDED)
					item_to_stock.unwield(user)
				user.temporarilyRemoveItemFromInventory(item_to_stock)

			if(istype(item_to_stock.loc, /obj/item/storage)) //inside a storage item
				var/obj/item/storage/S = item_to_stock.loc
				S.remove_from_storage(item_to_stock, user.loc, user)

			qdel(item_to_stock)
			if(!recharge)
				user.visible_message(span_notice("[user] stocks [src] with \a [R.product_name]."),
				span_notice("You stock [src] with \a [R.product_name]."))
			R.amount++
			updateUsrDialog()
			break //We found our item, no reason to go on.

/obj/machinery/vending/lasgun/proc/recharge_lasguncell(obj/item/cell/lasgun/A, mob/user)
	var/recharge_cost = (A.maxcharge - A.charge)
	if(recharge_cost > machine_current_charge)
		to_chat(user, span_warning("[A] cannot be recharged; [src] has inadequate charge remaining: [machine_current_charge] of [machine_max_charge]."))
		return FALSE
	else
		to_chat(user, span_warning("You insert [A] into [src] to be recharged."))
		if(icon_vend)
			flick(icon_vend,src)
		playsound(loc, 'sound/machines/hydraulics_1.ogg', 25, 0, 1)
		machine_current_charge -= min(machine_current_charge, recharge_cost)
		to_chat(user, span_notice("This dispenser has [machine_current_charge] of [machine_max_charge] remaining."))
		update_icon()
		return TRUE


/obj/machinery/vending/marineFood
	name = "\improper Marine Food and Drinks Vendor"
	desc = "Standard Issue Food and Drinks Vendor, containing standard military food and drinks."
	icon_state = "sustenance"
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		/obj/item/reagent_containers/food/snacks/protein_pack = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal1 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal2 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal3 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal4 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal5 = -1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal6 = -1,
		/obj/item/storage/box/MRE = -1,
		/obj/item/reagent_containers/food/drinks/flask/marine = -1,
	)
//Christmas inventory
/*
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas1 = 25,
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas2 = 25,
					/obj/item/reagent_containers/food/snacks/mre_pack/xmas3 = 25)*/
	vend_delay = 15
	//product_slogans = "Standard Issue Marine food!;It's good for you, and not the worst thing in the world.;Just fucking eat it.;"
	product_ads = "Try the cornbread.;Try the pizza.;Try the pasta.;Try the tofu, wimp.;Try the pork.; 9 Flavors of Protein!; You'll never guess the mystery flavor!"


/obj/machinery/vending/MarineMed
	name = "\improper MarineMed"
	desc = "Marine Medical drug dispenser - Provided by Nanotrasen Pharmaceuticals Division(TM)."
	icon_state = "marinemed"
	icon_deny = "marinemed-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;All natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_one_access = ALL_MARINE_ACCESS
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		"Pill Packet" = list(
			/obj/item/storage/pill_bottle/packet/bicaridine = -1,
			/obj/item/storage/pill_bottle/packet/kelotane = -1,
			/obj/item/storage/pill_bottle/packet/tramadol = -1,
			/obj/item/storage/pill_bottle/packet/tricordrazine = -1,
			/obj/item/storage/pill_bottle/packet/dylovene = -1,
		),
		"Auto Injector" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 30,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/alkysine = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/imidazoline = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 30,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 0,
		),
		"Heal Pack" = list(
			/obj/item/stack/medical/heal_pack/gauze = -1,
			/obj/item/stack/medical/heal_pack/ointment = -1,
			/obj/item/stack/medical/splint = -1,
			/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 50,
			/obj/item/stack/medical/heal_pack/advanced/burn_pack = 50,
		),
		"Misc" = list(
			/obj/item/defibrillator = 8,
			/obj/item/healthanalyzer = 16,
			/obj/item/bodybag/cryobag = 24,
		),
	)

/obj/machinery/vending/MarineMed/rebel
	req_one_access = ALL_MARINE_REBEL_ACCESS

/obj/machinery/vending/MarineMed/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		"Pill Packet" = list(
			/obj/item/storage/pill_bottle/packet/bicaridine = -1,
			/obj/item/storage/pill_bottle/packet/kelotane = -1,
			/obj/item/storage/pill_bottle/packet/tramadol = -1,
			/obj/item/storage/pill_bottle/packet/tricordrazine = -1,
			/obj/item/storage/pill_bottle/packet/dylovene = -1,
		),
		"Auto Injector" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/alkysine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/imidazoline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/virilyth = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/roulettium = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/rezadone = -1,
		),
		"Heal Pack" = list(
			/obj/item/stack/medical/heal_pack/gauze = -1,
			/obj/item/stack/medical/heal_pack/ointment = -1,
			/obj/item/stack/medical/heal_pack/advanced/bruise_pack = -1,
			/obj/item/stack/medical/heal_pack/advanced/burn_pack = -1,
			/obj/item/stack/medical/splint = -1,
		),
		"Misc" = list(
			/obj/item/healthanalyzer = -1,
			/obj/item/bodybag/cryobag = -1,
		),
	)

/obj/machinery/vending/MarineMed/Blood
	name = "\improper MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack dispensery."
	icon_state = "bloodvendor"
	icon_deny = "bloodvendor-deny"
	product_ads = "The best blood on the market!"
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP)
	products = list(
		/obj/item/reagent_containers/blood/APlus = 5,
		/obj/item/reagent_containers/blood/AMinus = 5,
		/obj/item/reagent_containers/blood/BPlus = 5,
		/obj/item/reagent_containers/blood/BMinus = 5,
		/obj/item/reagent_containers/blood/OPlus = 5,
		/obj/item/reagent_containers/blood/OMinus = 5,
		/obj/item/reagent_containers/blood/empty = 10,
	)

/obj/machinery/vending/MarineMed/Blood/rebel
	req_one_access = list(ACCESS_MARINE_MEDBAY_REBEL, ACCESS_MARINE_CHEMISTRY_REBEL)

/obj/machinery/vending/MarineMed/Blood/build_inventory(list/productlist, category)
	. = ..()
	var/temp_list[] = productlist
	var/obj/item/reagent_containers/blood/temp_path
	var/blood_type
	for(var/datum/vending_product/R AS in (product_records + coin_records))
		if(R.product_path in temp_list)
			temp_path = R.product_path
			blood_type = initial(temp_path.blood_type)
			R.product_name += blood_type? " [blood_type]" : ""
			temp_list -= R.product_path
			if(!temp_list.len) break

/obj/machinery/vending/marine_medic
	name = "\improper TerraGovTech Medic Vendor"
	desc = "A marine medic equipment vendor"
	product_ads = "They were gonna die anyway.;Let's get space drugged!"
	req_access = list(ACCESS_MARINE_MEDPREP)
	icon_state = "corpsmanvendor"
	icon_deny = "corpsmanvendor-deny"
	wrenchable = FALSE

	products = list(
		/obj/item/clothing/under/marine/corpsman = 4,
		/obj/item/clothing/head/modular/marine/m10x = 4,
		/obj/item/storage/backpack/marine/corpsman = 4,
		/obj/item/storage/backpack/marine/satchel/corpsman = 4,
		/obj/item/encryptionkey/med = 4,
		/obj/item/bodybag/cryobag = 4,
		/obj/item/healthanalyzer = 4,
		/obj/item/clothing/glasses/hud/health = 4,
		/obj/item/storage/firstaid/regular = 4,
		/obj/item/storage/firstaid/adv = 8,
		/obj/item/storage/pouch/magazine/large = 4,
		/obj/item/storage/pouch/magazine/pistol/large = 4,
		/obj/item/clothing/mask/gas = 4,
		/obj/item/storage/pouch/pistol = 4,
	)

/obj/machinery/vending/marine_medic/rebel
	req_access = list(ACCESS_MARINE_MEDPREP_REBEL)

/obj/machinery/vending/armor_supply
	name = "\improper Surplus Armor Equipment Vendor"
	desc = "Am automated equipment rack hooked up to a colossal storage of armor and accessories. Nanotrasen designed a new vendor that utilize bluespace technology to send surplus equipment from outer colonies' sweatshops to your hands! Be grateful."
	icon_state = "surplus_armor"
	icon_vend = "surplus-vend"
	icon_deny = "surplus-deny"
	isshared = TRUE
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
		"Armors" = list(
			/obj/item/clothing/suit/modular/xenonauten/light = -1,
			/obj/item/clothing/suit/modular/xenonauten = -1,
			/obj/item/clothing/suit/modular/xenonauten/heavy = -1,
			/obj/item/clothing/suit/modular = -1,
			/obj/item/clothing/suit/storage/marine/harness = -1,
			/obj/item/clothing/suit/storage/marine/harness/cowboy = -1,
			/obj/item/clothing/suit/storage/marine/cowboy = -1,
			/obj/item/clothing/suit/modular/xenonauten/pilot = -1,
			/obj/item/facepaint/green = -1,
			/obj/item/clothing/suit/storage/marine/robot/light = -1,
			/obj/item/clothing/suit/storage/marine/robot = -1,
			/obj/item/clothing/suit/storage/marine/robot/heavy = -1,
		),
		"Helmets" = list(
			/obj/item/clothing/head/modular/marine/m10x = -1,
			/obj/item/clothing/head/modular/marine/m10x/heavy = -1,
			/obj/item/clothing/head/modular/marine/skirmisher = -1,
			/obj/item/clothing/head/modular/marine = -1,
			/obj/item/clothing/head/modular/marine/eva = -1,
			/obj/item/clothing/head/modular/marine/eva/skull = -1,
			/obj/item/clothing/head/modular/marine/assault = -1,
			/obj/item/clothing/head/modular/marine/eod = -1,
			/obj/item/clothing/head/modular/marine/scout = -1,
			/obj/item/clothing/head/modular/marine/infantry = -1,
			/obj/item/clothing/head/modular/marine/helljumper = -1,
			/obj/item/clothing/head/helmet/marine/robot/light = -1,
			/obj/item/clothing/head/helmet/marine/robot = -1,
			/obj/item/clothing/head/helmet/marine/robot/heavy = -1,
		),
		"Jaeger chestpieces" = list(
			/obj/item/armor_module/armor/chest/marine/skirmisher = -1,
			/obj/item/armor_module/armor/chest/marine/skirmisher/scout = -1,
			/obj/item/armor_module/armor/chest/marine = -1,
			/obj/item/armor_module/armor/chest/marine/eva = -1,
			/obj/item/armor_module/armor/chest/marine/assault = -1,
			/obj/item/armor_module/armor/chest/marine/assault/eod = -1,
			/obj/item/armor_module/armor/chest/marine/helljumper = -1,
		),
		"Jaeger armpiece" = list(
			/obj/item/armor_module/armor/arms/marine/skirmisher = -1,
			/obj/item/armor_module/armor/arms/marine/scout = -1,
			/obj/item/armor_module/armor/arms/marine = -1,
			/obj/item/armor_module/armor/arms/marine/eva = -1,
			/obj/item/armor_module/armor/arms/marine/assault = -1,
			/obj/item/armor_module/armor/arms/marine/eod = -1,
			/obj/item/armor_module/armor/arms/marine/helljumper = -1,
		),
		"Jaeger legpiece" = list(
			/obj/item/armor_module/armor/legs/marine/skirmisher = -1,
			/obj/item/armor_module/armor/legs/marine/scout = -1,
			/obj/item/armor_module/armor/legs/marine = -1,
			/obj/item/armor_module/armor/legs/marine/eva = -1,
			/obj/item/armor_module/armor/legs/marine/assault = -1,
			/obj/item/armor_module/armor/legs/marine/eod = -1,
			/obj/item/armor_module/armor/legs/marine/scout = -1,
			/obj/item/armor_module/armor/legs/marine/helljumper = -1,
		),
		"Jaeger modules" = list(
			/obj/item/armor_module/storage/general = -1,
			/obj/item/armor_module/storage/engineering = -1,
			/obj/item/armor_module/storage/medical = -1,
			/obj/item/armor_module/storage/injector = -1,
			/obj/item/armor_module/module/welding = -1,
			/obj/item/armor_module/module/binoculars = -1,
			/obj/item/armor_module/module/tyr_head = -1,
			/obj/item/armor_module/module/antenna = -1,
			/obj/item/armor_module/module/mimir_environment_protection/mark1 = -1,
			/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1 = -1,
			/obj/item/armor_module/module/tyr_extra_armor/mark1 = -1,
			/obj/item/armor_module/module/ballistic_armor = -1,
			/obj/item/armor_module/module/better_shoulder_lamp = -1,
			/obj/item/armor_module/module/chemsystem = -1,
			/obj/item/armor_module/module/eshield = -1,
		),
	)

	prices = list()

/obj/machinery/vending/armor_supply/loyalist
	faction = FACTION_TERRAGOV

/obj/machinery/vending/armor_supply/rebel
	faction = FACTION_TERRAGOV_REBEL

/obj/machinery/vending/armor_supply/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

/obj/machinery/vending/uniform_supply
	name = "\improper Surplus Clothing Vendor"
	desc = "Am automated equipment rack hooked up to a colossal storage of clothing and accessories. Nanotrasen designed a new vendor that utilize bluespace technology to send surplus equipment from outer colonies' sweatshops to your hands! Be grateful."
	icon_state = "surplus_clothes"
	icon_vend = "surplus-vend"
	icon_deny = "surplus-deny"
	isshared = TRUE
	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
		"Standard" = list(
			/obj/item/clothing/under/marine/robotic = -1,
			/obj/item/clothing/under/marine = -1,
			/obj/item/clothing/under/marine/standard =-1,
			/obj/item/clothing/under/marine/camo =-1,
			/obj/item/clothing/under/marine/camo/desert =-1,
			/obj/item/clothing/under/marine/camo/snow =-1,
			/obj/item/clothing/under/marine/jaeger =-1,
			/obj/item/clothing/gloves/marine =-1,
			/obj/item/clothing/shoes/marine/full = -1,
			/obj/item/clothing/shoes/cowboy = -1,
			/obj/item/armor_module/armor/badge = -1,
			/obj/item/armor_module/armor/cape = -1,
			/obj/item/armor_module/armor/cape/half = -1,
			/obj/item/armor_module/armor/cape/scarf = -1,
			/obj/item/armor_module/armor/cape/short = -1,
		),
		"Webbings" = list(
			/obj/item/armor_module/storage/uniform/black_vest = -1,
			/obj/item/armor_module/storage/uniform/brown_vest = -1,
			/obj/item/armor_module/storage/uniform/white_vest = -1,
			/obj/item/armor_module/storage/uniform/webbing = -1,
			/obj/item/armor_module/storage/uniform/holster = -1,
		),
		"Belts" = list(
			/obj/item/storage/belt/marine = -1,
			/obj/item/storage/belt/shotgun = -1,
			/obj/item/storage/belt/shotgun/martini = -1,
			/obj/item/storage/belt/grenade = -1,
			/obj/item/belt_harness/marine = -1,
			/obj/item/storage/belt/sparepouch = -1,
			/obj/item/storage/belt/gun/pistol/standard_pistol = -1,
			/obj/item/storage/belt/gun/revolver/standard_revolver = -1,
			/obj/item/storage/belt/utility/full =-1,
		),
		"Pouches" = list(
			/obj/item/storage/pouch/pistol = -1,
			/obj/item/storage/pouch/magazine/large = -1,
			/obj/item/storage/pouch/magazine/pistol/large = -1,
			/obj/item/storage/pouch/shotgun = -1,
			/obj/item/storage/pouch/flare/full = -1,
			/obj/item/storage/pouch/grenade = -1,
			/obj/item/storage/pouch/explosive = -1,
			/obj/item/storage/pouch/medkit = -1,
			/obj/item/storage/pouch/medical_injectors = -1,
			/obj/item/storage/pouch/med_lolipops = -1,
			/obj/item/storage/pouch/construction = -1,
			/obj/item/storage/pouch/electronics = -1,
			/obj/item/storage/pouch/tools/full = -1,
			/obj/item/storage/pouch/field_pouch = -1,
			/obj/item/storage/pouch/general/large = -1,
			/obj/item/storage/pouch/document = -1,
		),
		"Headwear" = list(
			/obj/item/clothing/head/slouch = -1,
			/obj/item/clothing/head/headband/red = -1,
			/obj/item/clothing/head/headband/rambo = -1,
			/obj/item/clothing/head/headband/snake = -1,
			/obj/item/clothing/head/headband = -1,
			/obj/item/clothing/head/bandanna/grey = -1,
			/obj/item/clothing/head/bandanna/brown = -1,
			/obj/item/clothing/head/bandanna/red = -1,
			/obj/item/clothing/head/tgmcberet/tan = -1,
			/obj/item/clothing/head/tgmcberet/red = -1,
			/obj/item/clothing/head/tgmcberet/red2 = -1,
			/obj/item/clothing/head/tgmcberet/blueberet = -1,
			/obj/item/clothing/head/tgmcberet/darkgreen = -1,
			/obj/item/clothing/head/tgmcberet/green = -1,
			/obj/item/clothing/head/tgmcberet/snow = -1,
			/obj/item/clothing/head/beret/marine = -1,
			/obj/item/clothing/head/tgmcberet = -1,
			/obj/item/clothing/glasses/mgoggles = -1,
			/obj/item/clothing/glasses/mgoggles/prescription = -1,
		),
		"Masks" = list(
			/obj/item/clothing/mask/rebreather/scarf = -1,
			/obj/item/clothing/mask/bandanna/skull = -1,
			/obj/item/clothing/mask/bandanna/green = -1,
			/obj/item/clothing/mask/bandanna/white = -1,
			/obj/item/clothing/mask/bandanna/black = -1,
			/obj/item/clothing/mask/bandanna = -1,
			/obj/item/clothing/mask/bandanna/alpha = -1,
			/obj/item/clothing/mask/bandanna/bravo = -1,
			/obj/item/clothing/mask/bandanna/charlie = -1,
			/obj/item/clothing/mask/bandanna/delta = -1,
			/obj/item/clothing/mask/rebreather = -1,
			/obj/item/clothing/mask/breath = -1,
			/obj/item/clothing/mask/gas = -1,
			/obj/item/clothing/mask/gas/tactical = -1,
			/obj/item/clothing/mask/gas/tactical/coif = -1,
		),
		"Backpacks" = list(
			/obj/item/storage/backpack/marine/standard = -1,
			/obj/item/storage/backpack/marine/satchel = -1,
			/obj/item/tool/weldpack/marinestandard = -1,
		),
		"Instruments" = list(
			/obj/item/instrument/violin = -1,
			/obj/item/instrument/piano_synth = -1,
			/obj/item/instrument/banjo = -1,
			/obj/item/instrument/guitar = -1,
			/obj/item/instrument/glockenspiel = -1,
			/obj/item/instrument/accordion = -1,
			/obj/item/instrument/trumpet = -1,
			/obj/item/instrument/saxophone = -1,
			/obj/item/instrument/trombone = -1,
			/obj/item/instrument/recorder = -1,
			/obj/item/instrument/harmonica = -1,
		),
		"Service Dress" = list(
			/obj/effect/essentials_set/white_dress = -1,
			/obj/item/clothing/under/whites = -1,
			/obj/item/clothing/suit/white_dress_jacket = -1,
			/obj/item/clothing/head/white_dress = -1,
			/obj/item/clothing/shoes/white = -1,
			/obj/item/clothing/gloves/white = -1,
			/obj/effect/essentials_set/service_uniform = -1,
			/obj/item/clothing/under/service = -1,
			/obj/item/clothing/head/garrisoncap = -1,
			/obj/item/clothing/head/servicecap = -1,
		),
	)

	prices = list()

/obj/machinery/vending/uniform_supply/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

/obj/machinery/vending/dress_supply
	name = "\improper TerraGovTech dress uniform vendor"
	desc = "A automated rack hooked up to a colossal storage of dress uniforms."
	icon_state = "marineuniform"
	icon_vend = "marineuniform_vend"
	icon_deny = "marineuniform"
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_CARGO)
	product_ads = "Hey! You! Stop looking like a turtle and start looking like a TRUE soldier!;Dress whites, fresh off the ironing board!;Why kill in armor when you can kill in style?;These uniforms are so sharp you'd cut yourself just looking at them!"
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		/obj/item/clothing/under/whites = -1,
		/obj/item/clothing/head/white_dress = -1,
		/obj/item/clothing/shoes/white = -1,
		/obj/item/clothing/gloves/white = -1,
	)

/obj/machinery/vending/dress_supply/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

/obj/machinery/vending/valhalla_req
	name = "\improper TerraGovTech requisition vendor"
	desc = "A automated rack hooked up to a colossal storage of items."
	icon_state = "requisitionop"
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		"Weapon" = list(
			/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla = -1,
			/obj/item/weapon/gun/rifle/railgun = -1,
			/obj/item/ammo_magazine/railgun = -1,
			/obj/item/weapon/gun/rifle/tx8 = -1,
			/obj/item/ammo_magazine/rifle/tx8 = -1,
			/obj/item/ammo_magazine/rifle/tx8/impact = -1,
			/obj/item/ammo_magazine/rifle/tx8/incendiary = -1,
			/obj/item/weapon/gun/launcher/rocket/m57a4/t57 = -1,
			/obj/item/ammo_magazine/rocket/m57a4 = -1,
			/obj/item/weapon/gun/launcher/rocket/sadar = -1,
			/obj/item/ammo_magazine/rocket/sadar = -1,
			/obj/item/ammo_magazine/rocket/sadar/ap = -1,
			/obj/item/ammo_magazine/rocket/sadar/wp = -1,
			/obj/item/weapon/gun/shotgun/zx76 = -1,
			/obj/item/ammo_magazine/shotgun/tracker = -1,
			/obj/item/ammo_magazine/shotgun/incendiary = -1,
			/obj/item/weapon/gun/rifle/standard_autosniper = -1,
			/obj/item/ammo_magazine/rifle/autosniper = -1,
			/obj/item/weapon/gun/rifle/sniper/antimaterial = -1,
			/obj/item/ammo_magazine/sniper = -1,
			/obj/item/ammo_magazine/rifle/autosniper = -1,
			/obj/item/weapon/gun/minigun = -1,
			/obj/item/ammo_magazine/minigun_powerpack = -1,
			/obj/item/weapon/gun/standard_mmg = -1,
			/obj/item/ammo_magazine/standard_mmg = -1,
			/obj/item/weapon/gun/rifle/standard_smartmachinegun = -1,
			/obj/item/ammo_magazine/standard_smartmachinegun = -1,
			/obj/item/weapon/gun/minigun/smart_minigun = -1,
			/obj/item/ammo_magazine/minigun_powerpack/smartgun = -1,
			/obj/item/weapon/gun/launcher/rocket/oneuse = -1,
			/obj/item/ammo_magazine/rocket/oneuse = -1,
			/obj/item/storage/belt/gun/mateba/full = -1,
			/obj/item/ammo_magazine/revolver/mateba = -1,
			/obj/item/ammo_magazine/packet/mateba = -1,
			/obj/item/ammo_magazine/rifle/chamberedrifle/flak = -1,
			/obj/item/ammo_magazine/flamer_tank/backtank/X = -1,
			/obj/item/weapon/claymore/harvester = -1,
			/obj/item/weapon/twohanded/spear/tactical/harvester = -1,
			/obj/item/weapon/twohanded/rocketsledge = -1,
		),
		"Equipment" = list(
			/obj/item/clothing/mask/gas/swat = -1,
			/obj/item/clothing/glasses/night/imager_goggles = -1,
			/obj/item/clothing/head/helmet/riot = -1,
			/obj/item/clothing/suit/storage/marine/specialist = -1,
			/obj/item/clothing/head/helmet/marine/specialist = -1,
			/obj/item/clothing/gloves/marine/specialist = -1,
			/obj/item/clothing/suit/storage/marine/B17 = -1,
			/obj/item/clothing/head/helmet/marine/grenadier = -1,
			/obj/item/storage/backpack/marine/satchel/scout_cloak/scout = -1,
			/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper = -1,
			/obj/item/storage/belt/grenade/b17 = -1,
			/obj/item/armor_module/module/valkyrie_autodoc = -1,
			/obj/item/armor_module/module/fire_proof = -1,
			/obj/item/armor_module/module/tyr_extra_armor = -1,
			/obj/item/armor_module/module/tyr_head = -1,
			/obj/item/armor_module/module/mimir_environment_protection = -1,
			/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet = -1,
			/obj/item/armor_module/module/better_shoulder_lamp = -1,
			/obj/item/armor_module/module/hlin_explosive_armor = -1,
			/obj/item/attachable/heatlens = -1,
			/obj/item/storage/backpack/lightpack = -1,
			/obj/item/clothing/suit/storage/marine/riot = -1,
			/obj/item/clothing/head/helmet/marine/riot = -1,
		)
	)

/obj/machinery/vending/valhalla_seasonal_req
	name = "\improper TerraGovTech seasonal vendor"
	desc = "A automated rack hooked up to a colossal storage of items."
	icon_state = "requisitionop"
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		"Weapon" = list(
			/obj/item/weapon/gun/revolver/small = -1,
			/obj/item/ammo_magazine/revolver/small = -1,
			/obj/item/weapon/gun/revolver/single_action/m44 = -1,
			/obj/item/ammo_magazine/revolver = -1,
			/obj/item/weapon/gun/pistol/g22 = -1,
			/obj/item/ammo_magazine/pistol/g22 = -1,
			/obj/item/weapon/gun/pistol/heavy = -1,
			/obj/item/ammo_magazine/pistol/heavy = -1,
			/obj/item/weapon/gun/pistol/vp78 = -1,
			/obj/item/ammo_magazine/pistol/vp78 = -1,
			/obj/item/weapon/gun/pistol/highpower = -1,
			/obj/item/ammo_magazine/pistol/highpower = -1,
			/obj/item/weapon/gun/revolver/judge = -1,
			/obj/item/ammo_magazine/revolver/judge = -1,
			/obj/item/ammo_magazine/revolver/judge/buckshot = -1,
			/obj/item/weapon/gun/revolver/upp = -1,
			/obj/item/ammo_magazine/revolver/upp = -1,
			/obj/item/weapon/gun/smg/uzi = -1,
			/obj/item/ammo_magazine/smg/uzi = -1,
			/obj/item/weapon/gun/revolver/cmb = -1,
			/obj/item/ammo_magazine/revolver/cmb = -1,
			/obj/item/weapon/gun/smg/m25 = -1,
			/obj/item/ammo_magazine/smg/m25 = -1,
			/obj/item/weapon/gun/smg/mp7 = -1,
			/obj/item/ammo_magazine/smg/mp7 = -1,
			/obj/item/weapon/gun/rifle/mkh = -1,
			/obj/item/ammo_magazine/rifle/mkh = -1,
			/obj/item/weapon/gun/smg/ppsh = -1,
			/obj/item/ammo_magazine/smg/ppsh = -1,
			/obj/item/ammo_magazine/smg/ppsh/extended = -1,
			/obj/item/weapon/gun/shotgun/combat = -1,
			/obj/item/weapon/gun/shotgun/pump/cmb = -1,
			/obj/item/weapon/gun/rifle/mpi_km = -1,
			/obj/item/ammo_magazine/rifle/mpi_km = -1,
			/obj/item/weapon/gun/rifle/m16 = -1,
			/obj/item/ammo_magazine/rifle/m16 = -1,
			/obj/item/weapon/gun/rifle/m412 = -1,
			/obj/item/ammo_magazine/rifle = -1,
			/obj/item/weapon/gun/rifle/m41a = -1,
			/obj/item/ammo_magazine/rifle/m41a = -1,
			/obj/item/weapon/gun/rifle/type71/seasonal = -1,
			/obj/item/ammo_magazine/rifle/type71 = -1,
			/obj/item/weapon/gun/rifle/alf_machinecarbine = -1,
			/obj/item/ammo_magazine/rifle/alf_machinecarbine = -1,
		)
	)

/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	isshared = TRUE
	products = list(
		/obj/item/stack/cable_coil = -1,
		/obj/item/tool/crowbar = -1,
		/obj/item/tool/weldingtool = -1,
		/obj/item/tool/wirecutters = -1,
		/obj/item/tool/wrench = -1,
		/obj/item/tool/screwdriver = -1,
	)

/obj/machinery/vending/tool/nopower
	use_power = NO_POWER_USE
