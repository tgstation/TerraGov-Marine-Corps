

/datum/component/automatedfire/gun
	var/fire_mode
	var/auto_fire_shot_delay
	var/auto_burstfire_shot_delay
	var/burstfire_shot_delay
	var/burst_shots_to_fire
	var/shots_fired = 0
	var/shooting = FALSE
	var/obj/item/weapon/gun/gun 

/datum/component/automatedfire/gun/Initialize(_auto_fire_shot_delay = 0.3 SECONDS, _auto_burstfire_shot_delay = 0.2 SECONDS, _burst_shots_to_fire = 3, _fire_mode = GUN_FIREMODE_SEMIAUTO, _burstfire_shot_delay)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	
	gun = parent

	RegisterSignal(parent, COMSIG_GUN_FIRE_MODE_TOGGLE, .proc/modify_fire_mode)
	RegisterSignal(parent, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, .proc/modify_fire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_AUTOBURST_SHOT_DELAY_MODIFIED, .proc/modify_auto_burstfire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, .proc/modify_burst_shots_to_fire)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, .proc/modify_burstfire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_FIRE, .proc/initiate_shot)
	RegisterSignal(parent, COMSIG_GUN_STOP_FIRE, .proc/stop_firing)
	
	auto_fire_shot_delay = _auto_fire_shot_delay
	auto_burstfire_shot_delay = _auto_burstfire_shot_delay
	burst_shots_to_fire = _burst_shots_to_fire
	fire_mode = _fire_mode
	burstfire_shot_delay = _burstfire_shot_delay

/datum/component/automatedfire/gun/proc/modify_fire_mode(datum/source, _fire_mode)
	SIGNAL_HANDLER
	fire_mode = _fire_mode

/datum/component/automatedfire/gun/proc/modify_fire_shot_delay(datum/source, _auto_fire_shot_delay)
	SIGNAL_HANDLER
	auto_fire_shot_delay = _auto_fire_shot_delay

/datum/component/automatedfire/gun/proc/modify_auto_burstfire_shot_delay(datum/source, _auto_burstfire_shot_delay)
	SIGNAL_HANDLER
	auto_burstfire_shot_delay = _auto_burstfire_shot_delay

/datum/component/automatedfire/gun/proc/modify_burst_shots_to_fire(datum/source, _burst_shots_to_fire)
	SIGNAL_HANDLER
	burst_shots_to_fire = _burst_shots_to_fire

/datum/component/automatedfire/gun/proc/modify_burstfire_shot_delay(datum/source, _burstfire_shot_delay)
	SIGNAL_HANDLER
	burstfire_shot_delay = _burstfire_shot_delay

/datum/component/automatedfire/gun/proc/initiate_shot()
	SIGNAL_HANDLER
	if(shooting)//if we are already shooting, it means the gun is still on cooldown
		return
	shooting = TRUE
	next_fire = world.time
	shots_fired = 0
	schedule_shot()

/datum/component/automatedfire/gun/proc/stop_firing()
	SIGNAL_HANDLER
	if(!shooting)
		return
	shooting = FALSE
	DISABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
	unschedule_shot()

/datum/component/automatedfire/gun/process_shot()
	if(!SEND_SIGNAL(parent, COMSIG_GUN_FIRED))
		return AUTOFIRE_STOPPED_SHOOTING
	switch(fire_mode)
		if(GUN_FIREMODE_BURSTFIRE)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				DISABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
				return AUTOFIRE_STOPPED_SHOOTING
			ENABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
			next_fire = world.time + min(shots_fired, 3) * burstfire_shot_delay
			return AUTOFIRE_STILL_SHOOTING
		if(GUN_FIREMODE_AUTOBURST)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				next_fire = world.time + auto_burstfire_shot_delay
				shots_fired = 0
				DISABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
			else
				ENABLE_BITFIELD(gun.flags_gun_features, GUN_BURST_FIRING)
				next_fire = world.time + min(shots_fired, 3) * burstfire_shot_delay
			return AUTOFIRE_STILL_SHOOTING
		if(GUN_FIREMODE_AUTOMATIC)
			next_fire = world.time + auto_fire_shot_delay
			return AUTOFIRE_STILL_SHOOTING
	return AUTOFIRE_STOPPED_SHOOTING
