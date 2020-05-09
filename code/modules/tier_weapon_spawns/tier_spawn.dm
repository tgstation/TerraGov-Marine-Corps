/obj/effect/landmark/weapon_spawn/proc/spawn_weapon(/obj/item/weapon/weapon_to_spawn)
	new weapon_to_spawn(src.loc)

/obj/effect/landmark/weapon_spawn/proc/spawn_associated_ammo(obj/item/weapon/gun/gun_to_spawn)
	for(var/i in 1 to 3) //hardcoded 3 mags.
		new gun_to_spawn.current_mag

//pistols and knives
/obj/effect/landmark/weapon_spawn/proc/choose_weapon()
	weapon_to_spawn = pick(weapon_list)

	spawn_weapon(weapon_to_spawn)
	if(isgun(weapon_to_spawn))
		var/obj/item/weapon/gun/gun_to_spawn = weapon_to_spawn
		if(gun_to_spawn.current_mag)
			spawn_associated_ammo(gun_to_spawn)
