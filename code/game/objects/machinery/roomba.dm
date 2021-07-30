/// A cheap little roomba that runs around and keeps prep clean to decrease maptick and prep always being a fucking mess
/obj/machinery/roomba
	name = "Nanotrasen roomba"
	desc = "A robot vacuum cleaner designed by Nanotrasen. The roomba is designed to keep areas clean from dirty marines."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "roomba"
	density = FALSE
	anchored = FALSE
	///Keeps track of how many items have been sucked for fluff
	var/counter = 0
	///The mine we have attached to this roomba
	var/obj/item/explosive/mine/claymore //Claymore roomb
	///So It doesnt infinitely look for an exit and crash the server
	var/stuck_counter = 0
	///Admins can let it have a claymore
	var/allow_claymore = FALSE

/obj/machinery/roomba/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_AREA_EXITED, .proc/turn_around)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/suck_items)
	start_processing()

/obj/machinery/roomba/Destroy()
	stop_processing()
	return ..()

/obj/machinery/roomba/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "A panel on the top says it has cleaned [counter] items!")

///Turns the roomba around when it leaves an area to make sure it doesnt wander off
/obj/machinery/roomba/proc/turn_around(datum/target)
	SIGNAL_HANDLER
	visible_message(span_warning("The [src] beeps angrily as it is moved out of it's designated area!"))
	step_to(src, get_step(src,REVERSE_DIR(dir)))

/obj/machinery/roomba/process()
	var/list/dirs = CARDINAL_DIRS - REVERSE_DIR(dir)
	var/turf/selection
	var/newdir
	for(var/i=1 to length(dirs))
		newdir = pick_n_take(dirs)
		selection = get_step(src, newdir)
		if(!selection.density)
			break
		newdir = null
	if(!newdir)
		return
	step_to(src, get_step(src,newdir))


/obj/machinery/roomba/Bump(atom/A)
	. = ..()
	if(++stuck_counter <= 3)
		step_to(src, get_step(src, turn(dir, pick(90, -90))))
		return
	visible_message(span_warning("The [src] beeps angrily as it get stuck!"))
	stop_processing()
	addtimer(CALLBACK(src, .proc/reactivate), 20 SECONDS)

/obj/machinery/roomba/proc/reactivate()
	stuck_counter = 0
	start_processing()



///Called when the roomba moves, sucks in all items held in the tile and sends them to cryo
/obj/machinery/roomba/proc/suck_items()
	SIGNAL_HANDLER
	for(var/obj/item/sucker in loc)
		if(sucker.flags_item & NO_VACUUM)
			return
		sucker.store_in_cryo()
		GLOB.cryoed_item_list[CRYO_REQ] += sucker
		counter++
	stuck_counter = 0

/obj/machinery/roomba/attack_hand(mob/living/user)
	. = ..()
	visible_message(span_notice("[user] lovingly pats the [src]."), span_notice("You lovingly pat the [src]."))

/obj/machinery/roomba/attackby(obj/item/I, mob/living/user, def_zone)
	if(!allow_claymore)
		return
	if(!istype(I, /obj/item/explosive/mine) || claymore)
		return
	visible_message(span_warning("[user] begins to try to attach [I] to [src]..."))
	stop_processing()
	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_HOSTILE))
		start_processing()
		return
	start_processing()
	visible_message(span_warning("[user] slams [I]'s prongs through [src]!"))
	log_game("[user] has armed [src] with a claymore at [AREACOORD(src)]")
	user.temporarilyRemoveItemFromInventory(I)
	I.forceMove(src)
	add_overlay(image(I.icon, initial(I.icon_state) + "_roomba"))
	claymore = I
	claymore.armed = TRUE
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED_BY, .proc/attempt_mine_explode)

/obj/machinery/roomba/proc/attempt_mine_explode(datum/source, atom/movable/crosser, oldloc)
	SIGNAL_HANDLER
	if(!claymore.trip_mine(crosser))
		return
	claymore = null
	UnregisterSignal(src, COMSIG_MOVABLE_CROSSED_BY)
	cut_overlays()
