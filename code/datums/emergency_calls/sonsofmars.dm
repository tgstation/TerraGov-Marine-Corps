//Sons of Mars
/datum/emergency_call/som
	name = "SFOC-T Fireteam"
	probability = 10


/datum/emergency_call/som/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are part of TerraGov's Special Forces Operational Contingent-Terra (SFOC-T) unit whose background remain classified..</b>")
	to_chat(H, "<B>Though rumors say that [pick("you work for a death squad group assigned in", "you were modified to not feel any emotions in a research lab of", "you were a soldier who was affected by PTSD after an operation in", "you were an product of a classified genetics research in", "you were an experimental soldier in the depths of", "left for dead and later recovered in", "listed as KIA but remained alive during a botchered operation in", 5;"raised literally from the depths of hell itself. Only until you were recovered in", 5;"raised literally from the Higher Power. But realized you were in")] [pick(10;"Mars", 10;"Earth's moon, Luna", 10;"Earth", 10;"a space station", "a war-ridden outpost", "a jungle", "a defunct TGMC-NT station", "a desert planet", "an icey colony", "a frozen cave system", "a molten planet", "a digsite", "a research outpost")].</B>")
	to_chat(H, "<B>Nevertheless, you deny all of those rumors and kept your real identity hidden.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, you and your squadmates are sent by Nanotrasen to the TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], after a long period of [pick("cryostasis", "rest and relaxation")].</b>")
	to_chat(H, "<B>You must sweep and terminate any Sons of Mars personnel who are involved in the TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name]...</b>")
	to_chat(H, "<B>Follow any orders directly from TerraGov High Command.</b>")


/datum/emergency_call/som/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are an Elite unit of Special Forces Operational Contingent-Terra, lead the mission.</span></p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are an Intimidator unit of Special Forces Operational Contingent-Terra.</span></p>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/veteran)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a Dominator unit of Special Forces Operational Contingent-Terra.</span></p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/som/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<span class='notice'>You are an Operator unit of Special Forces Operational Contingent-Terra.</span>")

// HvH version:

/datum/emergency_call/som/hvh
	name = "SFOC-T Fireteam (Human vs. Human)"
	probability = 0

/datum/emergency_call/som/hvh/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/leader/hvh)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are an Elite unit of Special Forces Operational Contingent-Terra, lead the mission.</span></p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/medic/hvh)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are an Intimidator unit of Special Forces Operational Contingent-Terra.</span></p>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/veteran/hvh)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a Dominator unit of Special Forces Operational Contingent-Terra.</span></p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/som/standard/hvh)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<span class='notice'>You are an Operator unit of Special Forces Operational Contingent-Terra.</span>")
