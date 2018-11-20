//Nanotrasen commandos. Friendly to USCM, hostile to xenos.
/datum/emergency_call/pmc
	name = "PMC"
	probability = 25
	shuttle_id = "Distress_PMC"
	name_of_spawn = "Distress_PMC"

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is USCSS Royce responding to your distress call. We are boarding. Any hostile actions will be met with lethal force."
		objectives = "Secure the Corporate Liaison and the [MAIN_SHIP_NAME] Commander, and eliminate any hostile threats. Do not damage W-Y property."


/datum/emergency_call/pmc/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) 
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new /mob/living/carbon/human(spawn_loc)
	
	if(mob.gender == MALE)
		mob.name = pick(first_names_male_pmc) + " " + pick(last_names_pmc)
		mob.real_name = mob.name
		mob.voice_name = mob.name
	else
		mob.name = pick(first_names_female_pmc) + " " + pick(last_names_pmc)
		mob.real_name = mob.name
		mob.voice_name = mob.name

	mob.key = M.key
	mob.client?.change_view(world.view)

	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			var/datum/job/J = new /datum/job/pmc/leader
			mob.set_everything(mob, "PMC Leader")
			J.generate_equipment(mob)
		else
			if(prob(55)) //Randomize the heavy commandos and standard PMCs.
				var/datum/job/J = new /datum/job/pmc/standard
				mob.set_everything(mob, "PMC Standard")
				J.generate_equipment(mob)
				to_chat(mob, "<font size='3'>\red You are a Nanotrasen mercenary!</font>")
			else
				if(prob(30))
					var/datum/job/J = new /datum/job/pmc/sniper
					mob.set_everything(mob, "PMC Sniper")
					J.generate_equipment(mob)
					to_chat(mob, "<font size='3'>\red You are a Nanotrasen sniper!</font>")
				else
					var/datum/job/J = new /datum/job/pmc/gunner
					mob.set_everything(mob, "PMC Gunner")
					J.generate_equipment(mob)
					to_chat(mob, "<font size='3'>\red You are a Nanostrasen heavy gunner!</font>")
		print_backstory(mob)

	spawn(10)
		to_chat(M, "<B>Objectives:</b> [objectives]")

	if(original)
		cdel(original)


/datum/emergency_call/pmc/print_backstory(mob/living/carbon/human/M)
	to_chat(M, "<B>You were born [pick(75;"in Europe", 15;"in Asia", 10;"on Mars")] to a [pick(75;"well-off", 15;"well-established", 10;"average")] family.</b>")
	to_chat(M, "<B>Joining the ranks of Nanotrasen has proven to be very profitable for you.</b>")
	to_chat(M, "<B>While you are officially an employee, much of your work is off the books. You work as a skilled mercenary.</b>")
	to_chat(M, "<B>You are well-informed of the xenomorph threat.</b>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "<B>You are part of  Nanotrasen Task Force Oberon that arrived in 2182 following the UA withdrawl of the Tychon's Rift sector.</b>")
	to_chat(M, "<B>Task-force Oberon is stationed aboard the USCSS Royce, a powerful Nanotrasen cruiser that patrols the outer edges of Tychon's Rift. </b>")
	to_chat(M, "<B>Under the directive of Nanotrasen board member Johan Almric, you act as private security for Nanotrasen science teams.</b>")
	to_chat(M, "<B>The USCSS Royce contains a crew of roughly two hundred PMCs, and one hundred scientists and support personnel.</b>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "<B>Ensure no damage is incurred against Nanotrasen. Make sure the CL is safe.</b>")
	to_chat(M, "<B>Deny Nanotrasen's involvement and do not trust the UA/USCM forces.</b>")