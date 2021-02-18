/datum/component/automatedfire/automatic_shoot_at
	///The target we are shooting at
	var/atom/target
	///The ammo we are shooting
	var/datum/ammo/ammo
	///The delay between each shot in ticks
	var/shot_delay = 5
	///The timer used to regulate the shot
	var/shot_delay_timer
	///If we are shooting
	var/shooting = FALSE

/datum/component/automatedfire/automatic_shoot_at/Initialize(_shot_delay, _ammo)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	shooter = parent
	shot_delay = _shot_delay
	ammo = _ammo
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT, .proc/start_shooting)
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT, .proc/stop_shooting)

///Signal handler for starting the autoshooting at something
/datum/component/automatedfire/automatic_shoot_at/proc/start_shooting(datum/source, _target)
	SIGNAL_HANDLER
	target = _target
	next_fire = world.time
	if(!shooting)
		shooting = TRUE
		schedule()


///Signal handler for stoping the shooting
/datum/component/automatedfire/automatic_shoot_at/proc/stop_shooting(datum/source)
	SIGNAL_HANDLER
	target = null
	shooting = FALSE

/datum/component/automatedfire/automatic_shoot_at/process_shot()
	if(!shooting)
		return AUTOFIRE_STOPPED_SHOOTING
	var/obj/projectile/newspit = new(shooter.loc)
	newspit.generate_bullet(ammo)
	newspit.permutated += shooter
	newspit.fire_at(target, shooter, null, ammo.max_range, ammo.shell_speed)
	SEND_SIGNAL(shooter, COMSIG_AUTOMATIC_SHOOTER_SHOT_FIRED)
	next_fire = world.time + shot_delay
	return AUTOFIRE_STILL_SHOOTING
