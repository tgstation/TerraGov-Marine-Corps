/// A cheap little roomba that runs around and keeps prep clean to decrease maptick and prep always being a fucking mess
/obj/machinery/roomba
	name = "nanotrasen roomba"
	desc = "A nanotrasen roomba, designed to keep areas clean from dirty marines."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "roomba"
	density = FALSE
	anchored = FALSE
	///Keeps track of how many items have been sucked for fluff
	var/counter = 0

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
	visible_message("<span class='warning'>The [src] beeps angrily as it is moved out of it's designated area!</span>")
	var/reversedir = REVERSE_DIR(dir)
	Move(get_step(src,reversedir), reversedir)

/obj/machinery/roomba/process()
	var/list/dirs = CARDINAL_DIRS - REVERSE_DIR(dir)
	var/turf/selection
	var/newdir
	while(!newdir)
		newdir = pick_n_take(dirs)
		selection = get_step(src, newdir)
		if(selection.density)
			newdir = null
		if(!length(dirs))
			return //roomba stuck help
	Move(get_step(src,newdir), newdir)


/obj/machinery/roomba/Bump(atom/A)
	. = ..()
	var/newdir = turn(dir, (pick(90, -90)))
	Move(get_step(src,newdir), newdir)

///Called when the roomba moves, sucks in all items held in the tile and sends them to cryo
/obj/machinery/roomba/proc/suck_items()
	SIGNAL_HANDLER
	for(var/obj/item/sucker in loc)
		sucker.store_in_cryo()
		counter++

/obj/machinery/roomba/attack_hand(mob/living/user)
	. = ..()
	visible_message("<span class='notice'>[user] lovingly pats the [src].</span>", "<span class='notice'>You lovingly pat the [src].</span>")
