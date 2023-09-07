// ICC
/datum/emergency_call/icc
	name = "Independent Colonial Confederation Squad"
	base_probability = 26
	alignement_factor = 0

/datum/emergency_call/icc/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are part of the Independent Colonial Confederation Armed Forces (ICCAF), formed by the ICC, a group of former generation ship colonies which have banded together to form economic and military alliances against their much larger neighbor TerraGov.</b>")
	to_chat(H, "<B>Even though the ICC has its own standing army independent of its members, most larger members retain their own standing fleet and army, with their own equipment and doctrines, the standard force is known for being consistently underfunded and manned.</b>")
	to_chat(H, "<B>Due to this a large portion of ship personnel end up serving as adhoc ground personnel, however actual Infantrymen which are better known as 'Guardsmen' are well known for being high quality troops.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TerraGov vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. This is our chance to attack without being intercepted!</b>")
	to_chat(H, "<B>Eliminate the TerraGov personnel onboard, capture the ship. If there are fellow ICC contingents such as the SoM, then work with them in this goal. Take no prisoners.</B>")

/datum/emergency_call/icc/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/icc/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the ICC Squad Leader assigned to lead this group in responding to the TGMC distress signal sent nearby. Keep your team in one piece, take over this vessel and get the job done!</notice></p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/icc/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You an ICCN Medic assigned to make sure this group of people don't die while responding to the TGMC distress signal sent nearby. Keep your team in one piece, take over this vessel and get the job done!</notice></p>")
		medics++
		return

	if(prob(15))
		var/datum/job/J = SSjob.GetJobType(/datum/job/icc/guard)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a trained member of the ICCGF, unlike most you are a dedicated infantryman, better known as a 'Guardsman'. You have been attached to this ICCN group to investigate the TGMC distress signal sent nearby. Be the vanguard of your squad!")]</p>")
		return


	var/datum/job/J = SSjob.GetJobType(/datum/job/icc/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a trained member of the ICCN, you have been assigned to this squad directed to investigate the TGMC distress signal sent nearby. Don't let you and your team's guard down!</notice></p>")
