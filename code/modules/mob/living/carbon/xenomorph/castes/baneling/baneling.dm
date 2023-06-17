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
	/// reference to our pod so we can access vars
	var/obj/structure/xeno/baneling_pod/pod_ref

/mob/living/carbon/xenomorph/baneling/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/obj/structure/xeno/baneling_pod
	name = "Baneling Pod"
	desc = ""
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Baneling Pod"
	/// Maximum amount of stored charge
	var/stored_charge_max = 2
	/// Respawn charges, each charge makes respawn take 30 seconds. Maximum of 2 charges. If there is no charge the respawn takes 120 seconds.
	var/stored_charge = 2
	/// How long until we get another charge
	var/charge_refresh_time = 10 SECONDS
	/// Time to respawn if out of charges
	var/respawn_time = 10 SECONDS
	/// Our currently stored baneling
	var/mob/living/carbon/xenomorph/baneling/stored_baneling

/obj/structure/xeno/baneling_pod/New(turf/T, mob/M)
	RegisterSignal(M, COMSIG_MOB_DEATH, .proc/handle_baneling_death)
	. = ..()

/obj/structure/xeno/baneling_pod/proc/handle_baneling_death(mob/M)
	if(isnull(M))
		return
	stored_baneling = M
	stored_baneling.forceMove(src)
	if(stored_charge >= 1)
		stored_charge--
		addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), 5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(handle_charge)), charge_refresh_time)
		return
	addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), respawn_time)

/obj/structure/xeno/baneling_pod/proc/handle_charge()
	if(stored_charge >= stored_charge_max)
		return
	stored_charge++

/obj/structure/xeno/baneling_pod/proc/spawn_baneling(turf/spawn_location = loc)
	stored_baneling.heal_overall_damage(stored_baneling.maxHealth, stored_baneling.maxHealth, updating_health = TRUE)
	stored_baneling.forceMove(spawn_location)
	stored_baneling.revive()
	stored_baneling = null
