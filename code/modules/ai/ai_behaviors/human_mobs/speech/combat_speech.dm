#define COMBAT_HIGH_ENERGY \
	"THIS IS IT! CHARGE!!",\
	"BRING IT ON!!",\
	"You're mine!",\
	"Let's rock!",\
	"WASTE 'EM!!",\
	"Fuck you!",\
	"Get some!"

#define COMBAT_COLD \
	"Weapons free.",\
	"Moving in.",\
	"Engaging!",\
	"Engaging.",\
	"Hostiles!",\
	"Contact!"

/datum/ai_speech/retreating
	key = AI_SPEECH_RETREATING
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Cover me, I'm hit!",
			"I need help here!",
			"Falling back!",
			"Disengaging!",
			"HELP!!",
			"RUN!!",
		),
	)

/datum/ai_speech/initiating_combat
	key = AI_SPEECH_NEW_TARGET
	chat_lines = list(
		FACTION_NEUTRAL = list(
			COMBAT_HIGH_ENERGY,
		),
		FACTION_TERRAGOV = list(
			COMBAT_HIGH_ENERGY,
			"CONTACT!!",
		),
		FACTION_NANOTRASEN = list(
			COMBAT_COLD,
		),
		FACTION_SPECFORCE = list(
			COMBAT_COLD,
		),
	)

/datum/ai_speech/start_fire
	key = AI_SPEECH_START_FIRE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Weapons free!",
			"Open fire!",
			"Fuck you!",
			"Just die!",
			"Get some!",
			"Firing!",
			"Die!",
		),
	)

/datum/ai_speech/reloading
	key = AI_SPEECH_RELOADING
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Cover me, I'm reloading!",
			"Out, reloading!",
			"Changing mag!",
			"RELOADING!!",
		),
	)

/datum/ai_speech/out_of_range
	key = AI_SPEECH_OUT_OF_RANGE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"THEY'RE MAKING A BREAK FOR IT!!",
			"THEY'RE OUT OF SHOOTING RANGE!!",
			"Where'd they go?!",
			"We're losing 'em!",
			"They're running!",
			"I'm losing them!",
		),
	)

/datum/ai_speech/no_line_of_sight
	key = AI_SPEECH_NO_LINE_OF_SIGHT
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"I'm gonna find you, motherfucker!",
			"I lost sight of them!",
			"Where'd they go?!",
			"Target lost!",
			"Quit hiding!",
		),
	)

/datum/ai_speech/friendly_blocked
	key = AI_SPEECH_FRIENDLY_BLOCKING
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"YOU'RE IN MY FIRING LINE!!",
			"COME ON, GET CLEAR!!",
			"HOLDING FIRE, MOVE!!",
			"GET CLEAR!!",
			"MOVE IT!!",
		),
	)

/datum/ai_speech/dead_target
	key = AI_SPEECH_DEAD_TARGET
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Down for the count!",
			"Kill confirmed!",
			"They're down!",
			"Scratch one!",
			"Target down!",
			"We got one.",
			"Dead.",
		),
	)

#undef COMBAT_HIGH_ENERGY
#undef COMBAT_COLD
