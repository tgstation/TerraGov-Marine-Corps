
#define EMBEDID "embed-[embedded_flags]-[embed_chance]-[embed_process_chance]-[embed_limb_damage]-[embed_body_damage]-[embedded_unsafe_removal_time]-[embedded_unsafe_removal_dmg_multiplier]-[embedded_fall_chance]-[embedded_fall_dmg_multiplier]"


/proc/getEmbeddingBehavior(
	embedded_flags = EMBED_FLAGS,
	embed_chance = EMBED_CHANCE,
	embed_process_chance = EMBED_PROCESS_CHANCE,
	embed_limb_damage = EMBED_LIMB_DAMAGE,
	embed_body_damage = EMBED_BODY_DAMAGE,
	embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
	embedded_unsafe_removal_dmg_multiplier = EMBEDDED_UNSAFE_REMOVAL_DMG_MULTIPLIER,
	embedded_fall_chance = EMBEDDED_FALL_CHANCE,
	embedded_fall_dmg_multiplier = EMBEDDED_FALL_DMG_MULTIPLIER
	)

	. = locate(EMBEDID)
	if(!.)
		return new /datum/embedding_behavior(embedded_flags, embed_chance, embed_process_chance, embed_limb_damage, embed_body_damage, embedded_unsafe_removal_time, embedded_unsafe_removal_dmg_multiplier, embedded_fall_chance, embedded_fall_dmg_multiplier)


/datum/embedding_behavior
	var/embedded_flags = EMBED_FLAGS
	var/embed_chance = EMBED_CHANCE
	var/embed_process_chance = EMBED_PROCESS_CHANCE
	var/embed_limb_damage = EMBED_LIMB_DAMAGE
	var/embed_body_damage = EMBED_BODY_DAMAGE
	var/embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME //A time in ticks, multiplied by the w_class.
	var/embedded_unsafe_removal_dmg_multiplier = EMBEDDED_UNSAFE_REMOVAL_DMG_MULTIPLIER //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
	var/embedded_fall_chance = EMBEDDED_FALL_CHANCE
	var/embedded_fall_dmg_multiplier = EMBEDDED_FALL_DMG_MULTIPLIER //The coefficient of multiplication for the damage taken when falling naturally (this*w_class*)


/datum/embedding_behavior/New(
	embedded_flags = EMBED_FLAGS,
	embed_chance = EMBED_CHANCE,
	embed_process_chance = EMBED_PROCESS_CHANCE,
	embed_limb_damage = EMBED_LIMB_DAMAGE,
	embed_body_damage = EMBED_BODY_DAMAGE,
	embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
	embedded_unsafe_removal_dmg_multiplier = EMBEDDED_UNSAFE_REMOVAL_DMG_MULTIPLIER,
	embedded_fall_chance = EMBEDDED_FALL_CHANCE,
	embedded_fall_dmg_multiplier = EMBEDDED_FALL_DMG_MULTIPLIER
	)

	src.embedded_flags = embedded_flags
	src.embed_chance = embed_chance
	src.embed_process_chance = embed_process_chance
	src.embed_limb_damage = embed_limb_damage
	src.embed_body_damage = embed_body_damage
	src.embedded_unsafe_removal_time = embedded_unsafe_removal_time
	src.embedded_unsafe_removal_dmg_multiplier = embedded_unsafe_removal_dmg_multiplier
	src.embedded_fall_chance = embedded_fall_chance
	src.embedded_fall_dmg_multiplier = embedded_fall_dmg_multiplier
	tag = EMBEDID


/datum/embedding_behavior/proc/setRating(embedded_flags, embed_chance, embed_process_chance, embed_limb_damage, embed_body_damage, embedded_unsafe_removal_time, embedded_unsafe_removal_dmg_multiplier, embedded_fall_chance, embedded_fall_dmg_multiplier)
	return getEmbeddingBehavior((isnull(embedded_flags) ? src.embedded_flags : embedded_flags),\
		(isnull(embed_chance) ? src.embed_chance : embed_chance),\
		(isnull(embed_process_chance) ? src.embed_process_chance : embed_process_chance),\
		(isnull(embed_limb_damage) ? src.embed_limb_damage : embed_limb_damage),\
		(isnull(embed_body_damage) ? src.embed_body_damage : embed_body_damage),\
		(isnull(embedded_unsafe_removal_time) ? src.embedded_unsafe_removal_time : embedded_unsafe_removal_time),\
		(isnull(embedded_unsafe_removal_dmg_multiplier) ? src.embedded_unsafe_removal_dmg_multiplier : embedded_unsafe_removal_dmg_multiplier),\
		(isnull(embedded_fall_chance) ? src.embedded_fall_chance : embedded_fall_chance),\
		(isnull(embedded_fall_dmg_multiplier) ? src.embedded_fall_dmg_multiplier : embedded_fall_dmg_multiplier))


#undef EMBEDID
