//Supply drop. Just crates, no members.
#define ERT_CRATES pick(list(/obj/item/weapon/gun/smg/m25, \
							/obj/item/weapon/gun/smg/m25, \
							/obj/item/ammo_magazine/smg/m25/extended, \
							/obj/item/ammo_magazine/smg/m25/extended, \
							/obj/item/ammo_magazine/smg/m25/ap, \
							/obj/item/ammo_magazine/smg/m25/ap \
							), \
						list(/obj/item/weapon/gun/flamer, \
							/obj/item/weapon/gun/flamer, \
							/obj/item/ammo_magazine/flamer_tank, \
							/obj/item/ammo_magazine/flamer_tank \
							), \
						list(/obj/item/weapon/gun/rifle/standard_lmg, \
							/obj/item/ammo_magazine/standard_lmg, \
							/obj/item/ammo_magazine/standard_lmg, \
							), \
						list(/obj/item/weapon/gun/shotgun/combat, \
							/obj/item/weapon/gun/shotgun/combat, \
							/obj/item/ammo_magazine/shotgun/incendiary, \
							/obj/item/ammo_magazine/shotgun/incendiary \
							), \
						list(/obj/item/explosive/plastique, \
							/obj/item/explosive/plastique, \
							/obj/item/explosive/plastique, \
							/obj/item/detpack, \
							/obj/item/detpack, \
							/obj/item/assembly/signaler \
							), \
						list(/obj/item/weapon/gun/rifle/standard_carbine, \
							/obj/item/weapon/gun/rifle/standard_carbine, \
							/obj/item/ammo_magazine/rifle/incendiary, \
							/obj/item/ammo_magazine/rifle/incendiary, \
							/obj/item/ammo_magazine/rifle/incendiary, \
							/obj/item/ammo_magazine/rifle/ap, \
							/obj/item/ammo_magazine/rifle/ap \
							))


/datum/emergency_call/supplies
	name = "Supply Drop"
	mob_max = 0
	mob_min = 0
	base_probability = 0
	auto_shuttle_launch = TRUE


/datum/emergency_call/supplies/spawn_items()
	var/turf/drop_spawn
	var/total = rand(3,6)

	for(var/i = 1 to total)
		drop_spawn = get_spawn_point(TRUE)

		if(!istype(drop_spawn))
			return

		var/atom/location = new /obj/structure/closet/crate(drop_spawn)

		var/L[] = ERT_CRATES
		for(var/item in L)
			new item(location)


#undef ERT_CRATES
