//Santa is back in town
/datum/emergency_call/santa
	name = "Santa's Naughty Squad"
	base_probability = 20
	alignement_factor = -1


/datum/emergency_call/santa/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You [pick("fed the reindeer and worked hard for 11 months a year", "worked hard to deliver presents to good boys and girls of all species", "survived the ice, snow, and low gravity working tirelessly for Santa", "were a master craftsman who snuck onto Santa's galactic sleigh ride")].</b>")
	to_chat(H, "<B>As part of Santa's entourage, you travel with him to deliver presents to all who deserve to be rewarded.</b>")
	to_chat(H, "<B>Santa travels the galaxy once a year, visiting every single inhabited planet in a single period of 24 standard hours. Santa maintains an active defense force to punish especially naughty sapients with lethal force, this defense force currently numbers more than 30,000 elves and ships.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, while enroute to visit a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], the artificial intelligence in Santa's sleigh detected an abnormally high level of naughtiness in the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Santa has resolved to punish them in the spirit of Christmas!</b>")
	to_chat(H, "<B>Punish the naughty aliens onboard the ship, coal won't be enough this time. The only punishment Santa believes in now is hot lead!</B>")


/datum/emergency_call/santa/create_member(datum/mind/M)
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
		var/datum/job/J = SSjob.GetJobType(/datum/outfit/job/santa/ert/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are Santa Claus! Punish all naughty aliens with overwhelming firepower, starting with their naughty queen hiding on the ship.")]</p>")
		return

	if(medics < max_medics)
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/medic)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a Sons of Mars medic assigned to this fireteam to respond to the TGMC distress signal sent out nearby. Keep your squad alive in this fight!")]</p>")
		medics++
		return

	if(prob(65))
		var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/veteran)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are a veteran of the Sons of Mars and are assigned to this fireteam to respond to the TGMC distress signal sent out nearby. Do them proud and kill all who stand in your teams way!")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/som/ert/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, span_notice("You are a member of the Sons of Mars assigned to compose this fireteam to the TGMC distress signal sent out nearby. Protect yourself and your other teammembers, kill all who stand in your team's way!"))
