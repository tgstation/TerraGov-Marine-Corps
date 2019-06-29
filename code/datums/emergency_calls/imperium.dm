/datum/emergency_call/imperial
	name = "Imperial Guardsmen"
	probability = 0

/datum/emergency_call/imperial/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up [pick("on Cadia, the guardsmen factory", "on Holy Terra, the cradle of the Imperium")] to [pick(5;"a wealthy family of nobles, but you weren't as good as they wanted you to be, so they kicked you out",95;"a poor family that let you go on your own after you reached mature age, you never saw them again")].</B>")
	to_chat(H, "<B>You joined the Imperial Guard because [pick("you had nothing to lose, so you went with the worst, at least you could be somewhat useful", "after having your life be nothing but misery, you decided to make it even worse")].</B>")
	to_chat(H, "<B>Wait for the Emperor to give you objectives.</B>") // admin only ERT so have admins tell them what to do

/datum/emergency_call/imperial/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current
	
	if(!istype(spawn_loc))
		return
	
	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)
	
	// custom wh40k names when?
	if(H.gender == MALE)
		H.name = pick(GLOB.first_names_male) + " " + pick(GLOB.last_names)
	else
		H.name = pick(GLOB.first_names_female) + " " + pick(GLOB.last_names)
	H.real_name = H.name
	
	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)
	
	if(original)
		qdel(original)
	
	print_backstory(H)
	
	if(!leader)
		// assign leader
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/imperial/guardsman/sergeant)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a veteran of the Imperial Guard, a sergeant.\nYou lead your men to battle, and have fought many times.</span> <span class='danger'>FOR THE EMPEROR!</span>")
		return
	
	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/imperial/guardsman/medicae)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a medicae of the Imperial Guard, a medic.\nYou help fellow guardsmen to live, and if they cannot be saved, you end their suffering.</span> <span class='danger'>FOR THE EMPEROR!</span>")
		medics++
		return
	
	var/datum/job/J = SSjob.GetJobType(/datum/job/imperial/guardsman)
	SSjob.AssignRole(H, J.title)
	J.assign_equip(H)
	to_chat(H, "<span class='notice'>You are a member of the Imperial Guard, a lowly guardsman.\nThere are many like you, but you are special in your own way.\n</span><span class='danger'>FOR THE EMPEROR!</span>")