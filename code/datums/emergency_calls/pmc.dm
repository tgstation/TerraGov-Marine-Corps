/datum/emergency_call/pmc
	name = "PMC"
	probability = 25
	shuttle_id = "Distress_PMC"
	name_of_spawn = "Distress_PMC"


/datum/emergency_call/pmc/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>Joining the ranks of Nanotrasen has proven to be very profitable for you.</b>")
	to_chat(H, "<B>While you are officially an employee, much of your work is off the books. You work as a skilled mercenary.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Make sure the Corporate Liaison is safe.</b>")
	to_chat(H, "<B>If there is no Liaison, eliminate the threat and cooperate with the Captain before returning back home.</b>")


/datum/emergency_call/pmc/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawn_loc)

	if(H.gender == MALE)
		H.name = pick(first_names_male_pmc) + " " + pick(last_names_pmc)
		H.real_name = H.name
		H.voice_name = H.name
	else
		H.name = pick(first_names_female_pmc) + " " + pick(last_names_pmc)
		H.real_name = H.name
		H.voice_name = H.name

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	print_backstory(H)

	if(!leader)
		leader = H
		var/datum/job/J = new /datum/job/pmc/leader
		J.equip(H)
		to_chat(H, "<span class='notice'>You are the leader of this Nanotrasen mercenary squad!</span>")
		return

	if(prob(50))
		var/datum/job/J = new /datum/job/pmc/gunner
		J.equip(H)
		to_chat(H, "<span class='notice'>You are a Nanostrasen heavy gunner!</span>")
		return

	if(prob(30))
		var/datum/job/J = new /datum/job/pmc/sniper
		J.equip(H)
		to_chat(H, "<span class='notice'>You are a Nanotrasen sniper!</span>")
		return

	var/datum/job/J = new /datum/job/pmc/standard
	J.equip(H)
	to_chat(H, "<span class='notice'>You are a Nanotrasen mercenary!</span>")
