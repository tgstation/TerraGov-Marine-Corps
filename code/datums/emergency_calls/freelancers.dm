/datum/emergency_call/freelancers
	name = "Freelancers"
	probability = 25


/datum/emergency_call/freelancers/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>Today, you have been contracted by the TGMC to assist the [MAIN_SHIP_NAME].</b>")
	to_chat(H, "<B>Ensure they are not destroyed. Collect payment.</b>")


/datum/emergency_call/freelancers/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	if(H.gender == MALE)
		H.name = pick(first_names_male_clf) + " " + pick(last_names_clf)
		H.real_name = H.name
		H.voice_name = H.name
	else
		H.name = pick(first_names_female_clf) + " " + pick(last_names_clf)
		H.real_name = H.name
		H.voice_name = H.name

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = new /datum/job/freelancer/leader
		J.equip(H)
		to_chat(H, "<span class='notice'>You are the Freelancer leader!</notice>")
		return

	if(medics < max_medics)
		var/datum/job/J = new /datum/job/freelancer/medic
		J.equip(H)
		medics++
		to_chat(H, "<span class='notice'>You are a Freelancer medic!</notice>")
		return

	var/datum/job/J = new /datum/job/freelancer/standard
	J.equip(H)
	to_chat(H, "<span class='notice'>You are a Freelancer mercenary!</notice>")
