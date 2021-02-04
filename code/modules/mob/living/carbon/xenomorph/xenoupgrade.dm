
/mob/living/carbon/xenomorph/proc/upgrade_xeno(newlevel)
	if(!(newlevel in (GLOB.xenoupgradetiers - XENO_UPGRADE_BASETYPE - XENO_UPGRADE_INVALID)))
		return // smelly badmins
	hive.upgrade_xeno(src, upgrade, newlevel)
	upgrade = newlevel
	upgrade_stored = 0
	visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
	"<span class='xenonotice'>We begin to twist and contort.</span>")
	do_jitter_animation(1000)
	set_datum()
	var/selected_ability_type = selected_ability?.type

	for(var/check_existing_actions in xeno_abilities) //Remove xenos actions we shouldn't have
		var/datum/action/xeno_action/existing_action_path = check_existing_actions
		if(!locate(existing_action_path) in xeno_caste.actions)
			existing_action_path.remove_action(src)

	for(var/check_new_actions in xeno_caste.actions) //Give the xenos actions we don't currently have
		var/datum/action/xeno_action/new_action_path = check_new_actions
		if(!locate(new_action_path) in xeno_abilities)
			var/datum/action/xeno_action/A = new new_action_path()
			A.give_action(src)

	SEND_SIGNAL(src, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	if(selected_ability_type)
		for(var/datum/action/xeno_action/activable/activable_ability in actions)
			if(selected_ability_type != activable_ability.type)
				continue
			activable_ability.select()
			break

	if(queen_chosen_lead)
		give_rally_hive_ability() //Give them back their rally hive ability

	switch(upgrade)
		//FIRST UPGRADE
		if(XENO_UPGRADE_ONE)
			to_chat(src, "<span class='xenodanger'>We feel a bit stronger.</span>")

		//SECOND UPGRADE
		if(XENO_UPGRADE_TWO)
			to_chat(src, "<span class='xenodanger'>We feel a whole lot stronger.</span>")
			switch(tier)
				if(XENO_TIER_TWO)
					SSmonitor.stats.elder_T2++
				if(XENO_TIER_THREE)
					SSmonitor.stats.elder_T3++
				if(XENO_TIER_FOUR)
					SSmonitor.stats.elder_queen++

		//FINAL UPGRADE
		if(XENO_UPGRADE_THREE)
			to_chat(src, "<span class='xenoannounce'>[xeno_caste.ancient_message]</span>")
			switch(tier)
				if(XENO_TIER_TWO)
					SSmonitor.stats.ancient_T2++
				if(XENO_TIER_THREE)
					SSmonitor.stats.ancient_T3++
				if(XENO_TIER_FOUR)
					SSmonitor.stats.ancient_queen++

	generate_name() //Give them a new name now

	hud_set_plasma()
	med_hud_set_health()

	hud_set_queen_overwatch() //update the upgrade level insignia on our xeno hud.

	update_spits() //Update spits to new/better ones

//Tiered spawns.

//-----RUNNER START-----//

/mob/living/carbon/xenomorph/runner/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/runner/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/runner/ancient
	upgrade = XENO_UPGRADE_THREE

//-----RUNNER END-----//
//================//
//-----BULL START-----//

/mob/living/carbon/xenomorph/bull/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/bull/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/bull/ancient
	upgrade = XENO_UPGRADE_THREE

//-----BULL END-----//
//================//
//-----DRONE START-----//

/mob/living/carbon/xenomorph/drone/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/drone/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/drone/ancient
	upgrade = XENO_UPGRADE_THREE

//-----DRONE END-----//
//================//

//----------------------------------------------//
// ERT DRONE START

/mob/living/carbon/xenomorph/drone/elder/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/drone/elder/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/drone/elder/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/drone/elder/Zeta
	hivenumber = XENO_HIVE_ZETA

// ERT DRONE START END
//---------------------------------------------//
//-----CARRIER START-----//

/mob/living/carbon/xenomorph/carrier/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/carrier/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/carrier/ancient
	upgrade = XENO_UPGRADE_THREE

//-----CARRIER END-----//
//================//
//----HIVELORD START----//

/mob/living/carbon/xenomorph/hivelord/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/hivelord/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hivelord/ancient
	upgrade = XENO_UPGRADE_THREE

//----HIVELORD END----//
//================//
//----HIVEMIND START----//

/mob/living/carbon/xenomorph/hivemind/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/hivemind/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hivemind/ancient
	upgrade = XENO_UPGRADE_THREE

//----HIVEMIND END----//
//================//
//----PRAETORIAN START----//

/mob/living/carbon/xenomorph/praetorian/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/praetorian/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/praetorian/ancient
	upgrade = XENO_UPGRADE_THREE

//----PRAETORIAN END----//
//================//
//----RAVAGER START----//

/mob/living/carbon/xenomorph/ravager/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/ravager/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/ravager/ancient
	upgrade = XENO_UPGRADE_THREE

//----RAVAGER END----//
//================//
//----SENTINEL START----//

/mob/living/carbon/xenomorph/sentinel/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/sentinel/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/sentinel/ancient
	upgrade = XENO_UPGRADE_THREE

//----SENTINEL END----//
//================//
//-----SPITTER START-----//

/mob/living/carbon/xenomorph/spitter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/spitter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/spitter/ancient
	upgrade = XENO_UPGRADE_THREE

//-----SPITTER END-----//
//================//
//SENTINEL ERT START

/mob/living/carbon/xenomorph/spitter/mature/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/spitter/mature/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/spitter/mature/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/spitter/mature/Zeta
	hivenumber = XENO_HIVE_ZETA

//SENTINEL ERT END
//================//
//----HUNTER START----//

/mob/living/carbon/xenomorph/hunter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/hunter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hunter/ancient
	upgrade = XENO_UPGRADE_THREE

//----HUNTER END----//
//================//
//HUNTER ERT START

/mob/living/carbon/xenomorph/hunter/mature/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/hunter/mature/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/hunter/mature/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/hunter/mature/Zeta
	hivenumber = XENO_HIVE_ZETA

//HUNTER ERT END
//================//
//----QUEEN START----//

/mob/living/carbon/xenomorph/queen/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/queen/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/queen/ancient
	upgrade = XENO_UPGRADE_THREE

//----QUEEN END----//
//============//
//---CRUSHER START---//

/mob/living/carbon/xenomorph/crusher/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/crusher/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/crusher/ancient
	upgrade = XENO_UPGRADE_THREE

//---CRUSHER END---//
//============//
//---BOILER START---//

/mob/living/carbon/xenomorph/boiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/boiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/boiler/ancient
	upgrade = XENO_UPGRADE_THREE

//---BOILER END---//
//============//
//---DEFENDER START---//

/mob/living/carbon/xenomorph/defender/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/defender/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/defender/ancient
	upgrade = XENO_UPGRADE_THREE

//---DEFENDER END---//
//============//
//----WARRIOR START----//

/mob/living/carbon/xenomorph/warrior/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/warrior/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/warrior/ancient
	upgrade = XENO_UPGRADE_THREE

//----WARRIOR END----//
//============//
//----DEFILER START----//

/mob/living/carbon/xenomorph/Defiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/Defiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/Defiler/ancient
	upgrade = XENO_UPGRADE_THREE

//----DEFILER END----//
//============//
//----SHRIKE START----//

/mob/living/carbon/xenomorph/shrike/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/shrike/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/shrike/ancient
	upgrade = XENO_UPGRADE_THREE

//----SHRIKE END----//
//============//
