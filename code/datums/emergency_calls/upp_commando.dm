/datum/emergency_call/upp_commando
	name = "UPP Commandos"
	shuttle_id = "Distress_UPP"
	name_of_spawn = "Distress_UPP"


/datum/emergency_call/upp_commando/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up in relativly simple family in [pick(75;"Mars", 25;"a famished UPP colony")] with few belongings or luxuries.</B>")
	to_chat(H, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 20;"four", 30;"five", 20;"six")] children.</B>")
	to_chat(H, "<B>You come from a long line of [pick(40;"crop-harvesters", 20;"soldiers", 20;"factory workers", 5;"scientists", 15;"engineers")], and quickly enlisted to improve your living conditions.</B>")
	to_chat(H, "<B>Eliminate the TGMC force. Do not harm the civilians unless they attack you first.</B>")
	to_chat(H, "<span class='notice'>Use say :3 <text> to speak in your native tongue.</span>")


/datum/emergency_call/upp_commando/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	if(H.gender == MALE)
		H.name = pick(GLOB.first_names_male_russian) + " " + pick(GLOB.last_names_russian)
		H.real_name = H.name
		H.voice_name = H.name
	else
		H.name = pick(GLOB.first_names_female_russian) + " " + pick(GLOB.last_names_russian)
		H.real_name = H.name
		H.voice_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/commando/leader)
		J.equip(H)
		to_chat(H, "<span class='notice'>You are the leader of the elite UPP commando.</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/commando/medic)
		J.equip(H)
		to_chat(H, "<span class='notice'>You are the elite UPP commando medic.</span>")
		medics++
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/upp/commando/leader)
	J.equip(H)
	to_chat(H, "<span class='notice'>You are a member of the elite UPP commando.</span>")
