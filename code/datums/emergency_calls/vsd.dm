// VSD
/datum/emergency_call/vsd
	name = "Vyacheslav Security Detail PMCs"
	base_probability = 26
	alignement_factor = 0

/datum/emergency_call/vsd/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a member of the Syndicate's personal guns. The Vyacheslav Security Detail. You are here to take down this corporate scum by any means necessary. Kill anything in your path.</b>")
	to_chat(H, "<B>You are equipped with Ballistic Armor to counter some of TerraGov's weaponry. Jaeger's armor has a weakness, aim for the head and just below that chest plate. Jaeger has a weakness to 5.56.</b>")
	to_chat(H, "<B>A TerraGov vessel has entered Syndicate and I.C.C. airspace. You're here to take down the ship. Goodluck.</b>")
	to_chat(H, "")

/datum/emergency_call/vsd/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/vsd/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the leader of the Vyacheslav 'Death Squad' group. Lead your men to victory, leave no trace. Hoorah!</notice></p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/vsd/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the lifeline of the group. You are equiped to treat yourself and others, take much care with your comrades. Hoorah!</notice></p>")
		medics++
		return

	if(prob(15))
		var/datum/job/J = SSjob.GetJobType(/datum/job/vsd/spec)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are trained specially in several different skills. You are the gunner, frontliner, EXPLOSION! of your group. Welcome Specialist, protect your group at all costs. Hoorah!")]</p>")
		return


	var/datum/job/J = SSjob.GetJobType(/datum/job/vsd/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a trained Vyacheslav operative. You are no disposable. You are trained in every way possible to counter TGMC's weaponries. We will not accept any casualties here. Good luck grunt, Hoorah!</notice></p>")
