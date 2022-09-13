/datum/emergency_call/special_forces
	name = "Local System Special Forces"
	base_probability = 20
	alignement_factor = -1

/datum/emergency_call/special_forces/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are part of the local Special Responses unit, based within this isolated system, having received good training and equipment.</b>")
	to_chat(H, "<B>Usually, you spend most of your time providing security to the few big shots around here, in between RnR in your base and the occasional hostage situations.</b>")
	to_chat(H, "")
	to_chat(H, "<B>However, recently, one of the local settlement recently went dark, broadcasting a distress signal, just as a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name] showed up in orbit, and the two are probably linked.</b>")
	to_chat(H, "<B>Investigate their presence, and do your best to help the colony below!</b>")

/datum/emergency_call/special_forces/create_member(datum/mind/M)
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
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/special_forces/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the Special Forces captain assigned to lead this group in responding to the TGMC distress signal sent nearby. Keep your team in one piece and get the job done!</notice></p>")
		return

	if(prob(30))
		var/datum/job/J = SSjob.GetJobType(/datum/job/special_forces/breacher)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a specially trained member of this special force group directed to investigate the TGMC distress signal sent nearby. Be the vanguard of your squad!")]</p>")
		return


	var/datum/job/J = SSjob.GetJobType(/datum/job/special_forces/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a trained member of this special force group directed to investigate the TGMC distress signal sent nearby. Don't let you and your team's guard down!</notice></p>")
