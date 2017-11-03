
//UPP COMMANDOS



/datum/emergency_call/upp_commando
	name = "UPP Commandos"
	mob_max = 6
	probability = 0
	objectives = "Stealthily assault the ship. Use your silenced weapons, tranquilizers, and night vision to get the advantage on the enemy. Take out the power systems, comms and engine. Stick together and keep a low profile."


/datum/emergency_call/upp_commando/print_backstory(mob/living/carbon/human/M)
	M << ""
	M << "<B>You grew up in relativly simple family in [pick(75;"Eurasia", 25;"a famished UPP colony")] with few belongings or luxuries. </B>"
	M << "<B>The family you grew up with were [pick(50;"getting by", 25;"impoverished", 25;"starving")] and you were one of [pick(10;"two", 20;"three", 20;"four", 30;"five", 20;"six")] children.</B>"
	M << "<B>You come from a long line of [pick(40;"crop-harvesters", 20;"soldiers", 20;"factory workers", 5;"scientists", 15;"engineers")], and quickly enlisted to improve your living conditions.</B>"
	M << ""
	M << ""
	M << "<B>Following your enlistment UPP military at the age of 17 you were assigned to the 17th 'Smoldering Sons' battalion (six hundred strong) under the command of Colonel Ganbaatar. </B>"
	M << "<B>You were shipped off with the battalion to one of the UPP's most remote territories, a gas giant designated MV-35 in the Anglo-Japanese Arm, in the Tychon's Rift sector.  </B>"
	M << ""
	M << ""
	M << "<B>For the past 14 months, you and the rest of the Smoldering Sons have been stationed at MV-35's only facility, the helium refinery, Altai Station. </B>"
	M << "<B>As MV-35 and Altai Station are the only UPP-held zones in the Tychon's Rift sector for many lightyears, you have spent most of your military career holed up in crammed quarters in near darkness, waiting for supply shipments and transport escort deployments.</B>"
	//M << "<B>you have spent most of your military career holed up in crammed quarters in near darkness, waiting for supply shipments and transport escort deployments.</B>"
	M << ""
	M << ""
	M << "<B>With the recent arrival of the enemy USCM battalion the 'Falling Falcons' and their flagship, the [MAIN_SHIP_NAME], the UPP has felt threatened in the sector. </B>"
	M << "<B>In an effort to protect the vunerable MV-35 from the emproaching UA/USCM imperialists, the leadership of your battalion has opted this the best opportunity to strike at the Falling Falcons to catch them off guard. </B>"
	M << ""
	M << ""
	M << "<font size='3'>\red Glory to Colonel Ganbaatar.</font>"
	M << "<font size='3'>\red Glory to the Smoldering Sons.</font>"
	M << "<font size='3'>\red Glory to the UPP.</font>"
	M << ""
	M << ""
	M << "\blue Use say :3 <text> to speak in your native tongue."
	M << "\blue This allows you to speak privately with your fellow UPP allies."
	M << "\blue Utilize it with your radio to prevent enemy radio interceptions."



/datum/emergency_call/upp_commando/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(90;MALE,10;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Badai","Mongkeemur","Alexei","Andrei","Artyom","Viktor","Xangai","Ivan","Choban","Oleg", "Dayan", "Taghi", "Batu", "Arik", "Orda", "Ghazan", "Bala", "Gao", "Zhan", "Ren", "Hou", "Serafim", "Luca")
	var/list/first_names_fr = list("Altani","Cirina","Anastasiya","Saran","Wei","Oksana","Ren","Svena","Tatyana","Yaroslava", "Miruna", "Flori", "Lucia", "Anica")
	var/list/last_names_r = list("Azarov","Bogdanov","Barsukov","Golovin","Davydov","Khan","Noica","Barbu","Zhukov","Ivanov","Mihai","Kasputin","Belov","Melnikov", "Vasilevsky", "Proca", "Zaituc", "Arcos", "Kubat", "Kral", "Volf")

	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
		mob.f_style = "7 O'clock Shadow"
	else
		mob.real_name = "[pick(first_names_fr)] [pick(last_names_r)]"

	mob.name = mob.real_name
	mob.age = rand(25,35)
	mob.h_style = "Shaved Head"
	mob.r_hair = 15
	mob.g_hair = 15
	mob.b_hair = 25
	mob.r_eyes = 139
	mob.g_eyes = 62
	mob.b_eyes = 19
	mob.dna.ready_dna(mob)
	mob.s_tone = rand(0,40)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "UPP"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			mob.arm_equipment(mob, "UPP Commando (Leader)")
			mob << "<font size='3'>\red You are a commando officer of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
		else if(medics < max_medics)
			mob << "<font size='3'>\red You are a commando medic of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			mob.arm_equipment(mob, "UPP Commando (Medic)")
			medics++
		else
			mob << "<font size='3'>\red You are a commando of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			mob.arm_equipment(mob, "UPP Commando (Standard)")
		print_backstory(mob)

	spawn(10)
		mob << "<B>Objectives:</b> [objectives]"

	mob.remove_language("Sol Common")
	mob.add_language("Russian")

	if(original)
		cdel(original)


