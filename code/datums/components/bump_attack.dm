/datum/component/bump_attack
    var/active = FALSE

/datum/component/bump_attack/Initialize()
    . = ..()
    if(!ismovableatom(parent))
         return COMPONENT_INCOMPATIBLE
    if(isxeno(parent))
        RegisterSignal(parent, COMSIG_WELL_FIGURE_YOU_OUT_LATER, .proc/bump_attack_toggle)
    else
        return COMPONENT_INCOMPATIBLE


/datum/component/bump_attack/toggle_bump_attack(datum/source)
    if(isxeno(parent))
	    var/mob/living/carbon/xenomorph/xeno_bumper = parent
    else
        return
	active = !active
	to_chat(xeno_bumper, "<span class='notice'>You will now [active ? "attack" : "push"] those who are in your way.</span>")

	if(active)
		xeno_bumper.RegisterSignal(xeno_bumper, COMSIG_MOVABLE_BUMP, /mob/living/carbon/xenomorph/.proc/xeno_bump_attack)
	else
		xeno_bumper.UnregisterSignal(xeno_bumper, COMSIG_MOVABLE_BUMP)

