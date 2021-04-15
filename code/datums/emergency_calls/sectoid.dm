//Sectoids
/datum/emergency_call/sectoid
	name = "Sectoid Expedition"
	base_probability = 26
	spawn_type = /mob/living/carbon/human/species/sectoid
	shuttle_id = "distress_ufo"
	alignement_factor = 0

/datum/emergency_call/sectoid/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a sectoid, a mass-cloned alien soldier and psionics expert.")
	to_chat(H, "<B>You were sent to eliminate the local humans and to scout this sector of space for an abundance of resources. A distress signal from a primitive spacecraft has been picked up by our scanners.</B>")
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
	H.update_hair()

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/sectoid/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are the leader of this scouting expedition. You are able to use your stronger psionic powers to protect yourself from harm.</span></p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/sectoid/grunt)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'><span class='notice'>You are a grunt, with limited psionic potential.</span></p>")
