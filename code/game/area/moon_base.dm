#define INSIDE_OPEN "inside open"
#define CYCLE_TO_OUTSIDE "cycling to outside"
#define OUTSIDE_OPEN "outside open"
#define CYCLE_TO_INSIDE	"cycling to inside"

/area/moon_base/outside
	name = "Moon surface"
	gas_type = GAS_TYPE_PSEUDO_VACUUM
	pressure = MOON_SURFACE
	icon_state = "moonsurface"

/area/moon_base/inside
	gas_type = GAS_TYPE_AIR
	pressure = ONE_ATMOSPHERE

/area/moon_base/inside/atc
	name = "Air Traffic Control"
	icon_state = "atc"

/area/moon_base/inside/nexus
	name = "Nexus"
	icon_state = "nexus"

/area/moon_base/airlock
	gas_type = GAS_TYPE_AIR
	pressure = ONE_ATMOSPHERE
	var/state = INSIDE_OPEN
	icon_state = "airlockone"

/area/moon_base/airlock/Initialize(mapload, ...)
	. = ..()
	RegisterSignal(src, COMSIG_AIRLOCK_REQUEST_CYCLE, .proc/cycle)

/area/moon_base/airlock/proc/cycle()
	switch(state)
		if(CYCLE_TO_OUTSIDE, CYCLE_TO_INSIDE)
			return
		if(INSIDE_OPEN)
			state = CYCLE_TO_OUTSIDE
			SEND_SIGNAL(src, COMSIG_AIRLOCK_CYCLE_TO_OUT)
			addtimer(CALLBACK(src, .proc/finish_cycle), 3 SECONDS)
		if(OUTSIDE_OPEN)
			state = CYCLE_TO_INSIDE
			SEND_SIGNAL(src, COMSIG_AIRLOCK_CYCLE_TO_IN)
			addtimer(CALLBACK(src, .proc/finish_cycle), 3 SECONDS)

/area/moon_base/airlock/proc/finish_cycle()
	switch(state)
		if(CYCLE_TO_OUTSIDE)
			state = OUTSIDE_OPEN
			gas_type = GAS_TYPE_PSEUDO_VACUUM
			pressure = MOON_SURFACE
			SEND_SIGNAL(src, COMSIG_AIRLOCK_FINISH_CYCLE_TO_OUT)
		if(CYCLE_TO_INSIDE)
			state = INSIDE_OPEN
			gas_type = GAS_TYPE_AIR
			pressure = ONE_ATMOSPHERE
			SEND_SIGNAL(src, COMSIG_AIRLOCK_FINISH_CYCLE_TO_IN)

/area/moon_base/airlock/one
	name = "Airlock One"
	icon_state = "airlockone"

/area/moon_base/airlock/atcnorth
	name = "ATC North Airlock"

/area/moon_base/airlock/atcsouth
	name = "ATC South Airlock"

/area/moon_base/airlock/nexuswest
	name = "Nexus West Airlock"

/area/moon_base/airlock/nexussouth
	name = "Nexus South Airlock"

/area/moon_base/airlock/nexusnorth
	name = "Nexus North Airlock"

/obj/machinery/door/airlock/moon
	var/side = "inside"

/obj/machinery/door/airlock/moon/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(side == "inside")
		open_cycle()
		RegisterSignal(A, COMSIG_AIRLOCK_CYCLE_TO_OUT, .proc/close_cycle)
		RegisterSignal(A, COMSIG_AIRLOCK_FINISH_CYCLE_TO_IN, .proc/open_cycle)
	if(side == "outside")
		close_cycle()
		RegisterSignal(A, COMSIG_AIRLOCK_CYCLE_TO_IN, .proc/close_cycle)
		RegisterSignal(A, COMSIG_AIRLOCK_FINISH_CYCLE_TO_OUT, .proc/open_cycle)

/obj/machinery/door/airlock/moon/proc/close_cycle()
	unlock()
	close()
	lock()

/obj/machinery/door/airlock/moon/proc/open_cycle()
	unlock()
	open()
	lock()

/obj/machinery/door/airlock/moon/attack_hand(mob/living/user)
	if(density)
		var/area/A = get_area(src)
		SEND_SIGNAL(A, COMSIG_AIRLOCK_REQUEST_CYCLE)
	return ..()

/obj/machinery/door/airlock/moon/outside
	side = "outside"

