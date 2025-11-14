/obj/effect/landmark/campaign/vehicle_spawner
	icon = 'icons/effects/campaign_effects.dmi'
	faction = FACTION_TERRAGOV
	///Mech type for this spawner
	var/vehicle_type


///Creates and sets up the vehicle
/obj/effect/landmark/campaign/vehicle_spawner/proc/spawn_vehicle()
	if(!ispath(vehicle_type))
		return
	. = new vehicle_type(loc)

//mech spawn points
/obj/effect/landmark/campaign/vehicle_spawner/mech
	name = "tgmc med mech spawner"
	icon_state = "mech"
	vehicle_type = /obj/vehicle/sealed/mecha/combat/greyscale/assault/noskill
	///Colours to paint mechs from this spawner
	var/list/colors = list(ARMOR_PALETTE_SPACE_CADET, ARMOR_PALETTE_GREYISH_TURQUOISE)
	///Colours to paint mech heads from this spawner for better visual clarity
	var/list/head_colors = list(ARMOR_PALETTE_STORM, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_SYNDIE_GREEN)

/obj/effect/landmark/campaign/vehicle_spawner/mech/Initialize(mapload)
	. = ..()
	GLOB.campaign_mech_spawners[faction] += list(src)

/obj/effect/landmark/campaign/vehicle_spawner/mech/Destroy()
	GLOB.campaign_mech_spawners[faction] -= src
	return ..()

/obj/effect/landmark/campaign/vehicle_spawner/mech/spawn_vehicle()
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/mecha/combat/greyscale/new_mech = .
	for(var/i in new_mech.limbs)
		var/datum/mech_limb/limb = new_mech.limbs[i]
		limb.update_colors(arglist(istype(limb, /datum/mech_limb/head) ? head_colors : colors))
	new_mech.update_icon()

/obj/effect/landmark/campaign/vehicle_spawner/mech/heavy
	name = "tgmc heavy mech spawner"
	icon_state = "mech_heavy"
	head_colors = list(ARMOR_PALETTE_RED, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_SYNDIE_GREEN)
	vehicle_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/vehicle_spawner/mech/light
	name = "tgmc light mech spawner"
	icon_state = "mech_light"
	head_colors = list(ARMOR_PALETTE_SPACE_CADET, ARMOR_PALETTE_GREYISH_TURQUOISE, VISOR_PALETTE_SYNDIE_GREEN)
	vehicle_type = /obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill

/obj/effect/landmark/campaign/vehicle_spawner/mech/som
	name = "som med mech spawner"
	faction = FACTION_SOM
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_ANGELIC)
	head_colors = list(ARMOR_PALETTE_ANGELIC, ARMOR_PALETTE_GREY, VISOR_PALETTE_SYNDIE_GREEN)

/obj/effect/landmark/campaign/vehicle_spawner/mech/som/heavy
	name = "som heavy mech spawner"
	icon_state = "mech_heavy"
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_MAGENTA)
	head_colors = list(ARMOR_PALETTE_MAGENTA, ARMOR_PALETTE_GRAPE, VISOR_PALETTE_ELITE_ORANGE)
	vehicle_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/vehicle_spawner/mech/som/light
	name = "som light mech spawner"
	icon_state = "mech_light"
	colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_BLACK)
	head_colors = list(ARMOR_PALETTE_GINGER, ARMOR_PALETTE_BLACK, VISOR_PALETTE_SYNDIE_GREEN)
	vehicle_type = /obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill


/obj/effect/landmark/campaign/vehicle_spawner/tank
	name = "TGMC LTB tank spawner"
	icon_state = "tank_spawner"
	vehicle_type = /obj/vehicle/sealed/armored/multitile/campaign
	///List of gear the tank spawns with
	var/list/equipment_list = list(
		/obj/item/armored_weapon = 1,
		/obj/item/armored_weapon/secondary_weapon = 1,
		/obj/item/ammo_magazine/tank/ltb_cannon/heavy = 18,
		/obj/item/ammo_magazine/tank/ltb_cannon/apfds = 12,
		/obj/item/ammo_magazine/tank/ltb_cannon/canister/incendiary = 5,
		/obj/item/ammo_magazine/tank/secondary_cupola = 10,
	)

/obj/effect/landmark/campaign/vehicle_spawner/tank/Initialize(mapload)
	. = ..()
	GLOB.campaign_tank_spawners[faction] += list(src)

/obj/effect/landmark/campaign/vehicle_spawner/tank/Destroy()
	GLOB.campaign_tank_spawners[faction] -= src
	return ..()

/obj/effect/landmark/campaign/vehicle_spawner/tank/spawn_vehicle()
	. = ..()
	if(!.)
		return
	var/obj/vehicle/spawned_vehicle = .
	spawned_vehicle.setDir(dir)
	spawn_equipment()

///Spawns all required gear for the tank
/obj/effect/landmark/campaign/vehicle_spawner/tank/proc/spawn_equipment()
	var/turf/gun_turf = get_ranged_target_turf(src, REVERSE_DIR(dir), 3)
	var/ammo_turf = get_step(gun_turf, (turn(dir, 90)))
	var/pamphlet_turf = get_step(gun_turf, turn(dir, -90))
	for(var/obj/typepath AS in equipment_list)
		for(var/num = 1 to equipment_list[typepath])
			var/obj/new_item = new typepath(ammo_turf)
			if(!istype(new_item, /obj/item/armored_weapon))
				continue
			new_item.forceMove(gun_turf)
	for(var/i = 1 to 4)
		new /obj/item/pamphlet/tank_crew(pamphlet_turf)

/obj/effect/landmark/campaign/vehicle_spawner/tank/ltaap_chaingun
	name = "TGMC LTAAP tank spawner"
	equipment_list = list(
		/obj/item/armored_weapon/ltaap = 1,
		/obj/item/armored_weapon/secondary_weapon = 1,
		/obj/item/ammo_magazine/tank/ltaap_chaingun/hv = 20,
		/obj/item/ammo_magazine/tank/secondary_cupola = 10,
	)

/obj/effect/landmark/campaign/vehicle_spawner/tank/som
	name = "SOM tank spawner - coilgun"
	faction = FACTION_SOM
	vehicle_type = /obj/vehicle/sealed/armored/multitile/som_tank
	equipment_list = list(
		/obj/item/armored_weapon/coilgun = 1,
		/obj/item/armored_weapon/secondary_mlrs = 1,
		/obj/item/ammo_magazine/tank/coilgun = 40,
		/obj/item/ammo_magazine/tank/secondary_mlrs = 8,
	)

/obj/effect/landmark/campaign/vehicle_spawner/tank/som/particle_lance
	name = "SOM tank spawner - particle lance"
	equipment_list = list(
		/obj/item/armored_weapon/particle_lance = 1,
		/obj/item/armored_weapon/secondary_mlrs = 1,
		/obj/item/ammo_magazine/tank/particle_lance = 30,
		/obj/item/ammo_magazine/tank/secondary_mlrs = 8,
	)

/obj/effect/landmark/campaign/vehicle_spawner/tank/som/volkite_carronade
	name = "SOM tank spawner - carronade"
	equipment_list = list(
		/obj/item/armored_weapon/volkite_carronade = 1,
		/obj/item/armored_weapon/secondary_mlrs = 1,
		/obj/item/ammo_magazine/tank/volkite_carronade = 20,
		/obj/item/ammo_magazine/tank/secondary_mlrs = 8,
	)
