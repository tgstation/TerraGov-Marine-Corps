//Requisitions vendor

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
			/obj/item/pinpointer = 1,
			/obj/item/supply_beacon = 1,
			/obj/item/ammo_magazine/rifle/autosniper = 3,
			/obj/item/ammo_magazine/rifle/tx8 = 3,
			/obj/item/ammo_magazine/rocket/sadar = 3,
			/obj/item/ammo_magazine/minigun_powerpack = 2,
			/obj/item/ammo_magazine/shotgun/mbx900 = 2,
			/obj/item/explosive/plastique = 5,
			/obj/item/fulton_extraction_pack = 2,
			/obj/item/clothing/suit/storage/marine/boomvest = 20,
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
			/obj/machinery/unboxer = 1,
			/obj/item/stack/conveyor/thirty = 10,
			/obj/item/conveyor_switch_construct = 10,
		),
		"Grenade Boxes" = list(
			/obj/item/storage/box/visual/grenade/frag = 2,
			/obj/item/storage/box/visual/grenade/incendiary = 2,
			/obj/item/storage/box/visual/grenade/M15 = 2,
			/obj/item/storage/box/visual/grenade/cloak = 1,
			/obj/item/storage/box/visual/grenade/lasburster = 1,
		),
		"Ammo Boxes" = list(
			/obj/item/big_ammo_box = -1,
			/obj/item/big_ammo_box/smg = -1,
			/obj/item/big_ammo_box/mg = -1,
			/obj/item/shotgunbox = -1,
			/obj/item/shotgunbox/buckshot = -1,
			/obj/item/shotgunbox/flechette = -1,
			/obj/item/shotgunbox/tracker = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_pistol/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_heavypistol/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_revolver/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_pocketpistol/full = -1,
			/obj/item/storage/box/visual/magazine/compact/vp70/full = -1,
			/obj/item/storage/box/visual/magazine/compact/plasma_pistol/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_smg/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_machinepistol/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_assaultrifle/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_carbine/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_skirmishrifle/full = -1,
			/obj/item/storage/box/visual/magazine/compact/martini/full = -1,
			/obj/item/storage/box/visual/magazine/compact/ar11/full = -1,
			/obj/item/storage/box/visual/magazine/compact/lasrifle/marine/full = -1,
			/obj/item/storage/box/visual/magazine/compact/sh15/flechette/full = -1,
			/obj/item/storage/box/visual/magazine/compact/sh15/slug/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_dmr/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_br/full = -1,
			/obj/item/storage/box/visual/magazine/compact/chamberedrifle/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_lmg/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_gpmg/full = -1,
			/obj/item/storage/box/visual/magazine/compact/standard_mmg/full = -1,
		),
		"Mecha Ammo" = list(
			/obj/item/mecha_ammo/vendable/pistol = -1,
			/obj/item/mecha_ammo/vendable/burstpistol = -1,
			/obj/item/mecha_ammo/vendable/smg = -1,
			/obj/item/mecha_ammo/vendable/burstrifle = -1,
			/obj/item/mecha_ammo/vendable/rifle = -1,
			/obj/item/mecha_ammo/vendable/shotgun = -1,
			/obj/item/mecha_ammo/vendable/lmg = -1,
			/obj/item/mecha_ammo/vendable/lightcannon = -1,
			/obj/item/mecha_ammo/vendable/heavycannon = -1,
			/obj/item/mecha_ammo/vendable/minigun = -1,
			/obj/item/mecha_ammo/vendable/sniper = -1,
			/obj/item/mecha_ammo/vendable/grenade = -1,
			/obj/item/mecha_ammo/vendable/flamer = -1,
			/obj/item/mecha_ammo/vendable/rpg = -1,
		)
	)
