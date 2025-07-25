/*******************************************************************************
VEHICLES
*******************************************************************************/

/datum/supply_packs/vehicles
	group = "Vehicles"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/vehicles/motorbike
	name = "All-terrain motorbike"
	cost = 400
	contains = list(/obj/vehicle/ridden/motorbike)
	containertype = null

/datum/supply_packs/vehicles/sidecar
	name = "Motorbike sidecar upgrade"
	cost = 200
	contains = list(/obj/item/sidecar)

/datum/supply_packs/vehicles/jerrycan
	name = "Jerry can"
	cost = 100
	contains = list(/obj/item/reagent_containers/jerrycan)

/datum/supply_packs/vehicles/droid_combat
	name = "Combat droid with weapon equipped"
	contains = list(/obj/vehicle/unmanned/droid)
	cost = 400
	containertype = null

/datum/supply_packs/vehicles/droid_scout
	name = "Scout droid"
	contains = list(/obj/vehicle/unmanned/droid/scout)
	cost = 300
	containertype = null

/datum/supply_packs/vehicles/droid_powerloader
	name = "Powerloader droid"
	contains = list(/obj/vehicle/unmanned/droid/ripley)
	cost = 300
	containertype = null

/datum/supply_packs/vehicles/droid_weapon
	name = "Droid weapon"
	contains = list(/obj/item/uav_turret/droid)
	cost = 200
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/vehicles/tiny_uv
	name = "\"Skink\" tiny unmanned vehicle"
	contains = list(/obj/item/deployable_vehicle/tiny)
	cost = 50

/datum/supply_packs/vehicles/light_uv
	name = "\"Iguana\" light unmanned vehicle"
	contains = list(/obj/vehicle/unmanned)
	cost = 300

/datum/supply_packs/vehicles/medium_uv
	name = "\"Gecko\" Mmedium unmanned vehicle"
	contains = list(/obj/vehicle/unmanned/medium)
	cost = 500

/datum/supply_packs/vehicles/heavy_uv
	name = "\"Komodo\" heavy unmanned vehicle"
	contains = list(/obj/vehicle/unmanned/heavy)
	cost = 700

/datum/supply_packs/vehicles/uv_light_weapon
	name = "Light UV weapon"
	contains = list(/obj/item/uav_turret)
	cost = 200
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/vehicles/uv_heavy_weapon
	name = "Heavy UV weapon"
	contains = list(/obj/item/uav_turret/heavy)
	cost = 200
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/vehicles/uv_light_ammo
	name = "Light UV ammo - 11x35mm"
	contains = list(/obj/item/ammo_magazine/box11x35mm)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/vehicles/uv_heavy_ammo
	name = "Heavy UV ammo - 12x40mm"
	contains = list(/obj/item/ammo_magazine/box12x40mm)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/vehicles/vehicle_remote
	name = "Vehicle remote"
	contains = list(/obj/item/unmanned_vehicle_remote)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/supply_packs/vehicles/mounted_hsg
	name = "Dropship mounted HSG-102 heavy smartgun"
	contains = list(/obj/structure/dropship_equipment/shuttle/weapon_holder/machinegun)
	cost = 500

/datum/supply_packs/vehicles/minigun_nest
	name = "Dropship mounted MG-2005 minigun"
	contains = list(/obj/structure/dropship_equipment/shuttle/weapon_holder/minigun)
	cost = 750

/datum/supply_packs/vehicles/mounted_heavy_laser
	name = "Dropship mounted TE-9001 heavy laser"
	contains = list(/obj/structure/dropship_equipment/shuttle/weapon_holder/heavylaser)
	cost = 400

/datum/supply_packs/vehicles/hsg_ammo
	name = "Dropship mounted HSG-102 mounted heavy smartgun ammo"
	contains = list(/obj/item/ammo_magazine/hsg_102/hsg_nest)
	cost = 100
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/vehicles/minigun_ammo
	name = "Dropship mounted MG-2005 minigun ammo"
	contains = list(/obj/item/ammo_magazine/heavy_minigun)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/vehicles/hl_ammo
	name = "Dropship mounted TE-9001 heavy laser ammo (x3)"
	contains = list(/obj/item/cell/lasgun/heavy_laser, /obj/item/cell/lasgun/heavy_laser, /obj/item/cell/lasgun/heavy_laser)
	cost = 50
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/vehicles/bfg_cannon
	name = "Tank-mounted BFG 9500"
	contains = list(/obj/item/armored_weapon/bfg)
	cost = 1600

/datum/supply_packs/vehicles/bfg_rounds
	name = "Tank BFG antimatter container"
	contains = list(/obj/item/ammo_magazine/tank/bfg)
	cost = 200

/datum/supply_packs/vehicles/ltb_he_shell
	name = "LTB High Explosive tank shell"
	contains = list(/obj/item/ammo_magazine/tank/ltb_cannon)
	cost = 10

/datum/supply_packs/vehicles/ltb_apfds_shell
	name = "LTB APFDS tank shell"
	contains = list(/obj/item/ammo_magazine/tank/ltb_cannon/apfds)
	cost = 10

/datum/supply_packs/vehicles/ltb_canister_shell
	name = "LTB Canister tank shell"
	contains = list(/obj/item/ammo_magazine/tank/ltb_cannon/canister)
	cost = 10

/datum/supply_packs/vehicles/secondary_flamer_tank
	name = "Spray flamer tank"
	contains = list(/obj/item/ammo_magazine/tank/secondary_flamer_tank)
	cost = 10

/datum/supply_packs/vehicles/ltaap_rounds
	name = "LTAAP tank magazine"
	contains = list(/obj/item/ammo_magazine/tank/ltaap_chaingun)
	cost = 10

/datum/supply_packs/vehicles/autocannon_ap_rounds
	name = "Bushwhacker Autocannon Armor Piercing ammo box"
	contains = list(/obj/item/ammo_magazine/tank/autocannon)
	cost = 10

/datum/supply_packs/vehicles/autocannon_he_rounds
	name = "Bushwhacker Autocannon High Explosive ammo box"
	contains = list(/obj/item/ammo_magazine/tank/autocannon/high_explosive)
	cost = 10

/datum/supply_packs/vehicles/cupola_rounds
	name = "Cupola tank magazine"
	contains = list(/obj/item/ammo_magazine/tank/secondary_cupola)
	cost = 10

/datum/supply_packs/vehicles/tow_rocket
	name = "TOW Missile"
	contains = list(/obj/item/ammo_magazine/tank/tow_missile)
	cost = 5 // marginally cheaper due to being a single loader

/datum/supply_packs/vehicles/microrocket_pod
	name = "Microrocket pod"
	contains = list(/obj/item/ammo_magazine/tank/microrocket_rack)
	cost = 10

/datum/supply_packs/vehicles/repairpack
	name = "Mech repairpack"
	contains = list(/obj/item/repairpack)
	cost = 10
