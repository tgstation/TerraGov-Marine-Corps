

//UPP Strike Team
/datum/emergency_call/upp
	name = "UPP Naval Infantry (Squad)"
	mob_max = 7
	probability = 10
	shuttle_id = "Distress_UPP"
	name_of_spawn = "Distress_UPP"

	New()
		..()
		arrival_message = "T*is i* UP* d^sp^*ch`. STr*&e teaM, #*u are cLe*% for a*pr*%^h. Pr*mE a*l wE*p^ns )0r c|*$e @u*r*r$ c0m&*t."
		objectives = "Eliminate the UA Forces to ensure the UPP prescence in this sector is continued. Listen to your superior officers and take over the [MAIN_SHIP_NAME] at all costs."


/datum/emergency_call/upp/print_backstory(mob/living/carbon/human/M)
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



///////////////////UPP///////////////////////////

/datum/emergency_call/upp/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(60;MALE,40;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mr = list("Badai","Mongkeemur","Alexei","Andrei","Artyom","Viktor","Xangai","Ivan","Choban","Oleg", "Dayan", "Taghi", "Batu", "Arik", "Orda", "Ghazan", "Bala", "Gao", "Zhan", "Ren", "Hou", "Xue", "Serafim", "Luca", "Su", "György", "István", "Mihály")
	var/list/first_names_fr = list("Altani","Cirina","Anastasiya","Saran","Wei","Oksana","Ren","Svena","Tatyana","Yaroslava", "Izabella", "Kata", "Krisztina", "Miruna", "Flori", "Lucia", "Anica", "Li", "Yimu")
	var/list/last_names_r = list("Azarov","Bogdanov","Barsukov","Golovin","Davydov","Khan","Noica","Barbu","Zhukov","Ivanov","Mihai","Kasputin","Belov","Melnikov", "Vasilevsky", "Aleksander", "Halkovich", "Stanislaw", "Proca", "Zaituc", "Arcos", "Kubat", "Kral", "Volf", "Xun", "Jia")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mr)] [pick(last_names_r)]"
		mob.f_style = "5 O'clock Shadow"
	else
		mob.real_name = "[pick(first_names_fr)] [pick(last_names_r)]"

	mob.name = mob.real_name
	mob.age = rand(17,35)
	mob.h_style = "Shaved Head"
	mob.r_hair = 15
	mob.g_hair = 15
	mob.b_hair = 25
	mob.r_eyes = 139
	mob.g_eyes = 62
	mob.b_eyes = 19
	mob.dna.ready_dna(mob)
	mob.key = M.key
	if(mob.client) mob.client.change_view(world.view)
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "UPP"
	ticker.mode.traitors += mob.mind
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			mob.mind.set_cm_skills(/datum/skills/SL/upp)
			mob.arm_equipment(mob, "UPP Soldier (Leader)")
			mob << "<font size='3'>\red You are an officer of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
		else if(medics < max_medics)
			mob.mind.set_cm_skills(/datum/skills/combat_medic/crafty)
			mob << "<font size='3'>\red You are a medic of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			mob.arm_equipment(mob, "UPP Soldier (Medic)")
			medics++
		else if(heavies < max_heavies)
			mob.mind.set_cm_skills(/datum/skills/specialist/upp)
			mob << "<font size='3'>\red You are a soldier of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			mob.arm_equipment(mob, "UPP Soldier (Heavy)")
			heavies++
		else
			mob.mind.set_cm_skills(/datum/skills/pfc/crafty)
			mob << "<font size='3'>\red You are a soldier of the Union of Progressive People, a powerful socialist state that rivals the United Americas. </B>"
			mob.arm_equipment(mob, "UPP Soldier (Standard)")

		print_backstory(mob)


	spawn(10)
		mob << "<B>Objectives:</b> [objectives]"

	mob.remove_language("Sol Common")
	mob.add_language("Russian")

	if(original)
		cdel(original)





/datum/emergency_call/upp/platoon
	name = "UPP Naval Infantry (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
	max_medics = 2
	max_heavies = 2


