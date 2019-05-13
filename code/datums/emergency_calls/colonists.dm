//Colonist ERT with only basic items for events.
/datum/emergency_call/colonist
	name = "Colonists"


/datum/emergency_call/colonist/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a colonist!</b>")


/datum/emergency_call/colonist/create_member(datum/mind/M)
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

	var/datum/job/J = SSjob.GetJobType(/datum/job/other/colonist)
	SSjob.AssignRole(H, J.title)
	J.equip(H)