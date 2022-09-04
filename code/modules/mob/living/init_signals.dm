///Called on /mob/living/Initialize(), for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), .proc/on_knockedout_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), .proc/on_knockedout_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_LEGLESS), .proc/on_legless_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_LEGLESS), .proc/on_legless_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FAKEDEATH), .proc/on_fakedeath_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FAKEDEATH), .proc/on_fakedeath_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FLOORED), .proc/on_floored_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FLOORED), .proc/on_floored_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILE), .proc/on_immobile_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILE), .proc/on_immobile_trait_loss)


///Called when TRAIT_KNOCKEDOUT is added to the mob.
/mob/living/proc/on_knockedout_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(stat < UNCONSCIOUS)
		set_stat(UNCONSCIOUS)

///Called when TRAIT_KNOCKEDOUT is removed from the mob.
/mob/living/proc/on_knockedout_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(stat < DEAD)
		update_stat()


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
	if(!can_crawl)
		set_canmove(FALSE)
		add_movespeed_modifier(MOVESPEED_ID_CRAWLING, TRUE, 0, NONE, TRUE, crawl_speed)

///Called when TRAIT_FLOORED is removed from the mob.
/mob/living/proc/on_floored_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(lying_angle)
		set_lying_angle(0)
	if(!can_crawl)
		set_canmove(TRUE)
		remove_movespeed_modifier(MOVESPEED_ID_CRAWLING)


///Called when TRAIT_LEGLESS is added to the mob.
/mob/living/proc/on_immobile_trait_gain(datum/source)
	SIGNAL_HANDLER
	set_canmove(FALSE)

///Called when TRAIT_LEGLESS is removed from the mob.
/mob/living/proc/on_immobile_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(src, TRAIT_FLOORED) || can_crawl)
		set_canmove(TRUE)
