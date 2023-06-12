/mob/living/carbon/xenomorph/baneling
	caste_base_type = /mob/living/carbon/xenomorph/baneling
	name = "Baneling"
	desc = ""
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Baneling Walking"
	bubble_icon = "alienleft"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16

/mob/living/carbon/xenomorph/baneling/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/baneling/on_death()
	. = ..()

/obj/structure/xeno/baneling_pod
	/// The evolution of our baneling, we dont wanna lose it all due to the nature of baneling
	var/stored_evolution
	/// The maturity of our baneling, we wanna keep it between deaths
	var/stored_maturity
	/// Respawn charges, each charge makes respawn take 30 seconds. Maximum of 2 charges. If there is no charge the respawn takes 120 seconds.
	var/stored_charge = 2
	/// Time to respawn if out of charges
	var/respawn_time = 120 SECONDS
	/// The next type of baneling that we will spawn
	var/mob/living/carbon/xenomorph/baneling/next_baneling
	///

