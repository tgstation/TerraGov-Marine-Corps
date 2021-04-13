//Colonial Liberation Front
/datum/emergency_call/clf
	name = "CLF Cell"
	base_probability = 0


/datum/emergency_call/clf/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up [pick("on the TGMC prison station","in the LV-624 jungle","on a desert planet","on an icy colony")] to a[pick(50;" poor", 15;" well-off", 35;"n average")] family.</B>")
	to_chat(H, "<B>You joined the CLF because [pick(20;"you harbor a strong hatred for the oppressive TerraGov",5;"you are good at killing, and in times like these this is the place to be", 10;"your militia was absorbed into the CLF")] and you are considered a terrorist by the TGMC.</B>")
	to_chat(H, "<B>Assault the TGMC, and sabotage as much as you can. Ensure any survivors escape in your custody.</b>")


/datum/emergency_call/clf/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/clf/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<span class='notice'>You are a leader of the local resistance group, the Colonial Liberation Front.</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/clf/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<span class='notice'>You are a medic of the local resistance group, the Colonial Liberation Front.</span>")
		medics++
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/clf/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<span class='notice'>You are a member of the local resistance group, the Colonial Liberation Front.</span>")
