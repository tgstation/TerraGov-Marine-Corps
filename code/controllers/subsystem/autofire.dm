TIMER_SUBSYSTEM_DEF(automatedfire)
	name = "Automated fire"
	priority = FIRE_PRIORITY_AUTOFIRE

/datum/component/automatedfire
	///The owner of this component
	var/atom/shooter
	///Next shot timer ID
	var/shot_timer = null

///Handle the firing of the autofire component
/datum/component/automatedfire/proc/process_shot()
	return

/obj/structure/turret_debug
	name = "debug turret"
	///What kind of ammo it uses
	var/datum/ammo/ammo
	///Its target
	var/atom/target
	///At wich rate it fires in ticks
	var/firerate = 5.5

/obj/structure/turret_debug/fast
	name = "debug turret fast"
	firerate = 1

/obj/structure/turret_debug/super_fast
	name = "debug turret super fast"
	firerate = 0.5

/obj/structure/turret_debug/slow
	name = "debug turret slow"
	firerate = 25

/obj/structure/turret_debug/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/xeno/acid]
	target = locate(x+5, y, z)
	AddComponent(/datum/component/automatedfire/xeno_turret_autofire, firerate)
	RegisterSignal(src, COMSIG_AUTOMATIC_SHOOTER_SHOOT, .proc/shoot)
	SEND_SIGNAL(src, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT)
	var/static/number = 1
	name = "[name] [number]"
	number++

///Create the projectile
/obj/structure/turret_debug/proc/shoot()
	SIGNAL_HANDLER
	var/obj/projectile/newshot = new(loc)
	newshot.generate_bullet(ammo)
	newshot.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)

/datum/component/automatedfire/xeno_turret_autofire
	///Delay between two shots
	var/shot_delay
	///If we must shoot
	var/shooting = FALSE

/datum/component/automatedfire/xeno_turret_autofire/Initialize(_shot_delay)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	shot_delay = _shot_delay
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_START_SHOOTING_AT, .proc/start_shooting)
	RegisterSignal(parent, COMSIG_AUTOMATIC_SHOOTER_STOP_SHOOTING_AT, .proc/stop_shooting)

///Signal handler for starting the autoshooting at something
/datum/component/automatedfire/xeno_turret_autofire/proc/start_shooting(datum/source)
	SIGNAL_HANDLER
	if(!shooting)
		shooting = TRUE
		INVOKE_ASYNC(src, .proc/process_shot)


///Signal handler for stoping the shooting
/datum/component/automatedfire/xeno_turret_autofire/proc/stop_shooting(datum/source)
	SIGNAL_HANDLER
	shooting = FALSE

/datum/component/automatedfire/xeno_turret_autofire/process_shot()
	//We check if the parent is not null, because the component could be scheduled to fire and then the turret is destroyed
	if(!shooting || !parent)
		return
	SEND_SIGNAL(parent, COMSIG_AUTOMATIC_SHOOTER_SHOOT)
	shot_timer = addtimer(CALLBACK(src, .proc/process_shot), shot_delay, TIMER_DELETE_ME|TIMER_STOPPABLE, SSautomatedfire)
