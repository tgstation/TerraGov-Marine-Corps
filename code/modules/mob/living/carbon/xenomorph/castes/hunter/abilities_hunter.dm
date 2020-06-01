//Phase
/datum/action/xeno_action/phase
	name = "Phase"
	action_icon_state = "xenohide"
	mechanics_text = "Walk through anything for a duration of 1 second. Causes sunder with each use."
	ability_name = "phase"
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_PHASE
	cooldown_timer = HUNTER_PHASE_COOLDOWN
	var/last_phase = null
	var/phase = FALSE

/datum/action/xeno_action/phase/can_use_action(silent = FALSE, override_flags)
    . = ..()
    if(!.)
        return FALSE
    var/mob/living/carbon/xenomorph/phased = owner
    if(phased.on_fire)
        if(!silent)
            to_chat(phased, "<span class='warning'>The fire prevents us from phasing!</span>")
        return FALSE
    if(phase)
        if(!silent)
            to_chat(phased, "<span class='warning'>You are already phased!</span>")
        return FALSE
    return TRUE

/datum/action/xeno_action/phase/on_cooldown_finish()
    to_chat(owner, "<span class='xenodanger'><b>We're ready to phase again.</b></span>")
    playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
    return ..()

/datum/action/xeno_action/phase/action_activate()
    to_chat(owner, "<span class='xenodanger'>We lose cohesion within ourselves...</span>")
    phase = TRUE
    owner.alpha = 128 //50% visible
    addtimer(CALLBACK(src, .proc/materialize), 1 SECONDS)
    succeed_activate()
    add_cooldown()

/datum/action/xeno_action/phase/proc/materialize()
    if(!phase)//sanity check/safeguard
        return
    to_chat(owner, "<span class='xenodanger'>We materialize again.</span>")
    phase = FALSE
    owner.alpha = initial(owner.alpha) //no transparency/translucency
