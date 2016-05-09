//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

//var/list/all_supply_groups = list("Operations","Security","Hospitality","Engineering","Atmospherics","Medical","Science","Hydroponics", "Supply", "Miscellaneous")

var/list/all_supply_groups = list("Operations","Supplies","Engineering","Weapons","Ammo","Armor","Medical", "Clothing", "Science")

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = "Operations"

/datum/supply_packs/New()
	manifest += "<ul>"
	for(var/atom/movable/path in contains)
		if(!path)	continue
		manifest += "<li>[initial(path.name)]</li>"
	manifest += "</ul>"

/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/weapon/grenade/smokebomb,
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/mask/gas/swat)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "Special Ops crate"
	group = "Operations"

/datum/supply_packs/attachables
	name = "Rail Attachments"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/scope,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/quickfire
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "Attachables crate"
	group = "Operations"

/datum/supply_packs/m_attachables
	name = "Muzzle Attachments"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/compensator
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "Attachables crate"
	group = "Operations"

/datum/supply_packs/u_attachables
	name = "Underbarrel Attachments"
	contains = list(
					/obj/item/attachable/foregrip,
					/obj/item/attachable/gyro,
					/obj/item/attachable/bipod,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/flamer,
					/obj/item/attachable/burstfire_assembly
					)
	cost = 45
	containertype = /obj/structure/closet/crate
	containername = "Attachables crate"
	group = "Operations"

/datum/supply_packs/beacons
	name = "Squad Beacons"
	contains = list(
					/obj/item/device/squad_beacon,
					/obj/item/device/squad_beacon,
					/obj/item/device/squad_beacon/bomb,
					/obj/item/device/squad_beacon/bomb
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Squad Beacons crate"
	group = "Operations"

/datum/supply_packs/webbing
	name = "Webbing crate"
	contains = list(/obj/item/clothing/tie/holster,
					/obj/item/clothing/tie/storage/brown_vest,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "Webbing crate"
	group = "Operations"

/datum/supply_packs/explosives
	name = "Explosives crate"
	contains = list(
					/obj/item/weapon/storage/box/explosive_mines,
					/obj/item/weapon/storage/box/explosive_mines,
					/obj/item/weapon/storage/box/explosive_mines,
					/obj/item/weapon/grenade/explosive,
					/obj/item/weapon/grenade/explosive,
					/obj/item/weapon/grenade/incendiary
				)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "Explosives crate (WARNING)"
	group = "Operations"

/datum/supply_packs/weapons_inc
	name = "M240 Incinerator crate"
	contains = list(
					/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/flamethrower/full,
					/obj/item/weapon/tank/phoron/m240,
					/obj/item/weapon/tank/phoron/m240,
					/obj/item/weapon/tank/phoron/m240
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "M240 Incinerator crate"
	group = "Weapons"

/datum/supply_packs/weapons_sentry
	name = "UA 571-C sentry crate"
	contains = list(
				)
	cost = 120
	containertype = /obj/item/weapon/storage/box/sentry
	containername = "Sentry crate"
	group = "Weapons"

/datum/supply_packs/ammo_sentry
	name = "UA 571-C Sentry ammunition"
	contains = list(
					/obj/item/sentry_ammo,
					/obj/item/sentry_ammo
					)
	cost = 60
	containertype = /obj/structure/closet/crate
	containername = "Ammo crate"
	group = "Ammo"


/datum/supply_packs/ammo_exotic
	name = "Exotic Ammo crate (M42c, M56)"
	contains = list(
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/incendiary
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_exotic
	name = "Extended Magazine crate (M41A, M4A3, M39)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Ammo crate"
	group = "Ammo"

/datum/supply_packs/explosive_ammo_crate
	name = "Explosive Ammo crate (SADAR rockets)"
	contains = list(
					/obj/item/ammo_magazine/rocket_tube,
					/obj/item/ammo_magazine/rocket_tube,
					/obj/item/ammo_magazine/rocket_tube/ap,
					/obj/item/ammo_magazine/rocket_tube/ap,
					/obj/item/ammo_magazine/rocket_tube/wp,
					/obj/item/ammo_magazine/rocket_tube/wp
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Ammo crate"
	group = "Ammo"

/datum/supply_packs/armor_basic
	name = "M3 Pattern armor crate"
	contains = list(
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "Armor crate"
	group = "Armor"

/datum/supply_packs/armor_leader
	name = "M3 Pattern Squad Leader crate"
	contains = list(
					/obj/item/clothing/head/helmet/marine/leader,
					/obj/item/clothing/suit/storage/marine/marine_leader_armor
				)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "Armor crate"
	group = "Armor"

/datum/supply_packs/food
	name = "Kitchen supply crate"
	contains = list(/obj/item/weapon/reagent_containers/food/snacks/flour,
					/obj/item/weapon/reagent_containers/food/snacks/flour,
					/obj/item/weapon/reagent_containers/food/snacks/flour,
					/obj/item/weapon/reagent_containers/food/snacks/flour,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/reagent_containers/food/drinks/milk,
					/obj/item/weapon/storage/fancy/egg_box,
					/obj/item/weapon/reagent_containers/food/snacks/tofu,
					/obj/item/weapon/reagent_containers/food/snacks/tofu,
					/obj/item/weapon/reagent_containers/food/snacks/meat,
					/obj/item/weapon/reagent_containers/food/snacks/meat,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
					/obj/item/weapon/reagent_containers/food/snacks/grown/banana)
	cost = 15
	containertype = /obj/structure/closet/crate/freezer
	containername = "Food crate"
	group = "Supplies"

/datum/supply_packs/food2
	name = "USCM MRE crate"
	contains = list(/obj/item/weapon/storage/box/uscm_mre,
					/obj/item/weapon/storage/box/uscm_mre,
					/obj/item/weapon/storage/box/uscm_mre,
					/obj/item/weapon/storage/box/uscm_mre,
					/obj/item/weapon/storage/box/uscm_mre )
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "MRE crate"
	group = "Supplies"

/datum/supply_packs/food3
	name = "Weyland-Yutani brand MRE crate"
	contains = list(/obj/item/weapon/storage/box/wy_mre,
					/obj/item/weapon/storage/box/wy_mre,
					/obj/item/weapon/storage/box/wy_mre,
					/obj/item/weapon/storage/box/wy_mre,
					/obj/item/weapon/storage/box/wy_mre
					)
	cost = 12
	containertype = /obj/structure/closet/crate/freezer
	containername = "W-Y MRE crate"
	group = "Supplies"

/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list (/obj/item/weapon/storage/box/monkeycubes,
					/obj/item/weapon/storage/box/monkeycubes)
	cost = 20
	containertype = /obj/structure/closet/crate/freezer
	containername = "Monkey crate"
	group = "Supplies"

/datum/supply_packs/internals
	name = "Oxygen Internals crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air,
					/obj/item/weapon/tank/air)
	cost = 10
	containertype = /obj/structure/closet/crate/internals
	containername = "Internals crate"
	group = "Supplies"

/datum/supply_packs/evacuation
	name = "Emergency equipment"
	contains = list(/obj/item/weapon/storage/toolbox/emergency,
					/obj/item/weapon/storage/toolbox/emergency,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/weapon/tank/emergency_oxygen,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas)
	cost = 15
	containertype = /obj/structure/closet/crate/internals
	containername = "Emergency crate"
	group = "Supplies"

/datum/supply_packs/inflatable
	name = "Inflatable barriers"
	contains = list(/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "Inflatable Barrier Crate"
	group = "Engineering"

/datum/supply_packs/janitor
	name = "Janitorial supplies"
	contains = list(/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/reagent_containers/glass/bucket,
					/obj/item/weapon/mop,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/caution,
					/obj/item/weapon/storage/bag/trash,
					/obj/item/weapon/reagent_containers/spray/cleaner,
					/obj/item/weapon/reagent_containers/glass/rag,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/item/weapon/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket,
					/obj/item/weapon/paper/janitor)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Janitorial supplies"
	group = "Supplies"

/datum/supply_packs/lightbulbs
	name = "Replacement lights"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Replacement lights"
	group = "Engineering"

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list(/obj/machinery/bot/mulebot)
	cost = 160
	containertype = /obj/structure/largecrate/mule
	containername = "MULEbot Crate"
	group = "Supplies"

/datum/supply_packs/boxes
	name = "Empty boxes"
	contains = list(/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box,
	/obj/item/weapon/storage/box)
	cost = 10
	containertype = "/obj/structure/closet/crate"
	containername = "Empty box crate"
	group = "Supplies"

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/storage/box/autoinjectors)
	cost = 25
	containertype = /obj/structure/closet/crate/medical
	containername = "Medical crate"
	group = "Medical"

/datum/supply_packs/bodybag
	name = "Body bag crate"
	contains = list(/obj/item/weapon/storage/box/bodybags,
                    /obj/item/weapon/storage/box/bodybags,
                    /obj/item/weapon/storage/box/bodybags)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "Body bag crate"
	group = "Medical"

/datum/supply_packs/cryobag
	name = "Stasis bag crate"
	contains = list(/obj/item/bodybag/cryobag,
				    /obj/item/bodybag/cryobag,
	    			/obj/item/bodybag/cryobag)
	cost = 40
	containertype = /obj/structure/closet/crate/medical
	containername = "Stasis bag crate"
	group = "Medical"


/datum/supply_packs/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Metal sheets crate"
	group = "Engineering"

/datum/supply_packs/plas50
	name = "30 plasteel sheets"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 30
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "Plasteel sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Glass sheets crate"
	group = "Engineering"

/datum/supply_packs/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Wooden planks crate"
	group = "Engineering"

/datum/supply_packs/smescoil
	name = "Superconducting Magnetic Coil"
	contains = list(/obj/item/weapon/smes_coil)
	cost = 150
	containertype = /obj/structure/closet/crate
	containername = "Superconducting Magnetic Coil crate"
	group = "Engineering"

/datum/supply_packs/electrical
	name = "Electrical maintenance crate"
	contains = list(/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/weapon/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell,
					/obj/item/weapon/cell/high,
					/obj/item/weapon/cell/high)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Electrical maintenance crate"
	group = "Engineering"

/datum/supply_packs/mechanical
	name = "Mechanical maintenance crate"
	contains = list(/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/weapon/storage/belt/utility/full,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "Mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = "Engineering"

/datum/supply_packs/solar
	name = "Solar Pack crate"
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/weapon/circuitboard/solar_control,
					/obj/item/weapon/tracker_electronics,
					/obj/item/weapon/paper/solar)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "Solar pack crate"
	group = "Engineering"

/*/datum/supply_packs/engine
	name = "Emitter crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 40
	containertype = /obj/structure/closet/crate/secure
	containername = "Emitter crate"
	access = access_sulaco_CE
	group = "Engineering"*/

/datum/supply_packs/engine/field_gen
	name = "Field Generator crate"
	contains = list(/obj/machinery/field_generator,
					/obj/machinery/field_generator)
	containertype = /obj/structure/closet/crate/secure
	containername = "Field Generator crate"
	access = access_sulaco_CE
	group = "Engineering"
	cost = 30

/datum/supply_packs/engine/collector
	name = "Collector crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	containertype = /obj/structure/closet/crate
	containername = "Collector crate"
	group = "Engineering"
	cost = 30

/datum/supply_packs/hoverpod
	name = "Hoverpod Shipment"
	contains = list()
	cost = 150
	containertype = /obj/structure/largecrate/hoverpod
	containername = "Hoverpod Crate"
	group = "Operations"

/datum/supply_packs/phoron
	name = "Phoron assembly crate"
	contains = list(/obj/item/weapon/tank/phoron,
					/obj/item/weapon/tank/phoron,
					/obj/item/weapon/tank/phoron,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/phoron
	containername = "Phoron assembly crate"
	access = access_sulaco_engineering
	group = "Science"


/datum/supply_packs/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()

/datum/supply_packs/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/seeds/bloodtomatoseed,
					/obj/item/weapon/storage/pill_bottle/zoom,
					/obj/item/weapon/storage/pill_bottle/happy,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine)

	name = "Contraband crate"
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "Unlabeled crate"
	contraband = 1
	group = "Operations"

/datum/supply_packs/surgery
	name = "Surgery crate"
	contains = list(/obj/item/weapon/cautery,
					/obj/item/weapon/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/weapon/tank/anesthetic,
					/obj/item/weapon/FixOVein,
					/obj/item/weapon/hemostat,
					/obj/item/weapon/scalpel,
					/obj/item/weapon/bonegel,
					/obj/item/weapon/retractor,
					/obj/item/weapon/bonesetter,
					/obj/item/weapon/circular_saw)
	cost = 25
	containertype = "/obj/structure/closet/crate/secure"
	containername = "Surgery crate"
	access = access_sulaco_medbay
	group = "Medical"

/datum/supply_packs/sterile
	name = "Sterile equipment crate"
	contains = list(/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/weapon/storage/box/masks,
					/obj/item/weapon/storage/box/gloves)
	cost = 15
	containertype = "/obj/structure/closet/crate"
	containername = "Sterile equipment crate"
	group = "Medical"

//... Maybe later.
/*
/datum/supply_packs/randomised/pizza
	num_contained = 5
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable)
	name = "Surprise pack of five pizzas"
	cost = 15
	containertype = /obj/structure/closet/crate/freezer
	containername = "Pizza crate"
	group = "Hospitality"
*/

/datum/supply_packs/smbig
	name = "Supermatter Core"
	contains = list(/obj/machinery/power/supermatter)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/phoron
	containername = "Supermatter crate (CAUTION)"
	group = "Engineering"

/datum/supply_packs/radsuit
	contains = list(/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation)
	name = "Radiation suits package"
	cost = 20
	containertype = /obj/structure/closet/radiation
	containername = "Radiation suit locker"
	group = "Engineering"

/datum/supply_packs/pacman_parts
	name = "P.A.C.M.A.N. portable generator parts"
	cost = 45
	containername = "P.A.C.M.A.N. Portable Generator Construction Kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(/obj/item/weapon/stock_parts/micro_laser,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/circuitboard/pacman)

/datum/supply_packs/super_pacman_parts
	name = "Super P.A.C.M.A.N. portable generator parts"
	cost = 55
	containername = "Super P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(/obj/item/weapon/stock_parts/micro_laser,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/circuitboard/pacman/super)

/datum/supply_packs/randomised/dresses
	name = "Womens formal dress locker"
	containername = "Pretty dress locker"
	containertype = /obj/structure/closet
	cost = 45
	num_contained = 4
	contains = list(/obj/item/clothing/under/wedding/bride_orange,
					/obj/item/clothing/under/wedding/bride_purple,
					/obj/item/clothing/under/wedding/bride_blue,
					/obj/item/clothing/under/wedding/bride_red,
					/obj/item/clothing/under/wedding/bride_white,
					/obj/item/clothing/under/sundress,
					/obj/item/clothing/under/dress/dress_green,
					/obj/item/clothing/under/dress/dress_pink,
					/obj/item/clothing/under/dress/dress_orange,
					/obj/item/clothing/under/dress/dress_yellow,
					/obj/item/clothing/under/dress/dress_saloon)
	group = "Clothing"

/datum/supply_packs/officer_outfits
	contains = list(
					/obj/item/clothing/under/rank/ro_suit,
					/obj/item/clothing/under/marine/officer/logistics,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/exec,
					/obj/item/clothing/under/marine/officer/ce
					)
	name = "Officer outfit closet"
	cost = 45
	containertype = /obj/structure/closet
	containername = "Officer dress closet"
	group = "Clothing"

/datum/supply_packs/marine_outfits
	contains = list(
					/obj/item/clothing/under/marine_jumpsuit,
					/obj/item/clothing/under/marine_jumpsuit,
					/obj/item/clothing/under/marine_jumpsuit,
					/obj/item/clothing/under/marine_jumpsuit,
					/obj/item/clothing/under/marine_jumpsuit,
					/obj/item/weapon/storage/belt/marine,
					/obj/item/weapon/storage/belt/marine,
					/obj/item/weapon/storage/belt/marine,
					/obj/item/weapon/storage/backpack/marine,
					/obj/item/weapon/storage/backpack/marine,
					/obj/item/weapon/storage/backpack/marine,
					/obj/item/weapon/storage/backpack/marine,
					/obj/item/weapon/storage/backpack/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine
					)
	name = "Marine outfit closet"
	cost = 25
	containertype = /obj/structure/closet
	containername = "Marine outfit closet"
	group = "Clothing"

/datum/supply_packs/formal_wear
	contains = list(/obj/item/clothing/head/bowler,
					/obj/item/clothing/head/that,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/under/suit_jacket,
					/obj/item/clothing/under/suit_jacket/female,
					/obj/item/clothing/under/suit_jacket/really_black,
					/obj/item/clothing/under/suit_jacket/red,
					/obj/item/clothing/under/lawyer/bluesuit,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/shoes/leather,
					/obj/item/clothing/suit/wcoat)
	name = "Formalwear closet"
	cost = 40
	containertype = /obj/structure/closet
	containername = "Formalwear for the best occasions."
	group = "Clothing"

/datum/supply_packs/randomised
	var/num_contained = 5 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/HoS,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	name = "Collectable hat crate!"
	cost = 200
	containertype = /obj/structure/closet/crate
	containername = "Collectable hats crate! Brought to you by Bass.inc!"
	group = "Clothing"

/datum/supply_packs/randomised/guns
	contains = list()
	name = "Weyland-Yutani firearms (x3)"
	cost = 40
	containertype = /obj/structure/largecrate/guns
	containername = "Weyland-Armat firearms crate"
	group = "Weapons"

/datum/supply_packs/randomised/guns/merc
	contains = list()
	name = "Black Market firearm (x1)"
	cost = 25
	containertype = /obj/structure/largecrate/guns/merc
	containername = "Black market firearms crate"
	group = "Weapons"

/datum/supply_packs/randomised/guns/slavic
	contains = list()
	name = "Nagant-Yamasaki firearm (x1)"
	cost = 80
	containertype = /obj/structure/largecrate/guns/russian
	containername = "Nagant-Yamasaki firearms crate"
	group = "Weapons"
