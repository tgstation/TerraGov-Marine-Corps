
/mob/living/carbon/Xenomorph/proc/upgrade_xeno(newlevel)
	if(!(newlevel in (GLOB.xenoupgradetiers - XENO_UPGRADE_BASETYPE - XENO_UPGRADE_INVALID)))
		return // smelly badmins
	hive.upgrade_xeno(src, upgrade, newlevel)
	upgrade = newlevel
	upgrade_stored = 0
	visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
	"<span class='xenonotice'>You begin to twist and contort.</span>")
	do_jitter_animation(1000)
	set_datum()

	switch(upgrade)
		//FIRST UPGRADE
		if(XENO_UPGRADE_ONE)
			to_chat(src, "<span class='xenodanger'>You feel a bit stronger.</span>")

		//SECOND UPGRADE
		if(XENO_UPGRADE_TWO)
			to_chat(src, "<span class='xenodanger'>You feel a whole lot stronger.</span>")

		//Final UPGRADE
		if(XENO_UPGRADE_THREE)
			to_chat(src, "<span class='xenoannounce'>[xeno_caste.ancient_message]</span>")

	generate_name() //Give them a new name now

	hud_set_plasma()
	med_hud_set_health()

	hud_set_queen_overwatch() //update the upgrade level insignia on our xeno hud.

	update_spits() //Update spits to new/better ones

//Tiered spawns.
/mob/living/carbon/Xenomorph/Runner/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Runner/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Runner/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Drone/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Drone/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Drone/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Carrier/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Carrier/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Carrier/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Hivelord/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Hivelord/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Hivelord/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Praetorian/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Praetorian/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Praetorian/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Ravager/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Ravager/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Ravager/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Sentinel/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Sentinel/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Sentinel/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Spitter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Spitter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Spitter/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Hunter/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Hunter/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Hunter/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Queen/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Queen/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Queen/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Crusher/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Crusher/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Crusher/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Boiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Boiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Boiler/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Defender/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Defender/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Defender/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Warrior/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Warrior/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Warrior/ancient
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/Xenomorph/Defiler/mature
	upgrade = XENO_UPGRADE_ONE

/mob/living/carbon/Xenomorph/Defiler/elder
	upgrade = XENO_UPGRADE_TWO

/mob/living/carbon/Xenomorph/Defiler/ancient
	upgrade = XENO_UPGRADE_THREE