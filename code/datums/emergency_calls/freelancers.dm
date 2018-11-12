//Randomly-equipped mercenaries. May be friendly or hostile to the USCM, hostile to xenos.
/datum/emergency_call/mercs
	name = "Freelancers"
	probability = 25

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is Freelancer shuttle MC-98 responding to your distress call. Prepare for boarding."
		objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."



/datum/emergency_call/mercs/print_backstory(mob/living/carbon/human/mob)
	to_chat(mob, "<B> You started off in Tychon's Rift system as a colonist seeking work at one of the established colonies.</b>")
	to_chat(mob, "<B> The withdrawl of United American forces in the early 2180s, the system fell into disarray.</b>")
	to_chat(mob, "<B> Taking up arms as a mercenary, the Freelancers have become a powerful force of order in the system.</b>")
	to_chat(mob, "<B> While they are motivated primarily by money, many colonists see the Freelancers as the main forces of order in Tychon's Rift.</b>")
	if(hostility)
		to_chat(mob, "<B> Despite this, you have been tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>")
		to_chat(mob, "<B> Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.</b>")
	else
		to_chat(mob, "<B> To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..</b>")
		to_chat(mob, "<B> Ensure they are not destroyed.</b>")



/datum/emergency_call/mercs/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) 
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new /mob/living/carbon/human(spawn_loc)
	
	if(mob.gender == MALE)
		mob.name = pick(first_names_male_clf) + " " + pick(last_names_clf)
		mob.real_name = mob.name
		mob.voice_name = mob.name
	else
		mob.name = pick(first_names_female_clf) + " " + pick(last_names_clf)
		mob.real_name = mob.name
		mob.voice_name = mob.name

	mob.key = M.key
	mob.client?.change_view(world.view)

	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			var/datum/job/J = new /datum/job/freelancer/leader
			mob.set_everything(mob, "Freelancer Leader")
			J.generate_equipment(mob)
			to_chat(mob, "<font size='3'>\red You are the Freelancer leader!</font>")

		else if(medics < max_medics)
			var/datum/job/J = new /datum/job/freelancer/medic
			mob.set_everything(mob, "Freelancer Medic")
			J.generate_equipment(mob)
			medics++
			to_chat(mob, "<font size='3'>\red You are a Freelancer medic!</font>")
		else
			var/datum/job/J = new /datum/job/freelancer/standard
			mob.set_everything(mob, "Freelancer Standard")
			J.generate_equipment(mob)
			to_chat(mob, "<font size='3'>\red You are a Freelancer mercenary!</font>")
		print_backstory(mob)

	spawn(10)
		to_chat(M, "<B>Objectives:</b> [objectives]")

	if(original)
		cdel(original)