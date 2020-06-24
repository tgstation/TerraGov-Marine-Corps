/datum/emergency_call/upp
	name = "USL"
	probability = 0
	shuttle_id = "distress_upp"
	spawn_type = /mob/living/carbon/human/species/moth


/datum/emergency_call/upp/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up on an asteroid with few belongings or luxuries.</B>")
	to_chat(H, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 30;"four", 20;"five", 20;"six")] children.</B>")
	to_chat(H, "<B>You come from a long line of pirates and quickly joined the local band to improve your living conditions.</B>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Your USL Assault Pirate warband heads out and your stealing begins!</b>")
	to_chat(H, "<B>Eliminate the TGMC force if necessary. Do not harm the civilians unless they attack you first.</B>")
	to_chat(H, "<span class='notice'>Use say :3 <text> to speak in your native tongue.</span>")


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
		to_chat(H, "<span class='notice'>You are the leader of the USL squad in responding to the TGMC distress signal sent nearby. Let your squadmates march to battle, for the USL!</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<span class='notice'>You are a medic of the USL Pirate bands to respond to the TGMC distress signal sent nearby. Kit up and get ready to tend wounds!</span>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/heavy)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<span class='notice'>You are a specialist of the USL Pirate bands to respond to the TGMC distress signal sent nearby. Crush the vermin!</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/upp/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<span class='notice'>You are a member of the USL Pirate bands to respond to the TGMC distress signal sent nearby. Do not forget your training, stand tall with your other pirates!</span>")
