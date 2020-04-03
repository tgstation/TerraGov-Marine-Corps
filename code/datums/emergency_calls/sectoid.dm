//Sectoids
/datum/emergency_call/sectoid
	name = "Sectoids"
	probability = 5
	spawn_type = /mob/living/carbon/human/species/sectoid
	shuttle_id = "distress_ufo"

/datum/emergency_call/sectoid/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a sectoid, a mass-cloned alien soldier and psionics expert.")
	to_chat(H, "<B>You were sent to scout this sector of space for resources, and to eliminate any locals. Just now, you recived a distress signal from a primitive spacecraft.</B>")
	to_chat(H, "<B>Your mission is simple: Destroy all humans, and any other race that poses a threat.</b>")


/datum/emergency_call/sectoid/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .
	H.name = GLOB.namepool[/datum/namepool/sectoid].random_name(H)
	H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	var/datum/job/J = SSjob.GetJobType(/datum/job/sectoid/grunt)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<span class='notice'>You are a grunt, with limited psionic potential.</span>")
	H.update_hair()
