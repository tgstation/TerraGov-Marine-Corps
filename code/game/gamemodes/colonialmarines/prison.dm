//CM prison_rescue GAME MODE

/datum/game_mode/prison
	name = "Prison Station"
	config_tag = "Prison Station"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	monkey_amount = 24
	monkey_types = list(/mob/living/carbon/monkey)

	flags_round_type = MODE_INFESTATION

/* Pre-pre-startup */
//We have to be really careful that we don't pick() from null lists.
//So use list.len as much as possible before a pick() for logic checks.
/datum/game_mode/prison/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	if(!initialize_starting_xenomorph_list())
		return
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/prison/announce()
	world << "<span class='round_header'>The current game map is - Prison Station!</span>"

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
/datum/game_mode/prison/pre_setup()
	. = pre_setup_infestation()

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/prison/post_setup()
	initialize_post_predator_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from maximum-security prison \"Fiorina Orbital Penitentiary\". A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")

/*
/datum/game_mode/prison/transform_xeno(var/datum/mind/ghost)

	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(pick(xeno_spawn_prison))
	new_xeno.amount_grown = 200
	var/mob/original = ghost.current

	ghost.transfer_to(new_xeno)

	new_xeno << "<B>You are now an alien!</B>"
	new_xeno << "<B>Your job is to spread the hive and protect the Queen. You can become the Queen yourself by evolving into a drone.</B>"
	new_xeno << "Use say :a to talk to the hive."

	new_xeno.update_icons()

	if(original) //Just to be sure.
		cdel(original)
*/
//Start the Survivor players. This must go post-setup so we already have a body.
/datum/game_mode/prison/transform_survivor(var/datum/mind/ghost)

	var/mob/living/carbon/human/H = ghost.current

	H.loc = pick(surv_spawn)

	//Damage them for realism purposes
	H.take_organ_damage(rand(0,15), rand(0,15))

//Give them proper jobs and stuff here later
	var/randjob = rand(0,6)
	switch(randjob)
		if(0) //Scientist
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/tox(H), WEAR_BACK)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_MEDIC,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
		if(1) //Doctor
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/belt/medical(H), WEAR_L_HAND)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/med(H), WEAR_BACK)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_SURGERY,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
		if(2) //Corporate guy
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), WEAR_BACK)
			ghost.skills_list = list("cqc"=SKILL_CQC_WEAK,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_UNTRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_WEAK,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_UNTRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
		if(3) //Security
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(H), WEAR_L_HAND)
			ghost.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
		if(4 to 6) //Prisoner
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), WEAR_FEET)
			ghost.skills_list = list("cqc"=SKILL_CQC_DEFAULT,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_DEFAULT,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_NOVICE,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_DEFAULT,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_DEFAULT,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

	var/random_gear = rand(0,20)
	switch(random_gear)
		if(0)
			H.equip_to_slot_or_del(new /obj/item/device/camera/fluff/oldcamera(H), WEAR_R_HAND)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), WEAR_R_HAND)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), WEAR_R_HAND)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/storage/firstaid/regular(H), WEAR_R_HAND)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/tool/surgery/surgicaldrill(H), WEAR_R_HAND)
		if(5)
			H.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack(H), WEAR_R_HAND)
		if(6)
			H.equip_to_slot_or_del(new /obj/item/weapon/butterfly/switchblade(H), WEAR_R_HAND)
		if(7)
			H.equip_to_slot_or_del(new /obj/item/tool/kitchen/knife(H), WEAR_R_HAND)
		if(8)
			H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/lemoncakeslice(H), WEAR_R_HAND)
		if(9)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/dblue(H), WEAR_R_HAND)
		if(10)
			H.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank(H), WEAR_R_HAND)

	H.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/full(H), WEAR_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(H), WEAR_L_STORE)



	H.update_icons()

	//Give them some information
	spawn(4)
		H << "<h2>You are a survivor!</h2>"
		H << "\blue You are a survivor of the attack on Fiorina Orbital Penitentiary. You worked or lived on the prison station, and managed to avoid the alien attacks.. until now."
		H << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		H << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/prison/process()
	process_infestation()

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/prison/check_win()
	check_win_infestation()

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/prison/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/prison/declare_completion()
	. = declare_completion_infestation()
