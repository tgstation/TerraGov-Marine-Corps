//Colonial Liberation Front
/datum/emergency_call/clf
	name = "CLF"
	probability = 0


/datum/emergency_call/clf/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up [pick("on the TGMC prison station","in the LV-624 jungle","on a desert planet","on an icy colony")] to a[pick(50;" poor", 15;" well-off", 35;"n average")] family.</B>")
	to_chat(H, "<B>You joined the CLF because [pick(20;"you harbor a strong hatred for the oppressive TerraGov",5;"you are good at killing, and in times like these this is the place to be", 10;"your militia was absorbed into the CLF")] and you are considered a terrorist by the TGMC.</B>")
	to_chat(H, "<B>Assault the TGMC, and sabotage as much as you can. Ensure any survivors escape in your custody.</b>")


/datum/emergency_call/clf/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	if(H.gender == MALE)
		H.name = pick(GLOB.first_names_male_clf) + " " + pick(GLOB.last_names_clf)
		H.real_name = H.name
	else
		H.name = pick(GLOB.first_names_female_clf) + " " + pick(GLOB.last_names_clf)
		H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/clf/leader)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a leader of the local resistance group, the Colonial Liberation Front.</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/clf/medic)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a medic of the local resistance group, the Colonial Liberation Front.</span>")
		medics++
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/clf/standard)
	SSjob.AssignRole(H, J.title)
	J.assign_equip(H)
	to_chat(H, "<span class='notice'>You are a member of the local resistance group, the Colonial Liberation Front.</span>")