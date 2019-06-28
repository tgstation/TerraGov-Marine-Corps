/datum/emergency_call/pizza
	name = "Pizza Delivery"
	mob_max = 3
	probability = 5

/datum/emergency_call/pizza/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a pizza deliverer! Your employer is the Zippy Pizza Corporation.</b>")
	to_chat(H, "<B>Your job is to deliver your pizzas. You're PRETTY sure this is the right place...</b>")
	to_chat(H, "<B>Make sure you collect a tip.</b>")

/datum/emergency_call/pizza/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	var/datum/job/J = SSjob.GetJobType(/datum/job/other/pizza)
	SSjob.AssignRole(H, J.title)
	J.assign_equip(H)