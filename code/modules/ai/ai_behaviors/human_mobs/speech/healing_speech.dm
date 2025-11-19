#define UNREVIVABLE_GENERIC \
	"Damn it, they're gone!",\
	"I've lost them!",\
	"We lost them!",\
	"Braindead!",\
	"I'm sorry."

#define MOVE_TO_HEAL_GENERIC \
	"Hang in there, I'm coming!",\
	"Cover me, I'm moving up!",\
	"Coming, coming, coming!",\
	"Hold on, I'm coming!",\
	"Helping out here.",\
	"I'm on the way!"

/datum/ai_speech/corpsman_heal
	key = AI_SPEECH_HEALING
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"Quit your yapping, you're gonna be FINE!",
			"Don't stop shooting, I'll heal you!",
			"Wait up, I have something for you!",
			"Healing you, don't stop shooting!",
			"Hold on, I'm gonna fix you up!",
		),
	)

/datum/ai_speech/self_heal
	key = AI_SPEECH_SELF_HEAL
	chat_lines = list(
		FACTION_NEUTRAL = list(
			"I'm fixing myself up here, help!",
			"No pain, no gain...",
			"Healing over here!",
			"Cover me, man!",
			"I need help!",
		),
		FACTION_TERRAGOV = list(
			"I'm fixin' myself here, CORPSMAN!!",
			"CORPSMAN! OVER HERE!!",
			"I NEED A CORPSMAN!!",
			"CORPSMAN UP!!",
			"CORPSMAN!!",
			"Would you please cover me?!",
		),
	)

/datum/ai_speech/unrevivable
	key = AI_SPEECH_UNREVIVABLE
	chat_lines = list(
		FACTION_NEUTRAL = list(
			UNREVIVABLE_GENERIC,
		),
		FACTION_TERRAGOV = list(
			"What'd you call me for? This one's COLD!",
			"Gone forever, move along!",
			"They ain't coming back!",
			UNREVIVABLE_GENERIC,
		),
	)

/datum/ai_speech/move_to_heal
	key = AI_SPEECH_MOVE_TO_HEAL
	chat_lines = list(
		FACTION_NEUTRAL = list(
			MOVE_TO_HEAL_GENERIC,
		),
		FACTION_TERRAGOV = list(
			"Quit your yapping, I'm on the way!",
			"You don't even look that bad!",
			MOVE_TO_HEAL_GENERIC,
		),
	)

#undef UNREVIVABLE_GENERIC
