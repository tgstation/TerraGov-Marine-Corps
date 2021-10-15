/datum/emergency_call/skeleton
	name = "The Bone Zone"
	base_probability = 0
	spawn_type = /mob/living/carbon/human/species/skeleton


/datum/emergency_call/skeleton/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a skeleton, risen from beyond the grave.\n\
	Long have you rested, ejected into the void of space through battle or unfortunate circumstances, but now you have awoken.\n\
	The distress call has awoken you from your spacebound slumber.\n\
	Wipe out whatever has disturbed your eternal rest, so you may sleep once again.</b>")

/datum/emergency_call/skeleton/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .
	H.name = GLOB.namepool[/datum/namepool/skeleton].random_name(H)
	H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)
	H.update_hair()

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/skeleton/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the skeleton-in-chief. Lead your long-dead comrades to un-undeath or glory.")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/skeleton/basic)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a skeleton, with cool bones and stuff.")]</p>")
