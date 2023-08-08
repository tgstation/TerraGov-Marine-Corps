#define FIRESUPPORT_AVAILABLE (1<<0)

#define FIRESUPPORT_TYPE_GUN "gun"
#define FIRESUPPORT_TYPE_ROCKETS "rockets"
#define FIRESUPPORT_TYPE_CRUISE_MISSILE "cruise_missile"

#define FIRESUPPORT_TYPE_GUN_CAMPAIGN "gun_campaign"
#define FIRESUPPORT_TYPE_ROCKETS_CAMPAIGN "rockets_campaign"
#define FIRESUPPORT_TYPE_CRUISE_MISSILE_CAMPAIGN "cruise_missile_campaign"

GLOBAL_LIST_INIT(fire_support_types, list(
	FIRESUPPORT_TYPE_GUN = new /datum/fire_support/gau,
	FIRESUPPORT_TYPE_ROCKETS = new /datum/fire_support/rockets,
	FIRESUPPORT_TYPE_CRUISE_MISSILE = new /datum/fire_support/cruise_missile,
	FIRESUPPORT_TYPE_GUN_CAMPAIGN = new /datum/fire_support/gau/campaign,
	FIRESUPPORT_TYPE_ROCKETS_CAMPAIGN = new /datum/fire_support/rockets/campaign,
	FIRESUPPORT_TYPE_CRUISE_MISSILE_CAMPAIGN = new /datum/fire_support/cruise_missile/campaign,
	))
