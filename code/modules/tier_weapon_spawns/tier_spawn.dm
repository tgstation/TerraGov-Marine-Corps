/obj/effect/landmark/weapon_spawn/proc/spawn_associated_ammo(obj/item/weapon/gun/gun_to_spawn)
	for(var/i in 1 to 3) //hardcoded 3 mags.
		new gun_to_spawn.current_mag (get_turf(src))

//pistols and knives
/obj/effect/landmark/weapon_spawn/proc/choose_weapon()
	weapon_to_spawn = pick(weapon_list)

	to_chat(world, "ahhhhahhahahahah why aren't you spawning?")
	new weapon_to_spawn (get_turf(src))

	if(isgun(weapon_to_spawn))
		var/obj/item/weapon/gun/gun_to_spawn = weapon_to_spawn
		if(gun_to_spawn.current_mag)
			spawn_associated_ammo(gun_to_spawn)
