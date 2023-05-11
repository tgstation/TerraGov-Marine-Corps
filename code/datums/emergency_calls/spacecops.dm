/datum/emergency_call/spacecops
	name = "Colonial Law Enforcement Bureau Investigation Unit"
	base_probability = 20
	alignement_factor = -2
	///number of available special weapon dudes
	var/max_specialists = 3

/datum/emergency_call/spacecops/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B> You are a member of the local law enforcement unit stationed on a large nearby colony world, having arms and training above the civilian level with some exceptional gear given due to budget stimulus.</b>")
	to_chat(H, "<B>Usually, you spend most of your time patrolling the sector for criminal or terrorist activity in addition to eating donuts.</b>")
	to_chat(H, "")
	to_chat(H, "<B>However, recently, one of the local settlements recently went dark, broadcasting a distress signal, just as a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name] showed up in orbit, and the two are probably linked.</b>")
	to_chat(H, "<B>Investigate their presence, secure any criminal forces, and ensure space law is followed!</b>")

/datum/emergency_call/spacecops/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/spacecops/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the commander of this last minute police taskforce, find whatever needs to be batoned and/or disablered and proceed to shotgun it anyways, good luck lieutenant !</notice></p>")
		return
	if(max_specialists > 0)
		var/datum/job/J = SSjob.GetJobType(/datum/job/spacecops/tactical_officer)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the heavily armed tactical assault officer of your local police response team directed to investigate the TGMC distress signal sent nearby. Get in there and break something!")]</p>")
		max_specialists --
		return
	if(prob(30))
		var/datum/job/J = SSjob.GetJobType(/datum/job/spacecops/riot_officer)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a hard necked veteran officer loaded up with riot gear and a bad temper directed to investigate the TGMC distress signal sent nearby. Go bust some heads!")]</p>")
		return
	if(prob(30))
		var/datum/job/J = SSjob.GetJobType(/datum/job/spacecops/colonial_marshall)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a gunslinging,revolver spinning, hard eyed colonial marshall tagging along with the local response team on your way to take up your post on a nearbye colony that went dark. Make sure your colonists are alright!")]</p>")
		return
	var/datum/job/J = SSjob.GetJobType(/datum/job/spacecops/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a run of the mill beatcop called in last second to investigate the TGMC distress signal sent nearby. Hope whatever miscellanious gear you grabbed from the unlocked armory is enough for whatever you find!</notice></p>")
