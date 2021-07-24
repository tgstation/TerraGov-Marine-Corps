/datum/emergency_call/imperial
	name = "Imperial Guard Squad"
	base_probability = 0

/datum/emergency_call/imperial/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up [pick("on Cadia, the guardsmen factory", "on Holy Terra, the cradle of the Imperium")] to [pick(5;"a wealthy family of nobles, but you weren't as good as they wanted you to be, so they kicked you out",95;"a poor family that let you go on your own after you reached mature age, you never saw them again")].</B>")
	to_chat(H, "<B>You joined the Imperial Guard because [pick("you had nothing to lose, so you went with the worst, at least you could be somewhat useful", "after having your life be nothing but misery, you decided to make it even worse")].</B>")
	to_chat(H, "<B>Wait for the Emperor to give you objectives.</B>") // admin only ERT so have admins tell them what to do

/datum/emergency_call/imperial/create_member(datum/mind/M)
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
		// assign leader
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/imperial/guardsman/sergeant)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a veteran of the Imperial Guard, a sergeant.\nYou lead your men to battle, and have fought many times.")] [span_danger("FOR THE EMPEROR!")]</p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/imperial/guardsman/medicae)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a medicae of the Imperial Guard, a medic.\nYou help fellow guardsmen to live, and if they cannot be saved, you end their suffering.")] [span_danger("FOR THE EMPEROR!")]</p>")
		medics++
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/imperial/guardsman)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a member of the Imperial Guard, a lowly guardsman.\nThere are many like you, but you are special in your own way.\n")][span_danger("FOR THE EMPEROR!")]</p>")
