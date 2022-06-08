/obj/item/minelayer
	name = "\improper M21 APRDS \"Minelayer\""
	desc = "Anti-Personnel Rapid Deploy System, APRDS for short, is a device designed to quickly deploy M20 mines in large quantities. WARNING: Operating in tight places or existing mine fields will result in reduced efficiency."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "minelayer"
	max_integrity = 200
	flags_item = IS_DEPLOYABLE
	w_class = WEIGHT_CLASS_NORMAL
	///amount of currently stored mines
	var/stored_mines = 0

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
	///time between throws
	var/cooldown = 0.6 SECONDS
	///stored iff signal
	var/iff_signal


/obj/machinery/deployable/minelayer/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/turf/turf_list = RANGE_TURFS(range, loc)
	var/obj/item/card/id/id = user.get_idcard()
	iff_signal = id?.iff_signal
	playsound(loc, 'sound/machines/click.ogg', 25, 1)
	addtimer(CALLBACK(src, .proc/throw_mine, turf_list), 2 SECONDS)

///this proc is used to check for valid turfs and throw mines
/obj/machinery/deployable/minelayer/proc/throw_mine(list/turf/list_of_turfs)
	if(!stored_amount > 0 || !length(list_of_turfs))
		playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)
		return
	var/turf/target_turf = pick_n_take(list_of_turfs)
	if(target_turf.density || turf_block_check(src, target_turf) || locate(/obj/item/explosive/mine) in range(1, target_turf) || !line_of_sight(loc, target_turf))
		throw_mine(list_of_turfs)
		return
	var/obj/item/explosive/mine/mine_to_throw = new /obj/item/explosive/mine(loc)
	mine_to_throw.throw_at(target_turf, range * 2, 1, src, TRUE)
	stored_amount--
	playsound(loc, 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg', 25, 1)
	addtimer(CALLBACK(src, .proc/place_mine, target_turf, mine_to_throw), cooldown)
	addtimer(CALLBACK(src, .proc/throw_mine, list_of_turfs), cooldown)

///this proc is used to check a turf and place mines
/obj/machinery/deployable/minelayer/proc/place_mine(turf/T, obj/item/explosive/mine/throwed_mine)
	var/obj/item/explosive/mine/located_mine = locate(/obj/item/explosive/mine) in get_turf(throwed_mine)
	if(located_mine?.armed)
		return
	throwed_mine.deploy_mine(null, iff_signal)

/obj/machinery/deployable/minelayer/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/explosive/mine) && stored_amount <= max_amount)
		stored_amount++
		qdel(I)
		return
	if(!istype(I, /obj/item/storage/box/explosive_mines))
		return
	for(var/obj/item/explosive/mine/content AS in I)
		if(stored_amount < max_amount)
			stored_amount++
			qdel(content)

/obj/machinery/deployable/minelayer/disassemble(mob/user)
	for(var/i = 1 to stored_amount)
		new /obj/item/explosive/mine(loc)
	stored_amount = 0
	return ..()

/obj/machinery/deployable/minelayer/examine(mob/user)
	. = ..()
	. += span_info("[src] currently has [stored_amount]/[max_amount] stored mines.")
