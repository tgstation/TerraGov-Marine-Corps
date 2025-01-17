/datum/component/stamina_behavior
	var/stamina_state = STAMINA_STATE_IDLE
	///multiplier on stamina cost due to gravity
	var/drain_modifier = 1
	///extra modifier for handling elfs
	var/stim_drain_modifier = 1


/datum/component/stamina_behavior/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/stamina_holder = parent
	if(stamina_holder.m_intent == MOVE_INTENT_RUN)
		stamina_active()
	drain_modifier = stamina_holder.get_gravity()
	RegisterSignal(parent, COMSIG_MOB_TOGGLEMOVEINTENT, PROC_REF(on_toggle_move_intent))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_change_z))

/datum/component/stamina_behavior/proc/on_toggle_move_intent(datum/source, new_intent)
	SIGNAL_HANDLER
	switch(new_intent)
		if(MOVE_INTENT_RUN)
			stamina_active()
		if(MOVE_INTENT_WALK)
			stamina_idle()


/datum/component/stamina_behavior/proc/stamina_active()
	if(stamina_state == STAMINA_STATE_ACTIVE)
		return
	stamina_state = STAMINA_STATE_ACTIVE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move_run))
	RegisterSignal(parent, COMSIG_LIVING_SET_CANMOVE, PROC_REF(on_canmove_change))


/datum/component/stamina_behavior/proc/stamina_idle()
	if(stamina_state == STAMINA_STATE_IDLE)
		return
	stamina_state = STAMINA_STATE_IDLE
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_CANMOVE))


/datum/component/stamina_behavior/proc/on_move_run(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER
	if(Forced)
		return
	var/mob/living/stamina_holder = parent
	if(oldloc == stamina_holder.loc)
		return
	stamina_holder.adjustStaminaLoss(1 * drain_modifier * stim_drain_modifier)
	if(stamina_holder.staminaloss >= 0)
		stamina_holder.toggle_move_intent(MOVE_INTENT_WALK)


/datum/component/stamina_behavior/proc/on_canmove_change(datum/source, canmove)
	SIGNAL_HANDLER
	var/mob/living/stamina_holder = parent
	if(canmove || stamina_holder.m_intent == MOVE_INTENT_WALK)
		return
	stamina_holder.toggle_move_intent(MOVE_INTENT_WALK)

///changes the drain modifier if gravity changes
/datum/component/stamina_behavior/proc/on_change_z(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	var/mob/living/stamina_holder = parent
	drain_modifier = stamina_holder.get_gravity()
