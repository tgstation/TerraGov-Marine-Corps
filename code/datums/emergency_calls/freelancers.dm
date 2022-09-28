/datum/emergency_call/freelancers
	name = "Freelancer Mercenary Group"
	base_probability = 26
	alignement_factor = -1
	///Number of current Grenadiers in this squad.
	var/grenadiers
	///Max amount of Grenadiers allowed in this squad.
	var/max_grenadiers = 2


/datum/emergency_call/freelancers/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are part of a [pick(75;"distant", 25;"close")] family in a colony of [pick(25;"a space station", 25;"Earth", 50;"one of the many colonized planets")].</b>")
	to_chat(H, "<B>However, due to [pick("a famine", "a poverty", "a disease outbreak", "a small-scale disaster", "an uprising", "a mutiny", "the unbearable conditions", "the bad state", "the harsh opinion")] in your colony, you abandoned her. You were then hired by [pick("your cousin, who is a freelancer", "some freelancers", "a group of freelancers", "a squad of ex-military freelancers", "your long-lived companion, who is a freelancer")] to be part of a freelance mercenary group.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. You hope you can come back alive to get your pay!</b>")
	to_chat(H, "<B>Ensure they are not destroyed. Collect payment as long as you remain alive.</b>")


/datum/emergency_call/freelancers/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/freelancer/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the Freelancer mercenary assigned to lead this group in responding to the TGMC distress signal sent nearby. Keep your team in one piece to make sure they earn their payment!</notice></p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/freelancer/medic)
		H.apply_assigned_role_to_spawn(J)
		medics++
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a Freelancer mercenary medic assigned to this group to respond to the TGMC distress signal sent nearby. Do not let your teammates fall in battle!</notice></p>")
		return

	if(grenadiers < max_grenadiers)
		var/datum/job/J = SSjob.GetJobType(/datum/job/freelancer/grenadier)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, span_notice("You are a Grenadier of the local resistance group, the Colonial Liberation Front."))
		grenadiers++
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/freelancer/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a Freelancer mercenary assigned to this group to respond to the TGMC distress signal sent nearby. Don't let you and your team's guard down!</notice></p>")
