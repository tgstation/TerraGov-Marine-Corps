/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = ABOVE_TABLE_LAYER
	density = TRUE
	anchored = TRUE
	coverage = 20
	var/broken = 0
	var/processing = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 500

/obj/machinery/processor/nopower
	use_power = NO_POWER_USE

/datum/food_processor_process
	var/input
	var/output
	var/time = 40

/datum/food_processor_process/process(loc, what)
	if (src.output && loc)
		new src.output(loc)
	if (what)
		qdel(what)


/obj/machinery/processor/proc/select_recipe(X)
	for (var/Type in subtypesof(/datum/food_processor_process))
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(processing)
		to_chat(user, span_warning("The processor is in the process of processing."))
		return TRUE

	if(length(contents))
		to_chat(user, span_warning("Something is already in the processing chamber."))
		return TRUE

	var/obj/O = I

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		O = G.grabbed_thing

	var/datum/food_processor_process/P = select_recipe(O)
	if(!P)
		to_chat(user, span_warning("That probably won't blend."))
		return TRUE
	user.visible_message("[user] puts [O] into [src].", \
		"You put the [O] into [src].")
	user.drop_held_item()
	O.forceMove(src)

/obj/machinery/processor/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if (src.machine_stat != 0) //NOPOWER etc
		return
	if(src.processing)
		to_chat(user, span_warning("The processor is in the process of processing."))
		return 1
	if(src.contents.len == 0)
		to_chat(user, span_warning("The processor is empty."))
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			stack_trace("[O] in processor doesn't have a suitable recipe.") //-rastaf0
			continue
		src.processing = 1
		user.visible_message(span_notice(" [user] turns on [src]."), \
			"You turn on [src].", \
			"You hear a food processor.")
		playsound(src.loc, 'sound/machines/blender.ogg', 25, 1)
		use_power(active_power_usage)
		sleep(P.time)
		P.process(src.loc, O)
		src.processing = 0
	src.visible_message(span_notice(" \the [src] finished processing."), \
		"You hear the food processor stopping/")
