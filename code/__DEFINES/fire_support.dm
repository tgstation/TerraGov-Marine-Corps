///Can this firesupport type be used
#define FIRESUPPORT_AVAILABLE (1<<0)

///Firemodes for Campaign gamemode
///GAU gun run
#define FIRESUPPORT_TYPE_GUN "gun"
///Rocket barrage
#define FIRESUPPORT_TYPE_ROCKETS "rockets"
///Cruise missile strike
#define FIRESUPPORT_TYPE_CRUISE_MISSILE "cruise_missile"
///Volkite gun run
#define FIRESUPPORT_TYPE_VOLKITE "volkite_campaign"
///SOM Incendiary rocket barrage
#define FIRESUPPORT_TYPE_SOM_INCEND_ROCKETS "som_incend_rockets_campaign"
///Mortar barrage
#define FIRESUPPORT_TYPE_HE_MORTAR "he_mortar"
///Incendiary mortar barrage
#define FIRESUPPORT_TYPE_INCENDIARY_MORTAR "incendiary_mortar"
///Smoke mortar barrage
#define FIRESUPPORT_TYPE_SMOKE_MORTAR "smoke_mortar"
///Acid smoke mortar barrage
#define FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR "acid_smoke_mortar"

//Noncampaign mode types
///Unlimited GAU for regular gamemodes
#define FIRESUPPORT_TYPE_GUN_UNLIMITED "gun_unlimited"
///Unlimited rocket barrage for regular gamemodes
#define FIRESUPPORT_TYPE_ROCKETS_UNLIMITED "rockets_unlimited"
///Unlimited cruise missile for regular gamemodes
#define FIRESUPPORT_TYPE_CRUISE_MISSILE_UNLIMITED "cruise_missile_unlimited"

///Assoc list of firesupport types
GLOBAL_LIST_INIT(fire_support_types, list(
	FIRESUPPORT_TYPE_GUN_UNLIMITED = new /datum/fire_support/gau/unlimited,
	FIRESUPPORT_TYPE_ROCKETS_UNLIMITED = new /datum/fire_support/rockets/unlimited,
	FIRESUPPORT_TYPE_CRUISE_MISSILE_UNLIMITED = new /datum/fire_support/cruise_missile/unlimited,
	FIRESUPPORT_TYPE_GUN = new /datum/fire_support/gau,
	FIRESUPPORT_TYPE_ROCKETS = new /datum/fire_support/rockets,
	FIRESUPPORT_TYPE_CRUISE_MISSILE = new /datum/fire_support/cruise_missile,
	FIRESUPPORT_TYPE_VOLKITE = new /datum/fire_support/volkite,
	FIRESUPPORT_TYPE_SOM_INCEND_ROCKETS = new /datum/fire_support/rockets/som_incendiary,
	FIRESUPPORT_TYPE_HE_MORTAR = new /datum/fire_support/mortar,
	FIRESUPPORT_TYPE_INCENDIARY_MORTAR = new /datum/fire_support/mortar/incendiary,
	FIRESUPPORT_TYPE_SMOKE_MORTAR = new /datum/fire_support/mortar/smoke,
	FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR = new /datum/fire_support/mortar/smoke/acid,
	))
