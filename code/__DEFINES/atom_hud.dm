// for secHUDs and medHUDs and variants.
//The number is the location of the image on the list hud_list of humans.
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
#define HEALTH_HUD					"health_hud" // a simple line rounding the mob's number health
#define STATUS_HUD					"status_hud" // alive, dead, diseased, etc.
#define ID_HUD						"id_hud" // the job asigned to your ID
#define WANTED_HUD					"wanted_hud" // wanted, released, parroled, security status
#define IMPLOYAL_HUD				"loyalty_implant_hud" // loyality implant
#define IMPCHEM_HUD					"chemical_implant_hud" // chemical implant
#define IMPTRACK_HUD				"tracking_implant_hud" // tracking implant
#define SPECIALROLE_HUD				"antag_hud" // AntagHUD image
#define XENO_EMBRYO_HUD				"xeno_embryo_hud" // xeno larval stage.
#define HEALTH_HUD_XENO				"xeno_health_hud" //health HUD for xenos
#define SQUAD_HUD					"squad_hud" //squad hud showing who's leader, corpsman, etc for each squad.
#define PLASMA_HUD					"xeno_plasma_hud" //indicates the plasma level of xenos.
#define PHEROMONE_HUD				"xeno_pheromone_hud" //indicates which pheromone is active on a xeno.
#define QUEEN_OVERWATCH_HUD			"xeno_overwatch_hud" //indicates which xeno the queen is overwatching.
#define ORDER_HUD					"human_order_hud" //shows what orders are applied to marines
#define AI_DETECT_HUD				"ai_detect_hud" //hud for displaying the AI eye's location
#define PAIN_HUD					"pain_hud" //displays human pain / preceived health.

#define ADD_HUD_TO_COOLDOWN 20 //cooldown for being shown the images for any particular data hud

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1


//data HUD defines
#define DATA_HUD_SECURITY_BASIC		1
#define DATA_HUD_SECURITY_ADVANCED	2
#define DATA_HUD_MEDICAL_BASIC		3
#define DATA_HUD_MEDICAL_ADVANCED	4
#define DATA_HUD_MEDICAL_OBSERVER	5
#define DATA_HUD_XENO_INFECTION		6
#define DATA_HUD_XENO_STATUS		7
#define DATA_HUD_SQUAD				8
#define DATA_HUD_ORDER				9
#define DATA_HUD_AI_DETECT			10
#define DATA_HUD_MEDICAL_PAIN		11


// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_ORBIT "orbit"