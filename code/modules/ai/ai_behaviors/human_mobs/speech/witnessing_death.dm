#define DEATH_LINES_ANGRY \
	"You're gonna pay for that!",\
	"You're dead, asshole!",\
	"You're fucked now!",\
	"MOTHERFUCKER!!"

#define DEATH_LINES_SOLDIER \
	"Man down... I'm coming for you!",\
	"Man down... you piece of shit!"

#define GIB_LINES_ANGRY \
	"WOAH, LOOK OUT!!",\
	"OH MY GOD!!",\
	"HOLY SHIT!!",\
	"OH NOOO!!",\
	"FUCK!!"

/// When witnessing death and engaged in combat
/datum/ai_speech/witnessing_death
	key = AI_SPEECH_WITNESSING_DEATH
	chat_lines = list(
		FACTION_NEUTRAL = list(
			DEATH_LINES_ANGRY,
		),
		FACTION_TERRAGOV = list(
			DEATH_LINES_ANGRY,
			DEATH_LINES_SOLDIER,
		),
		FACTION_NANOTRASEN = list(
			DEATH_LINES_ANGRY,
			DEATH_LINES_SOLDIER,
		),
		FACTION_SPECFORCE = list(
			DEATH_LINES_ANGRY,
			DEATH_LINES_SOLDIER,
		),
	)

/// When witnessing a gibbing and engaged in combat
/datum/ai_speech/witnessing_gibbing
	key = AI_SPEECH_WITNESSING_GIBBING
	chat_lines = list(
		FACTION_NEUTRAL = list(
			GIB_LINES_ANGRY,
		),
	)

/// Called by being in combat and having line of sight with someone who's dead
/datum/ai_behavior/human/proc/witness_death(mob/living/carbon/human/source, mob/living/carbon/human/dead, gibbing)
	SIGNAL_HANDLER
	if(!combat_target)
		return
	if(!gibbing && source.faction != dead.faction) // it's fine to point out a gibbing even if they're an enemy. shit's CRAZY
		return
	key_speak(gibbing ? AI_SPEECH_WITNESSING_GIBBING : AI_SPEECH_WITNESSING_DEATH, unique_cooldown = 15 SECONDS)

#undef DEATH_LINES_ANGRY
#undef DEATH_LINES_SOLDIER
#undef GIB_LINES_ANGRY
