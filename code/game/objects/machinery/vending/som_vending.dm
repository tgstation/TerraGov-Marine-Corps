/obj/machinery/vending/weapon/som
	name = "\improper SOM automated weapons rack"
	faction = FACTION_SOM
	desc = "An automated weapon rack hooked up to a colossal storage of standard-issue weapons."
	icon_state = "marinearmory"
	icon_vend = "marinearmory-vend"
	icon_deny = "marinearmory"
	wrenchable = FALSE
	product_ads = ""
	isshared = TRUE

	products = list(
		"Rifles" = list(
			/obj/item/weapon/gun/rifle/som_carbine = -1,
			/obj/item/weapon/gun/rifle/mpi_km = -1,
			/obj/item/ammo_magazine/rifle/mpi_km/carbine = -1,
			/obj/item/ammo_magazine/rifle/mpi_km/carbine/black = -1,
			/obj/item/ammo_magazine/rifle/mpi_km/black = -1,
			/obj/item/ammo_magazine/rifle/mpi_km/extended = 30,
			/obj/item/ammo_magazine/rifle/som = -1,
			/obj/item/ammo_magazine/rifle/som/ap = 25,
			/obj/item/ammo_magazine/rifle/som/incendiary = 15,
			/obj/item/weapon/gun/rifle/som = -1,
			/obj/item/weapon/gun/rifle/icc_sharpshooter = -1,
			/obj/item/ammo_magazine/rifle/icc_sharpshooter = -1,
			/obj/item/weapon/gun/rifle/icc_battlecarbine = -1,
			/obj/item/ammo_magazine/rifle/icc_battlecarbine = -1,
			/obj/item/weapon/gun/rifle/icc_confrontationrifle = -1,
			/obj/item/ammo_magazine/rifle/icc_confrontationrifle = -1,
			/obj/item/weapon/gun/rifle/icc_autoshotgun = -1,
			/obj/item/ammo_magazine/rifle/icc_autoshotgun = -1,
			/obj/item/ammo_magazine/rifle/icc_autoshotgun/frag = 15,
			/obj/item/weapon/gun/rifle/icc_assaultcarbine = -1,
			/obj/item/ammo_magazine/rifle/icc_battlecarbine = -1,
			/obj/item/ammo_magazine/rifle/som_big = -1,
			/obj/item/ammo_magazine/rifle/som_big/incendiary = 10,
			/obj/item/ammo_magazine/rifle/som_big/anti_armour = 10,
		),
		"Energy Weapons" = list(
			/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger = -1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver = 5,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 5,
			/obj/item/cell/lasgun/volkite/small = -1,
			/obj/item/cell/lasgun/volkite = -1,
		),
		"SMGs" = list(
			/obj/item/weapon/gun/smg/som = -1,
			/obj/item/ammo_magazine/smg/som = -1,
			/obj/item/ammo_magazine/smg/som/ap = 25,
			/obj/item/ammo_magazine/smg/som/incendiary = 15,
			/obj/item/ammo_magazine/smg/som/rad = 5,
			/obj/item/weapon/gun/smg/icc_machinepistol = -1,
			/obj/item/ammo_magazine/smg/icc_machinepistol = -1,
			/obj/item/weapon/gun/smg/icc_pdw = -1,
			/obj/item/ammo_magazine/smg/icc_pdw = -1,
		),
		"Marksman" = list(
			/obj/item/weapon/gun/rifle/sniper/svd = 3,
			/obj/item/ammo_magazine/sniper/svd = 30,
			/obj/item/weapon/gun/rifle/chambered = -1,
			/obj/item/ammo_magazine/rifle/chamberedrifle = -1,
			/obj/item/weapon/gun/shotgun/pump/lever = -1,
			/obj/item/ammo_magazine/packet/magnum = -1,
			/obj/item/weapon/gun/shotgun/pump/bolt = -1,
			/obj/item/ammo_magazine/rifle/boltclip = -1,
			/obj/item/ammo_magazine/rifle/bolt = -1,
			/obj/item/weapon/gun/shotgun/double/martini = -1,
			/obj/item/ammo_magazine/rifle/martini = -1,
		),
		"Shotgun" = list(
			/obj/item/ammo_magazine/shotgun/buckshot = -1,
			/obj/item/ammo_magazine/shotgun = -1,
			/obj/item/ammo_magazine/shotgun/flechette = -1,
			/obj/item/ammo_magazine/shotgun/tracker = -1,
			/obj/item/ammo_magazine/shotgun/beanbag = -1,
			/obj/item/ammo_magazine/shotgun/heavy_buckshot = -1,
			/obj/item/ammo_magazine/shotgun/heavy_flechette = -1,
			/obj/item/ammo_magazine/shotgun/barrikada = -1,
			/obj/item/weapon/gun/shotgun/pump/sh23/som = -1,
			/obj/item/weapon/gun/shotgun/som = -1,
			/obj/item/weapon/gun/shotgun/som/burst = 2,
			/obj/item/weapon/gun/shotgun/double/sawn = 5,
			/obj/item/weapon/gun/shotgun/pump/trenchgun = 5,
		),
		"Machinegun" = list(
			/obj/item/weapon/gun/rifle/som_mg = -1,
			/obj/item/ammo_magazine/som_mg = -1,
			/obj/item/weapon/gun/rifle/icc_mg = -1,
			/obj/item/ammo_magazine/icc_mg = -1,
			/obj/item/ammo_magazine/icc_mg/packet = -1,
			/obj/item/ammo_magazine/icc_mg/belt = -1
		),
		"Melee" = list(
			/obj/item/weapon/shield/riot/marine/som = 6,
			/obj/item/attachable/bayonetknife/som = -1,
			/obj/item/stack/throwing_knife = -1,
			/obj/item/storage/belt/knifepouch = -1,
			/obj/item/weapon/energy/sword/som = 3,
			/obj/item/storage/holster/blade/machete/full = -1,
			/obj/item/storage/holster/blade/machete/full_harvester = -1,
			/obj/item/weapon/twohanded/glaive/harvester = -1,
			/obj/item/weapon/twohanded/spear/tactical = -1,
			/obj/item/weapon/twohanded/spear/tactical/harvester = -1,
			/obj/item/weapon/combat_knife/harvester = 12,
		),
		"Sidearm" = list(
			/obj/item/weapon/gun/pistol/som = -1,
			/obj/item/ammo_magazine/pistol/som = -1,
			/obj/item/ammo_magazine/pistol/som/extended = 40,
			/obj/item/ammo_magazine/pistol/som/incendiary = 20,
			/obj/item/weapon/gun/pistol/icc_dpistol = -1,
			/obj/item/ammo_magazine/pistol/icc_dpistol = -1,
			/obj/item/weapon/gun/pistol/plasma_pistol = -1,
			/obj/item/ammo_magazine/pistol/plasma_pistol = -1,
		),
		"Grenades" = list(
			/obj/item/weapon/gun/grenade_launcher/single_shot = -1,
			/obj/item/weapon/gun/grenade_launcher/multinade_launcher/unloaded = -1,
			/obj/item/explosive/grenade/m15 = 30,
			/obj/item/explosive/grenade/sticky = 125,
			/obj/item/explosive/grenade/sticky/trailblazer = 75,
			/obj/item/explosive/grenade/smokebomb/som = 25,
			/obj/item/explosive/grenade/incendiary/som = 50,
			/obj/item/explosive/grenade/som = 200,
			/obj/item/explosive/grenade/sticky/cloaker = 10,
			/obj/item/explosive/grenade/mirage = 20,
			/obj/item/explosive/grenade/smokebomb/satrapine = 30,
			/obj/item/explosive/grenade/flashbang/stun = 30,
			/obj/item/explosive/grenade/smokebomb/cloak = 25,
			/obj/item/explosive/grenade/smokebomb/drain = 15,
			/obj/item/explosive/grenade/mirage = 50,
			/obj/item/explosive/grenade/training = -1,
			/obj/item/explosive/grenade/impact = 20,
			/obj/item/explosive/grenade/phosphorus = 15,
			/obj/item/explosive/grenade/rad = 5,
			/obj/item/explosive/grenade/chem_grenade/metalfoam = 5,
			/obj/item/explosive/grenade/smokebomb/neuro = 5,
			/obj/item/explosive/grenade/smokebomb/acid = 5,
			/obj/item/explosive/grenade/smokebomb/aphrotoxin = 5,
			/obj/item/explosive/grenade/smokebomb/sleep = 5,
			/obj/item/storage/box/m94 = 200,
			/obj/item/ammo_magazine/handful/micro_grenade = 30,
			/obj/item/ammo_magazine/handful/micro_grenade/cluster = 20,
			/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 24,
			/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 12,
		),
		"Specialized" = list(
			/obj/item/weapon/gun/rifle/pepperball = 5,
			/obj/item/ammo_magazine/rifle/pepperball = -1,
			/obj/item/storage/holster/backholster/rpg/som = 4,
			/obj/item/ammo_magazine/flamer_tank/large/som = 10,
			/obj/item/ammo_magazine/flamer_tank/water = -1,
			/obj/item/jetpack_marine = 1,
			/obj/item/bodybag/tarp = 10,
			/obj/item/weapon/gun/launcher/rocket/som = 4,
			/obj/item/ammo_magazine/rocket/som = 8,
			/obj/item/ammo_magazine/rocket/som/light = 8,
			/obj/item/ammo_magazine/rocket/som/incendiary = 8,
			/obj/item/ammo_magazine/rocket/som/heat = 8,
			/obj/item/ammo_magazine/rocket/som/thermobaric = 8,
			/obj/item/ammo_magazine/rocket/som/rad = 6,
			/obj/item/weapon/gun/flamer/som = 4,
		),
		"Heavy Weapons" = list(
			/obj/structure/closet/crate/mortar_ammo/mortar_kit = 1,
			/obj/structure/closet/crate/mortar_ammo/howitzer_kit = 1,
			/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 4,
			/obj/item/cell/lasgun/volkite/turret = 4,
			/obj/item/storage/box/hsg_102 = 1,
			/obj/item/weapon/gun/heavymachinegun = 1,
			/obj/item/ammo_magazine/heavymachinegun = 5,
			/obj/item/ammo_magazine/heavymachinegun/small = 10,
		),
		"Attachments" = list(
			/obj/item/attachable/bayonet = -1,
			/obj/item/attachable/compensator = -1,
			/obj/item/attachable/extended_barrel = -1,
			/obj/item/attachable/suppressor = -1,
			/obj/item/attachable/heavy_barrel = -1,
			/obj/item/attachable/lace = -1,
			/obj/item/attachable/flashlight = -1,
			/obj/item/attachable/flashlight/under = -1,
			/obj/item/attachable/magnetic_harness = -1,
			/obj/item/attachable/reddot = -1,
			/obj/item/attachable/motiondetector = -1,
			/obj/item/attachable/scope/marine = -1,
			/obj/item/attachable/scope/mini = -1,
			/obj/item/attachable/angledgrip = -1,
			/obj/item/attachable/verticalgrip = -1,
			/obj/item/attachable/foldable/bipod = -1,
			/obj/item/attachable/gyro = -1,
			/obj/item/attachable/lasersight = -1,
			/obj/item/attachable/burstfire_assembly = -1,
			/obj/item/weapon/gun/shotgun/combat/masterkey = -1,
			/obj/item/weapon/gun/grenade_launcher/underslung = -1,
			/obj/item/weapon/gun/flamer/mini_flamer = -1,
			/obj/item/ammo_magazine/flamer_tank/mini = -1,
			/obj/item/weapon/gun/rifle/pepperball/pepperball_mini = -1,
			/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini = -1,
			/obj/item/attachable/stock/t76 = -1,
			/obj/item/attachable/flamer_nozzle = -1,
			/obj/item/attachable/flamer_nozzle/wide = -1,
			/obj/item/attachable/flamer_nozzle/long = -1,
		),
		"Boxes" = list(
			/obj/item/ammo_magazine/packet/p9mm = -1,
			/obj/item/ammo_magazine/packet/p9mmap = -1,
			/obj/item/ammo_magazine/packet/acp = -1,
			/obj/item/ammo_magazine/packet/pthreeightyacp = -1,
			/obj/item/ammo_magazine/packet/magnum = -1,
			/obj/item/ammo_magazine/packet/p10x20mm = -1,
			/obj/item/ammo_magazine/packet/p10x24mm = -1,
			/obj/item/ammo_magazine/packet/p10x25mm = -1,
			/obj/item/ammo_magazine/packet/p10x26mm = -1,
			/obj/item/ammo_magazine/packet/p10x265mm = -1,
			/obj/item/ammo_magazine/packet/p10x27mm = -1,
			/obj/item/ammo_magazine/packet/p492x34mm = -1,
			/obj/item/ammo_magazine/packet/p86x70mm = -1,
			/obj/item/ammo_magazine/packet/standardautoshotgun = -1,
			/obj/item/ammo_magazine/packet/standardautoshotgun/flechette = -1,
			/obj/item/ammo_magazine/packet/p4570 = -1,
			/obj/item/storage/box/visual/magazine = -1,
			/obj/item/storage/box/visual/grenade = -1,
			/obj/structure/closet/crate/mass_produced_crate = 25,
			/obj/structure/closet/crate/mass_produced_crate/ammo = 5,
			/obj/structure/closet/crate/mass_produced_crate/construction = 5,
			/obj/structure/closet/crate/mass_produced_crate/explosives = 5,
			/obj/structure/closet/crate/mass_produced_crate/medical = 5,
			/obj/structure/closet/crate/mass_produced_crate/supply = 5,
			/obj/structure/closet/crate/mass_produced_crate/weapon = 5,
		),
		"Utility" = list(
			/obj/item/roller/bedroll = -1,
			/obj/item/flashlight/combat = -1,
			/obj/item/weapon/gun/grenade_launcher/single_shot/flare/marine = -1,
			/obj/item/tool/shovel/etool = -1,
			/obj/item/tool/extinguisher = -1,
			/obj/item/tool/extinguisher/mini = -1,
			/obj/item/assembly/signaler = -1,
			/obj/item/binoculars = -1,
			/obj/item/compass = -1,
			/obj/item/tool/hand_labeler = -1,
			/obj/item/toy/deck/kotahi = -1,
			/obj/item/deployable_floodlight = 5,
		),
	)


/obj/machinery/vending/cargo_supply/som
	name = "\improper SOM Operational Supplies Vendor"
	desc = "A large vendor for dispensing specialty and bulk supplies. Restricted to cargo personnel only."
	icon_state = "requisitionop"
	icon_vend = "requisitionop-vend"
	icon_deny = "requisitionop-deny"
	req_one_access = list(213)
	wrenchable = FALSE
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
			/obj/item/radio/headset/mainship/som/zulu = -1,
			/obj/item/radio/headset/mainship/som/yankee = -1,
			/obj/item/radio/headset/mainship/som/xray = -1,
			/obj/item/radio/headset/mainship/som/whiskey = -1,
		),
		"Mining Equipment" = list(
			/obj/item/minerupgrade/automatic = 1,
			/obj/item/minerupgrade/reinforcement = 1,
			/obj/item/minerupgrade/overclock = 1,
		),
		"Reqtorio Basics" = list(
			/obj/item/paper/factoryhowto = -1,
			/obj/item/paper/factoryhowto/som = -1,
			/obj/machinery/factory/cutter = 1,
			/obj/machinery/factory/heater = 1,
			/obj/machinery/factory/flatter = 1,
			/obj/machinery/factory/former = 1,
			/obj/machinery/factory/reconstructor = 1,
			/obj/machinery/unboxer = 1,
			/obj/machinery/unboxer/syndicate = 2,
			/obj/item/stack/conveyor/thirty = 10,
			/obj/item/conveyor_switch_construct = 10,
		),
		"Grenade Boxes" = list(
			/obj/item/storage/box/visual/grenade/frag = 2,
			/obj/item/storage/box/visual/grenade/incendiary = 2,
			/obj/item/storage/box/visual/grenade/M15 = 2,
			/obj/item/storage/box/visual/grenade/cloak = 1,
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

/obj/machinery/vending/som/lasgun
	name = "\improper Potable SOM Charging Station"
	desc = "An automated power cell dispenser and charger. Used to recharge energy weapon power cells, including in the field. Has an internal battery that charges off the power grid when wrenched down."
	icon_state = "lascharger"
	icon_vend = "lascharger-vend"
	icon_deny = "lascharger-deny"
	wrenchable = TRUE
	drag_delay = FALSE
	anchored = FALSE
	idle_power_usage = 1
	active_power_usage = 50
	machine_current_charge = 50000 //integrated battery for recharging energy weapons. Normally 10000.
	machine_max_charge = 50000
	product_slogans = "Static Shock!;Power cell running low? Recharge here!;Need a charge?;Power up!;Electrifying!;Empower yourself!"
	products = list(
		/obj/item/cell/lasgun/volkite = 20,
		/obj/item/cell/lasgun/volkite/small = 10,
	)


	prices = list()

/obj/machinery/vending/som/lasgun/Initialize(mapload)
	. = ..()
	update_icon_state()

/obj/machinery/vending/som/lasgun/update_icon_state()
	if(machine_max_charge)
		switch(machine_current_charge / max(1,machine_max_charge))
			if(0.7 to 1)
				icon_state = "lascharger"
			if(0.51 to 0.75)
				icon_state = "lascharger_75"
			if(0.26 to 0.50)
				icon_state = "lascharger_50"
			if(0.01 to 0.25)
				icon_state = "lascharger_25"
			if(0)
				icon_state = "lascharger_0"

/obj/machinery/vending/som/lasgun/examine(mob/user)
	. = ..()
	. += "Internal battery charge: <b>[machine_current_charge]</b>/<b>[machine_max_charge]</b>"

/obj/machinery/vending/SyndiMed
	name = "\improper Syndicate Medicament Deployer"
	desc = "Medical drug dispenser, made for medical purposes."
	icon_state = "marinemed"
	icon_vend = "marinemed-vend"
	icon_deny = "marinemed-deny"
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		"Pill Bottles" = list(
			/obj/item/storage/pill_bottle/bicaridine = -1,
			/obj/item/storage/pill_bottle/kelotane = -1,
			/obj/item/storage/pill_bottle/tramadol = -1,
			/obj/item/storage/pill_bottle/tricordrazine = -1,
			/obj/item/storage/pill_bottle/dylovene = -1,
			/obj/item/storage/pill_bottle/paracetamol = -1,
			/obj/item/storage/pill_bottle/isotonic = -1,
			/obj/item/storage/pill_bottle = -1,
			/obj/item/storage/pill_bottle/aphrotoxin = 5,
		),
		"Auto Injector" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 30,
			/obj/item/reagent_containers/hypospray/autoinjector/spaceacillin = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/alkysine = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/imidazoline = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/aphrotoxin = 10,
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

	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		"Pill Bottles" = list(
			/obj/item/storage/pill_bottle/bicaridine = -1,
			/obj/item/storage/pill_bottle/kelotane = -1,
			/obj/item/storage/pill_bottle/tramadol = -1,
			/obj/item/storage/pill_bottle/tricordrazine = -1,
			/obj/item/storage/pill_bottle/dylovene = -1,
			/obj/item/storage/pill_bottle/paracetamol = -1,
			/obj/item/storage/pill_bottle/isotonic = -1,
			/obj/item/storage/pill_bottle/aphrotoxin = 5,
			/obj/item/storage/pill_bottle = -1,
		),
		"Auto Injector" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 30,
			/obj/item/reagent_containers/hypospray/autoinjector/spaceacillin = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/alkysine = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/imidazoline = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/aphrotoxin = 10,
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
/obj/machinery/vending/som/armor_supply
	name = "\improper High Quality Mining Equipment"
	desc = "An automated equipment rack hooked up to a colossal storage of armor and accessories. Nanotrasen designed a new vendor that utilizes bluespace technology to send surplus equipment from outer colonies' sweatshops to your hands! Be grateful."
	icon_state = "surplus_armor"
	icon_vend = "surplus-vend"
	icon_deny = "surplus_armor-deny"
	isshared = TRUE
	product_ads = "You are out of uniform, marine! Where is your armor? Don't have any? You expect me to believe that, maggot?;Why wear heavy armor and unable to chase the enemy when you can go light and zoom by your peers?;Thank your armor later when you didn't die!;I remember PAS, do you remember PAS?;Time to paint the rainbow!;So many selections to choose from!"
	products = list(
		"General Armors" = list(
			/obj/item/clothing/head/modular/som = -1,
			/obj/item/clothing/head/modular/som/bio = -1,
			/obj/item/clothing/head/modular/som/hades = 3,
			/obj/item/clothing/head/modular/som/engineer = -1,
			/obj/item/clothing/head/modular/som/lorica = 3,
			/obj/item/clothing/suit/modular/som/light = -1,
			/obj/item/clothing/suit/modular/som = -1,
			/obj/item/clothing/suit/modular/som/heavy = -1,
			/obj/item/clothing/suit/storage/marine/icc = -1,
			/obj/item/clothing/suit/storage/marine/icc/guard = -1,
			/obj/item/clothing/suit/storage/marine/icc/guard/heavy = -1,
			/obj/item/clothing/head/helmet/marine/icc = -1,
			/obj/item/clothing/head/helmet/marine/icc/guard = -1,
			/obj/item/clothing/head/helmet/marine/icc/guard/heavy = -1,
			/obj/item/clothing/head/helmet/marine/stolen = -1,
			/obj/item/clothing/head/modular/m10x/stolen = -1,
		),
		"Combat Drone" = list(
			/obj/item/clothing/suit/modular/robot/light = -1,
			/obj/item/clothing/suit/modular/robot = -1,
			/obj/item/clothing/suit/modular/robot/heavy = -1,
			/obj/item/clothing/head/modular/robot/light = -1,
			/obj/item/clothing/head/modular/robot = -1,
			/obj/item/clothing/head/modular/robot/heavy = -1,
		),
		"General" = list(
			/obj/item/facepaint/green = -1,
			/obj/item/clothing/suit/modular/rownin = -1
		),
		"OLD SCHOOL" = list(
			/obj/item/clothing/head/helmet/marine/som = -1,
			/obj/item/clothing/suit/storage/marine/som = -1,
		),
		"Armor modules" = list(
			/obj/item/armor_module/storage/general = -1,
			/obj/item/armor_module/storage/engineering = -1,
			/obj/item/armor_module/storage/medical = -1,
			/obj/item/armor_module/storage/injector = -1,
			/obj/item/armor_module/storage/grenade = -1,
			/obj/item/armor_module/module/binoculars = -1,
			/obj/item/armor_module/module/artemis = -1,
			/obj/item/armor_module/module/antenna = -1,
			/obj/item/armor_module/module/welding/som = 2,
			/obj/item/armor_module/module/fire_proof/som = 3,
			/obj/item/armor_module/module/mimir_environment_protection/som = -1,
			/obj/item/armor_module/module/tyr_extra_armor/som = -1,
			/obj/item/armor_module/module/knight/som = -1,
			/obj/item/armor_module/module/better_shoulder_lamp = -1,
			/obj/item/armor_module/module/chemsystem = -1,
			/obj/item/armor_module/module/eshield/som = -1,
		),
	)

	prices = list()

/obj/machinery/vending/som/uniform_supply
	name = "\improper SOMdrobe"
	desc = "An automated equipment rack hooked up to a colossal storage of clothing and accessories. Nanotrasen designed a new vendor that utilizes bluespace technology to send surplus equipment from outer colonies' sweatshops to your hands! Be grateful."
	icon_state = "surplus_clothes"
	icon_vend = "surplus-vend"
	icon_deny = "surplus_clothes-deny"
	isshared = TRUE
	products = list(
		"Standard" = list(
			/obj/item/clothing/under/marine/robotic = -1,
			/obj/item/clothing/under/marine/hyperscale = -1,
			/obj/item/clothing/under/marine/hyperscale_skirt = -1,
			/obj/item/clothing/under/marine/camo = -1,
			/obj/item/clothing/under/marine/orion_fatigue = -1,
			/obj/item/clothing/under/marine/red_fatigue = -1,
			/obj/item/clothing/under/marine/lv_fatigue = -1,
			/obj/item/armor_module/armor/badge = -1,
			/obj/item/armor_module/armor/cape = -1,
			/obj/item/armor_module/armor/cape/kama = -1,
			/obj/item/armor_module/module/pt_belt = -1,
			/obj/item/clothing/gloves/ruggedgloves = -1,
			/obj/item/clothing/gloves/marine/som = -1,
			/obj/item/clothing/gloves/brown = -1,
			/obj/item/clothing/gloves/marine/som = -1,
			/obj/item/clothing/gloves/marine/hyperscale = -1,
			/obj/item/clothing/shoes/marine/som/knife = -1,
			/obj/item/clothing/under/som = -1,
			/obj/item/clothing/under/icc = -1,
			/obj/item/clothing/gloves/marine/icc = -1,
			/obj/item/clothing/gloves/marine/icc/guard = -1,
			/obj/item/clothing/shoes/marine/icc/knife = -1,
			/obj/item/clothing/shoes/marine/icc/guard/knife = -1,
			/obj/item/armor_module/armor/badge = -1,
			/obj/item/armor_module/armor/cape = -1,
			/obj/item/armor_module/armor/cape/kama = -1,

		),
		"Webbings" = list(
			/obj/item/armor_module/storage/uniform/black_vest = -1,
			/obj/item/armor_module/storage/uniform/brown_vest = -1,
			/obj/item/armor_module/storage/uniform/white_vest = -1,
			/obj/item/armor_module/storage/uniform/webbing = -1,
			/obj/item/armor_module/storage/uniform/holster = -1,
		),
		"Belts" = list(
			/obj/item/storage/belt/knifepouch = -1,
			/obj/item/storage/holster/blade/machete/full = -1,
			/obj/item/storage/holster/blade/machete/full_harvester = -1,
			/obj/item/storage/holster/belt/pistol/m4a3/som = -1,
			/obj/item/belt_harness = -1,
			/obj/item/storage/belt/shotgun/som = -1,
			/obj/item/storage/belt/sparepouch/som = -1,
			/obj/item/storage/belt/marine/som = -1,
			/obj/item/storage/belt/grenade/som = -1,,
		),
		"Pouches" = list(
			/obj/item/storage/pouch/grenade/som = -1,
			/obj/item/storage/pouch/general/som = -1,
			/obj/item/storage/pouch/magazine/large/som = -1,
			/obj/item/storage/pouch/pistol/som = -1,
			/obj/item/storage/pouch/shotgun/som = -1,
			/obj/item/storage/pouch/construction/som = -1,
			/obj/item/storage/pouch/medkit/som = -1,
			/obj/item/storage/pouch/medical_injectors/som = -1,
			/obj/item/storage/pouch/firstaid/som = -1,
			/obj/item/storage/pouch/tools/som = -1,
		),
		"Headwear" = list(
			/obj/item/clothing/head/modular/style/beret = -1,
			/obj/item/clothing/head/modular/style/classic_beret = -1,
			/obj/item/clothing/head/modular/style/boonie = -1,
			/obj/item/clothing/head/modular/style/cap = -1,
			/obj/item/clothing/head/modular/style/slouchhat = -1,
			/obj/item/clothing/head/modular/style/ushanka = -1,
			/obj/item/clothing/head/modular/style/campaignhat = -1,
			/obj/item/clothing/head/modular/style/beanie = -1,
			/obj/item/clothing/head/modular/style/headband = -1,
			/obj/item/clothing/head/modular/style/bandana = -1,
		),
		"Masks" = list(
			/obj/item/clothing/mask/rebreather/scarf = -1,
			/obj/item/clothing/mask/bandanna/skull = -1,
			/obj/item/clothing/mask/bandanna/green = -1,
			/obj/item/clothing/mask/bandanna/white = -1,
			/obj/item/clothing/mask/bandanna/black = -1,
			/obj/item/clothing/mask/bandanna = -1,
			/obj/item/clothing/mask/rebreather = -1,
			/obj/item/clothing/mask/breath = -1,
			/obj/item/clothing/mask/gas/modular/skimask = -1,
			/obj/item/clothing/mask/gas/modular/coofmask = -1,
			/obj/item/clothing/mask/gas = -1,
			/obj/item/clothing/mask/gas/tactical = -1,
			/obj/item/clothing/mask/gas/tactical/coif = -1,
			/obj/item/clothing/mask/gas/icc = -1,
		),
		"Backpacks" = list(
			/obj/item/storage/backpack/satchel/som = -1,
			/obj/item/storage/backpack/lightpack/icc = 10,
			/obj/item/storage/backpack/lightpack/som = 10,
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
		"Dress Uniform" = list(
			/obj/item/clothing/shoes/white = -1,
			/obj/item/clothing/gloves/white = -1,
			/obj/item/clothing/head/garrisoncap = -1,
			/obj/item/clothing/head/serviceberet = -1,
			/obj/item/clothing/head/servicecampaignhat = -1,
			/obj/item/clothing/head/serviceushanka = -1,
			/obj/item/clothing/head/servicecap = -1,
		),
		"Surplus Headwear" = list(
			/obj/item/clothing/head/slouch = -1,
			/obj/item/clothing/head/headband/red = -1,
			/obj/item/clothing/head/headband/rambo = -1,
			/obj/item/clothing/head/headband/snake = -1,
			/obj/item/clothing/head/headband = -1,
			/obj/item/clothing/head/bandanna/grey = -1,
			/obj/item/clothing/head/bandanna/brown = -1,
			/obj/item/clothing/head/bandanna/red = -1,
		),
		"Medical Clothing" = list(
			/obj/item/clothing/under/rank/medical/blue = -1,
			/obj/item/clothing/under/rank/medical/green = -1,
			/obj/item/clothing/under/rank/medical/purple = -1,
			/obj/item/clothing/suit/storage/labcoat = -1,
			/obj/item/clothing/suit/surgical = -1,
			/obj/item/clothing/mask/surgical = -1,
			/obj/item/clothing/gloves/latex = -1,
			/obj/item/clothing/shoes/white = -1,
		),
		"Eyewear" = list(
			/obj/item/clothing/glasses/regular = -1,
			/obj/item/clothing/glasses/eyepatch = -1,
			/obj/item/clothing/glasses/sunglasses/fake/big = -1,
			/obj/item/clothing/glasses/sunglasses/fake/big/prescription = -1,
			/obj/item/clothing/glasses/sunglasses/fake = -1,
			/obj/item/clothing/glasses/sunglasses/fake/prescription = -1,
			/obj/item/clothing/glasses/mgoggles = -1,
			/obj/item/clothing/glasses/mgoggles/prescription = -1,
		),
		"Other" = list(
			/obj/item/clothing/under/lewd/panties = -1,
			/obj/item/clothing/under/lewd/chaps = -1,
			/obj/item/clothing/under/lewd/corset = -1,
			/obj/item/clothing/under/lewd/stripper = -1,
			/obj/item/clothing/under/lewd/stripper/green = -1,
			/obj/item/clothing/under/lewd/gear_harness = -1,
			/obj/item/clothing/under/lewd/keyholesweater = -1,
			/obj/item/clothing/under/lewd/stripper/mankini = -1,
			/obj/item/clothing/under/swimsuit/black = -1,
			/obj/item/clothing/under/swimsuit/blue = -1,
			/obj/item/clothing/under/swimsuit/green = -1,
			/obj/item/clothing/under/swimsuit/purple = -1,
			/obj/item/clothing/under/swimsuit/red = -1,
			/obj/item/clothing/under/sexymime = -1,
			/obj/item/clothing/mask/gas/sexymime = -1,
			/obj/item/clothing/under/sexyclown = -1,
			/obj/item/clothing/mask/gas/sexyclown = -1,
			/obj/item/clothing/under/shorts/grey = -1,
			/obj/item/clothing/under/shorts/black = -1,
			/obj/item/clothing/under/shorts/red = -1,
			/obj/item/clothing/under/shorts/blue = -1,
			/obj/item/clothing/under/shorts/green = -1,
			/obj/item/clothing/under/dress/maid = -1,
			/obj/item/clothing/under/dress/maid/sexy = -1,
			/obj/item/clothing/shoes/high_heels = -1,
			/obj/item/clothing/shoes/high_heels/red = -1,
			/obj/item/clothing/head/bunny_ears = -1,
		),
	)

	prices = list()
