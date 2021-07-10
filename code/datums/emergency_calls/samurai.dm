/datum/emergency_call/samurai
	name = "Samurai reenactor"
	base_probability = 0
	spawn_type = /mob/living/carbon/human


/datum/emergency_call/samurai/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a travelling samurai, travelling the world to right wrongs.\n\
	Or at least, this is how you present yourself on the Extranet..\n\
	To most, you and your 'companions' are a bunch of questionably clean reenactors.\n\
	Of course, that won't stop you from demonstrating the power of your weapons upon everyone!.</b>")

/datum/emergency_call/samurai/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/samurai/basic/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<span class='notice'>You are a leader of your clique of weebaboos. Prepare to demonstrate your might to those bakas!</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/samurai/basic)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<span class='notice'>You are a standard member of your tight-knight group. Try not to make too much of a fuss, you will be kicked out!</span>")
