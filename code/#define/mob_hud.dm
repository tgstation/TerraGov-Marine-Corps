// for secHUDs and medHUDs and variants.
//The number is the location of the image on the list hud_list of humans.
// /datum/mob_hud expects these to be unique
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
#define SQUAD_HUD			"12" //squad hud showing who's leader, medic, etc for each squad.
#define PLASMA_HUD			"13" //indicates the plasma level of xenos.
#define PHEROMONE_HUD		"14" //indicates which pheromone is active on a xeno.
#define QUEEN_OVERWATCH_HUD	"15" //indicates which xeno the queen is overwatching.


//data HUD (medhud, sechud) defines
#define MOB_HUD_SECURITY_BASIC		1
#define MOB_HUD_SECURITY_ADVANCED	2
#define MOB_HUD_MEDICAL_BASIC		3
#define MOB_HUD_MEDICAL_ADVANCED	4
#define MOB_HUD_MEDICAL_OBSERVER	5
#define MOB_HUD_XENO_INFECTION		6
#define MOB_HUD_XENO_STATUS			7
#define MOB_HUD_SQUAD				8

