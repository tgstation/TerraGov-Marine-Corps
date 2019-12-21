/datum/component/stamina_behavior
	var/stamina_state = STAMINA_STATE_IDLE


/datum/component/stamina_behavior/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/stamina_holder = parent
	if(stamina_holder.m_intent == MOVE_INTENT_RUN)
		stamina_active()
	RegisterSignal(parent, COMSIG_MOB_TOGGLEMOVEINTENT, .proc/on_toggle_move_intent)


/datum/component/stamina_behavior/proc/on_toggle_move_intent(datum/source, new_intent)
	switch(new_intent)
		if(MOVE_INTENT_RUN)
			stamina_active()
		if(MOVE_INTENT_WALK)
			stamina_idle()


/datum/component/stamina_behavior/proc/stamina_active()
	if(stamina_state == STAMINA_STATE_ACTIVE)
		return
	stamina_state = STAMINA_STATE_ACTIVE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_move_run)
	RegisterSignal(parent, COMSIG_LIVING_SET_CANMOVE, .proc/on_canmove_change)


/datum/component/stamina_behavior/proc/stamina_idle()
	if(stamina_state == STAMINA_STATE_IDLE)
		return
	stamina_state = STAMINA_STATE_IDLE
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_CANMOVE))


/datum/component/stamina_behavior/proc/on_move_run(datum/source, atom/oldloc, direction, Forced)
	if(Forced)
		return
	var/mob/living/stamina_holder = parent
	if(oldloc == stamina_holder.loc)
		return
	stamina_holder.adjustStaminaLoss(1)
	if(stamina_holder.staminaloss >= 0)
		stamina_holder.toggle_move_intent(MOVE_INTENT_WALK)


/datum/component/stamina_behavior/proc/on_canmove_change(datum/source, canmove)
	var/mob/living/stamina_holder = parent
	if(canmove || stamina_holder.m_intent == MOVE_INTENT_WALK)
		return
	stamina_holder.toggle_move_intent(MOVE_INTENT_WALK)
