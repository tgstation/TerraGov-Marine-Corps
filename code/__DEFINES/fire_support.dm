#define FIRESUPPORT_TYPE_GUN "gun"
#define FIRESUPPORT_TYPE_ROCKETS "rockets"
#define FIRESUPPORT_TYPE_CRUISE_MISSILE "cruise_missile"

GLOBAL_LIST_INIT(fire_support_types, list(
	FIRESUPPORT_TYPE_GUN = new /datum/fire_support/gau,
	FIRESUPPORT_TYPE_ROCKETS = new /datum/fire_support/rockets,
	FIRESUPPORT_TYPE_CRUISE_MISSILE = new /datum/fire_support/cruise_missile,
	))
