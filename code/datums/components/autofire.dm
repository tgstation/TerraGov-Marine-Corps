/datum/component/automatedfire/autofire
	///The current fire mode of the shooter
	var/fire_mode
	///Delay between two shots when in full auto
	var/auto_fire_shot_delay
	///Delay between two burst shots
	var/burstfire_shot_delay
	///Delay between two volley of burst
	var/auto_burst_fire_shot_delay
	///How many bullets are fired in burst mode
	var/burst_shots_to_fire
	///Count the shots fired when bursting
	var/shots_fired = 0
	///If the shooter is currently shooting
	var/shooting = FALSE
	///If TRUE, the shooter will reset its references at the end of the burst
	var/have_to_reset_at_burst_end = FALSE
	///If we are in a burst
	var/bursting = FALSE
	///Callback to set bursting mode on the parent
	var/datum/callback/callback_bursting
	///Callback to ask the parent to reset its firing vars
	var/datum/callback/callback_reset_fire
	///Callback to ask the parent to fire
	var/datum/callback/callback_fire

/datum/component/automatedfire/autofire/Initialize(_auto_fire_shot_delay = 0.3 SECONDS, _auto_burst_fire_shot_delay, _burstfire_shot_delay, _burst_shots_to_fire = 3, _fire_mode = GUN_FIREMODE_SEMIAUTO, datum/callback/_callback_bursting, datum/callback/_callback_reset_fire, datum/callback/_callback_fire)
	. = ..()

	RegisterSignal(parent, COMSIG_GUN_FIRE_MODE_TOGGLE, PROC_REF(modify_fire_mode))
	RegisterSignals(parent, list(COMSIG_GUN_AUTOFIREDELAY_MODIFIED, COMSIG_XENO_AUTOFIREDELAY_MODIFIED), PROC_REF(modify_fire_shot_delay))
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, PROC_REF(modify_burst_shots_to_fire))
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, PROC_REF(modify_burstfire_shot_delay))
	RegisterSignal(parent, COMSIG_GUN_AUTO_BURST_SHOT_DELAY_MODIFIED, PROC_REF(modify_autoburstfire_shot_delay))
	RegisterSignals(parent, list(COMSIG_GUN_FIRE, COMSIG_XENO_FIRE, COMSIG_MECH_FIRE), PROC_REF(initiate_shot))
	RegisterSignals(parent, list(COMSIG_GUN_STOP_FIRE, COMSIG_XENO_STOP_FIRE, COMSIG_MECH_STOP_FIRE), PROC_REF(stop_firing))

	auto_fire_shot_delay = _auto_fire_shot_delay
	burstfire_shot_delay = _burstfire_shot_delay
	burst_shots_to_fire = _burst_shots_to_fire
	auto_burst_fire_shot_delay = _auto_burst_fire_shot_delay
	fire_mode = _fire_mode
	callback_bursting = _callback_bursting
	callback_reset_fire = _callback_reset_fire
	callback_fire = _callback_fire

/datum/component/automatedfire/autofire/Destroy(force, silent)
	callback_fire = null
	callback_reset_fire = null
	callback_bursting = null
	return ..()

///Setter for fire mode
/datum/component/automatedfire/autofire/proc/modify_fire_mode(datum/source, _fire_mode)
	SIGNAL_HANDLER
	fire_mode = _fire_mode

///Setter for auto fire shot delay
/datum/component/automatedfire/autofire/proc/modify_fire_shot_delay(datum/source, _auto_fire_shot_delay)
	SIGNAL_HANDLER
	auto_fire_shot_delay = _auto_fire_shot_delay

///Setter for the number of shot in a burst
/datum/component/automatedfire/autofire/proc/modify_burst_shots_to_fire(datum/source, _burst_shots_to_fire)
	SIGNAL_HANDLER
	burst_shots_to_fire = _burst_shots_to_fire

///Setter for burst shot delay
/datum/component/automatedfire/autofire/proc/modify_burstfire_shot_delay(datum/source, _burstfire_shot_delay)
	SIGNAL_HANDLER
	burstfire_shot_delay = _burstfire_shot_delay

///Setter for autoburst shot delay
/datum/component/automatedfire/autofire/proc/modify_autoburstfire_shot_delay(datum/source, _auto_burst_fire_shot_delay)
	SIGNAL_HANDLER
	auto_burst_fire_shot_delay = _auto_burst_fire_shot_delay

///Insert the component in the bucket system if it was not in already
/datum/component/automatedfire/autofire/proc/initiate_shot()
	SIGNAL_HANDLER
	if(shooting)//if we are already shooting, it means the shooter is still on cooldown
		if(bursting) //something went wrong due to lag
			hard_reset()
		return
	shooting = TRUE
	process_shot()

///Remove the component from the bucket system if it was in
/datum/component/automatedfire/autofire/proc/stop_firing()
	SIGNAL_HANDLER
	if(!shooting)
		return
	///We are burst firing, we can't clean the state now. We will do it when the burst is over
	if(bursting)
		have_to_reset_at_burst_end = TRUE
		return
	shooting = FALSE
	shots_fired = 0

///Hard reset the autofire, happens when the shooter fall/is thrown, at the end of a burst or when it runs out of ammunition
/datum/component/automatedfire/autofire/proc/hard_reset()
	callback_reset_fire.Invoke() //resets the gun
	shots_fired = 0
	have_to_reset_at_burst_end = FALSE
	if(bursting)
		bursting = FALSE
		callback_bursting.Invoke(FALSE)
	shooting = FALSE

///Ask the shooter to fire and schedule the next shot if need
/datum/component/automatedfire/autofire/process_shot()
	if(!shooting)
		return
	if(next_fire > world.time)//This mean duplication somewhere, we abort now
		return
	if(!(callback_fire.Invoke() & AUTOFIRE_CONTINUE))//reset fire if we want to stop
		hard_reset()
		return
	switch(fire_mode)
		if(GUN_FIREMODE_BURSTFIRE)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				callback_bursting.Invoke(FALSE)
				bursting = FALSE
				stop_firing()
				if(have_to_reset_at_burst_end)//We failed to reset because we were bursting, we do it now
					callback_reset_fire.Invoke()
					have_to_reset_at_burst_end = FALSE
				return
			callback_bursting.Invoke(TRUE)
			bursting = TRUE
			next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOBURST)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				next_fire = world.time + auto_burst_fire_shot_delay
				shots_fired = 0
				callback_bursting.Invoke(FALSE)
				bursting = FALSE
				if(have_to_reset_at_burst_end)//We failed to reset because we were bursting, we do it now
					callback_reset_fire.Invoke()
					stop_firing()
					have_to_reset_at_burst_end = FALSE
			else
				callback_bursting.Invoke(TRUE)
				bursting = TRUE
				next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOMATIC)
			next_fire = world.time + auto_fire_shot_delay
		if(GUN_FIREMODE_SEMIAUTO)
			return
	schedule_shot()
