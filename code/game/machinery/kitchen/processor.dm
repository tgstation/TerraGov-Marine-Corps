/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = ABOVE_TABLE_LAYER
	density = 1
	anchored = 1
	var/broken = 0
	var/processing = 0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50



/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	proc/process(loc, what)
		if (src.output && loc)
			new src.output(loc)
		if (what)
			cdel(what)

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
					O.visible_message("\blue Suddenly [O] jumps out from the processor!", \
							"You jump out from the processor", \
							"You hear chimp")
					return
				var/obj/item/reagent_container/glass/bucket/bucket_of_blood = new(loc)
				var/datum/reagent/blood/B = new()
				B.holder = bucket_of_blood
				B.volume = 70
				//set reagent data
				B.data["donor"] = O

				for(var/datum/disease/D in O.viruses)
					if(D.spread_type != SPECIAL)
						B.data["viruses"] += D.Copy()

				B.data["blood_DNA"] = copytext(O.dna.unique_enzymes,1,0)
				if(O.resistances&&O.resistances.len)
					B.data["resistances"] = O.resistances.Copy()
				bucket_of_blood.reagents.reagent_list += B
				bucket_of_blood.reagents.update_total()
				bucket_of_blood.on_reagent_change()
				//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
				..()

			input = /mob/living/carbon/monkey
			output = null

/obj/machinery/processor/proc/select_recipe(var/X)
	for (var/Type in typesof(/datum/food_processor_process) - /datum/food_processor_process - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.processing)
		user << "\red The processor is in the process of processing."
		return 1
	if(src.contents.len > 0) //TODO: several items at once? several different items?
		user << "\red Something is already in the processing chamber."
		return 1
	var/obj/what = O
	if (istype(O, /obj/item/grab))
		var/obj/item/grab/G = O
		what = G.grabbed_thing

	var/datum/food_processor_process/P = select_recipe(what)
	if (!P)
		user << "\red That probably won't blend."
		return 1
	user.visible_message("[user] put [what] into [src].", \
		"You put the [what] into [src].")
	user.drop_held_item()
	what.forceMove(src)

/obj/machinery/processor/attack_hand(var/mob/user as mob)
	if (src.stat != 0) //NOPOWER etc
		return
	if(src.processing)
		user << "\red The processor is in the process of processing."
		return 1
	if(src.contents.len == 0)
		user << "\red The processor is empty."
		return 1
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor havent suitable recipe. How do you put it in?") //-rastaf0
			continue
		src.processing = 1
		user.visible_message("\blue [user] turns on [src].", \
			"You turn on [src].", \
			"You hear a food processor.")
		playsound(src.loc, 'sound/machines/blender.ogg', 25, 1)
		use_power(500)
		sleep(P.time)
		P.process(src.loc, O)
		src.processing = 0
	src.visible_message("\blue \the [src] finished processing.", \
		"You hear the food processor stopping/")

