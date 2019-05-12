//Sons of Mars
/datum/emergency_call/som
	name = "SOM"
	probability = 20


/datum/emergency_call/som/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<b>Lore.</b>")


/datum/emergency_call/som/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!spawn_loc)
		stack_trace("Tried to create_member() with no spawn_loc.")
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	if(H.gender == MALE)
		H.name = pick(GLOB.first_names_male_clf) + " " + pick(GLOB.last_names_clf)
		H.real_name = H.name
		H.voice_name = H.name
	else
		H.name = pick(GLOB.first_names_female_clf) + " " + pick(GLOB.last_names_clf)
		H.real_name = H.name
		H.voice_name = H.name

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/leader)
		J.equip(H)
		to_chat(H, "<span class='notice'>Lore.</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/medic)
		J.equip(H)
		to_chat(H, "<span class='notice'>Lore.</span>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/veteran)
		J.equip(H)
		to_chat(H, "<span class='notice'>Lore.</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/som/standard)
	J.equip(H)
	to_chat(H, "<span class='notice'>Lore.</span>")
