

//Supply drop. Just docks and has a crapload of stuff inside.
/datum/emergency_call/supplies
	name = "Supply Drop"
	mob_max = 0
	mob_min = 0
	arrival_message = "Weyland Yutani Automated Supply Drop 334-Q signal received. Docking procedures have commenced."
	probability = 5

/datum/emergency_call/supplies/spawn_items()
	var/turf/drop_spawn
	var/choice

	for(var/i = 1 to 3) //Spawns up to 3 random things.
		if(prob(20)) continue
		choice = (rand(1,8) - round(i/2)) //Decreasing values, rarer stuff goes at the end.
		if(choice < 0) choice = 0
		drop_spawn = get_spawn_point(1)
		if(istype(drop_spawn))
			switch(choice)
				if(0)
					new /obj/item/weapon/gun/pistol/m4a3(drop_spawn)
					new /obj/item/weapon/gun/pistol/m1911(drop_spawn)
					new /obj/item/ammo_magazine/pistol/extended(drop_spawn)
					new /obj/item/ammo_magazine/pistol/extended(drop_spawn)
					new /obj/item/ammo_magazine/pistol/ap(drop_spawn)
					new /obj/item/ammo_magazine/pistol/incendiary(drop_spawn)
				if(1)
					new /obj/item/weapon/gun/smg/m39(drop_spawn)
					new /obj/item/weapon/gun/smg/m39(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/extended(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/extended(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap(drop_spawn)
					new /obj/item/ammo_magazine/smg/m39/ap(drop_spawn)
				if(2)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
					new /obj/item/weapon/gun/flamer(drop_spawn)
				if(3)
					new /obj/item/explosive/plastique(drop_spawn)
					new /obj/item/explosive/plastique(drop_spawn)
					new /obj/item/explosive/plastique(drop_spawn)
					new /obj/item/explosive/grenade/frag/PMC(drop_spawn)
					new /obj/item/explosive/grenade/frag/PMC(drop_spawn)
					new /obj/item/explosive/grenade/frag/PMC(drop_spawn)
				if(4)
					new /obj/item/weapon/gun/rifle/m41a(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a(drop_spawn)
					new /obj/item/ammo_magazine/rifle/extended(drop_spawn)
					new /obj/item/ammo_magazine/rifle/extended(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/rifle/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/rifle/ap(drop_spawn)
					new /obj/item/ammo_magazine/rifle/ap(drop_spawn)
				if(5)
					new /obj/item/weapon/gun/shotgun/combat(drop_spawn)
					new /obj/item/weapon/gun/shotgun/combat(drop_spawn)
					new /obj/item/ammo_magazine/shotgun/incendiary(drop_spawn)
					new /obj/item/ammo_magazine/shotgun/incendiary(drop_spawn)
				/*if(6)
					new /obj/item/weapon/gun/rifle/m41a/scoped(drop_spawn)
					new /obj/item/weapon/gun/rifle/m41a/scoped(drop_spawn)
					new /obj/item/ammo_magazine/rifle/marksman(drop_spawn)
					new /obj/item/ammo_magazine/rifle/marksman(drop_spawn)*/
				if(6)
					new /obj/item/weapon/gun/rifle/lmg(drop_spawn)
					new /obj/item/weapon/gun/rifle/lmg(drop_spawn)
					new /obj/item/ammo_magazine/rifle/lmg(drop_spawn)
					new /obj/item/ammo_magazine/rifle/lmg(drop_spawn)
