/*******************************************************************************
WEAPONS
*******************************************************************************/

/datum/supply_packs/weapons
	group = "Weapons"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/weapons/sentry
	name = "ST-571 base defense sentry"
	contains = list(/obj/item/storage/box/crate/sentry)
	cost = 400

/datum/supply_packs/weapons/sentry_ammo
	name = "ST-571 sentry ammunition"
	contains = list(/obj/item/ammo_magazine/sentry)
	cost = 100

/datum/supply_packs/weapons/minisentry
	name = "ST-580 point defense sentry"
	contains = list(/obj/item/storage/box/crate/minisentry)
	cost = 400

/datum/supply_packs/weapons/minisentry_ammo
	name = "ST-580 point defense sentry ammo"
	contains = list(/obj/item/ammo_magazine/minisentry)
	cost = 100

/datum/supply_packs/weapons/sentry_shotgun
	name = "SHT-573 shotgun sentry"
	contains = list(/obj/item/storage/box/crate/sentry_shotgun)
	cost = 400

/datum/supply_packs/weapons/sentry_shotgun_ammo
	name = "SHT-573 shotgun sentry ammunition"
	contains = list(/obj/item/ammo_magazine/sentry/shotgun)
	cost = 100

/datum/supply_packs/weapons/sentry_sniper
	name = "SST-574 sniper sentry"
	contains = list(/obj/item/storage/box/crate/sentry_sniper)
	cost = 600

/datum/supply_packs/weapons/sentry_sniper_ammo
	name = "SST-574 sniper sentry ammunition"
	contains = list(/obj/item/ammo_magazine/sentry/sniper)
	cost = 100

/datum/supply_packs/weapons/sentry_flamer
	name = "SFT-575 flamethrower sentry"
	contains = list(/obj/item/storage/box/crate/sentry_flamer)
	cost = 400

/datum/supply_packs/weapons/sentry_flamer_ammo
	name = "SFT-575 flamethrower sentry ammo"
	contains = list(/obj/item/ammo_magazine/sentry/flamer)
	cost = 150

/datum/supply_packs/weapons/sentry_laser
	name = "SLT-576 laser sentry"
	contains = list(/obj/item/storage/box/crate/sentry_laser)
	cost = 400

/datum/supply_packs/weapons/sentry_laser_ammo
	name = "SLT-576 laser sentry ammo"
	contains = list(/obj/item/ammo_magazine/sentry/laser)
	cost = 200

/datum/supply_packs/weapons/buildasentry
	name = "Build-A-Sentry attachment system"
	contains = list(
		/obj/item/attachable/buildasentry,
	)
	cost = 250

/datum/supply_packs/weapons/hsg_102_emplacement
	name = "HSG-102 mounted heavy smartgun"
	contains = list(/obj/item/storage/box/hsg_102)
	cost = 600

/datum/supply_packs/weapons/hsg_102
	name = "HSG-102 mounted heavy smartgun ammo"
	contains = list(/obj/item/ammo_magazine/hsg_102)
	cost = 30

/datum/supply_packs/weapons/minigun_emplacement
	name = "MG-2005 mounted minigun"
	contains = list(/obj/item/weapon/gun/standard_minigun)
	cost = 600

/datum/supply_packs/weapons/minigun_ammo
	name = "MG-2005 mounted minigun ammo"
	contains = list(/obj/item/ammo_magazine/heavy_minigun)
	cost = 30

/datum/supply_packs/weapons/autocannon_emplacement
	name = "ATR-22 mounted flak cannon"
	contains = list(/obj/item/weapon/gun/standard_auto_cannon)
	cost = 700

/datum/supply_packs/weapons/ac_hv
	name = "ATR-22 high-velocity ammo"
	contains = list(/obj/item/ammo_magazine/auto_cannon)
	cost = 40

/datum/supply_packs/weapons/ac_flak
	name = "ATR-22 smart-detonating ammo"
	contains = list(/obj/item/ammo_magazine/auto_cannon/flak)
	cost = 40

/datum/supply_packs/weapons/ags_emplacement
	name = "AGLS-37 mounted automatic grenade launcher"
	contains = list(/obj/item/weapon/gun/standard_agls)
	cost = 700

/datum/supply_packs/weapons/ags_highexplo
	name = "AGLS-37 AGL high explosive grenades"
	contains = list(/obj/item/ammo_magazine/standard_agls)
	cost = 40

/datum/supply_packs/weapons/ags_frag
	name = "AGLS-37 AGL fragmentation grenades"
	contains = list(/obj/item/ammo_magazine/standard_agls/fragmentation)
	cost = 40

/datum/supply_packs/weapons/ags_incendiary
	name = "AGLS-37 AGL white phosphorous grenades"
	contains = list(/obj/item/ammo_magazine/standard_agls/incendiary)
	cost = 40

/datum/supply_packs/weapons/ags_flare
	name = "AGLS-37 AGL flare grenades"
	contains = list(/obj/item/ammo_magazine/standard_agls/flare)
	cost = 30

/datum/supply_packs/weapons/ags_cloak
	name = "AGLS-37 AGL cloak grenades"
	contains = list(/obj/item/ammo_magazine/standard_agls/cloak)
	cost = 30

/datum/supply_packs/weapons/antitankgun
	name = "AT-36 anti tank gun"
	contains = list(/obj/item/weapon/gun/standard_atgun)
	cost = 800

/datum/supply_packs/weapons/antitankgunammo
	name = "AT-36 ATG AP-HE shell (x3)"
	contains = list(
		/obj/item/ammo_magazine/standard_atgun,
		/obj/item/ammo_magazine/standard_atgun,
		/obj/item/ammo_magazine/standard_atgun,
	)
	cost = 40

/datum/supply_packs/weapons/antitankgunammo/apcr
	name = "AT-36 ATG APCR shell (x3)"
	contains = list(
		/obj/item/ammo_magazine/standard_atgun/apcr,
		/obj/item/ammo_magazine/standard_atgun/apcr,
		/obj/item/ammo_magazine/standard_atgun/apcr,
	)
	cost = 40

/datum/supply_packs/weapons/antitankgunammo/he
	name = "AT-36 ATG HE shell (x3)"
	contains = list(
		/obj/item/ammo_magazine/standard_atgun/he,
		/obj/item/ammo_magazine/standard_atgun/he,
		/obj/item/ammo_magazine/standard_atgun/he,
	)
	cost = 40

/datum/supply_packs/weapons/antitankgunammo/beehive
	name = "AT-36 ATG beehive shell (x3)"
	contains = list(
		/obj/item/ammo_magazine/standard_atgun/beehive,
		/obj/item/ammo_magazine/standard_atgun/beehive,
		/obj/item/ammo_magazine/standard_atgun/beehive,
	)
	cost = 40

/datum/supply_packs/weapons/antitankgunammo/incendiary
	name = "AT-36 ATG napalm shell (x3)"
	contains = list(
		/obj/item/ammo_magazine/standard_atgun/incend,
		/obj/item/ammo_magazine/standard_atgun/incend,
		/obj/item/ammo_magazine/standard_atgun/incend,
	)
	cost = 40

/datum/supply_packs/weapons/flak_gun
	name = "FK-88 flak gun"
	contains = list(/obj/item/weapon/gun/heavy_isg)
	cost = 1000

/datum/supply_packs/weapons/flak_he
	name = "FK-88 flak HE shell"
	contains = list(/obj/item/ammo_magazine/heavy_isg/he)
	cost = 50

/datum/supply_packs/weapons/flak_sabot
	name = "FK-88 flak APFDS shell"
	contains = list(/obj/item/ammo_magazine/heavy_isg/sabot)
	cost = 50

/datum/supply_packs/weapons/heavy_laser_emplacement
	name = "TE-9001 mounted heavy laser"
	contains = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/heavy_laser/deployable)
	cost = 400


/datum/supply_packs/weapons/heavy_laser_ammo
	name = "TE-9001 mounted heavy laser cell"
	contains = list(/obj/item/cell/lasgun/heavy_laser)
	cost = 15

/datum/supply_packs/weapons/tesla
	name = "Tesla shock rifle"
	contains = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla)
	cost = 600

/datum/supply_packs/weapons/plasma_cells
	name = "WML plasma energy cell (x3)"
	contains = list(
		/obj/item/cell/lasgun/plasma,
		/obj/item/cell/lasgun/plasma,
		/obj/item/cell/lasgun/plasma,
	)
	cost = 100

/datum/supply_packs/weapons/plasma_smg
	name = "PL-51 plasma SMG"
	contains = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg)
	cost = 400

/datum/supply_packs/weapons/plasma_rifle
	name = "PL-38 plasma rifle"
	contains = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle)
	cost = 350

/datum/supply_packs/weapons/plasma_cannon
	name = "PL-96 plasma cannon"
	contains = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon)
	cost = 400

/datum/supply_packs/weapons/tx54
	name = "GL-54 airburst grenade launcher"
	contains = list(/obj/item/weapon/gun/rifle/tx54)
	cost = 300

/datum/supply_packs/weapons/tx54_airburst
	name = "GL-54 airburst grenade magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx54)
	cost = 20

/datum/supply_packs/weapons/tx54_incendiary
	name = "GL-54 incendiary grenade magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx54/incendiary)
	cost = 60

/datum/supply_packs/weapons/tx54_smoke
	name = "GL-54 tactical smoke grenade magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx54/smoke)
	cost = 12

/datum/supply_packs/weapons/tx54_smoke/dense
	name = "GL-54 dense smoke grenade magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx54/smoke/dense)
	cost = 8

/datum/supply_packs/weapons/tx54_smoke/tangle
	name = "GL-54 tanglefoot grenade magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx54/smoke/tangle)
	cost = 48

/datum/supply_packs/weapons/tx55
	name = "AR-55 OICW rifle"
	contains = list(/obj/item/weapon/gun/rifle/tx55)
	cost = 525

/datum/supply_packs/weapons/recoillesskit
	name = "RL-160 recoilless rifle kit"
	contains = list(/obj/item/storage/holster/backholster/rpg/full)
	cost = 400
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/shell_regular
	name = "RL-160 RR HE shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/shell_le
	name = "RL-160 RR LE shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless/light)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/shell_heat
	name = "RL-160 HEAT shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless/heat)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/shell_smoke
	name = "RL-160 RR smoke shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless/smoke)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/shell_smoke
	name = "RL-160 RR cloak shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless/cloak)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/shell_smoke
	name = "RL-160 RR tanglefoot shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless/plasmaloss)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/pepperball
	name = "PB-12 pepperball gun"
	contains = list(/obj/item/weapon/gun/rifle/pepperball)
	cost = 100

/datum/supply_packs/weapons/bricks
	name = "Brick"
	contains = list(/obj/item/weapon/brick)
	cost = 10

/datum/supply_packs/weapons/railgun
	name = "SR-220 railgun"
	contains = list(/obj/item/weapon/gun/rifle/railgun)
	cost = 400

/datum/supply_packs/weapons/railgun_ammo
	name = "SR-220 railgun armor piercing discarding sabot APDS round"
	contains = list(/obj/item/ammo_magazine/railgun)
	cost = 30

/datum/supply_packs/weapons/railgun_ammo/hvap
	name = "SR-220 railgun high velocity armor piercing HVAP round"
	contains = list(/obj/item/ammo_magazine/railgun/hvap)

/datum/supply_packs/weapons/railgun_ammo/smart
	name = "SR-220 railgun smart armor piercing SAP round"
	contains = list(/obj/item/ammo_magazine/railgun/smart)

/datum/supply_packs/weapons/tx8
	name = "BR-8 scout rifle"
	contains = list(/obj/item/weapon/gun/rifle/tx8)
	cost = 400
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/scout_regular
	name = "BR-8 scout rifle magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx8)
	cost = 20
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/scout_regular_box
	name = "BR-8 scout rifle ammo box"
	contains = list(/obj/item/ammo_magazine/packet/scout_rifle)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/scout_impact
	name = "BR-8 scout rifle impact magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx8/impact)
	cost = 40
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/scout_incendiary
	name = "BR-8 scout rifle incendiary magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx8/incendiary)
	cost = 40
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/thermobaric
	name = "RL-57 quad thermobaric launcher"
	contains = list(/obj/item/weapon/gun/launcher/rocket/m57a4/t57)
	cost = 500
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/thermobaric_wp
	name = "RL-57 thermobaric rocket array"
	contains = list(/obj/item/ammo_magazine/rocket/m57a4)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/specdemo
	name = "RL-152 SADAR rocket launcher"
	contains = list(/obj/item/weapon/gun/launcher/rocket/sadar)
	cost = SADAR_PRICE
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/rpg_regular
	name = "RL-152 SADAR HE rocket"
	contains = list(/obj/item/ammo_magazine/rocket/sadar)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/rpg_regular_unguided
	name = "RL-152 SADAR HE rocket (unguided)"
	contains = list(/obj/item/ammo_magazine/rocket/sadar/unguided)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/rpg_ap
	name = "RL-152 SADAR AP rocket"
	contains = list(/obj/item/ammo_magazine/rocket/sadar/ap)
	cost = 60
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/rpg_wp
	name = "RL-152 SADAR WP rocket"
	contains = list(/obj/item/ammo_magazine/rocket/sadar/wp)
	cost = 40
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/rpg_wp_unguided
	name = "RL-152 SADAR WP rocket (unguided)"
	contains = list(/obj/item/ammo_magazine/rocket/sadar/wp/unguided)
	cost = 40
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/zx76
	name = "ZX-76 twin-barrled burst shotgun"
	contains = list(/obj/item/weapon/gun/shotgun/zx76)
	cost = 1000

/datum/supply_packs/weapons/shotguntracker
	name = "12 gauge tracker shells"
	contains = list(/obj/item/ammo_magazine/shotgun/tracker)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/incendiaryslugs
	name = "Box of incendiary slugs"
	contains = list(/obj/item/ammo_magazine/shotgun/incendiary)
	cost = 100
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/autosniper
	name = "SR-81 IFF auto sniper kit"
	contains = list(/obj/item/weapon/gun/rifle/standard_autosniper)
	cost = 500
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/autosniper_regular
	name = "SR-81 IFF sniper magazine"
	contains = list(/obj/item/ammo_magazine/rifle/autosniper)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/autosniper_packet
	name = "SR-81 IFF sniper ammo box"
	contains = list(/obj/item/ammo_magazine/packet/autosniper)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/antimaterial
	name = "SR-26 antimaterial rifle (AMR) kit"
	contains = list(/obj/item/weapon/gun/rifle/sniper/antimaterial)
	cost = 775
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/antimaterial_ammo
	name = "SR-26 AMR magazine"
	contains = list(/obj/item/ammo_magazine/sniper)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/antimaterial_incend_ammo
	name = "SR-26 AMR incendiary magazine"
	contains = list(/obj/item/ammo_magazine/sniper/incendiary)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/antimaterial_flak_ammo
	name = "SR-26 AMR flak magazine"
	contains = list(/obj/item/ammo_magazine/sniper/flak)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/specminigun
	name = "MG-100 Vindicator Minigun"
	contains = list(/obj/item/weapon/gun/minigun)
	cost = MINIGUN_PRICE

/datum/supply_packs/weapons/minigun
	name = "MG-100 Vindicator minigun powerpack"
	contains = list(/obj/item/ammo_magazine/minigun_powerpack)
	cost = 50

/datum/supply_packs/weapons/mmg
	name = "MG-27 medium machinegun"
	contains = list(/obj/item/weapon/gun/standard_mmg)
	cost = 100

/datum/supply_packs/weapons/hmg
	name = "HMG-08 heavy machinegun"
	contains = list(/obj/item/weapon/gun/heavymachinegun)
	cost = 400

/datum/supply_packs/weapons/hmg_ammo
	name = "HMG-08 heavy machinegun drum magazine"
	contains = list(/obj/item/ammo_magazine/heavymachinegun)
	cost = 70

/datum/supply_packs/weapons/hmg_ammo_small
	name = "HMG-08 heavy machinegun box magazine"
	contains = list(/obj/item/ammo_magazine/heavymachinegun/small)
	cost = 40

/datum/supply_packs/weapons/flamethrower
	name = "FL-84 flamethrower"
	contains = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard)
	cost = 150

/datum/supply_packs/weapons/napalm
	name = "FL-84 standard fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank/large)
	cost = 60

/datum/supply_packs/weapons/napalm_X
	name = "FL-84 X-fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank/large/X)
	cost = 300

/datum/supply_packs/weapons/back_fuel_tank
	name = "Standard backpack fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank/backtank)
	cost = 200

/datum/supply_packs/weapons/back_fuel_tank_x
	name = "X-fuel backpack fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank/backtank/X)
	cost = 600

/datum/supply_packs/weapons/fueltank
	name = "X-fuel tank"
	contains = list(/obj/structure/reagent_dispensers/fueltank/xfuel)
	cost = 600
	containertype = null

/datum/supply_packs/weapons/rpgoneuse
	name = "RL-72 disposable RPG"
	contains = list(/obj/item/weapon/gun/launcher/rocket/oneuse)
	cost = 100
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/mateba
	name = "Mateba autorevolver belt"
	contains = list(/obj/item/storage/holster/belt/mateba/full)
	notes = "Contains 6 speedloaders"
	cost = 150
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/mateba_ammo
	name = "Mateba speed loader"
	contains = list(/obj/item/ammo_magazine/revolver/mateba)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/mateba_packet
	name = "Mateba .454 casull packet"
	contains = list(/obj/item/ammo_magazine/packet/mateba)
	cost = 120
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/magnum
	name = "R-76 magnum"
	contains = list(/obj/item/weapon/gun/revolver/standard_magnum)
	notes = "Ammo is contained within normal marine vendors."
	cost = 75
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/standard_ammo
	name = "Surplus standard ammo crate"
	notes = "Contains 22 ammo boxes of a wide variety which come prefilled. You lazy bum."
	contains = list(/obj/structure/largecrate/supply/ammo/standard_ammo)
	containertype = null
	cost = 200

/datum/supply_packs/weapons/pfcflak
	name = "SR-127 flak magazine"
	contains = list(/obj/item/ammo_magazine/rifle/chamberedrifle/flak)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/rechargemag
	name = "Terra Experimental TE-X recharger battery"
	contains = list(/obj/item/cell/lasgun/lasrifle/recharger)
	cost = 60

/datum/supply_packs/weapons/xray_gun
	name = "Terra Experimental TE-X laser rifle"
	contains = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/xray)
	cost = 400

/datum/supply_packs/weapons/rocketsledge
	name = "Rocket sledge"
	contains = list(/obj/item/weapon/twohanded/rocketsledge)
	cost = 850

/datum/supply_packs/weapons/chainsaw
	name = "Chainsaw"
	contains = list(/obj/item/weapon/twohanded/chainsaw)
	cost = 500

/datum/supply_packs/weapons/smart_pistol
	name = "SP-13 smart machinepistol"
	contains = list(/obj/item/weapon/gun/pistol/smart_pistol)
	cost = 250

/datum/supply_packs/weapons/smart_pistol_ammo
	name = "SP-13 smart machinepistol ammo"
	contains = list(/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol)
	cost = 10
