/mob/living/carbon/xenomorph/hunter
	caste_base_type = /mob/living/carbon/xenomorph/hunter
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/castes/hunter.dmi'
	icon_state = "Hunter Running"
	bubble_icon = "alien"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/hunter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)

/mob/living/carbon/xenomorph/hunter/weapon_x
	caste_base_type = /mob/living/carbon/xenomorph/hunter/weapon_x

/mob/living/carbon/xenomorph/hunter/weapon_x/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(terminate_specimen))

///Removed the xeno after the mission ends
/mob/living/carbon/xenomorph/hunter/weapon_x/proc/terminate_specimen()
	SIGNAL_HANDLER
	qdel(src)

