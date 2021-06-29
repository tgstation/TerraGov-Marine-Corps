#define FACTION_NEUTRAL "Neutral"
#define FACTION_TERRAGOV "TerraGov"
#define FACTION_TERRAGOV_REBEL "TerraGov Rebel"
#define FACTION_XENO "Xeno"
#define FACTION_CLF "Colonial Liberation Force"
#define FACTION_DEATHSQUAD "Deathsquad"
#define FACTION_FREELANCERS "Freelancers"
#define FACTION_IMP "Imperium of Mankind"
#define FACTION_UNKN_MERCS "Unknown Mercenary Group"
#define FACTION_NANOTRASEN "Nanotrasen"
#define FACTION_SECTOIDS "Sectoids"
#define FACTION_SOM "Sons of Mars"
#define FACTION_USL "United Space Lepidoptera"
#define FACTION_ALIEN "Alien"
#define FACTION_SPIDER "Spider"
#define FACTION_HIVEBOT "Hivebot"
#define FACTION_HOSTILE "Hostile"
#define FACTION_PIRATE "Pirate"

//Alignement are currently only used by req.
///Mob with a neutral alignement cannot be sold by anyone
#define ALIGNEMENT_NEUTRAL 0
///Mob with an hostile alignement can be sold by everyone except members of their own faction
#define ALIGNEMENT_HOSTILE -1
///Mob with friendly alignement can only be sold by mob of the hostile or neutral alignement
#define ALIGNEMENT_FRIENDLY 1

//Alignement for each faction
GLOBAL_LIST_INIT(faction_to_alignement, list(
	FACTION_NEUTRAL = ALIGNEMENT_NEUTRAL,
	FACTION_TERRAGOV = ALIGNEMENT_FRIENDLY,
	FACTION_NANOTRASEN = ALIGNEMENT_FRIENDLY,
	FACTION_FREELANCERS = ALIGNEMENT_FRIENDLY,
	FACTION_XENO = ALIGNEMENT_HOSTILE,
	FACTION_CLF = ALIGNEMENT_HOSTILE,
	FACTION_DEATHSQUAD = ALIGNEMENT_HOSTILE,
	FACTION_IMP = ALIGNEMENT_HOSTILE,
	FACTION_UNKN_MERCS = ALIGNEMENT_HOSTILE,
	FACTION_SECTOIDS = ALIGNEMENT_HOSTILE,
	FACTION_SOM = ALIGNEMENT_HOSTILE,
	FACTION_USL = ALIGNEMENT_HOSTILE,
	FACTION_ALIEN = ALIGNEMENT_HOSTILE,
	FACTION_SPIDER = ALIGNEMENT_HOSTILE,
	FACTION_HIVEBOT = ALIGNEMENT_HOSTILE,
	FACTION_HOSTILE = ALIGNEMENT_HOSTILE,
	FACTION_PIRATE = ALIGNEMENT_HOSTILE,
))
