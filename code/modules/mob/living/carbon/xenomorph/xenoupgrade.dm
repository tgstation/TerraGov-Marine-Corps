
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
	remove_abilities()
	add_abilities()
	if(selected_ability_type)
		for(var/datum/action/xeno_action/activable/activable_ability in actions)
			if(selected_ability_type != activable_ability.type)
				continue
			activable_ability.select()
			break

	switch(upgrade)
		//FIRST UPGRADE
		if(XENO_UPGRADE_ONE)
			to_chat(src, "<span class='xenodanger'>We feel a bit stronger.</span>")

		//SECOND UPGRADE
		if(XENO_UPGRADE_TWO)
			to_chat(src, "<span class='xenodanger'>We feel a whole lot stronger.</span>")

		//Final UPGRADE
		if(XENO_UPGRADE_THREE)
			to_chat(src, "<span class='xenoannounce'>[xeno_caste.ancient_message]</span>")

	generate_name() //Give them a new name now

	hud_set_plasma()
	med_hud_set_health()

	hud_set_queen_overwatch() //update the upgrade level insignia on our xeno hud.

	update_spits() //Update spits to new/better ones

//Tiered spawns.
/mob/living/carbon/xenomorph/runner/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/runner/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/runner/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/panther/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/panther/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/panther/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/bull/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/bull/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/bull/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/drone/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/drone/elder
	upgrade = XENO_UPGRADE_TWO

// ERT Versions:
/mob/living/carbon/xenomorph/drone/elder/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/drone/elder/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/drone/elder/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/drone/elder/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/drone/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/carrier/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/carrier/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/carrier/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/hivelord/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/hivelord/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hivelord/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/hivemind/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/hivemind/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hivemind/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/praetorian/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/praetorian/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/praetorian/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/ravager/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/ravager/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/ravager/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/sentinel/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/sentinel/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/sentinel/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/spitter/mature
	upgrade = XENO_UPGRADE_ONE

// ERT Versions:
/mob/living/carbon/xenomorph/spitter/mature/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/spitter/mature/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/spitter/mature/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/spitter/mature/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/spitter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/spitter/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/hunter/mature
	upgrade = XENO_UPGRADE_ONE

// ERT Versions:
/mob/living/carbon/xenomorph/hunter/mature/Corrupted
	hivenumber = XENO_HIVE_CORRUPTED

/mob/living/carbon/xenomorph/hunter/mature/Alpha
	hivenumber = XENO_HIVE_ALPHA

/mob/living/carbon/xenomorph/hunter/mature/Beta
	hivenumber = XENO_HIVE_BETA

/mob/living/carbon/xenomorph/hunter/mature/Zeta
	hivenumber = XENO_HIVE_ZETA

/mob/living/carbon/xenomorph/hunter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/hunter/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/queen/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/queen/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/queen/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/crusher/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/crusher/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/crusher/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/boiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/boiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/boiler/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/defender/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/defender/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/defender/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/warrior/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/warrior/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/warrior/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/Defiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/Defiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/Defiler/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/shrike/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/xenomorph/shrike/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/xenomorph/shrike/ancient
	upgrade = XENO_UPGRADE_THREE
