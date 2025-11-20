#define GENERIC_HAZARD \
	"Watch your ass!",\
	"Look out!",\
	"Watch out!"

#define GENERIC_ACID \
	"Don't step in that bubbling stuff!",\
	"Green shit!",\
	"ACID!!",\
	"GOO!!"

#define SOLDIER_ACID \
	"Stay away from that acid!",\
	"Don't step in the acid!",\
	"They're spraying acid!",\
	"Watch out, acid!"

/datum/ai_speech/hazard
	key = AI_SPEECH_HAZARD_GENERIC
	chat_lines = list(
		FACTION_NEUTRAL = list(
			GENERIC_HAZARD,
			"I've never seen shit like this before!",
		),
	)

/datum/ai_speech/hazard/grenade
	key = AI_SPEECH_HAZARD_GRENADE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Let's get away from the grenade!",
			"Grenade, get out of the way!",
			"Grenade, look out!",
			"Grenade, move!",
			"Grenade!",
			GENERIC_HAZARD,
		),
	)

/datum/ai_speech/hazard/fire
	key = AI_SPEECH_HAZARD_FIRE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Someone put those flames out!",
			"Stay away from that fire!",
			"It's only a bit of fire.",
			"Clear those flames!",
			"Move, move, fire!",
			"Look out, fire!",
			"Fire!",
			GENERIC_HAZARD,
		),
	)

/datum/ai_speech/hazard/acid
	key = AI_SPEECH_HAZARD_ACID
	chat_lines = list(
		FACTION_NEUTRAL = list(
			GENERIC_ACID,
			GENERIC_HAZARD,
		),
		FACTION_TERRAGOV = list(
			SOLDIER_ACID,
		),
		FACTION_NANOTRASEN = list(
			SOLDIER_ACID,
		),
		FACTION_SPECFORCE = list(
			SOLDIER_ACID,
		),
	)

/datum/ai_speech/hazard/shuttle
	key = AI_SPEECH_HAZARD_SHUTTLE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Stay away from under that ship!",
			"Look out, something's landing!",
			"Get clear!",
			"Make way!",
			GENERIC_HAZARD,
		),
	)

/datum/ai_speech/hazard/cas
	key = AI_SPEECH_HAZARD_CAS
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"They're dropping CAS!",
			"Don't get bombed!",
			"Take cover!",
			"CAS!!",
			GENERIC_HAZARD,
		),
	)

/datum/ai_speech/hazard/facehugger
	key = AI_SPEECH_HAZARD_FACEHUGGER
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"SHOOT THAT FACEHUGGER!!",
			"FACEHUGGER! RUN!!",
			"FACEHUGGER!!",
			GENERIC_HAZARD,
		),
	)

/datum/ai_speech/hazard/xeno_aoe
	key = AI_SPEECH_HAZARD_XENO_AOE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Watch out, that xeno's doing something!",
			"Stay away from the xeno!",
			GENERIC_HAZARD,
		),
	)

#undef GENERIC_HAZARD
#undef GENERIC_ACID
#undef SOLDIER_ACID
