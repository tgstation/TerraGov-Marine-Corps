
/mob/living/carbon/Xenomorph/proc/upgrade_xeno(newlevel)
	upgrade = newlevel
	upgrade_stored = 0
	visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
	"<span class='xenonotice'>You begin to twist and contort.</span>")
	do_jitter_animation(1000)
	set_datum()

	switch(upgrade)
		//FIRST UPGRADE
		if(1)
			to_chat(src, "<span class='xenodanger'>You feel a bit stronger.</span>")

		//SECOND UPGRADE
		if(2)
			to_chat(src, "<span class='xenodanger'>You feel a whole lot stronger.</span>")

		//Final UPGRADE
		if(3)
			to_chat(src, "<span class='xenoannounce'>[xeno_caste.ancient_message]</span>")
			
	generate_name() //Give them a new name now

	hud_set_queen_overwatch() //update the upgrade level insignia on our xeno hud.

	update_spits() //Update spits to new/better ones

//Tiered spawns.
/mob/living/carbon/Xenomorph/Runner/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Runner/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Runner/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Drone/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Drone/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Drone/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Carrier/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Carrier/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Carrier/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Hivelord/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Hivelord/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Hivelord/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Praetorian/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Praetorian/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Praetorian/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Ravager/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Ravager/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Ravager/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Sentinel/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Sentinel/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Sentinel/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Spitter/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Spitter/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Spitter/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Hunter/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Hunter/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Hunter/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Queen/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Queen/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Queen/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Crusher/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Crusher/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Crusher/ancient
	upgrade = 3

/mob/living/carbon/Xenomorph/Boiler/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Boiler/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Boiler/ancient
	upgrade = 3



/mob/living/carbon/Xenomorph/Defender/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Defender/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Defender/ancient
	upgrade = 3


/mob/living/carbon/Xenomorph/Warrior/mature
	upgrade = 1

/mob/living/carbon/Xenomorph/Warrior/elder
	upgrade = 2

/mob/living/carbon/Xenomorph/Warrior/ancient
	upgrade = 3
