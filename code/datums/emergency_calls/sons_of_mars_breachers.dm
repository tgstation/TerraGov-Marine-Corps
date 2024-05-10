//Sons of Mars
/datum/emergency_call/som_breachers
	name = "Sons of Mars Squad"
	base_probability = 13
	alignement_factor = 0
	///number of available special weapon dudes
	var/max_specialists = 1

/datum/emergency_call/som_breachers/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You [pick("grew up in the mines working in horrible conditions until signing up to", "were part of a poor family until you decided to leave to join", "were born on a colony on Mars to a family of several brothers and sisters before leaving to", "worked at horrible conditions in the mines until deciding to leave to join", "have a proud family tradition of military service so enrolled as early as possible to serve")] the Sons of Mars (SoM).</b>")
	to_chat(H, "<B>Due to your [pick("marked distinction in combat", "ruthless record fighting against TGMC", "family's connections", "previous failures in combat")] you have been assigned to the 5th Special Assault Force of the SOM.</b>")
	to_chat(H, "<B>Membership in the 5th SAF is considered a great honour, typically sent into some of the most dangerous operations imaginable, with a special focus on ship combat. Casualty rates are often extremely high, although success in the 5th can often fast track a soldier's career.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TerraGov vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. This is our chance to attack without being intercepted!</b>")
	to_chat(H, "<B>Eliminate the TerraGov personnel onboard, capture the ship. If there are fellow ICC contingents such as the ICCAF, then work with them in this goal. Take no prisoners. Take back what was once lost.</B>")

/datum/emergency_call/som_breachers/do_activate(announce = TRUE)
	max_specialists = round(mob_max * 0.2)
	return ..()

/datum/emergency_call/som_breachers/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	var/datum/job/selected_job

	if(!leader)
		leader = H
		selected_job = SSjob.GetJobType(/datum/job/som/ert/leader/breacher)
		H.apply_assigned_role_to_spawn(selected_job)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a member of the Sons of Mars assigned to lead this elite breaching team, sent to response to the TGMC distress signal sent out nearby. Lead your team with conviction and crush the Terra Gov scum!")]</p>")
		return
	if(medics < max_medics)
		selected_job = SSjob.GetJobType(/datum/job/som/ert/medic/breacher)
		H.apply_assigned_role_to_spawn(selected_job)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a Sons of Mars medic assigned to this elite breaching team, sent to response to the TGMC distress signal sent out nearby. Keep your squad alive in this fight!")]</p>")
		medics++
		return
	if(max_specialists > 0)
		selected_job = SSjob.GetJobType(/datum/job/som/ert/breacher/specialist)
		H.apply_assigned_role_to_spawn(selected_job)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a veteran of the Sons of Mars trusted with specialised weaponry. You are assigned to this elite breaching team, sent to response to the TGMC distress signal sent out nearby. Do them proud and kill all who stand in your way!")]</p>")
		max_specialists --
		return

	selected_job = SSjob.GetJobType(/datum/job/som/ert/breacher)
	H.apply_assigned_role_to_spawn(selected_job)
	to_chat(H, span_notice("You are a member of the Sons of Mars assigned to this elite breaching team, sent to response to the TGMC distress signal sent out nearby. Your duty is to destroy all Terra Gov dogs you find. Show no mercy!"))
