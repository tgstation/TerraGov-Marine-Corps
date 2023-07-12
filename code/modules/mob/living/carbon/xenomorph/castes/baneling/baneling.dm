/mob/living/carbon/xenomorph/baneling
	caste_base_type = /mob/living/carbon/xenomorph/baneling
	name = "Baneling"
	desc = "A green alien that store chemicals and can run pretty fast . . ."
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

/obj/structure/xeno/baneling_pod
	name = "Baneling Pod"
	desc = "A baneling pod, storing fresh banelings "
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Baneling Pod"
	density = FALSE
	obj_flags = CAN_BE_HIT | PROJ_IGNORE_DENSITY
	/// Ref to our xeno
	var/mob/living/carbon/xenomorph/xeno_ref

/obj/structure/xeno/baneling_pod/Initialize(mapload, _hivenumber, xeno, ability_ref)
	. = ..()
	xeno_ref = xeno
	RegisterSignal(xeno_ref, COMSIG_MOB_DEATH, PROC_REF(handle_baneling_death))
	RegisterSignal(xeno_ref, COMSIG_QDELETING, PROC_REF(obj_destruction))
	RegisterSignal(ability_ref, COMSIG_ACTION_TRIGGER, PROC_REF(obj_destruction))
	addtimer(CALLBACK(src, PROC_REF(increase_charge)), BANELING_CHARGE_GAIN_TIME)

/obj/structure/xeno/baneling_pod/obj_destruction()
	if(length(contents) >= 1)
		xeno_ref.balloon_alert(xeno_ref, "YOUR POD IS DESTROYED")
		to_chat(xeno_ref, span_xenohighdanger("YOUR POD IS DESTROYED"))
		UnregisterSignal(xeno_ref, COMSIG_MOB_DEATH)
		xeno_ref = null
		return ..()
	if(xeno_ref.stat & DEAD)
		xeno_ref.forceMove(get_turf(loc))
		xeno_ref.death(FALSE)
	return ..()

/// Teleports baneling inside of itself, checks for charge and then respawns baneling
/obj/structure/xeno/baneling_pod/proc/handle_baneling_death()
	if(isnull(xeno_ref))
		return
	xeno_ref.forceMove(src)
	if(xeno_ref.stored_charge >= 1)
		xeno_ref.stored_charge--
		addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), BANELING_CHARGE_RESPAWN_TIME)
		addtimer(CALLBACK(src, PROC_REF(increase_charge)), BANELING_CHARGE_GAIN_TIME)
		to_chat(xeno_ref.client, span_xenohighdanger("You will respawn in [BANELING_CHARGE_RESPAWN_TIME/10] seconds"))
		return
	/// The respawn takes 4 times longer than consuming a charge would
	to_chat(xeno_ref.client, "You will respawn in [(BANELING_CHARGE_RESPAWN_TIME*4)/10] SECONDS")
	addtimer(CALLBACK(src, PROC_REF(spawn_baneling)), BANELING_CHARGE_RESPAWN_TIME*4)

/// Increase our current charge
/obj/structure/xeno/baneling_pod/proc/increase_charge()
	if(xeno_ref.stored_charge >= BANELING_CHARGE_MAX)
		return
	xeno_ref.stored_charge++
	if(xeno_ref.stored_charge != BANELING_CHARGE_MAX)
		addtimer(CALLBACK(src, PROC_REF(increase_charge)), BANELING_CHARGE_GAIN_TIME)

/// Rejuvinates and respawns the baneling
/obj/structure/xeno/baneling_pod/proc/spawn_baneling()
	xeno_ref.forceMove(get_turf(loc))
	xeno_ref.revive()
