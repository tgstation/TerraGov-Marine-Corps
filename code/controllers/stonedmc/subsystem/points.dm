// points per minute
#define DROPSHIP_POINT_RATE 18
#define SUPPLY_POINT_RATE 4

SUBSYSTEM_DEF(points)
	name = "Points"

	priority = FIRE_PRIORITY_POINTS
	flags = SS_KEEP_TIMING | SS_NO_INIT | SS_NO_TICK_CHECK

	wait = 10

	var/dropship_points = 0

/datum/controller/subsystem/points/fire(resumed = FALSE)
	dropship_points += DROPSHIP_POINT_RATE / 60

	if(supply_controller)
		supply_controller.points += SUPPLY_POINT_RATE / 60
