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

/// We do this to avoid a runtime with images assoc because baneling goes inside of their pod if they have one and there is no atom.z value inside of the pod
/mob/living/carbon/xenomorph/baneling/on_death()
	if(!isnull(pod_ref))
		return
	return ..()

/// Delete the pod if we evolve or devolve
/mob/living/carbon/xenomorph/baneling/finish_evolve()
	if(!isnull(pod_ref))
		pod_ref.baneling_ref = null
		pod_ref.obj_destruction()
		pod_ref = null
	return ..()

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
	var/stored_charge = 0
	/// How long until we get another charge
	var/charge_refresh_time = 180 SECONDS
	/// Time to respawn if we have charges
	var/respawn_time = 30 SECONDS
	/// Ref to our baneling
	var/mob/living/carbon/xenomorph/baneling/baneling_ref

/obj/structure/xeno/baneling_pod/New(loc, mob/M)
	. = ..()
	baneling_ref = M
	RegisterSignal(baneling_ref, COMSIG_MOB_DEATH, PROC_REF(handle_baneling_death))

/obj/structure/xeno/baneling_pod/obj_destruction()
	if(isnull(baneling_ref))
		return ..()
	// If the baneling is in crit or dead , then the pod gets destroyed and baneling never respawns
	if(baneling_ref.health <= -99)
		return ..()
	baneling_ref.balloon_alert(baneling_ref, "YOUR POD IS DESTROYED")
	to_chat(baneling_ref, span_xenohighdanger("YOUR POD IS DESTROYED"))
	UnregisterSignal(baneling_ref, COMSIG_MOB_DEATH)
	baneling_ref = null

/// Teleports baneling inside of itself, checks for charge and then respawns baneling
/obj/structure/xeno/baneling_pod/proc/handle_baneling_death(mob/M)
	if(isnull(M))
		return
	baneling_ref.forceMove(src)
	if(stored_charge >= 1)
		stored_charge--
		addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), respawn_time)
		addtimer(CALLBACK(src, PROC_REF(increase_charge)), charge_refresh_time)
		to_chat(baneling_ref.client, span_xenohighdanger("You will respawn in 30 seconds"))
		return
	/// The respawn takes 4 times longer than consuming a charge would
	to_chat(baneling_ref.client, "You will respawn in [(respawn_time*4)/10] SECONDS")
	addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), respawn_time*4)

/// Increase our current charge
/obj/structure/xeno/baneling_pod/proc/increase_charge()
	if(stored_charge >= stored_charge_max)
		return
	stored_charge++

/// Rejuvinates and respawns the baneling
/obj/structure/xeno/baneling_pod/proc/spawn_baneling()
	baneling_ref.forceMove(get_turf(loc))
	baneling_ref.revive()
