//Sons of Mars
/datum/emergency_call/som
	name = "SOM"
	probability = 20


/datum/emergency_call/som/print_backstory(mob/living/carbon/human/H)
	to_chat(H, pick("You grew up in the mines working in horrible conditions until signing up to the SoM.", \
		"You were part of a poor family until you decided to leave to join the SoM",\
		"You were born on a colony to a family of several brothers and sisters before leaving to the SoM",\
		"You worked at horrible conditions in the mines until deciding to leave to join the SoM."))
	to_chat(H, "Eliminate the TGMC.")


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
	else
		H.name = pick(GLOB.first_names_female_clf) + " " + pick(GLOB.last_names_clf)
		H.real_name = H.name

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/leader)
		J.equip(H)
		to_chat(H, "<span class='notice'>You are a Squad Leader of the Sons of Mars assigned to lead this fireteam to the Distress signal sent out nearby. Lead your squad in this read and kill everyone who stands in your teams way!</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/medic)
		J.equip(H)
		to_chat(H, "<span class='notice'>You are a Sons of Mars medic assigned to this fireteam to respond to the Distress signal. Keep your squad alive in this fight!</span>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/veteran)
		J.equip(H)
		to_chat(H, "<span class='notice'>You are a veteran of the Sons of Mars and are assigned to this fireteam to respond to the Distress signal sent out nearby. Do them proud and kill all who stand in your teams way!</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/som/standard)
	J.equip(H)
	to_chat(H, "<span class='notice'>You are a Squad Leader of the Sons of Mars assigned to lead this fireteam to the TGN distress signal sent out nearby. Lead your squad in this read and kill everyone who stands in your teams way!</span>")
