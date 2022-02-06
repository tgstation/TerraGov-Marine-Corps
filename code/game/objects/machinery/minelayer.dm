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

	playsound(loc, 'sound/machines/click.ogg', 25, 1)

	sleep(2 SECONDS)

	var/list/turf_list = list()

	for(var/turf/T AS in orange(range, loc))
		turf_list += T

	while(stored_amount > 0 && turf_list.len > 0)
		var/turf/target_turf = pick_n_take(turf_list)
		if(!target_turf.density && !turf_block_check(src, target_turf) && !(locate(/obj/item/explosive/mine) in range(1, target_turf)))
			var/obj/item/explosive/mine/placed_mine = new /obj/item/explosive/mine(loc)
			placed_mine.throw_at(target_turf, range * 2, 1, src, TRUE)
			playsound(loc, 'sound/machines/switch.ogg', 25, 1)
			stored_amount--
			sleep(0.6 SECONDS)
			deploy_mine(user, placed_mine, target_turf)

	playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)

/obj/machinery/deployable/minelayer/proc/deploy_mine(mob/living/user, obj/item/explosive/mine/placed_mine, turf/target_turf)
	var/obj/item/explosive/mine/located_mine = locate(/obj/item/explosive/mine) in get_turf(placed_mine)
	if(located_mine)
		if(located_mine.armed == TRUE)
			return
	var/obj/item/card/id/id = user.get_idcard()
	placed_mine.iff_signal = id?.iff_signal
	placed_mine.anchored = TRUE
	placed_mine.armed = TRUE
	placed_mine.update_icon()
	placed_mine.setDir(pick(CARDINAL_ALL_DIRS))
	placed_mine.tripwire = new /obj/effect/mine_tripwire(get_step(target_turf, placed_mine.dir))
	placed_mine.tripwire.linked_mine = placed_mine
	playsound(target_turf, 'sound/weapons/mine_armed.ogg', 25, 1)

/obj/machinery/deployable/minelayer/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/explosive/mine) && stored_amount <= max_amount)
		stored_amount++
		qdel(I)
	if(istype(I, /obj/item/storage/box/explosive_mines))
		for(var/obj/item/explosive/mine/content AS in I)
			if(stored_amount < max_amount)
				stored_amount++
				qdel(content)

/obj/machinery/deployable/minelayer/disassemble(mob/user)
	while(stored_amount > 0)
		new /obj/item/explosive/mine(loc)
		stored_amount--
	return ..()

/obj/machinery/deployable/minelayer/examine(mob/user)
	. = ..()
	to_chat(user, span_info("[src] currently has [stored_amount]/[max_amount] stored mines."))
