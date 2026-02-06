#define DEATH_LINES_ANGRY \
	"You're gonna pay for that!",\
	"%AFFECTED_FIRST_NAME%!",\
	"You're dead, asshole!",\
	"You're fucked now!",\
	"MOTHERFUCKER!!"

#define DEATH_LINES_SOLDIER_ANGRY \
	"Man down... I'm coming for you!",\
	"Man down... you piece of shit!",\
	"%AFFECTED_TITLE%!"

#define GIB_LINES_ANGRY \
	"WOAH, LOOK OUT!!",\
	"MOTHERFUCKER!!",\
	"OH MY GOD!!",\
	"HOLY SHIT!!",\
	"OH NOOO!!",\
	"FUCK!!"

/// Lines when witnessing faction members die in combat
GLOBAL_LIST_INIT(ai_witnessing_death_lines, list(
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
))

/// Lines when witnessing *anyone* get gibbed
GLOBAL_LIST_INIT(ai_witnessing_gibbing_lines, list(
	FACTION_NEUTRAL = list(
		GIB_LINES_ANGRY,
	),
))

/// Tied to [COMSIG_HUMAN_VIEW_DEATH], when having line of sight with someone who just died
/datum/ai_behavior/human/proc/witness_death(mob/living/carbon/human/source, mob/living/carbon/human/dead, gibbing)
	SIGNAL_HANDLER
	if(prob(75))
		return
	if(!gibbing) // gibbing is cool so it gets to bypass these things
		if(!combat_target)
			return
		if(dead.faction != source.faction)
			return
	. = HUMAN_VIEW_DEATH_STOP_LOOP
	INVOKE_NEXT_TICK(src, PROC_REF(point_out_death), gibbing, source, dead)

/// Wrapper for speech when witnessing a death, passed to [INVOKE_NEXT_TICK]
/// and ensures that speech only happens after the effects of `death()`
/datum/ai_behavior/human/proc/point_out_death(gibbing, mob/living/carbon/human/source, mob/living/carbon/human/dead)
	faction_list_speak(
		chat_lines = gibbing ? GLOB.ai_witnessing_gibbing_lines : GLOB.ai_witnessing_death_lines,
		unique_cooldown_key = gibbing ? AI_COOLDOWN_POINT_OUT_GIBBING : AI_COOLDOWN_POINT_OUT_DEATH,
		unique_cooldown_time = 15 SECONDS,
		talking_with = dead,
	)

#undef DEATH_LINES_ANGRY
#undef DEATH_LINES_SOLDIER_ANGRY
#undef GIB_LINES_ANGRY
