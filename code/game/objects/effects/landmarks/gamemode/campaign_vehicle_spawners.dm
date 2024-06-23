/obj/effect/landmark/campaign/vehicle_spawner
	icon = 'icons/effects/campaign_effects.dmi'
	///Faction associated with this spawner
	var/faction = FACTION_TERRAGOV
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

//tank

/obj/effect/landmark/campaign/vehicle_spawner/tank
	name = "TGMC tank spawner"
	icon_state = "tank_spawner"
	vehicle_type = /obj/vehicle/sealed/armored/multitile/campaign

/obj/effect/landmark/campaign/vehicle_spawner/tank/Initialize(mapload)
	. = ..()
	GLOB.campaign_tank_spawners[faction] += list(src)

/obj/effect/landmark/campaign/vehicle_spawner/tank/Destroy()
	GLOB.campaign_tank_spawners[faction] -= src
	return ..()

/obj/effect/landmark/campaign/vehicle_spawner/tank/som
	name = "SOM tank spawner"
	faction = FACTION_SOM
	vehicle_type = /obj/vehicle/sealed/armored/multitile/som_tank
