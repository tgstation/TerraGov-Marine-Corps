/obj/item/minelayer
	name = "\improper M21 APRDS \"Minelayer\""
	desc = "Anti-Personnel Rapid Deploy System, APRDS for short, is a device designed to quickly deploy M20 mines in large quantities. WARNING: Operating in tight places or existing mine fields will result in reduced efficiency."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "minelayer"

	max_integrity = 200
	flags_item = IS_DEPLOYABLE|DEPLOYED_NO_ROTATE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/minelayer/Initialize()
	. = ..()
	AddElement(/datum/element/deployable_item, /obj/machinery/deployable/minelayer, 1 SECONDS)

/obj/machinery/deployable/minelayer
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = NO_POWER_USE
	///how many mines are currently stored
	var/stored_amount = 0
	///how many mines can be stored
	var/max_amount = 10
	///radius on mine placement
	var/range = 4

/obj/machinery/deployable/minelayer/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	sleep(3 SECONDS)

	var/obj/item/card/id/id = user.get_idcard()
	var/list/turf_list = list()

	for(var/turf/T AS in oview(range, loc))
		turf_list += T

	while(stored_amount > 0 && turf_list)
		var/turf/target_turf = pick_n_take(turf_list)
		if(!target_turf.density && !turf_block_check(src, target_turf) && !(locate(/obj/item/explosive/mine) in range(1, target_turf)))
			var/obj/item/explosive/mine/placed_mine = new /obj/item/explosive/mine(loc)
			placed_mine.throw_at(target_turf, range, 1)
			if(!(locate(/obj/item/explosive/mine) in get_turf(placed_mine)))
				placed_mine.iff_signal = id?.iff_signal
				placed_mine.anchored = TRUE
				placed_mine.armed = TRUE
				placed_mine.update_icon()
				placed_mine.setDir(pick(CARDINAL_ALL_DIRS))
				placed_mine.tripwire = new /obj/effect/mine_tripwire(get_step(target_turf, placed_mine.dir))
				placed_mine.tripwire.linked_mine = placed_mine
				playsound(target_turf, 'sound/weapons/mine_armed.ogg', 25, 1)
				stored_amount--
				sleep(0.5 SECONDS)

/obj/machinery/deployable/minelayer/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/explosive/mine) && stored_amount <= max_amount)
		stored_amount++
		qdel(I)

/obj/machinery/deployable/minelayer/wrench_act(mob/living/user, obj/item/I)
	while(stored_amount > 0)
		new /obj/item/explosive/mine(loc)
		stored_amount--

	return ..()

/obj/machinery/deployable/minelayer/examine(mob/user)
	. = ..()
	to_chat(user, span_info("[src] currently has [stored_amount]/[max_amount] stored mines."))
