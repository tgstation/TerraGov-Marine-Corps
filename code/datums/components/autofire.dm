/datum/component/automatedfire/autofire
	///The current fire mode of the shooter
	var/fire_mode
	///Delay between two shot when in full auto
	var/auto_fire_shot_delay
	///Delay between two burst shots
	var/burstfire_shot_delay
	///How many bullets are fired in burst mode
	var/burst_shots_to_fire
	///Count the shots fired when bursting
	var/shots_fired = 0
	///If the shooter is currently shooting
	var/shooting = FALSE
	///If TRUE, the shooter will reset its references at the end of the burst
	var/have_to_reset = FALSE
	///If we are in a burst
	var/bursting = FALSE

/datum/component/automatedfire/autofire/Initialize(_auto_fire_shot_delay = 0.3 SECONDS, _burstfire_shot_delay, _burst_shots_to_fire = 3, _fire_mode = GUN_FIREMODE_SEMIAUTO)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_GUN_FIRE_MODE_TOGGLE, .proc/modify_fire_mode)
	RegisterSignal(parent, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, .proc/modify_fire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, .proc/modify_burst_shots_to_fire)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, .proc/modify_burstfire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_FIRE, .proc/initiate_shot)
	RegisterSignal(parent, COMSIG_GUN_STOP_FIRE, .proc/stop_firing)
	
	auto_fire_shot_delay = _auto_fire_shot_delay
	burstfire_shot_delay = _burstfire_shot_delay
	burst_shots_to_fire = _burst_shots_to_fire
	fire_mode = _fire_mode
	
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

///Insert the component in the bucket system if it was not in already
/datum/component/automatedfire/autofire/proc/initiate_shot()
	SIGNAL_HANDLER
	if(shooting)//if we are already shooting, it means the shooter is still on cooldown
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
		have_to_reset = TRUE
		return
	shooting = FALSE
	shots_fired = 0

///Hard reset the autofire, happens when the shooter fall/is thrown, at the end of a burst or when it runs out of ammunition
/datum/component/automatedfire/autofire/proc/hard_reset()
	shots_fired = 0
	have_to_reset = FALSE
	if(bursting)
		bursting = FALSE
		SEND_SIGNAL(parent, COMSIG_GUN_SET_BURSTING, FALSE)
	if(shooting)
		shooting = FALSE

///Ask the shooter to fire and schedule the next shot if need
/datum/component/automatedfire/autofire/process_shot()
	if(!shooting)
		return
	if(!SEND_SIGNAL(parent, COMSIG_GUN_MUST_FIRE) & GUN_HAS_FIRED)
		hard_reset()
		return
	switch(fire_mode)
		if(GUN_FIREMODE_BURSTFIRE)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				SEND_SIGNAL(parent, COMSIG_GUN_SET_BURSTING, FALSE)
				bursting = FALSE
				stop_firing()
				if(have_to_reset)//We failed to reset because we were bursting, we do it now
					SEND_SIGNAL(parent, COMSIG_GUN_FIRE_RESET)
				return
			SEND_SIGNAL(parent, COMSIG_GUN_SET_BURSTING, TRUE)
			bursting = TRUE
			next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOBURST)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				next_fire = world.time + 3 * auto_fire_shot_delay
				shots_fired = 0
				SEND_SIGNAL(parent, COMSIG_GUN_SET_BURSTING, FALSE)
				bursting = FALSE
				if(have_to_reset)//We failed to reset because we were bursting, we do it now
					SEND_SIGNAL(parent, COMSIG_GUN_FIRE_RESET)
					stop_firing()
			else
				SEND_SIGNAL(parent, COMSIG_GUN_SET_BURSTING, TRUE)
				bursting = TRUE
				next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOMATIC)
			next_fire = world.time + auto_fire_shot_delay
		if(GUN_FIREMODE_SEMIAUTO)
			return
	schedule_shot()
