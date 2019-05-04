/datum/emergency_call/deathsquad
	name = "Deathsquad"
	probability = 0
	shuttle_id = "Distress_PMC"
	name_of_spawn = "Distress_PMC"


/datum/emergency_call/deathsquad/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B> You must clear out any traces of the infestation and its survivors..</b>")
	to_chat(H, "<B> Follow any orders directly from Nanotrasen!</b>")


/datum/emergency_call/deathsquad/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current
	var/list/names = list("Alpha","Beta", "Gamma", "Delta","Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omnicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	H.name = pick(names)
	H.real_name = H.name
	H.voice_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/deathsquad/leader)
		SSjob.AssignRole(H, J.title)
		J.equip(H)
		to_chat(H, "<span class='notice'>You are the leader of the elite Death Squad commando!</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/deathsquad/standard)
		SSjob.AssignRole(H, J.title)
	J.equip(H)
	to_chat(H, "<span class='notice'>You are a member of the elite Death Squad commando!</span>")