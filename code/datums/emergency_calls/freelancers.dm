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

	H.key = M.key

	if(original)
		qdel(original)

	H.client?.change_view(world.view))

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = new /datum/job/freelancer/leader
		H.set_everything(H, "Freelancer Leader")
		J.generate_equipment(H)
		to_chat(H, "<span class='notice'>You are the Freelancer leader!</notice>")
		return

	if(medics < max_medics)
		var/datum/job/J = new /datum/job/freelancer/medic
		H.set_everything(H, "Freelancer Medic")
		J.generate_equipment(H)
		medics++
		to_chat(H, "<span class='notice'>You are a Freelancer medic!</notice>")
		return

	var/datum/job/J = new /datum/job/freelancer/standard
	H.set_everything(H, "Freelancer Standard")
	J.generate_equipment(H)
	to_chat(H, "<span class='notice'>You are a Freelancer mercenary!</notice>")
