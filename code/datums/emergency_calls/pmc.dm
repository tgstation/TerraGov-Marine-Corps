/datum/emergency_call/pmc
	name = "PMC"
	probability = 25
	shuttle_id = "distress_pmc"


/datum/emergency_call/pmc/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>After leaving your [pick(75;"distant", 20;"close", 5;"ever-lovingly close")] [pick("family", "friends", "band of friends", "friend group", "relatives", "cousins")] [pick("behind", "behind in safety", "behind secretly", "behind regrettably")], you decided to join the ranks of a Nanotrasen private military contracting group.</b>")
	to_chat(H, "<B>Working there has proven to be [pick(50;"very", 20;"somewhat", 5;"astoundingly")] profitable for you.</b>")
	to_chat(H, "<B>While you are [pick("enlisted as", "officially", "part-time officially", "privately")] [pick("an employee", "a security officer", "an officer")], much of your work is off the books. You work as a skilled rapid-response contractor.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Your time is running short, get your shuttle launching!</b>")
	to_chat(H, "<B>Make sure the Corporate Liaison is safe.</b>")
	to_chat(H, "<B>If there is no Liaison, eliminate the threat and cooperate with the Captain before returning back home.</b>")


/datum/emergency_call/pmc/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	H.name = GLOB.namepool[/datum/namepool/pmc].random_name(H)
	H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/leader)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are the leader of this Nanotrasen contractor team in responding to the TGMC distress signal sent out nearby. Address the situation and get your team to safety!</span>")
		return

	if(prob(50))
		var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/gunner)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a Nanostrasen heavy gunner assigned to this team to respond to the TGMC distress signal sent out nearby. Be the back guard of your squad!</span>")
		return

	if(prob(30))
		var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/sniper)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a Nanotrasen heavy sniper assigned to this team to respond to the TGMC distress signal sent out nearby. Support your squad with long ranged firepower!</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/pmc/standard)
	SSjob.AssignRole(H, J.title)
	J.assign_equip(H)
	to_chat(H, "<span class='notice'>You are a Nanotrasen contractor assigned to this team to respond to the TGMC distress signal sent out nearby. Assist your team and protect NT's interests whenever possible!</span>")
