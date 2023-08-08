///Can this firesupport type be used
#define FIRESUPPORT_AVAILABLE (1<<0)

///GAU gun run
#define FIRESUPPORT_TYPE_GUN "gun"
///Rocket barrage
#define FIRESUPPORT_TYPE_ROCKETS "rockets"
///Cruise missile strike
#define FIRESUPPORT_TYPE_CRUISE_MISSILE "cruise_missile"
///Use limited GAU for campaign mode
#define FIRESUPPORT_TYPE_GUN_CAMPAIGN "gun_campaign"
///Use limited rocket barrage for campaign mode
#define FIRESUPPORT_TYPE_ROCKETS_CAMPAIGN "rockets_campaign"
///Use limited cruise missile for campaign mode
#define FIRESUPPORT_TYPE_CRUISE_MISSILE_CAMPAIGN "cruise_missile_campaign"
///Use limited volkite gun run for campaign mode
#define FIRESUPPORT_TYPE_VOLKITE_CAMPAIGN "volkite_campaign"
///Use limited incendiary rocket barrage for campaign mode
#define FIRESUPPORT_TYPE_SOM_INCEND_ROCKETS_CAMPAIGN "som_incend_rockets_campaign"

///Assoc list of firesupport types
GLOBAL_LIST_INIT(fire_support_types, list(
	FIRESUPPORT_TYPE_GUN = new /datum/fire_support/gau,
	FIRESUPPORT_TYPE_ROCKETS = new /datum/fire_support/rockets,
	FIRESUPPORT_TYPE_CRUISE_MISSILE = new /datum/fire_support/cruise_missile,
	FIRESUPPORT_TYPE_GUN_CAMPAIGN = new /datum/fire_support/gau/campaign,
	FIRESUPPORT_TYPE_ROCKETS_CAMPAIGN = new /datum/fire_support/rockets/campaign,
	FIRESUPPORT_TYPE_CRUISE_MISSILE_CAMPAIGN = new /datum/fire_support/cruise_missile/campaign,
	FIRESUPPORT_TYPE_VOLKITE_CAMPAIGN = new /datum/fire_support/volkite,
	FIRESUPPORT_TYPE_SOM_INCEND_ROCKETS_CAMPAIGN = new /datum/fire_support/rockets/som_incendiary,
	))
