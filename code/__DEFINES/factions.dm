#define FACTION_NEUTRAL "Neutral"
#define FACTION_TERRAGOV "TerraGov"
#define FACTION_XENO "Xeno"
#define FACTION_ZOMBIE "Zombie"
#define FACTION_CLF "Colonial Liberation Force"
#define FACTION_DEATHSQUAD "Deathsquad"
#define FACTION_FREELANCERS "Freelancers"
#define FACTION_IMP "Imperium of Mankind"
#define FACTION_UNKN_MERCS "Unknown Mercenary Group"
#define FACTION_NANOTRASEN "Nanotrasen"
#define FACTION_SECTOIDS "Sectoids"
#define FACTION_SOM "Sons of Mars"
#define FACTION_ICC "Independent Colonial Confederation"
#define FACTION_USL "United Space Lepidoptera"
#define FACTION_ALIEN "Alien"
#define FACTION_SPIDER "Spider"
#define FACTION_HIVEBOT "Hivebot"
#define FACTION_HOSTILE "Hostile"
#define FACTION_PIRATE "Pirate"
#define FACTION_SPECFORCE "Special Forces"

//Alignement are currently only used by req.
///Mob with a neutral alignement cannot be sold by anyone
#define ALIGNEMENT_NEUTRAL 0
///Mob with an hostile alignement can be sold by everyone except members of their own faction
#define ALIGNEMENT_HOSTILE -1
///Mob with friendly alignement can only be sold by mob of the hostile or neutral alignement
#define ALIGNEMENT_FRIENDLY 1

///Alignement for each faction
GLOBAL_LIST_INIT(faction_to_alignement, list(
	FACTION_NEUTRAL = ALIGNEMENT_NEUTRAL,
	//Friendly
	FACTION_TERRAGOV = ALIGNEMENT_FRIENDLY,
	FACTION_NANOTRASEN = ALIGNEMENT_FRIENDLY,
	FACTION_FREELANCERS = ALIGNEMENT_FRIENDLY,
	FACTION_SPECFORCE = ALIGNEMENT_FRIENDLY,
	//Hostile
	FACTION_XENO = ALIGNEMENT_HOSTILE,
	FACTION_CLF = ALIGNEMENT_HOSTILE,
	FACTION_DEATHSQUAD = ALIGNEMENT_HOSTILE,
	FACTION_IMP = ALIGNEMENT_HOSTILE,
	FACTION_UNKN_MERCS = ALIGNEMENT_HOSTILE,
	FACTION_SECTOIDS = ALIGNEMENT_HOSTILE,
	FACTION_SOM = ALIGNEMENT_HOSTILE,
	FACTION_ICC = ALIGNEMENT_HOSTILE,
	FACTION_USL = ALIGNEMENT_HOSTILE,
	FACTION_ALIEN = ALIGNEMENT_HOSTILE,
	FACTION_SPIDER = ALIGNEMENT_HOSTILE,
	FACTION_HIVEBOT = ALIGNEMENT_HOSTILE,
	FACTION_HOSTILE = ALIGNEMENT_HOSTILE,
	FACTION_PIRATE = ALIGNEMENT_HOSTILE,
))

///Iff signals for factions
#define TGMC_LOYALIST_IFF (1<<0) //Friendly IFF Signal
#define SOM_IFF (1<<1)
#define DEATHSQUAD_IFF (1<<2)
#define ICC_IFF (1<<3)
#define CLF_IFF (1<<4)
#define IMP_IFF (1<<5)
#define UNKN_MERCS_IFF (1<<6)
#define SECTOIDS_IFF (1<<7)
#define USL_IFF (1<<8)
#define PIRATE_IFF (1<<9)

///Iff for each faction that is able to use iff
GLOBAL_LIST_INIT(faction_to_iff, list(
	FACTION_NEUTRAL = TGMC_LOYALIST_IFF,
	FACTION_TERRAGOV = TGMC_LOYALIST_IFF,
	FACTION_SPECFORCE = TGMC_LOYALIST_IFF,
	FACTION_NANOTRASEN = TGMC_LOYALIST_IFF,
	FACTION_FREELANCERS = TGMC_LOYALIST_IFF,
	FACTION_CLF = CLF_IFF,
	FACTION_DEATHSQUAD = DEATHSQUAD_IFF,
	FACTION_IMP = IMP_IFF,
	FACTION_UNKN_MERCS = UNKN_MERCS_IFF,
	FACTION_SECTOIDS = SECTOIDS_IFF,
	FACTION_SOM = SOM_IFF,
	FACTION_ICC = ICC_IFF,
	FACTION_USL = USL_IFF,
	FACTION_PIRATE = PIRATE_IFF,
))

///List of correspond factions to data hud
GLOBAL_LIST_INIT(faction_to_data_hud, list(
	FACTION_TERRAGOV = DATA_HUD_SQUAD_TERRAGOV,
	FACTION_SOM = DATA_HUD_SQUAD_SOM,
))

GLOBAL_LIST_INIT(faction_to_squad_hud, list(
	FACTION_TERRAGOV = SQUAD_HUD_TERRAGOV,
	FACTION_SOM = SQUAD_HUD_SOM,
))

GLOBAL_LIST_INIT(faction_to_portrait, list(
	FACTION_TERRAGOV = /atom/movable/screen/text/screen_text/picture/potrait,
	FACTION_SOM = /atom/movable/screen/text/screen_text/picture/potrait/som_over,
))

GLOBAL_LIST_INIT(faction_to_mech_spawner, list(
	FACTION_TERRAGOV = list(
		"heavy" = /obj/effect/landmark/campaign/mech_spawner/heavy,
		"medium" = /obj/effect/landmark/campaign/mech_spawner,
		"light" = /obj/effect/landmark/campaign/mech_spawner/light,
	),
	FACTION_SOM = list(
		"heavy" = /obj/effect/landmark/campaign/mech_spawner/som/heavy,
		"medium" = /obj/effect/landmark/campaign/mech_spawner/som,
		"light" = /obj/effect/landmark/campaign/mech_spawner/som/light,
	),
))
