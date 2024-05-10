///Can this firesupport type be used
#define FIRESUPPORT_AVAILABLE (1<<0)

//Firemodes for Campaign gamemode
///GAU gun run
#define FIRESUPPORT_TYPE_GUN "gun"
///Laser beam run
#define FIRESUPPORT_TYPE_LASER "laser"
///Rocket barrage
#define FIRESUPPORT_TYPE_ROCKETS "rockets"
///Cruise missile strike
#define FIRESUPPORT_TYPE_CRUISE_MISSILE "cruise_missile"
///Sentry drop pod
#define FIRESUPPORT_TYPE_SENTRY_POD "sentry_pod"
///Supply drop pod
#define FIRESUPPORT_TYPE_SUPPLY_POD "supply_pod"
///Volkite gun run
#define FIRESUPPORT_TYPE_VOLKITE "volkite_gun"
///SOM Incendiary rocket barrage
#define FIRESUPPORT_TYPE_INCEND_ROCKETS "incend_rockets"
///Radioactive missile
#define FIRESUPPORT_TYPE_RAD_MISSILE "rad_missile"
///HE Mortar barrage
#define FIRESUPPORT_TYPE_HE_MORTAR "he_mortar"
///Incendiary mortar barrage
#define FIRESUPPORT_TYPE_INCENDIARY_MORTAR "incendiary_mortar"
///Smoke mortar barrage
#define FIRESUPPORT_TYPE_SMOKE_MORTAR "smoke_mortar"
///Acid smoke mortar barrage
#define FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR "acid_smoke_mortar"
///SOM HE Mortar barrage
#define FIRESUPPORT_TYPE_HE_MORTAR_SOM "he_mortar_som"
///SOM Incendiary mortar barrage
#define FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM "incendiary_mortar_som"
///SOM Smoke mortar barrage
#define FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM "smoke_mortar_som"
///Satrapine smoke mortar barrage
#define FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR "satrapine_smoke_mortar"

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
	FIRESUPPORT_TYPE_LASER = new /datum/fire_support/laser,
	FIRESUPPORT_TYPE_ROCKETS = new /datum/fire_support/rockets,
	FIRESUPPORT_TYPE_CRUISE_MISSILE = new /datum/fire_support/cruise_missile,
	FIRESUPPORT_TYPE_SENTRY_POD = new /datum/fire_support/droppod,
	FIRESUPPORT_TYPE_SUPPLY_POD = new /datum/fire_support/droppod/supply,
	FIRESUPPORT_TYPE_VOLKITE = new /datum/fire_support/volkite,
	FIRESUPPORT_TYPE_INCEND_ROCKETS = new /datum/fire_support/incendiary_rockets,
	FIRESUPPORT_TYPE_RAD_MISSILE = new /datum/fire_support/rad_missile,
	FIRESUPPORT_TYPE_HE_MORTAR = new /datum/fire_support/mortar,
	FIRESUPPORT_TYPE_INCENDIARY_MORTAR = new /datum/fire_support/mortar/incendiary,
	FIRESUPPORT_TYPE_SMOKE_MORTAR = new /datum/fire_support/mortar/smoke,
	FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR = new /datum/fire_support/mortar/smoke/acid,
	FIRESUPPORT_TYPE_HE_MORTAR_SOM = new /datum/fire_support/mortar/som,
	FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM = new /datum/fire_support/mortar/incendiary/som,
	FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM = new /datum/fire_support/mortar/smoke/som,
	FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR = new /datum/fire_support/mortar/smoke/satrapine,
	))
