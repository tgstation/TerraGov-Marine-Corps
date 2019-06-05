// for secHUDs and medHUDs and variants.
//The number is the location of the image on the list hud_list of humans.
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists
#define HEALTH_HUD			"1" // a simple line rounding the mob's number health
#define STATUS_HUD			"2" // alive, dead, diseased, etc.
#define ID_HUD				"3" // the job asigned to your ID
#define WANTED_HUD			"4" // wanted, released, parroled, security status
#define IMPLOYAL_HUD		"5" // loyality implant
#define IMPCHEM_HUD			"6" // chemical implant
#define IMPTRACK_HUD		"7" // tracking implant
#define SPECIALROLE_HUD 	"8" // AntagHUD image
#define STATUS_HUD_OOC		"9" // STATUS_HUD without virus db check for someone being ill.
#define STATUS_HUD_XENO_INFECTION		"10" // STATUS_HUD without virus db check for someone being ill.
#define HEALTH_HUD_XENO		"11" //health HUD for xenos
#define SQUAD_HUD			"12" //squad hud showing who's leader, corpsman, etc for each squad.
#define PLASMA_HUD			"13" //indicates the plasma level of xenos.
#define PHEROMONE_HUD		"14" //indicates which pheromone is active on a xeno.
#define QUEEN_OVERWATCH_HUD	"15" //indicates which xeno the queen is overwatching.
#define STATUS_HUD_OBSERVER_INFECTION "16" //gives observers the xeno larval stage
#define ORDER_HUD "17" //shows what orders are applied to marines
#define AI_DETECT_HUD "18"

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


// Notification action types
#define NOTIFY_JUMP "jump"
#define NOTIFY_ATTACK "attack"
#define NOTIFY_ORBIT "orbit"