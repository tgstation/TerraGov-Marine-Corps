#define BULLET_PING_DURATION 3 //ticks
#define BULLET_PING_PROBABILITY 65

/**
 * # Bullet Ping Subsystem
 *
 * Maintains a timer-like system except simplified to become a tick number rotating two dimensional buffer
 * containing the current and previous ticks bullet pings.
 */
SUBSYSTEM_DEF(bullet_ping)
	name = "Bullet ping"
	priority = FIRE_PRIORITY_BULLET_PINGS
	wait = 1 // Rotates the ping buffer every tick.
	flags = SS_TICKER

	///Two dimensional list of ping overlays. Index: Modulo world.time + 1.
	var/list/list/datum/bullet_ping/overlays = list()
	///Index number of overlays calculated from world time.
	var/current_index = 1

/datum/bullet_ping
	///Atom that the bullet ping will display over.
	var/atom/parent
	///Image of the bullet ping overlay to be displayed.
	var/image/ping

/datum/controller/subsystem/bullet_ping/Initialize()
	initialized = TRUE
	for(var/i = 0, i < BULLET_PING_DURATION, i++)
		// Initializing empty buffers for all ticks possible.
		overlays += list(list())

/datum/controller/subsystem/bullet_ping/stat_entry()
	var/builder = ""
	var/sum = 0
	for(var/i = 1, i <= BULLET_PING_DURATION, i++)
		sum += overlays[i].len
		builder += "[i]: [overlays[i].len] || "
	..("[builder]T:[sum]")

/datum/controller/subsystem/bullet_ping/Recover()
	overlays = SSbullet_ping.overlays

/datum/controller/subsystem/bullet_ping/fire()
	// Updating current index.
	current_index = world.time % BULLET_PING_DURATION + 1
	// Clear current list of overlays.
	for(var/datum/bullet_ping/overlay AS in overlays[current_index])
		overlay.parent.cut_overlay(overlay.ping)
		if(MC_TICK_CHECK)
			return

///Calculates probability of bullet ping appearing and generates a ping overlay for it.
/datum/controller/subsystem/bullet_ping/proc/generate(atom/source, obj/projectile/P)
	if(!P.ammo.ping)
		return
	if(!prob(BULLET_PING_PROBABILITY))
		return
	if(P.ammo.sound_bounce)
		playsound(src, P.ammo.sound_bounce, 50, 1)
	var/image/I = image('icons/obj/items/projectiles.dmi', source, P.ammo.ping, 10)
	var/angle = !isnull(P.dir_angle) ? P.dir_angle : round(Get_Angle(P.starting_turf, src), 1)
	if(prob(60))
		angle += rand(-angle, 360 - angle)
	I.pixel_x += rand(-6,6)
	I.pixel_y += rand(-6,6)

	var/matrix/rotate = matrix()
	rotate.Turn(angle)
	I.transform = rotate
	source.add_overlay(I)
	var/datum/bullet_ping/overlay = new
	overlay.parent = source
	overlay.ping = I
	overlays[current_index] += overlay

#undef BULLET_PING_DURATION
#undef BULLET_PING_PROBABILITY
