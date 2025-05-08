/datum/emergency_call/retired
	name = "Retired TGMC Veteran Squad"
	base_probability = 5
	alignement_factor = -1

/datum/emergency_call/retired/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are an old, retired member of the TerraGov marine corps.</b>")
	to_chat(H, "<B>Althought you may be past your prime, high command has deemed you capable enough to be sent to the [SSmapping.configs[SHIP_MAP].map_name], which has recently sent out a distress signal.</b>")
	to_chat(H, "<B>Investigate why the distress signal was sent and show the younger generation how it's done!</b>")

/datum/emergency_call/retired/create_member(datum/mind/mind_to_assign)
	. = ..()
	if(!.)
		return
	var/mob/original = mind_to_assign.current
	var/mob/living/carbon/human/H = .

	if(H.physique == MALE)
		H.h_style = pick("Bald", "Balding Hair", "Balding Fade", "Balding ponytail", "Balding medium")
	else
		H.h_style = pick("Overeye Very Short", "Updo", "Ponytail 1")

	H.r_hair = 235
	H.g_hair = 235
	H.b_hair = 235
	H.r_facial = 235
	H.g_facial = 235
	H.b_facial = 235
	H.update_hair()

	mind_to_assign.transfer_to(H, TRUE)
	H.fully_replace_character_name(mind_to_assign.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/retired/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the TGMC retired veteran expedition leader! Lead your fellow veterans to one last hurrah!</notice></p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/retired)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are an augmented TGMC veteran, you may have had a few limbs replaced with synthetic versions, but at least you can walk! Follow the expedition leader and relive your glory days!</notice></p>")
