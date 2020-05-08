/obj/effect/landmark/weapon_spawn/proc/spawn_weapon(var/obj/item/weapon/weapon_to_spawn)
	new weapon_to_spawn

/obj/effect/landmark/weapon_spawn/proc/spawn_associated_ammo(var/obj/item/weapon/weapon_to_spawn)
	if(weapon_to_spawn.current_mag)
		for(var/i = 1, i <= 3, i++) //hardcoded 3 mags.
			new weapon_to_spawn.current_mag

//pistols and knives
/obj/effect/landmark/weapon_spawn/proc/tier_1()
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3,
						/obj/item/weapon/combat_knife,
						/obj/item/weapon/throwing_knife
						)
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	spawn_associated_ammo(weapon_to_spawn)

//pistols and smgs
/obj/effect/landmark/weapon_spawn/proc/tier_2()
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3
						)
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	spawn_associated_ammo(weapon_to_spawn)

//shotguns and rifles
/obj/effect/landmark/weapon_spawn/proc/tier_3()
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3
						)
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	spawn_associated_ammo(weapon_to_spawn)

//low impact specialist weapons and ERT weapons
/obj/effect/landmark/weapon_spawn/proc/tier_4()
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3
						)
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	spawn_associated_ammo(weapon_to_spawn)

//high impact specialist weapons and ERT weapons
/obj/effect/landmark/weapon_spawn/proc/tier_5()
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3
						)
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	spawn_associated_ammo(weapon_to_spawn)

//the admin only spawn stuff
/obj/effect/landmark/weapon_spawn/proc/tier_6()
	weapon_list = list(	/obj/item/weapon/gun/pistol/standard_pistol,
						/obj/item/weapon/gun/pistol/m4a3
						)
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	spawn_associated_ammo(weapon_to_spawn)
