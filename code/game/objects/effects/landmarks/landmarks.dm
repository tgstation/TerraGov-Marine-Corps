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

/obj/effect/landmark/monkey_spawn
	icon_state = "monkey_spawn"

/obj/effect/landmark/monkey_spawn/Initialize() // unused but i won't remove the landmarks for these yet
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress

/obj/effect/landmark/distress_item


/obj/effect/landmark/xeno_silo_spawn
	name = "xeno silo spawn landmark"
	icon_state = "tdome_observer"

/obj/effect/landmark/xeno_silo_spawn/Initialize()
	GLOB.xeno_resin_silo_turfs += loc
	. = ..()
	return INITIALIZE_HINT_QDEL


/obj/effect/landmark/nuke_spawn
	name = "nuke spawn landmark"
	icon_state = "tdome_observer"

/obj/effect/landmark/nuke_spawn/Initialize()
	GLOB.nuke_spawn_locs += loc
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/weapon_spawn
	name = "Base Weapon Spawn"
	icon_state = "x"
	var/weapon_list = list()
	var/weapon_to_spawn = null

/obj/effect/landmark/weapon_spawn/Initialize()
	GLOB.weapon_spawn_list += src
	choose_weapon()
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/weapon_spawn/Destroy()
	GLOB.weapon_spawn_list -= src
	return ..()

/obj/effect/landmark/weapon_spawn/proc/spawn_associated_ammo(obj/item/weapon/gun/gun_to_spawn)
	var/obj/item/ammo_magazine/gun_mag = gun_to_spawn.current_mag
	for(var/i in 1 to 3) //hardcoded 3 mags.
		new gun_mag (get_turf(src))

//pistols and knives
/obj/effect/landmark/weapon_spawn/proc/choose_weapon()
	weapon_to_spawn = pick(weapon_list)

	new weapon_to_spawn (get_turf(src))

	if(isgun(weapon_to_spawn))
		var/obj/item/weapon/gun/gun_to_spawn = weapon_to_spawn
		if(gun_to_spawn.current_mag)
			spawn_associated_ammo(gun_to_spawn)

/obj/effect/landmark/weapon_spawn/tier1_weapon_spawn
	name = "Tier 1 Weapon Spawn"
	icon_state = "weapon1"
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
					/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/throwing_knife
					)

/obj/effect/landmark/weapon_spawn/tier2_weapon_spawn
	name = "Tier 2 Weapon Spawn"
	icon_state = "weapon2"

/obj/effect/landmark/weapon_spawn/tier3_weapon_spawn
	name = "Tier 3 Weapon Spawn"
	icon_state = "weapon3"

/obj/effect/landmark/weapon_spawn/tier4_weapon_spawn
	name = "Tier 4 Weapon Spawn"
	icon_state = "weapon4"

/obj/effect/landmark/weapon_spawn/tier5_weapon_spawn
	name = "Tier 5 Weapon Spawn"
	icon_state = "weapon5"

/obj/effect/landmark/weapon_spawn/tier6_weapon_spawn
	name = "Tier 6 Weapon Spawn"
	icon_state = "weapon6"
