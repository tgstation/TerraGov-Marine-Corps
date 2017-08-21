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
	var/group = null
	var/randomised_num_contained = 0 //randomly picks X of items out of the contains list instead of using all.

/datum/supply_packs/New()
	if(randomised_num_contained)
		manifest += "Contains any [randomised_num_contained] of:"
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
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing
					)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	group = "Operations"

/datum/supply_packs/attachables
	name = "Rail Attachments crate"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/scope,
					/obj/item/attachable/reddot,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/quickfire
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Operations"

/datum/supply_packs/m_attachables
	name = "Muzzle Attachments crate"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/compensator
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Operations"

/datum/supply_packs/u_attachables
	name = "Underbarrel Attachments crate"
	contains = list(
					/obj/item/attachable/foregrip,
					/obj/item/attachable/gyro,
					/obj/item/attachable/bipod,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/flamer,
					/obj/item/attachable/burstfire_assembly
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Operations"

/datum/supply_packs/s_attachables
	name = "Stock Attachments crate"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/shotgun
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "stocks crate"
	group = "Operations"

/datum/supply_packs/beacons
	name = "Squad Beacons crate"
	contains = list(
					/obj/item/device/squad_tracking_beacon,
					/obj/item/device/squad_tracking_beacon,
					/obj/item/device/squad_beacon,
					/obj/item/device/squad_beacon,
					/obj/item/device/squad_beacon/bomb,
					/obj/item/device/squad_beacon/bomb
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "squad beacons crate"
	group = "Operations"

/datum/supply_packs/webbing
	name = "Webbings and Gun Belts crate"
	contains = list(/obj/item/clothing/tie/holster,
					/obj/item/clothing/tie/storage/brown_vest,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/weapon/storage/belt/gun/m4a3,
					/obj/item/weapon/storage/belt/gun/m44,
					/obj/item/weapon/storage/large_holster/m39
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "extra storage crate"
	group = "Operations"

/datum/supply_packs/pouches
	name = "Pouches crate"
	randomised_num_contained = 6
	contains = list(/obj/item/weapon/storage/pouch/general,
					/obj/item/weapon/storage/pouch/general/medium,
					/obj/item/weapon/storage/pouch/general/large,
					/obj/item/weapon/storage/pouch/firstaid/full,
					/obj/item/weapon/storage/pouch/bayonet,
					/obj/item/weapon/storage/pouch/pistol,
					/obj/item/weapon/storage/pouch/magazine,
					/obj/item/weapon/storage/pouch/magazine/large,
					/obj/item/weapon/storage/pouch/magazine/pistol,
					/obj/item/weapon/storage/pouch/magazine/pistol/large,
					/obj/item/weapon/storage/pouch/explosive,
					/obj/item/weapon/storage/pouch/medical,
					/obj/item/weapon/storage/pouch/syringe,
					/obj/item/weapon/storage/pouch/medkit,
					/obj/item/weapon/storage/pouch/document,
					/obj/item/weapon/storage/pouch/flare,
					/obj/item/weapon/storage/pouch/electronics,
					/obj/item/weapon/storage/pouch/construction,
					/obj/item/weapon/storage/pouch/radio,
					/obj/item/weapon/storage/pouch/survival
					)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "pouches crate"
	group = "Operations"


/datum/supply_packs/explosives
	name = "Explosives crate"
	contains = list(
					/obj/item/weapon/storage/box/explosive_mines,
					/obj/item/weapon/grenade/explosive,
					/obj/item/weapon/grenade/explosive,
					/obj/item/weapon/grenade/incendiary,
					/obj/item/weapon/grenade/incendiary,
					/obj/item/weapon/grenade/explosive/m15,
					/obj/item/weapon/grenade/explosive/m15
				)
	cost = 50
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosives crate (WARNING)"
	group = "Operations"

/datum/supply_packs/flares
	name = "Flare pack crate (M94)"
	contains = list(
					/obj/item/weapon/storage/box/m94,
					/obj/item/weapon/storage/box/m94,
					/obj/item/weapon/storage/box/m94,
					/obj/item/weapon/storage/box/m94
				)
	cost = 10
	containertype = /obj/structure/closet/crate/ammo
	containername = "flare pack crate"
	group = "Operations"


/datum/supply_packs/flamethrower
	name = "M240 Flamethrower crate"
	contains = list(
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank
				)
	cost = 50
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240 Incinerator crate"
	group = "Weapons"

/datum/supply_packs/weapons_sentry
	name = "UA 571-C sentry crate"
	contains = list(
				)
	cost = 120
	containertype = /obj/item/weapon/storage/box/sentry
	containername = "sentry crate"
	group = "Weapons"

/datum/supply_packs/ammo_regular
	name = "Regular Magazine crate"
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot
				)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_shotgun_regular
	name = "Shotgun Ammo Boxes crate"
	contains = list(
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot
				)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle
	name = "Large Ammo Box crate (M41A)"
	contains = list(/obj/item/big_ammo_box)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle_ap
	name = "Large AP Ammo Box crate (M41A)"
	contains = list(/obj/item/big_ammo_box/ap)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_smg
	name = "Large Ammo Box crate (M39)"
	contains = list(/obj/item/big_ammo_box/smg)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended
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
	containertype = /obj/structure/closet/crate/ammo
	containername = "extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap
	name = "Armor Piercing Magazine crate (M41A, M4A3, M39)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
				)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_black_market
	name = "Black Market ammo crate"
	randomised_num_contained = 6
	contains = list(
					/obj/item/ammo_magazine/revolver/upp,
					/obj/item/ammo_magazine/revolver/small,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/cmb,
					/obj/item/ammo_magazine/pistol/heavy,
					/obj/item/ammo_magazine/pistol/c99,
					/obj/item/ammo_magazine/pistol/automatic,
					/obj/item/ammo_magazine/pistol/holdout,
					/obj/item/ammo_magazine/pistol/highpower,
					/obj/item/ammo_magazine/pistol/vp70,
					/obj/item/ammo_magazine/pistol/vp78,
					/obj/item/ammo_magazine/smg/mp7,
					/obj/item/ammo_magazine/smg/skorpion,
					/obj/item/ammo_magazine/smg/ppsh,
					/obj/item/ammo_magazine/smg/ppsh/extended,
					/obj/item/ammo_magazine/smg/uzi,
					/obj/item/ammo_magazine/smg/p90,
					/obj/item/ammo_magazine/rifle/sniper/svd,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/mar40,
					/obj/item/ammo_magazine/rifle/mar40/extended,
					)
	cost = 40
	contraband = 1
	containertype = /obj/structure/closet/crate/ammo
	containername = "black market ammo crate"
	group = "Ammo"

//This crate has a little bit of everything, mostly okay stuff, but it does have some really unique picks.
/datum/supply_packs/surplus
	name = "Surplus Ammo crate"
	randomised_num_contained = 5
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/incendiary,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/hp,
					/obj/item/ammo_magazine/pistol/incendiary,
					/obj/item/ammo_magazine/pistol/m1911,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver/marksman,
					/obj/item/ammo_magazine/revolver/heavy,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/incendiary
				)
	cost = 50
	containertype = /obj/structure/closet/crate/ammo
	containername = "surplus ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartgun
	name = "M56 Smartgun Powerpack crate"
	contains = list(
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
				)
	cost = 25
	containertype = /obj/structure/closet/crate/ammo
	containername = "smartgun powerpack crate"
	group = "Ammo"


/datum/supply_packs/ammo_sniper
	name = "M42A Sniper Ammo crate"
	contains = list(
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/incendiary
				)
	cost = 25
	containertype = /obj/structure/closet/crate/ammo
	containername = "sniper ammo crate"
	group = "Ammo"




/datum/supply_packs/explosive_ammo_crate
	name = "SADAR Rocket Ammo crate"
	contains = list(
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp
				)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "SADAR ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sentry
	name = "UA 571-C Sentry ammunition"
	contains = list(
					/obj/item/sentry_ammo,
					/obj/item/sentry_ammo
					)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
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
	containername = "armor crate"
	group = "Armor"

/datum/supply_packs/armor_leader
	name = "M3 Pattern Squad Leader crate"
	contains = list(
					/obj/item/clothing/head/helmet/marine/leader,
					/obj/item/clothing/suit/storage/marine/leader
				)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "squad leader armor crate"
	group = "Armor"

/datum/supply_packs/mre
	name = "USCM MRE crate"
	contains = list(/obj/item/weapon/storage/box/MRE,
					/obj/item/weapon/storage/box/MRE,
					/obj/item/weapon/storage/box/MRE,
					/obj/item/weapon/storage/box/MRE,
					/obj/item/weapon/storage/box/MRE )
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper MRE crate"
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
	containername = "internals crate"
	group = "Supplies"

/datum/supply_packs/evacuation
	name = "\improper Emergency equipment"
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
	containername = "emergency crate"
	group = "Supplies"

/datum/supply_packs/inflatable
	name = "inflatable barriers"
	contains = list(/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable,
					/obj/item/weapon/storage/briefcase/inflatable)
	cost = 20
	containertype = /obj/structure/closet/crate/construction
	containername = "inflatable barriers crate"
	group = "Engineering"

/datum/supply_packs/janitor
	name = "\improper Janitorial supplies"
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
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper Janitorial supplies crate"
	group = "Supplies"

/datum/supply_packs/lightbulbs
	name = "replacement lights"
	contains = list(/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed,
					/obj/item/weapon/storage/box/lights/mixed)
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "replacement lights crate"
	group = "Engineering"

/datum/supply_packs/boxes
	name = "empty boxes"
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
	containertype = "/obj/structure/closet/crate/supply"
	containername = "empty box crate"
	group = "Supplies"

/datum/supply_packs/sandbags
	name = "empty sandbags crate"
	contains = list(/obj/item/stack/sandbags_empty)
	amount = 50
	cost = 15
	containertype = "/obj/structure/closet/crate/supply"
	containername = "empty sandbags crate"
	group = "Supplies"

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list(/obj/item/weapon/storage/box/autoinjectors,
					/obj/item/weapon/storage/box/syringes,
					/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,
					/obj/item/weapon/reagent_containers/glass/bottle/bicaridine,
					/obj/item/weapon/reagent_containers/glass/bottle/dexalin,
					/obj/item/weapon/reagent_containers/glass/bottle/spaceacillin,
					/obj/item/weapon/reagent_containers/glass/bottle/kelotane,
					/obj/item/weapon/reagent_containers/glass/bottle/tramadol,
					/obj/item/weapon/storage/pill_bottle/inaprovaline,
					/obj/item/weapon/storage/pill_bottle/antitox,
					/obj/item/weapon/storage/pill_bottle/bicaridine,
					/obj/item/weapon/storage/pill_bottle/dexalin,
					/obj/item/weapon/storage/pill_bottle/spaceacillin,
					/obj/item/weapon/storage/pill_bottle/kelotane,
					/obj/item/weapon/storage/pill_bottle/tramadol,
					/obj/item/weapon/storage/box/pillbottles)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"


/datum/supply_packs/firstaid
	name = "First-aid kit crate"
	contains = list(/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/regular,
					/obj/item/weapon/storage/firstaid/fire,
					/obj/item/weapon/storage/firstaid/toxin,
					/obj/item/weapon/storage/firstaid/o2,
					/obj/item/weapon/storage/firstaid/adv,
					/obj/item/weapon/storage/firstaid/adv)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"


/datum/supply_packs/bodybag
	name = "Body bag crate"
	contains = list(/obj/item/weapon/storage/box/bodybags,
                    /obj/item/weapon/storage/box/bodybags,
                    /obj/item/weapon/storage/box/bodybags)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "body bag crate"
	group = "Medical"

/datum/supply_packs/cryobag
	name = "Stasis bag crate"
	contains = list(/obj/item/bodybag/cryobag,
				    /obj/item/bodybag/cryobag,
	    			/obj/item/bodybag/cryobag)
	cost = 40
	containertype = /obj/structure/closet/crate/medical
	containername = "stasis bag crate"
	group = "Medical"


/datum/supply_packs/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "metal sheets crate"
	group = "Engineering"

/datum/supply_packs/plas50
	name = "30 plasteel sheets"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 30
	cost = 50
	containertype = /obj/structure/closet/crate/supply
	containername = "plasteel sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "glass sheets crate"
	group = "Engineering"

/datum/supply_packs/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "wooden planks crate"
	group = "Engineering"

/datum/supply_packs/smescoil
	name = "Superconducting Magnetic Coil"
	contains = list(/obj/item/weapon/smes_coil)
	cost = 150
	containertype = /obj/structure/closet/crate/construction
	containername = "superconducting magnetic coil crate"
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
	containertype = /obj/structure/closet/crate/construction
	containername = "electrical maintenance crate"
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
	containertype = /obj/structure/closet/crate/construction
	containername = "mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = "Engineering"

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
	containername = "phoron assembly crate"
	access = ACCESS_MARINE_ENGINEERING
	group = "Science"

/datum/supply_packs/contraband
	randomised_num_contained = 5
	contains = list(/obj/item/seeds/bloodtomatoseed,
					/obj/item/weapon/storage/pill_bottle/zoom,
					/obj/item/weapon/storage/pill_bottle/happy,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine)

	name = "Contraband crate"
	cost = 50
	containertype = /obj/structure/closet/crate/supply
	containername = "unlabeled crate"
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
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/sterile
	name = "Sterile equipment crate"
	contains = list(/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/weapon/storage/box/masks,
					/obj/item/weapon/storage/box/gloves)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "sterile equipment crate"
	group = "Medical"

/datum/supply_packs/pacman_parts
	name = "P.A.C.M.A.N. portable generator parts"
	cost = 45
	containername = "\improper P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(/obj/item/weapon/stock_parts/micro_laser,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/circuitboard/pacman)

/datum/supply_packs/super_pacman_parts
	name = "Super P.A.C.M.A.N. portable generator parts"
	cost = 55
	containername = "\improper Super P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(/obj/item/weapon/stock_parts/micro_laser,
					/obj/item/weapon/stock_parts/capacitor,
					/obj/item/weapon/stock_parts/matter_bin,
					/obj/item/weapon/circuitboard/pacman/super)

/datum/supply_packs/officer_outfits
	contains = list(
					/obj/item/clothing/under/rank/ro_suit,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/exec,
					/obj/item/clothing/under/marine/officer/ce
					)
	name = "Officer outfit closet"
	cost = 45
	containertype = /obj/structure/closet
	containername = "officer dress closet"
	group = "Clothing"

/datum/supply_packs/marine_outfits
	contains = list(
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
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
	containername = "marine outfit closet"
	group = "Clothing"

/datum/supply_packs/gun
	randomised_num_contained = 6
	contains = list()
	name = "Weyland-Yutani firearms (x3)"
	cost = 40
	containertype = /obj/structure/largecrate/guns
	containername = "\improper Weyland-Armat firearms crate"
	group = "Weapons"

/datum/supply_packs/gun/merc
	contains = list()
	name = "Black Market firearm (x1)"
	cost = 25
	contraband = 1
	containertype = /obj/structure/largecrate/guns/merc
	containername = "\improper black market firearms crate"
	group = "Weapons"


/datum/supply_packs/gun_holster
	contains = list(/obj/item/weapon/storage/large_holster/m39,
					/obj/item/weapon/storage/large_holster/m39)
	name = "M39 Holster crate"
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "holster crate"
	group = "Weapons"

/datum/supply_packs/gun_holster/m44
	name = "M44 Holster crate"
	cost = 15
	contains = list(/obj/item/weapon/storage/belt/gun/m44,
					/obj/item/weapon/storage/belt/gun/m44)

/datum/supply_packs/gun_holster/m4a3
	name = "M4A3 Holster crate"
	cost = 15
	contains = list(/obj/item/weapon/storage/belt/gun/m4a3,
					/obj/item/weapon/storage/belt/gun/m4a3)
