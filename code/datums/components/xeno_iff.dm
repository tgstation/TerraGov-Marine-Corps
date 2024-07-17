/**
 * A special component that reacts to certain things that check for IFF and returns the IFF attached.
 * Applied by xeno IFF tags and meant for xenos only.
 */


/datum/component/xeno_iff
	///The IFF this component carries. SOM xenos? I got you.
	var/iff_type

/datum/component/xeno_iff/Initialize(_iff_type = TGMC_LOYALIST_IFF)
	. = ..()
	if(!isxeno(parent))
		return COMPONENT_INCOMPATIBLE //Only xenos should have a xeno IFF. Obviously.
	iff_type = _iff_type

/datum/component/xeno_iff/RegisterWithParent()
	RegisterSignal(parent, COMSIG_XENO_IFF_CHECK, PROC_REF(iff_check))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_XENOMORPH_EVOLVED, PROC_REF(evolve_carry_over))

/datum/component/xeno_iff/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_XENO_IFF_CHECK, COMSIG_ATOM_EXAMINE, COMSIG_XENOMORPH_EVOLVED))

/**
 * Reacts to an IFF check requesting signal by attaching its own IFF to the bitflag contained in the list sent.
 * Done this way because of in-place list magic, so for example a xeno could have multiple reactions from different sources and it would properly combine them.
 */
/datum/component/xeno_iff/proc/iff_check(datum/source, list/iff_list)
	SIGNAL_HANDLER
	iff_list[1] |= iff_type

/**
 * Handles being examined by showing a tag is attached, aswell as if it is friendly relative to the own (if a human examines).
 */
/datum/component/xeno_iff/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "It seems to have a small smart-IFF tag clamped onto it!"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.wear_id || !CHECK_BITFIELD(iff_type, H.wear_id.iff_signal))
			examine_list += "Your IFF recognizes its tag as hostile."
		else
			examine_list += "Its tag's IFF recognizes you as friendly."

/**
 * Handles when a xenomorph evolves by attaching a new component to the evolved xeno.
 * How does it remain attached past evolution? I have no clue, bluespace magic. Would be pain to use if it didn't last however.
 */
/datum/component/xeno_iff/proc/evolve_carry_over(datum/source, mob/living/carbon/xenomorph/new_xeno)
	SIGNAL_HANDLER
	new_xeno.AddComponent(/datum/component/xeno_iff, iff_type)

