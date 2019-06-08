//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

#define RO_PRICE_NEAR_FREE		10
#define RO_PRICE_VERY_CHEAP		20
#define RO_PRICE_CHEAP			30
#define RO_PRICE_NORMAL			40
#define RO_PRICE_PRICY			60
#define RO_PRICE_KINDA_PRICY	50
#define RO_PRICE_PRETTY_PRICY	80
#define RO_PRICE_VERY_PRICY		100
#define RO_PRICE_MAX_PRICY		120

var/list/all_supply_groups = list("Operations", "Weapons", "Hardpoint Modules", "Attachments", "Ammo", "Armor", "Clothing", "Medical", "Engineering", "Science", "Supplies")

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = null
	var/randomised_num_contained = 0 //Randomly picks X of items out of the contains list instead of using all.

/datum/supply_packs/New()
	if(randomised_num_contained)
		manifest += "Contains any [randomised_num_contained] of:"
	manifest += "<ul>"
	for(var/atom/movable/path in contains)
		if(!path)	continue
		manifest += "<li>[initial(path.name)]</li>"
	manifest += "</ul>"


/datum/supply_packs/proc/generate(atom/movable/location)
	for(var/i in contains)
		var/atom/movable/AM = i
		new AM(location)


/*******************************************************************************
OPERATIONS
*******************************************************************************/


/datum/supply_packs/specialops
	name = "special operations crate (operator kit x1)"
	contains = list(
					/obj/item/weapon/gun/pistol/b92fs/M9,
					/obj/item/ammo_magazine/pistol/b92fstranq,
					/obj/item/clothing/under/syndicate/combat,
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/tie/storage/black_vest
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper spec ops crate"
	group = "Operations"

/datum/supply_packs/beacons_supply
	name = "supply beacons crate (x2)"
	contains = list(
			/obj/item/squad_beacon,
			/obj/item/squad_beacon
			)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper supply beacons crate"
	group = "Operations"

/datum/supply_packs/beacons_orbital
	name = "orbital beacons crate (x2)"
	contains = list(
					/obj/item/squad_beacon/bomb,
					/obj/item/squad_beacon/bomb
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "\improper orbital beacons crate"
	group = "Operations"

/datum/supply_packs/binoculars_regular
	name = "binoculars crate (x1)"
	contains = list(
					/obj/item/binoculars
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper binoculars crate"
	group = "Operations"

/datum/supply_packs/binoculars_tatical
	name = "tactical binoculars crate (x1)"
	contains = list(
					/obj/item/binoculars/tactical
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper tactical binoculars crate"
	group = "Operations"

/datum/supply_packs/flares
	name = "flare packs crate (x20)"
	contains = list(
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper flare pack crate"
	group = "Operations"

/datum/supply_packs/alpha
	name = "Alpha Supply Crate"
	contains = list(
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/alpha
	containername = "\improper Alpha Supply Crate"
	group = "Operations"

/datum/supply_packs/bravo
	name = "Bravo Supply Crate"
	contains = list(
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/bravo
	containername = "\improper Bravo Supply Crate"
	group = "Operations"

/datum/supply_packs/charlie
	name = "Charlie Supply Crate"
	contains = list(
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/charlie
	containername = "\improper Charlie Supply Crate"
	group = "Operations"

/datum/supply_packs/delta
	name = "Delta Supply Crate"
	contains = list(
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/delta
	containername = "\improper Delta Supply Crate"
	group = "Operations"

/datum/supply_packs/tarps
	name = "V1 thermal-dampening tarp crate (x5)"
	contains = list(
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper V1 thermal-dampening tarp crate"
	group = "Operations"

/datum/supply_packs/contraband
	randomised_num_contained = 5
	contains = list(
					/obj/item/seeds/bloodtomatoseed,
					/obj/item/storage/pill_bottle/zoom,
					/obj/item/storage/pill_bottle/happy,
					/obj/item/reagent_container/food/drinks/bottle/pwine
					)

	name = "contraband crate"
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper unlabeled crate"
	contraband = 1
	group = "Operations"


/*******************************************************************************
WEAPONS
*******************************************************************************/

/datum/supply_packs/specgrenadier
	name = "Grenadier Specialist crate (M92 x1)"
	contains = list(
					/obj/item/weapon/gun/launcher/m92
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Grenadier Specialist crate"
	group = "Weapons"

/datum/supply_packs/specscout
	name = "Scout Specialist crate (M4RA x1)"
	contains = list(
					/obj/item/weapon/gun/rifle/m4ra
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Scout Specialist crate"
	group = "Weapons"

/datum/supply_packs/specdemo
	name = "Demolitionist Specialist crate (M5 RPG x1)"
	contains = list(
					/obj/item/weapon/gun/launcher/rocket
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Demolitionist Specialist crate"
	group = "Weapons"

/datum/supply_packs/specpyro
	name = "Pyro Specialist crate (M240T x1)"
	contains = list(
					/obj/item/weapon/gun/flamer/M240T
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Pyro Specialist crate"
	group = "Weapons"

/datum/supply_packs/specsniper
	name = "Sniper Specialist crate (M42A x1)"
	contains = list(
					/obj/item/weapon/gun/rifle/sniper/M42A
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Sniper Specialist crate"
	group = "Weapons"

/datum/supply_packs/specminigun
	name = "MIC-A7 Vindicator Minigun crate (MIC-A7 x1)"
	contains = list(
					/obj/item/weapon/gun/minigun
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper MIC A7 Vindicator Minigun crate"
	group = "Weapons"

/datum/supply_packs/specshotgun
	name = "ZX-76 Assault Shotgun crate (ZX-76 x1)"
	contains = list(
					/obj/item/weapon/gun/shotgun/merc/scout
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper ZX-76 Assault Shotgun crate"
	group = "Weapons"


/datum/supply_packs/flamethrower
	name = "M240 Flamethrower crate (M240 x3)"
	contains = list(
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240 Flamethrower crate"
	group = "Weapons"

/datum/supply_packs/weapons_sentry
	name = "UA 571-C sentry crate (x1)"
	contains = list(
					/obj/item/storage/box/sentry
					)
	cost = RO_PRICE_MAX_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper sentry crate"
	group = "Weapons"

/datum/supply_packs/weapons_minisentry
	name = "UA-580 point defense sentry crate (x1)"
	contains = list(
					/obj/item/storage/box/minisentry
					)
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper mini-sentry crate"
	group = "Weapons"

/datum/supply_packs/weapons_m56d_emplacement
	name = "M56D mounted smartgun crate (x1)"
	contains = list(
					/obj/item/storage/box/m56d_hmg
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M56D emplacement crate"
	group = "Weapons"

/datum/supply_packs/gun/pistols
	contains = list(
					/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/weapon/gun/revolver/m44,
					/obj/item/weapon/gun/revolver/m44,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver
					)
	name = "surplus sidearms crate (M4A3 x2, M44 x2, ammo x2 each)"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper sidearms crate"
	group = "Weapons"

/datum/supply_packs/gun/shotguns
	contains = list(
					/obj/item/weapon/gun/shotgun/pump,
					/obj/item/weapon/gun/shotgun/pump,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/shotgun/flechette
					)
	name = "surplus shotguns crate (M37A2 x2, M37A2 ammo x2 each)"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper shotguns crate"
	group = "Weapons"

/datum/supply_packs/gun/smgs
	contains = list(
					/obj/item/weapon/gun/smg/m39,
					/obj/item/weapon/gun/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	name = "surplus SMG crate (M39 x2, M39 ammo x2 AP, 2x Standard)"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper SMGs crate"
	group = "Weapons"

/datum/supply_packs/gun/rifles
	contains = list(
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap
					)
	name = "surplus rifles crate (M41A x2, M41A ammo x2 AP, 2x Standard)"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper rifles crate"
	group = "Weapons"

/datum/supply_packs/gun/lasrifle
	contains = list(
					/obj/item/weapon/gun/energy/lasgun/M43,
					/obj/item/weapon/gun/energy/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43
					)
	name = "surplus lasrifle crate (M43 lasgun x2, M43 battery packs x2)"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper lasrifle crate"
	group = "Weapons"

/datum/supply_packs/gun/heavyrifle
	contains = list(
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg
					)
	name = "M41AE2 HPR crate (HPR x1, HPR ammo box x1)"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper M41AE2 HPR crate"
	group = "Weapons"

/datum/supply_packs/gun/heavyrifle_squad
	contains = list(
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg
					)
	name = "M41AE2 HPR squad crate (HPR x5, HPR ammo box x5)"
	cost = RO_PRICE_PRETTY_PRICY
	containertype = /obj/structure/closet/crate
	containername = "\improper M41AE2 HPR squad crate"
	group = "Weapons"

/datum/supply_packs/gun/combatshotgun
	contains = list(
					/obj/item/weapon/gun/shotgun/combat,
					/obj/item/ammo_magazine/shotgun/,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/flechette
					)
	name = "MK221 tactical shotgun crate"
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "\improper MK221 tactical shotgun crate"
	group = "Weapons"

/datum/supply_packs/gun/merc
	contains = list()
	name = "black market firearms (x1)"
	cost = RO_PRICE_CHEAP
	contraband = 1
	containertype = /obj/structure/largecrate/guns/merc
	containername = "\improper black market firearms crate"
	group = "Weapons"

/datum/supply_packs/gun_holster
	contains = list(
					/obj/item/storage/large_holster/m39,
					/obj/item/storage/large_holster/m39
					)
	name = "M39 holster crate (x2)"
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate
	containername = "\improper holster crate"
	group = "Weapons"

/datum/supply_packs/gun_holster/m44
	name = "M44 holster crate (x2)"
	cost = RO_PRICE_NEAR_FREE
	contains = list(
					/obj/item/storage/belt/gun/m44,
					/obj/item/storage/belt/gun/m44
					)
	group = "Weapons"

/datum/supply_packs/gun_holster/m4a3
	name = "M4A3 holster crate (x2)"
	cost = RO_PRICE_NEAR_FREE
	contains = list(
					/obj/item/storage/belt/gun/m4a3,
					/obj/item/storage/belt/gun/m4a3
					)
	group = "Weapons"

/datum/supply_packs/explosives
	name = "surplus explosives crate (claymore mine x4, M40 HIDP x2, M40 HEDP x2, M15 HE x2)"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosives crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_mines
	name = "claymore mines crate (x8)"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/storage/box/explosive_mines
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive mine boxes crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_m15
	name = "M15 high explosive grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M15 grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_incendiary
	name = "M40 HIDP incendiary grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 HIDP incendiary grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_M40_HEDP
	name = "M40 HEDP high explosive grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 HEDP grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_M40_IMDP
	name = "M40 IMDP impact grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/impact,
					/obj/item/explosive/grenade/impact,
					/obj/item/explosive/grenade/impact,
					/obj/item/explosive/grenade/impact,
					/obj/item/explosive/grenade/impact,
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 IMDP grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hedp
	name = "M40 HEDP high explosive grenade box crate (x25)"
	contains = list(
					/obj/item/storage/box/nade_box
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HEDP grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hidp
	name = "M40 HIDP incendiary explosive grenade box crate (x15)"
	contains = list(
					/obj/item/storage/box/nade_box/HIDP
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HIDP grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_m15
	name = "M15 fragmentation grenade box crate (x25)"
	contains = list(
					/obj/item/storage/box/nade_box/M15
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper Fragmentation M15 grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_imdp
	name = "M40 IMDP impact grenade box crate (x25)"
	contains = list(
					/obj/item/storage/box/nade_box/impact
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive IMDP grenade crate (WARNING)"
	group = "Weapons"


/datum/supply_packs/plastique
	name = "plastic explosives crate (x5)"
	contains = list(
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper plastic explosives crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/mortar
	name = "M402 mortar crate (x1)"
	contains = list(
					/obj/item/mortar_kit
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M402 mortar crate"
	group = "Weapons"

/datum/supply_packs/detpack
	name = "detpack explosives crate (x6)"
	contains = list(
					/obj/item/radio/detpack,
					/obj/item/radio/detpack,
					/obj/item/radio/detpack,
					/obj/item/radio/detpack,
					/obj/item/radio/detpack,
					/obj/item/radio/detpack,
					/obj/item/assembly/signaler,
					/obj/item/assembly/signaler,
					/obj/item/assembly/signaler,
					)
	cost = RO_PRICE_KINDA_PRICY
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper detpack explosives crate (WARNING)"
	group = "Weapons"

/*******************************************************************************
HARDPOINT MODULES (and their ammo)
*******************************************************************************/

/datum/supply_packs/ltb_cannon
	name = "LTB Cannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/primary/cannon)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun
	name = "LTAA-AP Minigun Assembly (x1)"
	contains = list(/obj/item/hardpoint/primary/minigun)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/flamer_module
	name = "Secondary Flamer Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/flamer)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/towlauncher
	name = "Secondary TOW Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/towlauncher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/m56_cupola
	name = "Secondary M56 Cupola Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/m56cupola)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_glauncher
	name = "Secondary Grenade Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/grenade_launcher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_slauncher
	name = "Smoke Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/support/smoke_launcher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/weapons_sensor
	name = "Weapons Sensor Array (x1)"
	contains = list(/obj/item/hardpoint/support/weapons_sensor)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/artillery_module
	name = "Artillery Module (x1)"
	contains = list(/obj/item/hardpoint/support/artillery_module)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/overdrive_enhancer
	name = "Overdrive Enhancer (x1)"
	contains = list(/obj/item/hardpoint/support/overdrive_enhancer)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ballistic_armor
	name = "Ballistic Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/ballistic)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/caustic_armor
	name = "Caustic Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/caustic)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/concussive_armor
	name = "Concussive Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/concussive)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/paladin_armor
	name = "Paladin Armor Module (x1)"
	contains = list(/obj/item/hardpoint/armor/paladin)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/snowplow_armor
	name = "Snowplow Module (x1)"
	contains = list(/obj/item/hardpoint/armor/snowplow)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_treads
	name = "Tank Treads (x1)"
	contains = list(/obj/item/hardpoint/treads/standard)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltb_cannon_ammo
	name = "LTB Cannon Magazines (x10)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun_ammo
	name = "LTAA AP Minigun Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_glauncher_ammo
	name = "Grenade Launcher Magazines (x10)"
	contains = list(
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_slauncher_ammo
	name = "Smoke Launcher Magazines (x10)"
	contains = list(
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_towlauncher_ammo
	name = "TOW Launcher Magazines (x4)"
	contains = list(
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_cupola_ammo
	name = "M56 Cupola Magazines (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/m56_cupola,
					/obj/item/ammo_magazine/tank/m56_cupola
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_flamer_ammo
	name = "Flamer Magazines (x5)"
	contains = list(
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"


/*******************************************************************************
ATTACHMENTS
*******************************************************************************/


/datum/supply_packs/attachables
	name = "rail attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper attachables crate"
	group = "Attachments"

/datum/supply_packs/rail_reddot
	name = "red-dot sight attachment crate (x8)"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper red-dot sight attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_scope
	name = "railscope attachment crate (x2)"
	contains = list(
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper scope attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_miniscope
	name = "mini railscope attachment crate (x2)"
	contains = list(
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/scope/mini,
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper mini scope attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_magneticharness
	name = "magnetic harness attachment crate (x6)"
	contains = list(
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper magnetic harness attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_quickfire
	name = "quickfire adaptor attachment crate (x2)"
	contains = list(
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper quickfire attachment crate"
	group = "Attachments"

/datum/supply_packs/m_attachables
	name = "muzzle attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper attachables crate"
	group = "Attachments"

/datum/supply_packs/muzzle_suppressor
	name = "suppressor attachment crate (x8)"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper suppressor attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_bayonet
	name = "bayonet attachment crate (x8)"
	contains = list(
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper bayonet attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_extended
	name = "extended barrel attachment crate (x6)"
	contains = list(
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper extended barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_heavy
	name = "barrel charger attachment crate (x2)"
	contains = list(
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper heavy barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_compensator
	name = "compensator attachment crate (x6)"
	contains = list(
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper compensator attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_attachables
	name = "underbarrel attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/lasersight,
					/obj/item/attachable/lasersight,
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper attachables crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_foregrip
	name = "foregrip attachment crate (x8)"
	contains = list(
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper foregrip attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_gyro
	name = "gyroscopic stabilizer attachment crate (x2)"
	contains = list(
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper gyro attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_bipod
	name = "bipod attachment crate (x6)"
	contains = list(
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper bipod attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_shotgun
	name = "underbarrel shotgun attachment crate (x4)"
	contains = list(
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper shotgun attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_flamer
	name = "underbarrel flamer attachment crate (x4)"
	contains = list(
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper flamer attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_burstfire_assembly
	name = "burstfire assembly attachment crate (x2)"
	contains = list(
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper burstfire assembly attachment crate"
	group = "Attachments"

/datum/supply_packs/s_attachables
	name = "stock attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/smg,
					/obj/item/attachable/stock/smg,
					/obj/item/attachable/stock/tactical,
					/obj/item/attachable/stock/tactical
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper stocks crate"
	group = "Attachments"

/datum/supply_packs/stock_revolver
	name = "revolver stock attachment crate (x4)"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper stock revolver attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_rifle
	name = "rifle stock attachment crate (x4)"
	contains = list(
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper rifle stock attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_shotgun
	name = "shotgun stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun
			)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper shotgun stock attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_smg
	name = "submachinegun stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg
			)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper smg stock attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_smg
	name = "combat shotgun stock attachment crate (x3)"
	contains = list(
			/obj/item/attachable/stock/tactical,
			/obj/item/attachable/stock/tactical,
			/obj/item/attachable/stock/tactical
			)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper combat shotgun attachment crate"
	group = "Attachments"

/*******************************************************************************
AMMO
*******************************************************************************/

/datum/supply_packs/ammobox
	name = "M41A Ammo Box Crate"
	contains = list(
					/obj/item/ammobox
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxap
	name = "M41A Ammo AP Box Crate"
	contains = list(
					/obj/item/ammobox/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A AP ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxext
	name = "M41A Ext Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/ext
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A Ext ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxm39
	name = "M39 Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/m39
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxm39ap
	name = "M39 AP Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/m39ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 AP ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxm39ext
	name = "M39 Ext Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/m39ext
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 Ext ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxm4a3
	name = "M4A3 Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/m4a3
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxm4a3ap
	name = "M4A3 AP Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/m4a3ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 AP ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxm4a3ext
	name = "M4A3 Ext Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/m4a3ext
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 Ext ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxslug
	name = "Slug Ammo Box Crate"
	contains = list(
					/obj/item/ammo_magazine/shotgunbox
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Slug ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxbuckshot
	name = "Buckshot Ammo Box Crate"
	contains = list(
					/obj/item/ammo_magazine/shotgunbox/buckshot
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Buckshot ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxflechette
	name = "Flechette Ammo Box Crate"
	contains = list(
					/obj/item/ammo_magazine/shotgunbox/flechette
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Flechette ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular
	name = "regular magazines crate (M41A x5, M4A3 x2, M44 x2, M39 x2, M37A2 x1)"
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
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m41a
	name = "regular M41A magazines crate (x8)"
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m4a3
	name = "regular M4A3 magazines crate (x10)"
	contains = list(
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m44
	name = "regular M44 magazines crate (x10)"
	contains = list(
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M44 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m39
	name = "regular M39 magazines crate (x10)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_shotgun
	name = "regular shotgun shells crate (x5 slugs, x5 buckshot)"
	contains = list(
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M37A2 ammo crate"
	group = "Ammo"



/datum/supply_packs/ammo_extended
	name = "extended magazines crate (M41A x2, M4A3 x2, M39 x2)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m41a
	name = "extended M41A magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m4a3
	name = "extended M4A3 magazines crate (x8)"
	contains = list(
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m39
	name = "extended M39 magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap
	name = "armor piercing magazines crate (M41A x2, M4A3 x2, M39 x2)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m41a
	name = "armor piercing M41A magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m4a3
	name = "armor piercing M4A3 magazines crate (x8)"
	contains = list(
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M4A3 armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m39
	name = "armor piercing M39 magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_flechette_shotgun
	name = "flechette shotgun shells crate (x5)"
	contains = list(
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/shotgun/flechette
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M37A2 ammo crate"
	group = "Ammo"


/datum/supply_packs/ammo_scout_regular
	name = "M4RA scout magazines crate (x5)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper regular scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_impact
	name = "M4RA scout impact magazines crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra/impact,
					/obj/item/ammo_magazine/rifle/m4ra/impact,
					/obj/item/ammo_magazine/rifle/m4ra/impact
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper impact scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_incendiary
	name = "M4RA scout incendiary magazines crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra/incendiary,
					/obj/item/ammo_magazine/rifle/m4ra/incendiary,
					/obj/item/ammo_magazine/rifle/m4ra/incendiary
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper incendiary scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_regular
	name = "M42A sniper magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper regular sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_flak
	name = "M42A sniper flak magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper flak sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_incendiary
	name = "M42A sniper incendiary magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper incendiary sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_regular
	name = "M5 RPG HE rockets crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper regular M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_ap
	name = "M5 RPG AP rockets crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper armor piercing M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_wp
	name = "M5 RPG WP rockets crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper white phosphorus M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle
	name = "large M41A ammo box crate (x400 rounds)"
	contains = list(
					/obj/item/big_ammo_box
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle_ap
	name = "large armor piercing M41A ammo box crate (x400 AP rounds)"
	contains = list(
					/obj/item/big_ammo_box/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M41A ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_smg
	name = "large M39 ammo box crate (x400 rounds)"
	contains = list(
					/obj/item/big_ammo_box/smg
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M39 ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_black_market
	name = "black market ammo crate"
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
					/obj/item/ammo_magazine/sniper/svd,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/mar40,
					/obj/item/ammo_magazine/rifle/mar40/extended,
					)
	cost = RO_PRICE_NORMAL
	contraband = 1
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper black market ammo crate"
	group = "Ammo"

/datum/supply_packs/surplus
	name = "surplus ammo crate (x10)"
	randomised_num_contained = 10
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/incendiary,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/hp,
					/obj/item/ammo_magazine/pistol/incendiary,
					/obj/item/ammo_magazine/pistol/m1911,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver/marksman,
					/obj/item/ammo_magazine/revolver/heavy,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/incendiary
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper surplus ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartgun
	name = "M56 smartgun powerpack crate (x2)"
	contains = list(
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper smartgun powerpack crate"
	group = "Ammo"

/datum/supply_packs/ammo_sentry
	name = "UA 571-C sentry ammunition (x2)"
	contains = list(
					/obj/item/ammo_magazine/sentry,
					/obj/item/ammo_magazine/sentry
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper sentry ammo crate"
	group = "Ammo"

/datum/supply_packs/napalm
	name = "M240 fuel crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M240 fuel crate"
	group = "Ammo"

/datum/supply_packs/pyro
	name = "M240-T fuel crate (extended x2, type-B x1, type-X x1)"
	contains = list(
					/obj/item/ammo_magazine/flamer_tank/large,
					/obj/item/ammo_magazine/flamer_tank/large,
					/obj/item/ammo_magazine/flamer_tank/large/B,
					/obj/item/ammo_magazine/flamer_tank/large/X
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240-T fuel crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_he
	name = "M402 mortar ammo crate (x8 HE)"
	cost = RO_PRICE_PRICY
	contains = list(
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_incend
	name = "M402 mortar ammo crate (x8 Incend)"
	cost = RO_PRICE_PRICY
	contains = list(
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_flare
	name = "M402 mortar ammo crate (x10 Flare)"
	cost = RO_PRICE_NORMAL
	contains = list(
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_smoke
	name = "M402 mortar ammo crate (x10 Smoke)"
	cost = RO_PRICE_NORMAL
	contains = list(
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_flash
	name = "M402 mortar ammo crate (x10 Flash)"
	cost = RO_PRICE_NORMAL
	contains = list(
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_minisentry
	name = "UA-580 point defense sentry ammo crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/minisentry,
					/obj/item/ammo_magazine/minisentry,
					/obj/item/ammo_magazine/minisentry
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper mini-sentry ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_m56d
	name = "M56D mounted smartgun ammo crate (x2)"
	contains = list(
					/obj/item/ammo_magazine/m56d,
					/obj/item/ammo_magazine/m56d
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M56D emplacement ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_lasguncharger
	name = "ColMarTech Lasgun Field Charger (M43 x10, M43 Highcap x2)"
	contains = list(
					/obj/machinery/vending/lasgun
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper ColMarTech Lasgun Field Charger"
	group = "Ammo"

/datum/supply_packs/ammo_lasgun
	name = "M43 lasgun battery crate (M43 x15)"
	contains = list(
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43,
					/obj/item/cell/lasgun/M43
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "lasgun battery crate"
	group = "Ammo"

/datum/supply_packs/ammo_lasgun_highcap
	name = "M43 lasgun highcap battery crate (M43 highcap x7)"
	contains = list(
					/obj/item/cell/lasgun/M43/highcap,
					/obj/item/cell/lasgun/M43/highcap,
					/obj/item/cell/lasgun/M43/highcap,
					/obj/item/cell/lasgun/M43/highcap,
					/obj/item/cell/lasgun/M43/highcap,
					/obj/item/cell/lasgun/M43/highcap,
					/obj/item/cell/lasgun/M43/highcap
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_minigun
	name = "Vindicator Minigun Ammo Drums (x3)"
	contains = list(
					/obj/item/ammo_magazine/minigun,
					/obj/item/ammo_magazine/minigun,
					/obj/item/ammo_magazine/minigun
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper minigun ammo crate"
	group = "Ammo"


/*******************************************************************************
ARMOR
*******************************************************************************/


/datum/supply_packs/armor_basic
	name = "M3 pattern armor crate (x5 helmet, x5 armor)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper armor crate"
	group = "Armor"

/datum/supply_packs/armor_leader
	name = "M3 pattern squad leader crate (x1 helmet, x1 armor)"
	contains = list(
					/obj/item/clothing/head/helmet/marine/leader,
					/obj/item/clothing/suit/storage/marine/leader
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper squad leader armor crate"
	group = "Armor"


/*******************************************************************************
CLOTHING
*******************************************************************************/


/datum/supply_packs/officer_outfits
	contains = list(
					/obj/item/clothing/under/rank/ro_suit,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/exec,
					/obj/item/clothing/under/marine/officer/ce
					)
	name = "officer outfit crate"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper officer dress crate"
	group = "Clothing"

/datum/supply_packs/marine_outfits
	contains = list(
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/backpack/marine/standard,
					/obj/item/storage/backpack/marine/standard,
					/obj/item/storage/backpack/marine/standard,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine
					)
	name = "marine outfit crate"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper marine outfit crate"
	group = "Clothing"

/datum/supply_packs/webbing
	name = "webbings and holsters crate"
	contains = list(
					/obj/item/clothing/tie/holster,
					/obj/item/clothing/tie/storage/brown_vest,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/storage/belt/gun/m4a3,
					/obj/item/storage/belt/gun/m44,
					/obj/item/storage/large_holster/m39
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper extra storage crate"
	group = "Clothing"

/datum/supply_packs/pouches_general
	name = "general pouches crate (2x normal, 1x medium, 1x large)"
	contains = list(
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general/medium,
					/obj/item/storage/pouch/general/large
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper general pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_weapons
	name = "weapons pouches crate (1x bayonet, pistol, explosive)"
	contains = list(
					/obj/item/storage/pouch/bayonet,
					/obj/item/storage/pouch/pistol,
					/obj/item/storage/pouch/explosive
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper weapons pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_ammo
	name = "ammo pouches crate (1x normal, large, pistol, large pistol)"
	contains = list(
					/obj/item/storage/pouch/magazine,
					/obj/item/storage/pouch/magazine/large,
					/obj/item/storage/pouch/magazine/pistol,
					/obj/item/storage/pouch/magazine/pistol/large
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper ammo pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_medical
	name = "medical pouches crate (1x firstaid, medical, syringe, medkit, autoinjector)"
	contains = list(
					/obj/item/storage/pouch/firstaid,
					/obj/item/storage/pouch/medical,
					/obj/item/storage/pouch/syringe,
					/obj/item/storage/pouch/medkit,
					/obj/item/storage/pouch/autoinjector
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper medical pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_survival
	name = "survival pouches crate (1x radio, flare, survival)"
	contains = list(
					/obj/item/storage/pouch/radio,
					/obj/item/storage/pouch/flare,
					/obj/item/storage/pouch/survival
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper survival pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_construction
	name = "construction pouches crate (1x document, electronics, tools, construction)"
	contains = list(
					/obj/item/storage/pouch/document,
					/obj/item/storage/pouch/electronics,
                    /obj/item/storage/pouch/tools,
					/obj/item/storage/pouch/construction
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "\improper construction pouches crate"
	group = "Clothing"


/*******************************************************************************
MEDICAL
*******************************************************************************/


/datum/supply_packs/medical
	name = "medical crate"
	contains = list(
					/obj/item/storage/box/autoinjectors,
					/obj/item/storage/box/syringes,
					/obj/item/reagent_container/glass/bottle/inaprovaline,
					/obj/item/reagent_container/glass/bottle/dylovene,
					/obj/item/reagent_container/glass/bottle/bicaridine,
					/obj/item/reagent_container/glass/bottle/dexalin,
					/obj/item/reagent_container/glass/bottle/spaceacillin,
					/obj/item/reagent_container/glass/bottle/kelotane,
					/obj/item/reagent_container/glass/bottle/tramadol,
					/obj/item/storage/pill_bottle/inaprovaline,
					/obj/item/storage/pill_bottle/dylovene,
					/obj/item/storage/pill_bottle/bicaridine,
					/obj/item/storage/pill_bottle/dexalin,
					/obj/item/storage/pill_bottle/spaceacillin,
					/obj/item/storage/pill_bottle/kelotane,
					/obj/item/storage/pill_bottle/tramadol,
					/obj/item/storage/pill_bottle/quickclot,
					/obj/item/storage/pill_bottle/peridaxon,
					/obj/item/storage/box/pillbottles
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper medical crate"
	group = "Medical"

/datum/supply_packs/firstaid
	name = "first aid kit crate (2x each)"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper medical crate"
	group = "Medical"

/datum/supply_packs/bodybag
	name = "body bag crate (x28)"
	contains = list(
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags
			)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper body bag crate"
	group = "Medical"

/datum/supply_packs/cryobag
	name = "stasis bag crate (x3)"
	contains = list(
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag
			)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper stasis bag crate"
	group = "Medical"

/datum/supply_packs/surgery
	name = "surgery crate (x1 surgical tray)"
	contains = list(
					/obj/item/storage/surgical_tray,
					/obj/item/clothing/tie/storage/white_vest
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/anesthetic
	name = "anesthetic crate (x4 masks, x4 tanks)"
	contains = list(
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/anesthetic,
					/obj/item/tank/anesthetic,
					/obj/item/tank/anesthetic,
					/obj/item/tank/anesthetic
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/sterile
	name = "sterile equipment crate"
	contains = list(
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper sterile equipment crate"
	group = "Medical"

/datum/supply_packs/hypospray
	name = "hypospray crate (x5 hyposprays)"
	contains = list(
					/obj/item/reagent_container/hypospray/advanced,
					/obj/item/reagent_container/hypospray/advanced,
					/obj/item/reagent_container/hypospray/advanced,
					/obj/item/reagent_container/hypospray/advanced,
					/obj/item/reagent_container/hypospray/advanced
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper hypospray crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/medvac
	name = "medvac system crate (medvac stretcher and beacon)"
	contains = list(
					/obj/item/roller/medevac,
					/obj/item/medevac_beacon
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper medvac crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/*******************************************************************************
ENGINEERING
*******************************************************************************/


/datum/supply_packs/sandbags
	name = "empty sandbags crate (x50)"
	contains = list(/obj/item/stack/sandbags_empty/full)
	cost = RO_PRICE_VERY_CHEAP
	containertype = "/obj/structure/closet/crate/supply"
	containername = "\improper empty sandbags crate"
	group = "Engineering"

/datum/supply_packs/metal50
	name = "50 metal sheets (x50)"
	contains = list(/obj/item/stack/sheet/metal/large_stack)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper metal sheets crate"
	group = "Engineering"

/datum/supply_packs/plas50
	name = "plasteel sheets (x30)"
	contains = list(/obj/item/stack/sheet/plasteel/medium_stack)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper plasteel sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 glass sheets (x50)"
	contains = list(/obj/item/stack/sheet/glass/large_stack)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper glass sheets crate"
	group = "Engineering"

/datum/supply_packs/wood50
	name = "wooden planks (x50)"
	contains = list(/obj/item/stack/sheet/wood/large_stack)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper wooden planks crate"
	group = "Engineering"

/datum/supply_packs/smescoil
	name = "superconducting magnetic coil crate (x1)"
	contains = list(/obj/item/stock_parts/smes_coil)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper superconducting magnetic coil crate"
	group = "Engineering"

/datum/supply_packs/electrical
	name = "electrical maintenance crate (toolbox x2, insulated x2, cell x2, hi-cap cell x2)"
	contains = list(
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/cell,
					/obj/item/cell,
					/obj/item/cell/high,
					/obj/item/cell/high
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper electrical maintenance crate"
	group = "Engineering"

/datum/supply_packs/mechanical
	name = "mechanical maintenance crate (utility belt x3, hazard vest x3, welding helmet x2, hard hat x1)"
	contains = list(
					/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/fueltank
	name = "fuel tank crate (x1)"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/largecrate
	containername = "\improper fuel tank crate"
	group = "Engineering"

/datum/supply_packs/inflatable
	name = "inflatable barriers (x9 doors, x12 walls)"
	contains = list(
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper inflatable barriers crate"
	group = "Engineering"

/datum/supply_packs/lightbulbs
	name = "replacement lights (x42 tube, x21 bulb)"
	contains = list(
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper replacement lights crate"
	group = "Engineering"

/datum/supply_packs/pacman_parts
	name = "P.A.C.M.A.N. portable generator parts"
	contains = list(
				/obj/item/stock_parts/micro_laser,
				/obj/item/stock_parts/capacitor,
				/obj/item/stock_parts/matter_bin,
				/obj/item/circuitboard/machine/pacman
				)
	cost = RO_PRICE_CHEAP
	containername = "\improper P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"


/datum/supply_packs/super_pacman_parts
	name = "Super P.A.C.M.A.N. portable generator parts"
	cost = RO_PRICE_NORMAL
	containername = "\improper Super P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(
					/obj/item/stock_parts/micro_laser,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/matter_bin,
					/obj/item/circuitboard/machine/pacman/super
					)

/datum/supply_packs/general_circuitboards
	name = "General circuitboard crate (10x)"
	cost = RO_PRICE_NEAR_FREE
	containername = "\improper General circuit board crate (10x)"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/circuitboard/general,
					/obj/item/multitool
					)

/*******************************************************************************
SCIENCE
*******************************************************************************/


/datum/supply_packs/phoron
	name = "phoron assembly crate"
	contains = list(
					/obj/item/tank/phoron,
					/obj/item/tank/phoron,
					/obj/item/tank/phoron,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/secure/phoron
	containername = "\improper phoron assembly crate"
	access = ACCESS_MARINE_ENGINEERING
	group = "Science"


/*******************************************************************************
SUPPLIES
*******************************************************************************/


/datum/supply_packs/mre
	name = "TGMC MRE crate (x40)"
	contains = list(
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper MRE crate"
	group = "Supplies"

/datum/supply_packs/internals
	name = "oxygen internals crate (x3 masks, x3 tanks)"
	contains = list(
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/air,
					/obj/item/tank/air,
					/obj/item/tank/air
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/internals
	containername = "\improper internals crate"
	group = "Supplies"

/datum/supply_packs/evacuation
	name = "emergency equipment (x2 toolbox, x2 hazard vest, x5 oxygen tank, x5 masks)"
	contains = list(
					/obj/item/storage/toolbox/emergency,
					/obj/item/storage/toolbox/emergency,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/internals
	containername = "\improper emergency crate"
	group = "Supplies"

/datum/supply_packs/boxes
	name = "empty boxes (x10)"
	contains = list(
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = "/obj/structure/closet/crate/supply"
	containername = "\improper empty box crate"
	group = "Supplies"

/datum/supply_packs/janitor
	name = "assorted janitorial supplies"
	contains = list(
					/obj/item/reagent_container/glass/bucket,
					/obj/item/reagent_container/glass/bucket,
					/obj/item/reagent_container/glass/bucket,
					/obj/item/tool/mop,
					/obj/item/tool/wet_sign,
					/obj/item/tool/wet_sign,
					/obj/item/tool/wet_sign,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_container/spray/cleaner,
					/obj/item/reagent_container/glass/rag,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket,
					/obj/item/paper/janitor
					)
	cost = RO_PRICE_NEAR_FREE
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper janitorial supplies crate"
	group = "Supplies"
