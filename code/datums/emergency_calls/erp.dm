/datum/emergency_call/erp
	name = "Emergency Response Pranksters"
	base_probability = 0

/datum/emergency_call/erp/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You are a prankster, of the Emergency Response Pranksters, a dedicated responder to whatever situation needs entertainment</b>")
	to_chat(H, "<B>Recently a beacon has been sent from [SSmapping.configs[SHIP_MAP].map_name], a plea for PRANKING and ENTERTAINMENT!</b>")
	to_chat(H, "<B>Entertain the good people of the TGMC there and make sure all non-TGMC anti-fun-sources are PRANKED & eliminated post-haste!</b>")

/datum/emergency_call/erp/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, pick("Bologna", "Giggles", "Bozo", "Gooby", "Smokey", "Gorgo", "Willy", "Bouba", "Kiki", "Goode", "Badde", "Ugglee",))

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/erp/masterprankster)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are an ERP Master Prankster sent to entertain & prank at the TGMC distress signal location sent nearby. Coordinate your fellow entertainers & pranksters in bringing joy to this situation!")]</p>")
		return

	if(prob(30))
		var/datum/job/J = SSjob.GetJobType(/datum/job/erp/piethrower)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are an ERP Pie Thrower sent to entertain & prank at the TGMC distress signal location sent nearby. Fire your amazing explosive pies at the sources of anti-fun!")]</p>")
		return

	if(prob(30))
		var/datum/job/J = SSjob.GetJobType(/datum/job/erp/boobookisser)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are an ERP Boo-boo Kisser sent to entertain & prank at the TGMC distress signal location sent nearby. Use your anti-boo-boo equipment to keep your fellow pranksters alive & FUN!")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/erp)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are an ERP Prankster sent to entertain & prank at the TGMC distress signal location sent nearby. Entertain your friends & prank sources of anti-fun!")]</p>")
