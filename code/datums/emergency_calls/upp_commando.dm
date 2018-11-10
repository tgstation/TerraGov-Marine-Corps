
//UPP COMMANDOS



/datum/emergency_call/upp_commando
	name = "UPP Commandos"
	probability = 0
	objectives = "Stealthily assault the ship. Use your silenced weapons, tranquilizers, and night vision to get the advantage on the enemy. Take out the power systems, comms and engine. Stick together and keep a low profile."
	shuttle_id = "Distress_UPP"
	name_of_spawn = "Distress_UPP"

/datum/emergency_call/upp_commando/print_backstory(mob/living/carbon/human/M)
	to_chat(M, "")
	to_chat(M, "<B>You grew up in relativly simple family in [pick(75;"Eurasia", 25;"a famished UPP colony")] with few belongings or luxuries. </B>")
	to_chat(M, "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 20;"four", 30;"five", 20;"six")] children.</B>")
	to_chat(M, "<B>You come from a long line of [pick(40;"crop-harvesters", 20;"soldiers", 20;"factory workers", 5;"scientists", 15;"engineers")], and quickly enlisted to improve your living conditions.</B>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "<B>Following your enlistment UPP military at the age of 17 you were assigned to the 17th 'Smoldering Sons' battalion (six hundred strong) under the command of Colonel Ganbaatar. </B>")
	to_chat(M, "<B>You were shipped off with the battalion to one of the UPP's most remote territories, a gas giant designated MV-35 in the Anglo-Japanese Arm, in the Tychon's Rift sector.  </B>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "<B>For the past 14 months, you and the rest of the Smoldering Sons have been stationed at MV-35's only facility, the helium refinery, Altai Station. </B>")
	to_chat(M, "<B>As MV-35 and Altai Station are the only UPP-held zones in the Tychon's Rift sector for many lightyears, you have spent most of your military career holed up in crammed quarters in near darkness, waiting for supply shipments and transport escort deployments.</B>")
	//to_chat(M, "<B>you have spent most of your military career holed up in crammed quarters in near darkness, waiting for supply shipments and transport escort deployments.</B>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "<B>With the recent arrival of the enemy USCM battalion the 'Falling Falcons' and their flagship, the [MAIN_SHIP_NAME], the UPP has felt threatened in the sector. </B>")
	to_chat(M, "<B>In an effort to protect the vunerable MV-35 from the emproaching UA/USCM imperialists, the leadership of your battalion has opted this the best opportunity to strike at the Falling Falcons to catch them off guard. </B>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "<font size='3'>\red Glory to Colonel Ganbaatar.</font>")
	to_chat(M, "<font size='3'>\red Glory to the Smoldering Sons.</font>")
	to_chat(M, "<font size='3'>\red Glory to the UPP.</font>")
	to_chat(M, "")
	to_chat(M, "")
	to_chat(M, "\blue Use say :3 <text> to speak in your native tongue.")
	to_chat(M, "\blue This allows you to speak privately with your fellow UPP allies.")
	to_chat(M, "\blue Utilize it with your radio to prevent enemy radio interceptions.")



/datum/emergency_call/upp_commando/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) 
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new /mob/living/carbon/human(spawn_loc)
	
	if(mob.gender == MALE)
		mob.name = pick(first_names_male_russian) + " " + pick(last_names_russian)
		mob.real_name = mob.name
		mob.voice_name = mob.name
	else
		mob.name = pick(first_names_female_russian) + " " + pick(last_names_russian)
		mob.real_name = mob.name
		mob.voice_name = mob.name

	mob.key = M.key
	mob.client?.change_view(world.view)

	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			var/datum/job/J = new /datum/job/upp/commando/leader
			mob.set_everything(mob, "UPP Commando Leader")
			J.generate_equipment(mob)
			J.generate_entry_conditions(mob)
			to_chat(mob, "<font size='3'>\red You are a commando officer of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>")
		else if(medics < max_medics)
			var/datum/job/J = new /datum/job/upp/commando/medic
			mob.set_everything(mob, "UPP Commando Medic")
			J.generate_equipment(mob)
			J.generate_entry_conditions(mob)
			to_chat(mob, "<font size='3'>\red You are a commando medic of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>")
			medics++
		else
			var/datum/job/J = new /datum/job/upp/commando/leader
			mob.set_everything(mob, "UPP Commando Standard")
			J.generate_equipment(mob)
			J.generate_entry_conditions(mob)
			to_chat(mob, "<font size='3'>\red You are a commando of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>")
		print_backstory(mob)

	spawn(10)
		to_chat(mob, "<B>Objectives:</b> [objectives]")

	if(original)
		cdel(original)