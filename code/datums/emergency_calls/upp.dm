/datum/emergency_call/upp
	name = "UPP"
	probability = 10
	shuttle_id = "distress_upp"


/datum/emergency_call/upp/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You grew up in relativly simple family in [pick(75;"a space station", 25;"a famished UPP colony")] with few belongings or luxuries.</B>")
	to_chat(H, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 20;"four", 30;"five", 20;"six")] children.</B>")
	to_chat(H, "<B>You come from a long line of [pick(40;"crop-harvesters", 20;"soldiers", 20;"factory workers", 5;"scientists", 15;"engineers")], and quickly enlisted to improve your living conditions.</B>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. The UPP assault team is authorized and your operation is a go!</b>")
	to_chat(H, "<B>Eliminate the TGMC force. Do not harm the civilians unless they attack you first.</B>")
	to_chat(H, "<span class='notice'>Use say :3 <text> to speak in your native tongue.</span>")


/datum/emergency_call/upp/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	H.name = GLOB.namepool[/datum/namepool/russian].random_name(H)
	H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/leader)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are the leader of the UPP squad in responding to the TGMC distress signal sent nearby. Let your squadmates march to battle, for glory!</span>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/medic)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a medic of the UPP army to respond to the TGMC distress signal sent nearby. Kit up and get ready to tend wounds!</span>")
		medics++
		return

	if(prob(20))
		var/datum/job/J = SSjob.GetJobType(/datum/job/upp/heavy)
		SSjob.AssignRole(H, J.title)
		J.assign_equip(H)
		to_chat(H, "<span class='notice'>You are a specialist of the UPP army to respond to the TGMC distress signal sent nearby. Crush the vermin!</span>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/upp/standard)
	SSjob.AssignRole(H, J.title)
	J.assign_equip(H)
	to_chat(H, "<span class='notice'>You are a member of the UPP army to respond to the TGMC distress signal sent nearby. Do not forget your training, stand tall with your other comrades!</span>")
