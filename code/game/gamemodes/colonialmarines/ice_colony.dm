//CM prison_rescue GAME MODE

/datum/game_mode/ice_colony
	name = "Ice Colony"
	config_tag = "Ice Colony"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	monkey_amount = 24
	monkey_types = list(/mob/living/carbon/monkey/yiren)

	flags_round_type = MODE_INFESTATION

/* Pre-pre-startup */
//We have to be really careful that we don't pick() from null lists.
//So use list.len as much as possible before a pick() for logic checks.
/datum/game_mode/ice_colony/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	if(!initialize_starting_xenomorph_list())
		return
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/ice_colony/announce()
	world << "<span class='round_header'>The current game map is - Ice colony!</span>"

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
/datum/game_mode/ice_colony/pre_setup()
	. = pre_setup_infestation()

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/ice_colony/post_setup()
	initialize_post_predator_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from archaeology site \"Shiva's Snowball\", on border ice world \"Ifrit\". A response team from the [MAIN_SHIP_NAME] will be dispatched shortly to investigate.", "[MAIN_SHIP_NAME]")

/*
/datum/game_mode/ice_colony/transform_xeno(var/datum/mind/ghost)

	var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(pick(xeno_spawn_ice_colony))
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
/datum/game_mode/ice_colony/transform_survivor(var/datum/mind/ghost)

	var/mob/living/carbon/human/H = ghost.current

	H.loc = pick(surv_spawn)

	//Damage them for realism purposes
	H.take_organ_damage(rand(0,15), rand(0,15))

	var/id_assignment = ""

//Give them proper jobs and stuff here later
	var/randjob = rand(0,3)
	switch(randjob)
		if(0) //Scientist
			id_assignment = "Scientist"
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/tox(H), WEAR_BACK)
			ghost.set_cm_skills(/datum/skills/civilian/survivor/scientist)
		if(1) //Doctor
			id_assignment = "Doctor"
			H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/belt/medical(H), WEAR_L_HAND)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/med(H), WEAR_BACK)
			ghost.set_cm_skills(/datum/skills/civilian/survivor/doctor)
		if(2) //Corporate guy
			id_assignment = "Salesman"
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), WEAR_BACK)
			ghost.set_cm_skills(/datum/skills/civilian/survivor)
		if(3) //Security
			id_assignment = "Security"
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(H), WEAR_BODY)
			H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(H), WEAR_BACK)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(H), WEAR_L_HAND)
			ghost.set_cm_skills(/datum/skills/civilian/survivor/marshall)

	H.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(H), WEAR_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(H), WEAR_JACKET)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(H), WEAR_FACE)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(H), WEAR_FEET)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS)

	var/obj/item/card/id/W = new(H)
	W.name = "[H.real_name]'s ID Card ([id_assignment])"
	W.assignment = id_assignment
	W.paygrade = "C"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, WEAR_ID)

	var/random_weap = rand(0,4)
	switch(random_weap)
		if(0)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(H), WEAR_WAIST)
		if(1)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/b92fs(H), WEAR_WAIST)
		if(2)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/kt42(H), WEAR_WAIST)
		if(3)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/uzi(H), WEAR_WAIST)
		if(4)
			H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/small(H), WEAR_WAIST)


	var/random_gear = rand(0,20)
	switch(random_gear)
		if(0)
			H.equip_to_slot_or_del(new /obj/item/device/camera/oldcamera(H), WEAR_R_HAND)
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
		H << "\blue You are a survivor of the attack on the ice habitat. You worked or lived on the colony, and managed to avoid the alien attacks.. until now."
		H << "\blue You are fully aware of the xenomorph threat and are able to use this knowledge as you see fit."
		H << "\blue You are NOT aware of the marines or their intentions, and lingering around arrival zones will get you survivor-banned."
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/ice_colony/process()
	process_infestation()

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/ice_colony/check_win()
	check_win_infestation()

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/ice_colony/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/ice_colony/declare_completion()
	. = declare_completion_infestation()
