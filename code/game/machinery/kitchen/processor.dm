/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = ABOVE_TABLE_LAYER
	density = TRUE
	anchored = TRUE
	var/broken = 0
	var/processing = 0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50



/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	process(loc, what)
		if (src.output && loc)
			new src.output(loc)
		if (what)
			qdel(what)

	/* objs */
	meat
		input = /obj/item/reagent_container/food/snacks/meat
		output = /obj/item/reagent_container/food/snacks/meatball

	potato
		input = /obj/item/reagent_container/food/snacks/grown/potato
		output = /obj/item/reagent_container/food/snacks/rawsticks

	carrot
		input = /obj/item/reagent_container/food/snacks/grown/carrot
		output = /obj/item/reagent_container/food/snacks/carrotfries

	soybeans
		input = /obj/item/reagent_container/food/snacks/grown/soybeans
		output = /obj/item/reagent_container/food/snacks/soydope

	wheat
		input = /obj/item/reagent_container/food/snacks/grown/wheat
		output = /obj/item/reagent_container/food/snacks/flour

	spaghetti
		input = /obj/item/reagent_container/food/snacks/flour
		output = /obj/item/reagent_container/food/snacks/spagetti

	/* mobs */
	mob
		process(loc, what)
			..()


		monkey
			process(loc, what)
				var/mob/living/carbon/monkey/O = what
				if (O.client) //grief-proof
					O.loc = loc
					O.visible_message("<span class='notice'> Suddenly [O] jumps out from the processor!</span>", \
							"You jump out from the processor", \
							"You hear chimp")
					return
				var/obj/item/reagent_container/glass/bucket/bucket_of_blood = new(loc)
				var/datum/reagent/blood/B = new()
				B.holder = bucket_of_blood
				B.volume = 70
				//set reagent data
				B.data["donor"] = O

				bucket_of_blood.reagents.reagent_list += B
				bucket_of_blood.reagents.update_total()
				bucket_of_blood.on_reagent_change()
				//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
				..()

			input = /mob/living/carbon/monkey
			output = null

/obj/machinery/processor/proc/select_recipe(var/X)
	for (var/Type in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(processing)
		to_chat(user, "<span class='warning'>The processor is in the process of processing.</span>")
		return TRUE

	if(length(contents))
		to_chat(user, "<span class='warning'>Something is already in the processing chamber.</span>")
		return TRUE

	var/obj/O = I

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		O = G.grabbed_thing

	var/datum/food_processor_process/P = select_recipe(O)
	if(!P)
		to_chat(user, "<span class='warning'>That probably won't blend.</span>")
		return TRUE
	user.visible_message("[user] puts [O] into [src].", \
		"You put the [O] into [src].")
	user.drop_held_item()
	O.forceMove(src)

/obj/machinery/processor/attack_hand(var/mob/user as mob)
	if (src.machine_stat != 0) //NOPOWER etc
		return
	if(src.processing)
		to_chat(user, "<span class='warning'>The processor is in the process of processing.</span>")
		return 1
	if(src.contents.len == 0)
		to_chat(user, "<span class='warning'>The processor is empty.</span>")
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0
			continue
		src.processing = 1
		user.visible_message("<span class='notice'> [user] turns on [src].</span>", \
			"You turn on [src].", \
			"You hear a food processor.")
		playsound(src.loc, 'sound/machines/blender.ogg', 25, 1)
		use_power(500)
		sleep(P.time)
		P.process(src.loc, O)
		src.processing = 0
	src.visible_message("<span class='notice'> \the [src] finished processing.</span>", \
		"You hear the food processor stopping/")

