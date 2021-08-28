/datum/emergency_call/upp
	name = "USL Pirate Band"
	base_probability = 0
	shuttle_id = "distress_upp"
	spawn_type = /mob/living/carbon/human/species/moth


/datum/emergency_call/upp/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up on [pick(50;"an asteriod", 25;"a famished colony", 25;"a classified station")] with [pick(75;"few", 25;"some")] belongings or luxuries.</B>")
	to_chat(H, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 30;"four", 20;"five", 20;"six")] children.</B>")
	to_chat(H, "<B>You come from a long line of [pick(50;"pirates", 25;"renegades", 25;"rogue soldiers")] and quickly joined the local band to improve your living conditions.</B>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Your USL assault pirate warband heads out and your stealing begins!</b>")
	to_chat(H, "<B>Eliminate the TGMC force if necessary. Do not harm the civilians unless they attack you first.</B>")
	to_chat(H, span_notice("You speak in a language that humans cannot understand, only you and your fellow pirates can.<br>Type in <b>\",0 <text>\" in the say verb</b> to speak in Galactic Common.<br>Type in <b>\";,0 <text>\" in the say verb</b> to commincate the radio in Galactic Common."))


/datum/emergency_call/upp/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the leader of the USL pirate band in responding to the TGMC distress signal sent nearby. Let your squadmates march to battle, for the USL!")]</p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a medic of the USL pirate band to respond to the TGMC distress signal sent nearby. Kit up and get ready to tend wounds!")]</p>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/heavy)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a specialist of the USL pirate band to respond to the TGMC distress signal sent nearby. Crush the vermin!")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/upp/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a member of the USL pirate band to respond to the TGMC distress signal sent nearby. Do not forget your training, stand tall with your other pirates!")]</p>")

/datum/emergency_call/upphvh
	name = "USL Pirate Band (Human vs. Human)"
	base_probability = 0
	shuttle_id = "distress_upp"
	spawn_type = /mob/living/carbon/human/species/moth


/datum/emergency_call/upphvh/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up on [pick(50;"an asteriod", 25;"a famished colony", 25;"a classified station")] with [pick(75;"few", 25;"some")] belongings or luxuries.</B>")
	to_chat(H, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 30;"four", 20;"five", 20;"six")] children.</B>")
	to_chat(H, "<B>You come from a long line of [pick(50;"pirates", 25;"renegades", 25;"rogue soldiers")] and quickly joined the local band to improve your living conditions.</B>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Your USL assault pirate warband heads out and your stealing begins!</b>")
	to_chat(H, "<B>Eliminate the TGMC force if necessary. Do not harm the civilians unless they attack you first.</B>")
	to_chat(H, span_notice("You speak in a language that humans cannot understand, only you and your fellow pirates can.<br>Type in <b>\",0 <text>\" in the say verb</b> to speak in Galactic Common.<br>Type in <b>\";,0 <text>\" in the say verb</b> to commincate the radio in Galactic Common."))


/datum/emergency_call/upphvh/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/leader/hvh)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are the leader of the USL pirate band in responding to the TGMC distress signal sent nearby. Let your squadmates march to battle, for the USL!")]</p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/medic/hvh)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a medic of the USL pirate band to respond to the TGMC distress signal sent nearby. Kit up and get ready to tend wounds!")]</p>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/heavy/hvh)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a specialist of the USL pirate band to respond to the TGMC distress signal sent nearby. Crush the vermin!")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/upp/standard/hvh)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a member of the USL pirate band to respond to the TGMC distress signal sent nearby. Do not forget your training, stand tall with your other pirates!")]</p>")

/datum/emergency_call/upphvh/human
	name = "USL Human Pirate Band (Human vs. Human)"
	spawn_type = /mob/living/carbon/human
