


//Randomly-equipped mercenaries. May be friendly or hostile to the USCM, hostile to xenos.
/datum/emergency_call/mercs
	name = "Freelancers (Squad)"
	mob_max = 8
	probability = 25

	New()
		..()
		arrival_message = "[MAIN_SHIP_NAME], this is Freelancer shuttle MC-98 responding to your distress call. Prepare for boarding."
		objectives = "Help the crew of the [MAIN_SHIP_NAME] in exchange for payment, and choose your payment well. Do what your Captain says. Ensure your survival at all costs."



/datum/emergency_call/mercs/print_backstory(mob/living/carbon/human/mob)
	mob << "<B> You started off in Tychon's Rift system as a colonist seeking work at one of the established colonies.</b>"
	mob << "<B> The withdrawl of United American forces in the early 2180s, the system fell into disarray.</b>"
	mob << "<B> Taking up arms as a mercenary, the Freelancers have become a powerful force of order in the system.</b>"
	mob << "<B> While they are motivated primarily by money, many colonists see the Freelancers as the main forces of order in Tychon's Rift.</b>"
	if(hostility)
		mob << "<B> Despite this, you have been tasked to ransack the [MAIN_SHIP_NAME] and kill anyone who gets in your way.</b>"
		mob << "<B> Any UPP, CLF or WY forces also responding are to be considered neutral parties unless proven hostile.</b>"
	else
		mob << "<B> To this end, you have been contacted by Weyland-Yutani of the USCSS Royce to assist the [MAIN_SHIP_NAME]..</b>"
		mob << "<B> Ensure they are not destroyed.</b>"



/datum/emergency_call/mercs/create_member(datum/mind/M)
	var/turf/spawn_loc = get_spawn_point()
	var/mob/original = M.current

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/mob = new(spawn_loc)
	mob.gender = pick(80;MALE,20;FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance_for(mob)
	var/list/first_names_mcol = list("Alan","Jack","Bil","Jonathan","John","Shiro","Gareth","Clark","Sam", "Lionel", "Aaron", "Charlie", "Scott", "Winston", "Aidan", "Ellis", "Mason", "Wesley", "Nicholas", "Calvin", "Nishikawa", "Hiroto", "Chiba", "Ouchi", "Furuse", "Takagi", "Oba", "Kishimoto")
	var/list/first_names_fcol = list("Emma", "Adelynn", "Mary", "Halie", "Chelsea", "Lexie", "Arya", "Alicia", "Selah", "Amber", "Heather", "Myra", "Heidi", "Charlotte", "Ashley", "Raven", "Tori", "Anne", "Madison", "Oliva", "Lydia", "Tia", "Riko", "Ari", "Machida", "Ueki", "Mihara", "Noda")
	var/list/last_names_col = list("Hawkins","Rickshaw","Elliot","Billard","Cooper","Fox", "Barlow", "Barrows", "Stewart", "Morgan", "Green", "Stone", "Titan", "Crowe", "Krantz", "Pathillo", "Driggers", "Burr", "Hunt", "Yuko", "Gesshin", "Takanibu", "Tetsuzan", "Tomomi", "Bokkai", "Takesi")
	if(mob.gender == MALE)
		mob.real_name = "[pick(first_names_mcol)] [pick(last_names_col)]"
		mob.f_style = "5 O'clock Shadow"
	else
		mob.real_name = "[pick(first_names_fcol)] [pick(last_names_col)]"
	mob.name = mob.real_name
	mob.age = rand(20,45)
	mob.dna.ready_dna(mob)
	mob.r_hair = 25
	mob.g_hair = 25
	mob.b_hair = 35
	mob.s_tone = rand(0,120)
	mob.key = M.key
	if(mob.client) mob.client.view = world.view
	mob.mind.assigned_role = "MODE"
	mob.mind.special_role = "Mercenary"
	ticker.mode.traitors += mob.mind
	mob.mind.skills_list = list("cqc"=SKILL_CQC_MASTER,"endurance"=0,"engineer"=SKILL_ENGINEER_METAL,"firearms"=SKILL_FIREARMS_TRAINED,
		"smartgun"=SKILL_SMART_TRAINED,"heavy_weapons"=SKILL_HEAVY_TRAINED,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,
		"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	spawn(0)
		if(!leader)       //First one spawned is always the leader.
			leader = mob
			mob.arm_equipment(mob, "Freelancer (Leader)")
			mob << "<font size='3'>\red You are the Freelancer leader!</font>"

		else if(medics < max_medics)
			mob.arm_equipment(mob, "Freelancer (Medic)")
			medics++
			mob << "<font size='3'>\red You are a Freelancer medic!</font>"
		else
			mob.arm_equipment(mob, "Freelancer (Standard)")
			mob << "<font size='3'>\red You are a Freelancer mercenary!</font>"
		print_backstory(mob)

	spawn(10)
		M << "<B>Objectives:</b> [objectives]"

	if(original)
		cdel(original)



/datum/emergency_call/mercs/platoon
	name = "Freelancers (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
	max_medics = 3
