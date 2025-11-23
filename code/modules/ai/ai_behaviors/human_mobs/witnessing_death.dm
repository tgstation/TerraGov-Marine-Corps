#define DEATH_LINES_ANGRY \
	"You're gonna pay for that!",\
	"You're dead, asshole!",\
	"You're fucked now!",\
	"MOTHERFUCKER!!"

#define DEATH_LINES_SOLDIER_ANGRY \
	"Man down... I'm coming for you!",\
	"Man down... you piece of shit!"

#define GIB_LINES_ANGRY \
	"WOAH, LOOK OUT!!",\
	"MOTHERFUCKER!!",\
	"OH MY GOD!!",\
	"HOLY SHIT!!",\
	"OH NOOO!!",\
	"FUCK!!"

/datum/ai_behavior/human
	/// Lines when witnessing faction members die in combat
	var/list/witnessing_death_lines = list(
		FACTION_NEUTRAL = list(
			DEATH_LINES_ANGRY,
		),
		FACTION_TERRAGOV = list(
			DEATH_LINES_ANGRY,
			DEATH_LINES_SOLDIER_ANGRY,
		),
		FACTION_NANOTRASEN = list(
			DEATH_LINES_ANGRY,
			DEATH_LINES_SOLDIER_ANGRY,
		),
		FACTION_SPECFORCE = list(
			DEATH_LINES_ANGRY,
			DEATH_LINES_SOLDIER_ANGRY,
		),
	)
	/// Lines when witnessing *anyone* be gibbed
	var/list/witnessing_gibbing_lines = list(
		FACTION_NEUTRAL = list(
			GIB_LINES_ANGRY,
		),
	)

/// Tied to [COMSIG_HUMAN_VIEW_DEATH], when having line of sight with someone who just died
/datum/ai_behavior/human/proc/witness_death(mob/living/carbon/human/source, mob/living/carbon/human/dead, gibbing)
	SIGNAL_HANDLER
	if(!prob(25))
		return
	if(!gibbing) // gibbing is cool so it gets to bypass needing to be in combat and share a faction
		if(!combat_target)
			return
		if(dead.faction != source.faction)
			return
	. = HUMAN_VIEW_DEATH_STOP_LOOP
	list_speak(
		chat_lines = gibbing ? witnessing_gibbing_lines : witnessing_death_lines,
		unique_cooldown_key = gibbing ? "point_out_gibbing" : "point_out_death",
		unique_cooldown_time = 15 SECONDS,
	)

#undef DEATH_LINES_ANGRY
#undef DEATH_LINES_SOLDIER_ANGRY
#undef GIB_LINES_ANGRY
