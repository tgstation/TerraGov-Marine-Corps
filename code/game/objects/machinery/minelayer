/obj/machinery/deployable/minelayer
	name = "\improper M21 APRDS \"Minelayer\""
	desc = "Anti-Personnel Rapid Deploy System, APRDS for short, is a device designed to quickly deploy M20 mines in large quantities. WARNING: Operating in tight places or existing mine fields will result in reduced efficiency."
	///radius on mine placement
	var/range = 3
	///amount of mines that we attempt to place
	var/amount = 5
	///amount of mines placed
	var/placed = 0
	///who activated the grenade
	var/mob/user = null //we need user to get iff signal

/obj/item/explosive/grenade/minelayer/attack_self(mob/M)
	user = M
	return ..()

/obj/item/explosive/grenade/minelayer/prime()
	if(!user) //if chain exploded; we dont want to place mines without iff
		explosion(loc, light_impact_range = 1, flash_range = 2)
		qdel(src)
		return

	var/obj/item/card/id/id = user.get_idcard()
	var/list/turf_list = list()

	for(var/turf/T AS in view(range, loc))
		turf_list += T

	while(placed <= amount)
		var/turf/target_turf = pick_n_take(turf_list)
		if(!target_turf.density && !turf_block_check(src, target_turf) && !(locate(/obj/item/explosive/mine) in range(1, target_turf)))
			var/obj/item/explosive/mine/placed_mine = new /obj/item/explosive/mine(target_turf)
			placed_mine.iff_signal = id?.iff_signal
			placed_mine.anchored = TRUE
			placed_mine.armed = TRUE
			placed_mine.update_icon()
			placed_mine.setDir(pick(CARDINAL_ALL_DIRS))
			placed_mine.tripwire = new /obj/effect/mine_tripwire(get_step(target_turf, placed_mine.dir))
			placed_mine.tripwire.linked_mine = placed_mine
			placed++

	playsound(loc, 'sound/effects/phasein.ogg', 25, 1)
	playsound(loc, 'sound/weapons/mine_armed.ogg', 50, 1)
	qdel(src)
