
/mob/living/carbon/xenomorph/proc/upgrade_xeno(newlevel, silent = FALSE)
	if(!(newlevel in (GLOB.xenoupgradetiers - XENO_UPGRADE_INVALID)))
		return
	hive.upgrade_xeno(src, upgrade, newlevel)
	upgrade = newlevel
	upgrade_stored = 0
	if(!silent)
		visible_message(span_xenonotice("\The [src] begins to twist and contort."), \
		span_xenonotice("We begin to twist and contort."))
		do_jitter_animation(1000)
	set_datum(FALSE)
	var/selected_ability_type = selected_ability?.type

	var/list/datum/action/xeno_action/actions_already_added = xeno_abilities
	xeno_abilities = list()

	for(var/allowed_action_path in xeno_caste.actions)
		var/found = FALSE
		for(var/datum/action/xeno_action/action_already_added AS in actions_already_added)
			if(action_already_added.type == allowed_action_path)
				xeno_abilities.Add(action_already_added)
				actions_already_added.Remove(action_already_added)
				found = TRUE
				break
		if(found)
			continue
		var/datum/action/xeno_action/action = new allowed_action_path()
		if(SSticker.mode?.flags_xeno_abilities & action.gamemode_flags)
			action.give_action(src)

	for(var/datum/action/xeno_action/action_already_added AS in actions_already_added)
		action_already_added.remove_action(src)

	SEND_SIGNAL(src, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	if(selected_ability_type)
		for(var/datum/action/xeno_action/activable/activable_ability in actions)
			if(selected_ability_type != activable_ability.type)
				continue
			activable_ability.select()
			break

	if(queen_chosen_lead)
		give_rally_abilities() //Give them back their rally hive ability

	switch(upgrade)
		//FIRST UPGRADE
		if(XENO_UPGRADE_ONE)
			if(!silent)
				to_chat(src, span_xenodanger("We feel a bit stronger."))

		//SECOND UPGRADE
		if(XENO_UPGRADE_TWO)
			if(!silent)
				to_chat(src, span_xenodanger("We feel a whole lot stronger."))
			switch(tier)
				if(XENO_TIER_TWO)
					SSmonitor.stats.elder_T2++
				if(XENO_TIER_THREE)
					SSmonitor.stats.elder_T3++
				if(XENO_TIER_FOUR)
					SSmonitor.stats.elder_T4++

		//FINAL UPGRADE
		if(XENO_UPGRADE_THREE)
			if(!silent)
				to_chat(src, span_xenoannounce("[xeno_caste.ancient_message]"))
			switch(tier)
				if(XENO_TIER_TWO)
					SSmonitor.stats.ancient_T2++
				if(XENO_TIER_THREE)
					SSmonitor.stats.ancient_T3++
				if(XENO_TIER_FOUR)
					SSmonitor.stats.ancient_T4++

		//PURCHASED UPGRADE
		if(XENO_UPGRADE_FOUR)
			if(!silent)
				to_chat(src, span_xenoannounce(xeno_caste.primordial_message))

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

/mob/living/carbon/xenomorph/runner/primordial
	upgrade = XENO_UPGRADE_FOUR

//-----RUNNER END-----//
//================//
//-----BULL START-----//

/mob/living/carbon/xenomorph/bull/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/bull/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/bull/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/bull/primordial
	upgrade = XENO_UPGRADE_FOUR

//-----BULL END-----//
//================//
//-----DRONE START-----//

/mob/living/carbon/xenomorph/drone/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/drone/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/drone/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/drone/primordial
	upgrade = XENO_UPGRADE_FOUR

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

/mob/living/carbon/xenomorph/carrier/primordial
	upgrade = XENO_UPGRADE_FOUR

//-----CARRIER END-----//
//================//
//----HIVELORD START----//

/mob/living/carbon/xenomorph/hivelord/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/hivelord/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hivelord/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/hivelord/primordial
	upgrade = XENO_UPGRADE_FOUR

//----HIVELORD END----//
//================//

//================//
//----PRAETORIAN START----//

/mob/living/carbon/xenomorph/praetorian/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/praetorian/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/praetorian/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/praetorian/primordial
	upgrade = XENO_UPGRADE_FOUR

//----PRAETORIAN END----//
//================//
//----RAVAGER START----//

/mob/living/carbon/xenomorph/ravager/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/ravager/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/ravager/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/ravager/primordial
	upgrade = XENO_UPGRADE_FOUR

//----RAVAGER END----//
//================//
//----SENTINEL START----//

/mob/living/carbon/xenomorph/sentinel/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/sentinel/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/sentinel/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/sentinel/primordial
	upgrade = XENO_UPGRADE_FOUR

//----SENTINEL END----//
//================//
//-----SPITTER START-----//

/mob/living/carbon/xenomorph/spitter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/spitter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/spitter/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/spitter/primordial
	upgrade = XENO_UPGRADE_FOUR

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

/mob/living/carbon/xenomorph/hunter/primordial
	upgrade = XENO_UPGRADE_FOUR

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

/mob/living/carbon/xenomorph/queen/primordial
	upgrade = XENO_UPGRADE_FOUR

//----QUEEN END----//
//============//
//---CRUSHER START---//

/mob/living/carbon/xenomorph/crusher/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/crusher/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/crusher/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/crusher/primordial
	upgrade = XENO_UPGRADE_FOUR

//---CRUSHER END---//
//============//
//---GORGER START---//

/mob/living/carbon/xenomorph/gorger/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/gorger/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/gorger/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/gorger/primordial
	upgrade = XENO_UPGRADE_FOUR

//---GORGER END---//
//============//
//---BOILER START---//

/mob/living/carbon/xenomorph/boiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/boiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/boiler/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/boiler/primordial
	upgrade = XENO_UPGRADE_FOUR

//---BOILER END---//
//============//
//---DEFENDER START---//

/mob/living/carbon/xenomorph/defender/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/defender/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/defender/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/defender/primordial
	upgrade = XENO_UPGRADE_FOUR

//---DEFENDER END---//
//============//
//----WARRIOR START----//

/mob/living/carbon/xenomorph/warrior/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/warrior/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/warrior/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/warrior/primordial
	upgrade = XENO_UPGRADE_FOUR

//----WARRIOR END----//
//============//
//----DEFILER START----//

/mob/living/carbon/xenomorph/Defiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/Defiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/Defiler/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/Defiler/primordial
	upgrade = XENO_UPGRADE_FOUR

//----DEFILER END----//
//============//
//----SHRIKE START----//

/mob/living/carbon/xenomorph/shrike/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/shrike/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/shrike/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/shrike/primordial
	upgrade = XENO_UPGRADE_FOUR

//----SHRIKE END----//
//============//

/mob/living/carbon/xenomorph/wraith/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/wraith/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/wraith/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/wraith/primordial
	upgrade = XENO_UPGRADE_FOUR
