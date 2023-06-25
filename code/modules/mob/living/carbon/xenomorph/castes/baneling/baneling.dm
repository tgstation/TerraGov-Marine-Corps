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
	/// reference to our pod
	var/obj/structure/xeno/baneling_pod/pod_ref

/// We do this to avoid a runtime with images assoc because baneling goes inside of their pod if they have one and there is no atom.z value inside of the pod
/mob/living/carbon/xenomorph/baneling/on_death()
	if(!isnull(pod_ref))
		return
	return ..()

/mob/living/carbon/xenomorph/baneling/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/obj/structure/xeno/baneling_pod
	name = "Baneling Pod"
	desc = "A baneling pod, storing fresh banelings "
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Baneling Pod"
	density = FALSE
	obj_flags = CAN_BE_HIT | PROJ_IGNORE_DENSITY
	/// Maximum amount of stored charge
	var/stored_charge_max = 2
	/// Respawn charges, each charge makes respawn take 30 seconds. Maximum of 2 charges. If there is no charge the respawn takes 120 seconds.
	var/stored_charge = 2
	/// How long until we get another charge
	var/charge_refresh_time = 180 SECONDS
	/// Time to respawn if out of charges
	var/respawn_time = 30 SECONDS
	/// Our currently stored baneling
	var/mob/living/carbon/xenomorph/baneling/stored_baneling
	/// Ref to our baneling
	var/mob/living/carbon/xenomorph/baneling/baneling_ref

/obj/structure/xeno/baneling_pod/obj_destruction()
	if(isnull(baneling_ref))
		return ..()
	// If the baneling is in crit or dead , then the pod gets destroyed and baneling never respawns
	if(baneling_ref.health <= -99)
		return ..()
	// pod is invincible if baneling is alive
	obj_integrity = 1

/// Teleports baneling inside of itself, checks for charge and then respawns baneling
/obj/structure/xeno/baneling_pod/proc/handle_baneling_death(mob/M)
	if(isnull(M))
		return
	stored_baneling = M
	stored_baneling.forceMove(src)
	if(stored_charge >= 1)
		stored_charge--
		addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), respawn_time)
		addtimer(CALLBACK(src, PROC_REF(increase_charge)), charge_refresh_time)
		return
	addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), respawn_time)

/// Increase our current charge
/obj/structure/xeno/baneling_pod/proc/increase_charge()
	if(stored_charge >= stored_charge_max)
		return
	stored_charge++

/// Rejuvinates and respawns the baneling
/obj/structure/xeno/baneling_pod/proc/spawn_baneling(turf/spawn_location = loc)
	stored_baneling.heal_overall_damage(stored_baneling.maxHealth, stored_baneling.maxHealth, updating_health = TRUE)
	stored_baneling.forceMove(spawn_location)
	stored_baneling.revive()
	stored_baneling = null
