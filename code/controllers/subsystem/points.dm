// points per minute
#define DROPSHIP_POINT_RATE 18
#define SUPPLY_POINT_RATE 4

#define POINTS_PER_SLIP 1
#define POINTS_PER_CRATE 5
#define POINTS_PER_PLATINUM 5

SUBSYSTEM_DEF(points)
	name = "Points"

	priority = FIRE_PRIORITY_POINTS
	flags = SS_KEEP_TIMING | SS_NO_INIT | SS_NO_TICK_CHECK

	wait = 10 SECONDS

	var/dropship_points = 0
	var/supply_points = 120

/datum/controller/subsystem/points/fire(resumed = FALSE)
	dropship_points += DROPSHIP_POINT_RATE / (1 MINUTES / wait)

	supply_points += SUPPLY_POINT_RATE / (1 MINUTES / wait)

/datum/controller/subsystem/points/proc/scale_supply_points(scale)
	supply_points = round(supply_points * scale)
