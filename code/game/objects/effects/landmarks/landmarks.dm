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
	choose_weapon()
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/weapon_spawn/proc/spawn_associated_ammo(obj/item/weapon/gun/gun_to_spawn)
	//fuck you grenade launchers you snowflake pieces of shit
	if(istype(gun_to_spawn, /obj/item/weapon/gun/launcher/m92) || istype(gun_to_spawn, /obj/item/weapon/gun/launcher/m81))
		new /obj/item/storage/box/nade_box (get_turf(src))
		return
	
	if(istype(gun_to_spawn, /obj/item/weapon/gun/flare))
		new /obj/item/storage/box/m94 (get_turf(src))
		return

	if(istype(gun_to_spawn, /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/energy_gun_to_spawn = gun_to_spawn
		for(var/i in 1 to 3)
			new energy_gun_to_spawn.cell_type (get_turf(src))
		return

	if(!gun_to_spawn.current_mag)
		stack_trace("Attempted to spawn ammo for a gun that has no current_mag. Someone make a bugreport for this weapon [initial(gun_to_spawn.name)] as related to the tiered weapon spawning.")
		return
	var/obj/item/ammo_magazine/gun_mag = gun_to_spawn.current_mag.type

	if(istype(gun_to_spawn, /obj/item/weapon/gun/shotgun))
		var/obj/item/ammo_magazine/handful/handful_to_generate
		for(var/i in 1 to 3)
			handful_to_generate = new (get_turf(src))
			handful_to_generate.generate_handful(initial(gun_mag.default_ammo), initial(gun_mag.caliber), 5,5, /obj/item/weapon/gun/shotgun)
		return

	if(istype(gun_to_spawn, /obj/item/weapon/gun/revolver))
		var/obj/item/ammo_magazine/handful/handful_to_generate
		for(var/i in 1 to 3)
			handful_to_generate = new (get_turf(src))
			handful_to_generate.generate_handful(initial(gun_mag.default_ammo), initial(gun_mag.caliber), 8,8, /obj/item/weapon/gun/shotgun)
		return

	for(var/i in 1 to 3) //hardcoded 3 mags.
		new gun_mag (get_turf(src))

/obj/effect/landmark/weapon_spawn/proc/choose_weapon()
	weapon_to_spawn = pick(weapon_list)

	weapon_to_spawn = new weapon_to_spawn (get_turf(src))

	if(isgun(weapon_to_spawn))
		spawn_associated_ammo(weapon_to_spawn)

/obj/effect/landmark/weapon_spawn/tier1_weapon_spawn
	name = "Tier 1 Weapon Spawn"
	icon_state = "weapon1"
	weapon_list = list(	/obj/item/weapon/gun/energy/lasgun/M43/practice,
						/obj/item/weapon/gun/flare,
						/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3,
						/obj/item/weapon/gun/pistol/m1911,
						/obj/item/weapon/gun/pistol/b92fs,
						/obj/item/weapon/gun/pistol/b92fs/M9,
						/obj/item/weapon/gun/pistol/heavy,
						/obj/item/weapon/gun/pistol/heavy/gold,
						/obj/item/weapon/gun/pistol/c99,
						/obj/item/weapon/gun/pistol/c99/russian,
						/obj/item/weapon/gun/pistol/c99/upp,
						/obj/item/weapon/gun/pistol/c99/upp/tranq,
						/obj/item/weapon/gun/pistol/kt42,
						/obj/item/weapon/gun/pistol/holdout,
						/obj/item/weapon/gun/pistol/highpower,
						/obj/item/weapon/gun/pistol/vp70,
						/obj/item/weapon/gun/pistol/vp78,
						/obj/item/weapon/gun/revolver/standard_revolver,
						/obj/item/weapon/gun/revolver/m44,
						/obj/item/weapon/gun/revolver/upp,
						/obj/item/weapon/gun/revolver/small,
						/obj/item/weapon/gun/revolver/cmb,
						/obj/item/weapon/claymore/mercsword/machete,
						/obj/item/weapon/katana/replica,
						/obj/item/weapon/combat_knife,
						/obj/item/weapon/combat_knife/upp,
						/obj/item/weapon/throwing_knife,
						/obj/item/weapon/unathiknife,
						/obj/item/weapon/chainofcommand,
						/obj/item/weapon/broken_bottle,
						/obj/item/weapon/baseballbat,
						/obj/item/weapon/baseballbat/metal,
						/obj/item/weapon/butterfly,
						/obj/item/weapon/butterfly/switchblade,
						/obj/item/weapon/butterfly/katana
						)

/obj/effect/landmark/weapon_spawn/tier2_weapon_spawn
	name = "Tier 2 Weapon Spawn"
	icon_state = "weapon2"
	weapon_list = list(	/obj/item/weapon/gun/energy/lasgun/M43,
						/obj/item/weapon/gun/energy/lasgun/M43/stripped,
						/obj/item/weapon/gun/shotgun/pump/lever,
						/obj/item/weapon/gun/pistol/b92fs/raffica,
						/obj/item/weapon/gun/pistol/m1911/custom,
						/obj/item/weapon/gun/pistol/m4a3/custom,
						/obj/item/weapon/gun/revolver/mateba,
						/obj/item/weapon/gun/revolver/mateba/admiral,
						/obj/item/weapon/gun/revolver/mateba/captain,
						/obj/item/weapon/gun/smg/standard_smg,
						/obj/item/weapon/gun/smg/m39,
						/obj/item/weapon/gun/smg/mp5,
						/obj/item/weapon/gun/smg/mp7,
						/obj/item/weapon/gun/smg/skorpion,
						/obj/item/weapon/gun/smg/skorpion/upp,
						/obj/item/weapon/gun/smg/ppsh,
						/obj/item/weapon/gun/smg/uzi,
						/obj/item/weapon/gun/smg/p90,
						/obj/item/weapon/claymore,
						/obj/item/weapon/claymore/mercsword,
						/obj/item/weapon/claymore/mercsword/captain,
						/obj/item/weapon/claymore/mercsword/commissar_sword,
						/obj/item/weapon/katana,
						/obj/item/weapon/twohanded/fireaxe,
						/obj/item/weapon/twohanded/spear,
						/obj/item/weapon/twohanded/glaive
						)

/obj/effect/landmark/weapon_spawn/tier3_weapon_spawn
	name = "Tier 3 Weapon Spawn"
	icon_state = "weapon3"
	weapon_list = list(	/obj/item/weapon/gun/rifle/standard_carbine,
						/obj/item/weapon/gun/rifle/standard_assaultrifle,
						/obj/item/weapon/gun/rifle/standard_dmr,
						/obj/item/weapon/gun/rifle/m41a1,
						/obj/item/weapon/gun/rifle/m41a1/elite,
						/obj/item/weapon/gun/rifle/m41a,
						/obj/item/weapon/gun/rifle/ak47,
						/obj/item/weapon/gun/rifle/ak47/carbine,
						/obj/item/weapon/gun/rifle/m16,
						/obj/item/weapon/gun/rifle/standard_lmg,
						/obj/item/weapon/gun/rifle/m41ae2_hpr,
						/obj/item/weapon/gun/rifle/type71/flamer,
						/obj/item/weapon/gun/rifle/type71,
						/obj/item/weapon/gun/rifle/type71/carbine,
						/obj/item/weapon/gun/rifle/type71/carbine/commando,
						/obj/item/weapon/gun/rifle/sx16,
						/obj/item/weapon/gun/rifle/standard_autoshotgun,
						/obj/item/weapon/gun/energy/lasgun/lasrifle,
						/obj/item/weapon/gun/shotgun/pump,
						/obj/item/weapon/gun/shotgun/pump/cmb,
						/obj/item/weapon/gun/shotgun/pump/ksg,
						/obj/item/weapon/gun/shotgun/pump/t35,
						/obj/item/weapon/gun/flamer,
						/obj/item/weapon/gun/pistol/auto9,
						/obj/item/weapon/gun/smg/m39/elite,
						/obj/item/weapon/energy/sword,
						/obj/item/weapon/energy/sword/pirate,
						/obj/item/weapon/energy/sword/green,
						/obj/item/weapon/energy/sword/red
						)

/obj/effect/landmark/weapon_spawn/tier4_weapon_spawn
	name = "Tier 4 Weapon Spawn"
	icon_state = "weapon4"
	weapon_list = list(	/obj/item/weapon/gun/rifle/sniper/elite,
						/obj/item/weapon/gun/rifle/sniper/elite/xmas,
						/obj/item/weapon/gun/rifle/sniper/M42A,
						/obj/item/weapon/gun/rifle/sniper/svd,
						/obj/item/weapon/gun/launcher/m81,
						/obj/item/weapon/gun/rifle/standard_smartmachinegun,
						/obj/item/weapon/gun/rifle/sectoid_rifle,
						/obj/item/weapon/gun/rifle/m4ra,
						/obj/item/weapon/gun/shotgun/pump/bolt,
						/obj/item/weapon/gun/shotgun/pump/lever/mbx900,
						/obj/item/weapon/gun/shotgun/merc,
						/obj/item/weapon/gun/shotgun/merc/scout,
						/obj/item/weapon/gun/shotgun/combat,
						/obj/item/weapon/gun/shotgun/double,
						/obj/item/weapon/gun/shotgun/double/sawn,
						/obj/item/weapon/gun/flamer/M240T,
						/obj/item/weapon/energy/axe
						)

/obj/effect/landmark/weapon_spawn/tier5_weapon_spawn
	name = "Tier 5 Weapon Spawn"
	icon_state = "weapon5"
	weapon_list = list(	/obj/item/weapon/gun/launcher/rocket,
						/obj/item/weapon/gun/launcher/rocket/m57a4,
						/obj/item/weapon/gun/launcher/rocket/m57a4/xmas,
						/obj/item/weapon/gun/minigun,
						/obj/item/weapon/gun/launcher/m92,
						/obj/item/weapon/gun/energy/lasgun/pulse
						)

/obj/effect/landmark/weapon_spawn/tier6_weapon_spawn
	name = "Tier meme Weapon Spawn"
	icon_state = "weapon6"
	weapon_list = list(	/obj/item/weapon/gun/pistol/chimp,
						/obj/item/weapon/banhammer
						)
