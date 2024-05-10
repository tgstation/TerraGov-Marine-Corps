///Called on /mob/living/Initialize(), for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_LEGLESS), PROC_REF(on_legless_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_LEGLESS), PROC_REF(on_legless_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FAKEDEATH), PROC_REF(on_fakedeath_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FAKEDEATH), PROC_REF(on_fakedeath_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILE), PROC_REF(on_immobile_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILE), PROC_REF(on_immobile_trait_loss))

	RegisterSignal(src, COMSIG_AURA_STARTED, PROC_REF(add_emitted_auras))
	RegisterSignal(src, COMSIG_AURA_FINISHED, PROC_REF(remove_emitted_auras))


///Called when TRAIT_KNOCKEDOUT is added to the mob.
/mob/living/proc/on_knockedout_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(stat < UNCONSCIOUS)
		set_stat(UNCONSCIOUS)
	last_unconscious = world.time

///Called when TRAIT_KNOCKEDOUT is removed from the mob.
/mob/living/proc/on_knockedout_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(stat < DEAD)
		update_stat()
	record_time_unconscious()


///Called when TRAIT_LEGLESS is added to the mob.
/mob/living/proc/on_legless_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_FLOORED, TRAIT_LEGLESS)

///Called when TRAIT_LEGLESS is removed from the mob.
/mob/living/proc/on_legless_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_FLOORED, TRAIT_LEGLESS)


///Called when TRAIT_FAKEDEATH is added to the mob.
/mob/living/proc/on_fakedeath_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_FLOORED, TRAIT_FAKEDEATH)

///Called when TRAIT_FAKEDEATH is removed from the mob.
/mob/living/proc/on_fakedeath_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_FLOORED, TRAIT_FAKEDEATH)


///Called when TRAIT_FLOORED is added to the mob.
/mob/living/proc/on_floored_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(buckled && buckled.buckle_lying != -1)
		set_lying_angle(buckled.buckle_lying) //Might not actually be laying down, like with chairs, but the rest of the logic applies.
	else if(!lying_angle)
		set_lying_angle(pick(90, 270))
	set_canmove(FALSE)
	last_rested = world.time

///Called when TRAIT_FLOORED is removed from the mob.
/mob/living/proc/on_floored_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(lying_angle)
		set_lying_angle(0)
	if(!HAS_TRAIT(src, TRAIT_IMMOBILE))
		set_canmove(TRUE)
	record_time_lying_down()


///Called when TRAIT_LEGLESS is added to the mob.
/mob/living/proc/on_immobile_trait_gain(datum/source)
	SIGNAL_HANDLER
	set_canmove(FALSE)

///Called when TRAIT_LEGLESS is removed from the mob.
/mob/living/proc/on_immobile_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(src, TRAIT_FLOORED))
		set_canmove(TRUE)
