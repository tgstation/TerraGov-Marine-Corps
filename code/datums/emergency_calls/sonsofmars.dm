//Sons of Mars
/datum/emergency_call/som
	name = "Sons of Mars Squad"
	base_probability = 26
	alignement_factor = 0
	///number of available special weapon dudes
	var/max_specialists = 1


/datum/emergency_call/som/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You [pick("grew up in the mines working in horrible conditions until signing up to", "were part of a poor family until you decided to leave to join", "were born on a colony on Mars to a family of several brothers and sisters before leaving to", "worked at horrible conditions in the mines until deciding to leave to join")] the Sons of Mars (SoM).</b>")
	to_chat(H, "<B>As a member state of the Independent Colonial Confederation (ICC), the SoM, which formed in 2180, is a heavily industrialized group with a standing army of approx. 200,000 enlisted or trained members.</b>")
	to_chat(H, "<B>Even though the ICC has its own standing army independent of its members, most larger members retain their own standing fleet and army, with their own equipment and doctrines.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, a TerraGov vessel, [SSmapping.configs[SHIP_MAP].map_name], has sent out a distress signal on the orbit of [SSmapping.configs[GROUND_MAP].map_name]. This is our chance to attack without being intercepted!</b>")
	to_chat(H, "<B>Eliminate the TerraGov personnel onboard, capture the ship. If there are fellow ICC contingents such as the ICCAF, then work with them in this goal. Take no prisoners. Take back what was once lost.</B>")

/datum/emergency_call/som/do_activate(announce = TRUE)
	max_specialists = round(mob_max * 0.2)
	return ..()

/datum/emergency_call/som/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a member of the Sons of Mars assigned to lead this fireteam to the TGMC distress signal sent out nearby. Lead your fireteam to top-working conidition!")]</p>")
		return
	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a Sons of Mars medic assigned to this fireteam to respond to the TGMC distress signal sent out nearby. Keep your squad alive in this fight!")]</p>")
		medics++
		return
	if(max_specialists > 0)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/specialist)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a veteran of the Sons of Mars trusted with specialised weaponry. You are assigned to this fireteam to respond to the TGMC distress signal sent out nearby. Do them proud and kill all who stand in your teams way!")]</p>")
		max_specialists --
		return
	if(prob(65))
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/veteran)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a veteran of the Sons of Mars and are assigned to this fireteam to respond to the TGMC distress signal sent out nearby. Do them proud and kill all who stand in your teams way!")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, span_notice("You are a member of the Sons of Mars assigned to compose this fireteam to the TGMC distress signal sent out nearby. Protect yourself and your other teammembers, kill all who stand in your team's way!"))
