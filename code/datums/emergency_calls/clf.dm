

//Colonial Liberation Front
/datum/emergency_call/clf
	name = "Colonial Liberation Front (Squad)"
	mob_max = 10
	arrival_message = "Incoming Transmission: 'Attention, you are tresspassing on our soverign territory. Expect no forgiveness.'"
	objectives = "Assault the USCM, and sabotage as much as you can. Ensure any survivors escape in your custody."
	probability = 20




/datum/emergency_call/clf/print_backstory(mob/living/carbon/human/mob)
	mob << "<B>You grew up [pick(5;"on the UA prison station", 10;"in the LV-624 jungle", 25;"on the farms of LV-771", 25;"in the slums of LV-221", 20;"the red wastes of LV-361", 15;"the icy tundra of LV-571")] to a [pick(50;"poor", 15;"well-off", 35;"average")] family.</B>"
	mob << "<B>As a native of the Tychon's Rift sector, you joined the CLF because [pick(20;"the Dust Raiders killed someone close to you in 2181", 20;"you harbor a strong hatred of the United Americas", 10;"you are a wanted criminal in the United Americas", 5;"have UPP sympathies and want to see the UA driven out of the secor", 10;"you believe the USCM occupation will hurt your quality of life", 5;"are a violent person and want to kill someone for the sake of killing", 20;"want the Tychon's Rift to be free from outsiders", 10;"your militia was absorbed into the CLF")] and are considered a terrorist by the UA.</B>"

	mob << "<B>The Tychon's Rift sector has largely enjoyed its indepdendence..</B>"
	mob << "<B>Though technically part of the United American frontier, many colonists in the Tychon's Rift have enjoyed their freedoms.</B>"
	mob << ""
	mob << "<B>In 2181, however, the United Americas moved the USCM Battalion, the 'Dust Raiders', and the battalion flagship, the USS Alistoun, to the Tychon's Rift sector. </B>"
	mob << "<B>The Dust Raiders responded with deadly force, scattering many of the colonists who attempted to fight their occupation.</B>"
	mob << "<B>The Dust Raiders and their flagship, the USS Alistoun eventually withdrew from the sector by the end of the year.</font></B>"
	mob << "<B> "
	mob << "<B>With the Tychon's Rift sector existing in relative isolation from United America oversight for the last five years, many colonists have considered themselves free from governmental rule.</B>"
	mob << ""
	mob << "<B>The year is now 2186.</B>"
	mob << "<B>The arrival of the USCM Battalion, the Falling Falcons, and their flagship, the USS Almayer, have reaffirmed that the United Americas considers Tychon's Rift part of their holdings.</B>"
	mob << "<B>It is up to you and your fellow colonists to make them realize their trespasses. This sector is no longer theirs.</B>"



/datum/emergency_call/clf/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(60;MALE, 40;FEMALE)
	var/list/first_names_mreb = list("Alan","Jack","Bil","Jonathan","John","Shiro","Gareth","Clark","Sam", "Lionel", "Aaron", "Charlie", "Scott", "Winston", "Aidan", "Ellis", "Mason", "Wesley", "Nicholas", "Calvin", "Nishikawa", "Hiroto", "Chiba", "Ouchi", "Furuse", "Takagi", "Oba", "Kishimoto")
	var/list/first_names_freb = list("Emma", "Adelynn", "Mary", "Halie", "Chelsea", "Lexie", "Arya", "Alicia", "Selah", "Amber", "Heather", "Myra", "Heidi", "Charlotte", "Oliva", "Lydia", "Tia", "Riko", "Ari", "Machida", "Ueki", "Mihara", "Noda")
	var/list/last_names_reb = list("Hawkins","Rickshaw","Elliot","Billard","Cooper","Fox", "Barlow", "Barrows", "Stewart", "Morgan", "Green", "Stone", "Burr", "Hunt", "Yuko", "Gesshin", "Takanibu", "Tetsuzan", "Tomomi", "Bokkai", "Takesi")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mreb)] [pick(last_names_reb)]"
	else
		mob.real_name = "[pick(first_names_freb)] [pick(last_names_reb)]"
	mob.name = mob.real_name
	mob.age = rand(17,45)
	mob.dna.ready_dna(mob)
	mob.key = M.key
	if(mob.client) mob.client.change_view(world.view)
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "CLF"
	ticker.mode.traitors += mob.mind
	mob.r_hair = 25
	mob.g_hair = 25
	mob.b_hair = 35
	mob.r_eyes = 139
	mob.g_eyes = 62
	mob.b_eyes = 19

	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			mob.mind.set_cm_skills(/datum/skills/pfc)
			mob << "<font size='4'>\red You are a leader of the local resistance group, the Colonial Liberation Front."
			mob.arm_equipment(mob, "CLF Fighter (Leader)")
			leader = mob
		else if(medics < max_medics)
			mob.mind.set_cm_skills(/datum/skills/combat_medic)
			mob << "<font size='4'>\red You are a medic of the local resistance group, the Colonial Liberation Front."
			mob.arm_equipment(mob, "CLF Fighter (Medic)")
			medics++
		else
			mob.mind.set_cm_skills(/datum/skills/SL)
			mob << "<font size='4'>\red You are a member of the local resistance group, the Colonial Liberation Front."
			mob.arm_equipment(mob, "CLF Fighter (Standard)")
		print_backstory(mob)

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)
	return



/datum/emergency_call/clf/platoon
	name = "Colonial Liberation Front (Platoon)"
	mob_min = 8
	mob_max = 35
	probability = 0
	max_medics = 2