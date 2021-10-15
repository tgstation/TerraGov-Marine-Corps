/datum/emergency_call/upp_commando
	name = "USL Pirate Band Elites"
	base_probability = 0
	shuttle_id = SHUTTLE_DISTRESS_UPP
	spawn_type = /mob/living/carbon/human/species/moth


/datum/emergency_call/upp_commando/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up on [pick(50;"an asteriod", 25;"a famished colony", 25;"a classified station")] with [pick(75;"few", 25;"some")] belongings or luxuries.</B>")
	to_chat(H, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 30;"four", 20;"five", 20;"six")] children.</B>")
	to_chat(H, "<B>You come from a long line of [pick(25;"professionals", 25;"renegades", 50;"rogue soldiers")] and quickly joined the local band to improve your living conditions.</B>")
	to_chat(H, "")
	to_chat(H, "<B>Today, you and your teammates are sent by the United Space Lepidoptera to [SSmapping.configs[SHIP_MAP].map_name] after a long period of lying still in a local asteroid belt. Commence the infiltration mission!</b>")
	to_chat(H, "<B>Eliminate the TGMC force if necessary. Do not harm the civilians unless they attack you first.</B>")
	to_chat(H, span_notice("You speak in a language that humans cannot understand, only you and your fellow pirates can.<br>Type in <b>\",0 <text>\" in the say verb</b> to speak in Galactic Common.<br>Type in <b>\";,0 <text>\" in the say verb</b> to commincate the radio in Galactic Common."))


/datum/emergency_call/upp_commando/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	H.name = GLOB.namepool[/datum/namepool/moth].random_name(H)
	H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/commando/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the leader of the Elite USL pirate band.")]</p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/commando/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the medic of the Elite USL pirate band.")]</p>")
		medics++
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/upp/commando/leader)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a member of the Elite USL pirate band.")]</p>")
