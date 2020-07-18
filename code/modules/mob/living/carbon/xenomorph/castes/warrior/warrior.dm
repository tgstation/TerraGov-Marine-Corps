/mob/living/carbon/xenomorph/warrior
	caste_base_type = /mob/living/carbon/xenomorph/warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warrior Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO

// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/xenomorph/warrior/handle_special_state()
	if(agility)
		icon_state = "Warrior Agility"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/warrior/handle_special_wound_states(severity)
	. = ..()
	if(agility)
		return "warrior_wounded_agility_[severity]"

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/warrior/stop_pulling()
	if(isliving(pulling) && !isxeno(pulling))
		var/mob/living/L = pulling
		grab_resist_level = 0 //zero it out
		L.SetStun(0)
		UnregisterSignal(L, COMSIG_LIVING_DO_RESIST)
	..()

/mob/living/carbon/xenomorph/warrior/start_pulling(atom/movable/AM, lunge, suppress_message = TRUE)
	if(!check_state() || agility || !isliving(AM))
		return FALSE

	var/mob/living/L = AM

	if(isxeno(L))
		return ..()

	if(lunge && ..(L, suppress_message))
		return neck_grab(L)

	if(SEND_SIGNAL(src, COMSIG_WARRIOR_NECKGRAB, L) & COMSIG_WARRIOR_CANT_NECKGRAB)
		return FALSE

	. = ..(L, suppress_message)

	if(.) //successful pull
		neck_grab(L)

	SEND_SIGNAL(src, COMSIG_WARRIOR_USED_GRAB)


/mob/living/carbon/xenomorph/warrior/proc/neck_grab(mob/living/L)
	use_plasma(10)

	GLOB.round_statistics.warrior_grabs++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_grabs")
	setGrabState(GRAB_NECK)
	ENABLE_BITFIELD(L.restrained_flags, RESTRAINED_NECKGRAB)
	RegisterSignal(L, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
	L.drop_all_held_items()
	L.Paralyze(1)
	visible_message("<span class='xenowarning'>\The [src] grabs [L] by the throat!</span>", \
	"<span class='xenowarning'>We grab [L] by the throat!</span>")
	return TRUE


/mob/living/carbon/xenomorph/warrior/resisted_against(datum/source)
	var/mob/living/victim = source
	victim.do_resist_grab()


/mob/living/carbon/xenomorph/warrior/hitby(atom/movable/AM, speed = 5)
	if(ishuman(AM))
		return
	..()
