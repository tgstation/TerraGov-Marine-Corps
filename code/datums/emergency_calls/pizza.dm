/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 3
	probability = 5

/datum/emergency_call/pizza/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a pizza deliverer! Your employer is the [pick("Discount Pizza","Pizza Kingdom","Papa Pizza")] Corporation.</b>")
	to_chat(H, "<B>Your job is to deliver your pizzas. You're PRETTY sure this is the right place..</b>")
	to_chat(H, "<B>Make sure you get a tip.</b>")

/datum/emergency_call/pizza/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	H.key = M.key

	if(original)
		qdel(original)

	H.client?.change_view(world.view)

	print_backstory(H)

	var/datum/job/J = new /datum/job/other/pizza
	J.equip(H)
