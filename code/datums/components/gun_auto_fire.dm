

/datum/component/automatedfire/gun
	var/fire_mode
	var/fire_shot_delay
	var/burstfire_shot_delay
	var/burst_shots_to_fire

/datum/component/automatedfire/gun/Initialize(_fire_shot_delay = 0.3 SECONDS, _burstfire_shot_delay = 0.2 SECONDS, _burst_shots_to_fire = 3, _fire_mode = GUN_FIREMODE_SEMIAUTO)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	
	RegisterSignal(parent, COMSIG_GUN_FIRE_MODE_TOGGLE, .proc/modify_fire_mode)
	RegisterSignal(parent, COMSIG_GUN_FIREDELAY_MODIFIED, .proc/modify_fire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, .proc/modify_burstfire_shot_delay)
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, .proc/modify_burst_shots_to_fire)
	RegisterSignal(parent, COMSIG_GUN_FIRE, .proc/initate_fire)
	RegisterSignal(parent, COMSIG_GUN_STOP_FIRE, .proc/stop_fire)
	
	fire_shot_delay = _fire_shot_delay
	burstfire_shot_delay = _burstfire_shot_delay
	burst_shots_to_fire = _burst_shots_to_fire
	fire_mode = _fire_mode

/datum/component/automatedfire/gun/proc/modify_fire_mode(datum/source, _fire_mode)
	SIGNAL_HANDLER
	fire_mode = _fire_mode

/datum/component/automatedfire/gun/proc/modify_fire_shot_delay(datum/source, _fire_shot_delay)
	SIGNAL_HANDLER
	fire_shot_delay = _fire_shot_delay

/datum/component/automatedfire/gun/proc/modify_burstfire_shot_delay(datum/source, _burstfire_shot_delay)
	SIGNAL_HANDLER
	burstfire_shot_delay = _burstfire_shot_delay

/datum/component/automatedfire/gun/proc/modify_burst_shots_to_fire(datum/source, _burst_shots_to_fire)
	SIGNAL_HANDLER
	burst_shots_to_fire = _burst_shots_to_fire