

/datum/component/automatedfire/gun
	///The current fire mode of the gun
	var/fire_mode
	///Delay between two shot when in full auto
	var/auto_fire_shot_delay
	///Used to calculate the delay between two rounds of burst
	var/auto_burstfire_shot_delay
	///Delay between two burst shots
	var/burstfire_shot_delay
	///How many bullets are fired in burst mode
	var/burst_shots_to_fire
	///Count the shots fired when bursting
	var/shots_fired = 0
	///If the gun is currently shooting
	var/shooting = FALSE
	///If TRUE, the gun will reset its references at the end of the burst
	var/have_to_reset = FALSE
	///Reference to the parent
	var/obj/item/weapon/gun/gun 
	var/last_fire

/datum/component/automatedfire/gun/Initialize(_auto_fire_shot_delay = 0.3 SECONDS, _burstfire_shot_delay, _burst_shots_to_fire = 3, _fire_mode = GUN_FIREMODE_SEMIAUTO)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	
	gun = parent

	RegisterSignal(parent, COMSIG_GUN_FIRE_MODE_TOGGLE, .proc/modify_fire_mode)
	RegisterSignal(parent, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, .proc/modify_fire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, .proc/modify_burst_shots_to_fire)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, .proc/modify_burstfire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_FIRE, .proc/initiate_shot)
	RegisterSignal(parent, COMSIG_GUN_STOP_FIRE, .proc/stop_firing)
	RegisterSignal(parent, COMSIG_GUN_AUTO_FIRE_COMP_RESET, .proc/hard_reset)
	
	auto_fire_shot_delay = _auto_fire_shot_delay
	burstfire_shot_delay = _burstfire_shot_delay
	burst_shots_to_fire = _burst_shots_to_fire
	fire_mode = _fire_mode
	
///Setter for fire mode
/datum/component/automatedfire/gun/proc/modify_fire_mode(datum/source, _fire_mode)
	SIGNAL_HANDLER
	fire_mode = _fire_mode

///Setter for auto fire shot delay
/datum/component/automatedfire/gun/proc/modify_fire_shot_delay(datum/source, _auto_fire_shot_delay)
	SIGNAL_HANDLER
	auto_fire_shot_delay = _auto_fire_shot_delay

///Setter for the number of shot in a burst
/datum/component/automatedfire/gun/proc/modify_burst_shots_to_fire(datum/source, _burst_shots_to_fire)
	SIGNAL_HANDLER
	burst_shots_to_fire = _burst_shots_to_fire

///Setter for burst shot delay
/datum/component/automatedfire/gun/proc/modify_burstfire_shot_delay(datum/source, _burstfire_shot_delay)
	SIGNAL_HANDLER
	burstfire_shot_delay = _burstfire_shot_delay

///Insert the component in the bucket system if it was not in already
/datum/component/automatedfire/gun/proc/initiate_shot()
	SIGNAL_HANDLER
	if(shooting)//if we are already shooting, it means the gun is still on cooldown
		return
	shooting = TRUE
	next_fire = world.time
	shots_fired = 0
	auto_burstfire_shot_delay = 0
	schedule_shot()

///Remove the component from the bucket system if it was in
/datum/component/automatedfire/gun/proc/stop_firing()
	SIGNAL_HANDLER
	if(!shooting)
		return
	if(CHECK_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING))
		have_to_reset = TRUE
		return
	shooting = FALSE
	unschedule_shot()

///Hard reset the autofire, so it can be used again in situation where it would be stuck
/datum/component/automatedfire/gun/proc/hard_reset()
	SIGNAL_HANDLER
	shots_fired = 0
	auto_burstfire_shot_delay = 0
	have_to_reset = FALSE
	DISABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
	if(shooting)
		unschedule_shot()
		shooting = FALSE

///Ask the gun to fire and schedule the next shot if need
/datum/component/automatedfire/gun/process_shot()
	if(!SEND_SIGNAL(parent, COMSIG_GUN_MUST_FIRE) & GUN_HAS_FIRED)
		return
	if(last_fire)
		if((world.time -last_fire) != auto_fire_shot_delay)
			message_admins("mistake [world.time -last_fire - auto_fire_shot_delay]")
	last_fire = 0
	switch(fire_mode)
		if(GUN_FIREMODE_BURSTFIRE)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				DISABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
				gun.extra_delay = auto_fire_shot_delay * 1.5
				if(have_to_reset)//We failed to reset because we were bursting, we do it now
					SEND_SIGNAL(gun, COMSIG_GUN_FIRE_RESET)
					shooting = FALSE
				return
			ENABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
			next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOBURST)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				next_fire = world.time + auto_burstfire_shot_delay
				shots_fired = 0
				auto_burstfire_shot_delay = 0
				DISABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
				if(have_to_reset)//We failed to reset because we were bursting, we do it now
					SEND_SIGNAL(gun, COMSIG_GUN_FIRE_RESET)
					shooting = FALSE
			else
				ENABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
				auto_burstfire_shot_delay = min(auto_burstfire_shot_delay+(burstfire_shot_delay*2), auto_fire_shot_delay*3)
				next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOMATIC)
			next_fire = world.time + auto_fire_shot_delay
		if(GUN_FIREMODE_SEMIAUTO)
			return
	last_fire = world.time
	schedule_shot()
