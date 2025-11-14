/datum/emergency_call/pmc
	name = "NT Private Military Contractor Squad"
	base_probability = 11
	alignement_factor = -2
	shuttle_id = SHUTTLE_DISTRESS_PMC
	///Number of current Smartgunners in this squad.
	var/smartgunners = 0
	///Max amount of Smartgunners allowed in this squad.
	var/max_smartgunners = 2
	///Number of current Snipers in this squad.
	var/snipers = 0
	///Max amount of Snipers allowed in this squad.
	var/max_snipers = 1

/datum/emergency_call/pmc/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>After leaving your [pick(75;"distant", 20;"close", 5;"ever-lovingly close")] [pick("family", "friends", "band of friends", "friend group", "relatives", "cousins")] [pick("behind", "behind in safety", "behind secretly", "behind regrettably")], you decided to join the ranks of a private military contracting group working for Nanotrasen.</b>")
	to_chat(H, "<B>Working there has proven to be [pick(50;"very", 20;"somewhat", 5;"astoundingly")] profitable for you.</b>")
	to_chat(H, "<B>While you are [pick("enlisted as", "officially", "part-time officially", "privately")] [pick("an employee", "a security officer", "an officer")], much of your work is off the books. You work as a skilled rapid-response contractor.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Your time is running short, get your shuttle launching!</b>")
	to_chat(H, "<B>Make sure the Corporate Liaison is safe.</b>")
	to_chat(H, "<B>If there is no Liaison, eliminate the threat and cooperate with the Captain before returning back home.</b>")


/datum/emergency_call/pmc/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the leader of this private military contractor team in responding to the TGMC distress signal sent out nearby. Address the situation and get your team to safety!")]</p>")
		return

	if(smartgunners < max_smartgunners)
		var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/gunner)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a PMC heavy gunner assigned to this team to respond to the TGMC distress signal sent out nearby. Be the back guard of your squad!")]</p>")
		smartgunners++
		return

	if(snipers < max_snipers)
		var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/sniper)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a PMC heavy sniper assigned to this team to respond to the TGMC distress signal sent out nearby. Support your squad with long ranged firepower!")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a private military contractor assigned to this team to respond to the TGMC distress signal sent out nearby. Assist your team and protect NT's interests whenever possible!")]</p>")
