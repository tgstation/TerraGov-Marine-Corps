/obj/effect/landmark
	name = "landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	resistance_flags = UNACIDABLE
	layer = MID_LANDMARK_LAYER
	invisibility = INVISIBILITY_ABSTRACT


/obj/effect/landmark/Initialize()
	. = ..()
	GLOB.landmarks_list += src


/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()


/obj/effect/landmark/proc/after_round_start()
	return


/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE
	var/used = FALSE


/obj/effect/landmark/start/Initialize()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		if(!GLOB.jobspawn_overrides[name])
			GLOB.jobspawn_overrides[name] = list()
		GLOB.jobspawn_overrides[name] += src
	. = ..()
	if(name != "start")
		tag = "start*[name]"


/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		GLOB.jobspawn_overrides[name] -= src
	return ..()


/obj/effect/landmark/start/after_round_start()
	if(delete_after_roundstart)
		qdel(src)


/obj/effect/landmark/newplayer_start/New() //This can't be Initialize() or players will start in a wrong loc at roundstart.
	GLOB.newplayer_start += src


/obj/effect/landmark/start/latejoin
	icon_state = "latejoin"

/obj/effect/landmark/start/latejoin/Initialize()
	. = ..()
	GLOB.latejoin += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoinrebel/Initialize()
	. = ..()
	GLOB.latejoinrebel += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoinsom/Initialize()
	. = ..()
	GLOB.latejoinsom += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin_gateway/Initialize()
	. = ..()
	GLOB.latejoin_gateway += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin_cryo/Initialize()
	. = ..()
	GLOB.latejoin_cryo += loc
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/thunderdome/one
	icon_state = "tdome_t1"

/obj/effect/landmark/thunderdome/one/Initialize()
	. = ..()
	GLOB.tdome1 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two
	icon_state = "tdome_t2"

/obj/effect/landmark/thunderdome/two/Initialize()
	. = ..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/observe
	icon_state = "tdome_observer"

/obj/effect/landmark/thunderdome/observe/Initialize()
	. = ..()
	return INITIALIZE_HINT_QDEL // unused

/obj/effect/landmark/thunderdome/admin
	icon_state = "tdome_admin"

/obj/effect/landmark/thunderdome/admin/Initialize()
	. = ..()
	return INITIALIZE_HINT_QDEL // unused

/obj/effect/landmark/deathmatch/Initialize()
	. = ..()
	GLOB.deathmatch += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress

/obj/effect/landmark/distress_item

/obj/effect/landmark/weed_node
	name = "xeno weed node spawn landmark"
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "weednode"

/obj/effect/landmark/weed_node/Initialize()
	GLOB.xeno_weed_node_turfs += loc
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_resin_door
	name = "xeno resin door spawn landmark"
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "resin"

/obj/effect/landmark/xeno_resin_door/Initialize()
	GLOB.xeno_resin_door_turfs += loc
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_resin_wall
	name = "xeno resin wall spawn landmark"
	icon = 'icons/Xeno/structures.dmi'
	icon_state = "resin0"

/obj/effect/landmark/xeno_resin_wall/Initialize()
	GLOB.xeno_resin_wall_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_silo_spawn
	name = "xeno silo spawn landmark"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "weed_silo"

/obj/effect/landmark/xeno_silo_spawn/Initialize()
	GLOB.xeno_resin_silo_turfs += loc
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_turret_spawn
	name = "xeno turret spawn landmark"
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = "acid_turret"

/obj/effect/landmark/xeno_turret_spawn/Initialize()
	GLOB.xeno_turret_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/nuke_spawn
	name = "nuke spawn landmark"
	icon_state = "tdome_observer"

/obj/effect/landmark/nuke_spawn/Initialize()
	GLOB.nuke_spawn_locs += loc
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/dropship_start_location
	name = "dropship_start_location"

/obj/effect/landmark/dropship_start_location/Initialize()
	GLOB.minidropship_start_loc = loc
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/weapon_spawn
	name = "Base Weapon Spawn"
	icon_state = "x"
	var/weapon_list = list()
	var/weapon_to_spawn = null

/obj/effect/landmark/weapon_spawn/Initialize()
	choose_weapon()
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/weapon_spawn/proc/spawn_associated_ammo(obj/item/weapon/gun/gun_to_spawn)
	//fuck you grenade launchers you snowflake pieces of shit
	if(istype(gun_to_spawn, /obj/item/weapon/gun/grenade_launcher/multinade_launcher) || istype(gun_to_spawn, /obj/item/weapon/gun/grenade_launcher/single_shot))
		new /obj/item/storage/box/visual/grenade/frag (get_turf(src))
		return

	if(istype(gun_to_spawn, /obj/item/weapon/gun/grenade_launcher/single_shot/flare))
		new /obj/item/storage/box/m94 (get_turf(src))
		return

	if(!gun_to_spawn.default_ammo_type)
		return

	if(CHECK_BITFIELD(gun_to_spawn.reciever_flags, AMMO_RECIEVER_HANDFULS) && istype(gun_to_spawn.default_ammo_type, /datum/ammo))
		var/obj/item/ammo_magazine/handful/handful_to_generate
		var/datum/ammo/ammo_to_spawn = gun_to_spawn.default_ammo_type
		for(var/i in 1 to 3)
			handful_to_generate = new (get_turf(src))
			handful_to_generate.generate_handful(GLOB.ammo_list[ammo_to_spawn], initial(gun_to_spawn.caliber), initial(ammo_to_spawn.handful_amount), gun_to_spawn.type)
		return

	var/obj/item/ammo_to_spawn = gun_to_spawn.default_ammo_type
	for(var/i in 1 to 3) //hardcoded 3 mags.
		new ammo_to_spawn (get_turf(src))

/obj/effect/landmark/weapon_spawn/proc/choose_weapon()
	weapon_to_spawn = pick(weapon_list)

	weapon_to_spawn = new weapon_to_spawn (get_turf(src))

	if(isgun(weapon_to_spawn))
		spawn_associated_ammo(weapon_to_spawn)

/obj/effect/landmark/weapon_spawn/tier1_weapon_spawn
	name = "Tier 1 Weapon Spawn"
	icon_state = "weapon1"
	weapon_list = list(
		/obj/item/weapon/gun/energy/lasgun/M43/practice,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla,
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare,
		/obj/item/weapon/gun/pistol/standard_pistol,
		/obj/item/weapon/gun/pistol/standard_pocketpistol,
		/obj/item/weapon/gun/pistol/rt3,
		/obj/item/weapon/gun/pistol/m1911,
		/obj/item/weapon/gun/pistol/standard_heavypistol,
		/obj/item/weapon/gun/pistol/g22,
		/obj/item/weapon/gun/pistol/heavy,
		/obj/item/weapon/gun/pistol/heavy/gold,
		/obj/item/weapon/gun/pistol/c99,
		/obj/item/weapon/gun/pistol/c99/tranq,
		/obj/item/weapon/gun/pistol/holdout,
		/obj/item/weapon/gun/pistol/highpower,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/weapon/gun/pistol/vp78,
		/obj/item/weapon/gun/revolver/standard_revolver,
		/obj/item/weapon/gun/revolver/single_action/m44,
		/obj/item/weapon/gun/revolver/upp,
		/obj/item/weapon/gun/revolver/small,
		/obj/item/weapon/gun/revolver/cmb,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/katana/replica,
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/combat_knife/upp,
		/obj/item/stack/throwing_knife,
		/obj/item/weapon/chainofcommand,
		/obj/item/weapon/broken_bottle,
		/obj/item/weapon/baseballbat,
		/obj/item/weapon/baseballbat/metal,
		/obj/item/weapon/butterfly,
		/obj/item/weapon/butterfly/switchblade,
		/obj/item/weapon/katana/samurai,
	)

/obj/effect/landmark/weapon_spawn/tier2_weapon_spawn
	name = "Tier 2 Weapon Spawn"
	icon_state = "weapon2"
	weapon_list = list(
		/obj/item/weapon/gun/energy/lasgun/M43,
		/obj/item/weapon/gun/shotgun/pump/lever,
		/obj/item/weapon/gun/pistol/g22/tranq,
		/obj/item/weapon/gun/pistol/m1911/custom,
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/weapon/gun/revolver/mateba/notmarine,
		/obj/item/weapon/gun/revolver/mateba/custom,
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/weapon/gun/smg/standard_smg,
		/obj/item/weapon/gun/smg/m25,
		/obj/item/weapon/gun/smg/mp7,
		/obj/item/weapon/gun/smg/skorpion,
		/obj/item/weapon/gun/smg/ppsh,
		/obj/item/weapon/gun/smg/uzi,
		/obj/item/weapon/claymore,
		/obj/item/weapon/claymore/mercsword,
		/obj/item/weapon/claymore/mercsword/captain,
		/obj/item/weapon/claymore/mercsword/commissar_sword,
		/obj/item/weapon/katana,
		/obj/item/weapon/twohanded/fireaxe,
		/obj/item/weapon/twohanded/spear,
		/obj/item/weapon/twohanded/glaive,
	)

/obj/effect/landmark/weapon_spawn/tier3_weapon_spawn
	name = "Tier 3 Weapon Spawn"
	icon_state = "weapon3"
	weapon_list = list(
		/obj/item/weapon/gun/rifle/standard_carbine,
		/obj/item/weapon/gun/rifle/standard_assaultrifle,
		/obj/item/weapon/gun/rifle/standard_dmr,
		/obj/item/weapon/gun/rifle/standard_br,
		/obj/item/weapon/gun/rifle/m412,
		/obj/item/weapon/gun/rifle/m41a,
		/obj/item/weapon/gun/rifle/mpi_km,
		/obj/item/weapon/gun/rifle/m16,
		/obj/item/weapon/gun/rifle/famas,
		/obj/item/weapon/gun/rifle/alf_machinecarbine,
		/obj/item/weapon/gun/rifle/standard_lmg,
		/obj/item/weapon/gun/rifle/standard_gpmg,
		/obj/item/weapon/gun/rifle/m412l1_hpr,
		/obj/item/weapon/gun/rifle/type71/flamer,
		/obj/item/weapon/gun/rifle/type71,
		/obj/item/weapon/gun/rifle/standard_autoshotgun,
		/obj/item/weapon/gun/energy/lasgun/lasrifle,
		/obj/item/weapon/gun/shotgun/pump,
		/obj/item/weapon/gun/shotgun/pump/t35,
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/weapon/gun/shotgun/combat/standardmarine,
		/obj/item/weapon/gun/flamer/big_flamer,
		/obj/item/weapon/gun/pistol/auto9,
		/obj/item/weapon/gun/rifle/chambered,
		/obj/item/weapon/gun/rifle/tx11,
	)

/obj/effect/landmark/weapon_spawn/tier4_weapon_spawn
	name = "Tier 4 Weapon Spawn"
	icon_state = "weapon4"
	weapon_list = list(
		/obj/item/weapon/gun/rifle/type71/commando,
		/obj/item/weapon/gun/rifle/m412/elite,
		/obj/item/weapon/gun/rifle/sniper/elite,
		/obj/item/weapon/gun/smg/m25/elite,
		/obj/item/weapon/gun/rifle/sniper/elite/xmas,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/weapon/gun/rifle/railgun,
		/obj/item/weapon/gun/rifle/sniper/svd,
		/obj/item/weapon/gun/grenade_launcher/single_shot,
		/obj/item/weapon/gun/rifle/standard_smartmachinegun,
		/obj/item/weapon/gun/rifle/sectoid_rifle,
		/obj/item/weapon/gun/rifle/tx8,
		/obj/item/weapon/gun/shotgun/pump/bolt,
		/obj/item/weapon/gun/shotgun/pump/lever/mbx900,
		/obj/item/weapon/gun/shotgun/pump/cmb,
		/obj/item/weapon/gun/shotgun/double,
		/obj/item/weapon/gun/shotgun/double/sawn,
		/obj/item/weapon/gun/flamer/big_flamer/marinestandard,
		/obj/item/weapon/gun/rifle/standard_autosniper,
		/obj/item/weapon/energy/axe,
	)

/obj/effect/landmark/weapon_spawn/tier5_weapon_spawn
	name = "Tier 5 Weapon Spawn"
	icon_state = "weapon5"
	weapon_list = list(
		/obj/item/weapon/gun/launcher/rocket,
		/obj/item/weapon/gun/launcher/rocket/m57a4,
		/obj/item/weapon/gun/minigun,
		/obj/item/weapon/gun/grenade_launcher/multinade_launcher,
		/obj/item/weapon/gun/energy/lasgun/pulse,
	)

/obj/effect/landmark/weapon_spawn/tier6_weapon_spawn
	name = "Tier meme Weapon Spawn"
	icon_state = "weapon6"
	weapon_list = list(	/obj/item/weapon/gun/pistol/chimp,
						/obj/item/weapon/banhammer,
						/obj/item/weapon/chainsword,
						)

//used to spawn a different dropship control console groundside for HvH mode
/obj/effect/landmark/dropship_console_spawn_lz1
	name = "Dropship console spawn lz1"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"

/obj/effect/landmark/dropship_console_spawn_lz1/Initialize()
	. = ..()
	GLOB.lz1_shuttle_console_turfs_list += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/dropship_console_spawn_lz2
	name = "Dropship console spawn lz1"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "shuttle"

/obj/effect/landmark/dropship_console_spawn_lz2/Initialize()
	. = ..()
	GLOB.lz2_shuttle_console_turfs_list += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/fob_sentry
	name = "Fob sentry"
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry"

/obj/effect/landmark/fob_sentry/Initialize()
	. = ..()
	GLOB.fob_sentries_loc += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/fob_sentry_rebel
	name = "Rebel fob sentry"
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry"

/obj/effect/landmark/fob_sentry_rebel/Initialize()
	. = ..()
	GLOB.fob_sentries_rebel_loc += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/sensor_tower
	name = "Sensor tower"
	icon = 'icons/obj/structures/sensor.dmi'
	icon_state = "sensor"

/obj/effect/landmark/sensor_tower/Initialize()
	. = ..()
	var/area/area_to_control = get_area(src)
	area_to_control.set_to_contested()
	GLOB.sensor_towers += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/valhalla_xeno_spawn_landmark_close
	name = "Valhalla xeno spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn_valhalla"

/obj/effect/landmark/valhalla_xeno_spawn_landmark_close/Initialize()
	. = ..()
	GLOB.valhalla_xeno_spawn_landmark[CLOSE] = src

/obj/effect/landmark/valhalla_xeno_spawn_landmark_close_two
	name = "Valhalla xeno spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn_valhalla"

/obj/effect/landmark/valhalla_xeno_spawn_landmark_close_two/Initialize()
	. = ..()
	GLOB.valhalla_xeno_spawn_landmark[CLOSE2] = src

/obj/effect/landmark/valhalla_xeno_spawn_landmark_far
	name = "Valhalla xeno spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn_valhalla"

/obj/effect/landmark/valhalla_xeno_spawn_landmark_far/Initialize()
	. = ..()
	GLOB.valhalla_xeno_spawn_landmark[FAR] = src

/obj/effect/landmark/valhalla_xeno_spawn_landmark_far_two
	name = "Valhalla xeno spawn"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "xeno_spawn_valhalla"

/obj/effect/landmark/valhalla_xeno_spawn_landmark_far_two/Initialize()
	. = ..()
	GLOB.valhalla_xeno_spawn_landmark[FAR2] = src
