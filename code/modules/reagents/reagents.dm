GLOBAL_LIST_INIT(name2reagent, build_name2reagent())

/proc/build_name2reagent()
	. = list()
	for (var/t in subtypesof(/datum/reagent))
		var/datum/reagent/R = t
		if (length(initial(R.name)))
			.[ckey(initial(R.name))] = t

/// A single reagent
/datum/reagent
	/// datums don't have names by default
	var/name = "Reagent"
	/// nor do they have descriptions
	var/description = ""
	///J/(K*mol)
	var/specific_heat = SPECIFIC_HEAT_DEFAULT
	/// used by taste messages
	var/taste_description = "metaphorical salt"
	///how this taste compares to others. Higher values means it is more noticable
	var/taste_multi = 1
	/// reagent holder this belongs to
	var/datum/reagents/holder = null
	/// LIQUID, SOLID, GAS
	var/reagent_state = LIQUID
	/// special data associated with this like viruses etc
	var/list/data
	/// increments everytime on_mob_life is called
	var/current_cycle = 0
	///pretend this is moles
	var/volume = 0
	/// color it looks in containers etc
	var/color = "#000000" // rgb: 0, 0, 0
	/// can this reagent be synthesized? (for example: odysseus syringe gun)
	var/can_synth = TRUE
	///how fast the reagent is metabolized by the mob
	var/custom_metabolism = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	/// You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/overdosed = FALSE
	/// You really fucked up and now getting the worst of the worse.
	var/overdosed_crit = FALSE
	/// above this overdoses happen
	var/overdose_threshold = 0
	/// above this the big bad overdoses happen
	var/overdose_crit_threshold = 0
	/// above this amount addictions start
	var/addiction_threshold = 0
	/// increases as addiction gets worse
	var/addiction_stage = 0
	/// does this show up on health analyzers
	var/scannable = FALSE
	/// if false stops metab in liverless mobs
	var/self_consuming = FALSE
	/// List of reagents removed by this chemical
	var/list/datum/reagent/purge_list
	/// rate at which it purges specific chems
	var/purge_rate = 0
	/// Specific trait flags, like HEARTSTOPPER CHESTSTOPPER BRADYCARDICS TACHYCARDIC
	var/trait_flags = NONE
	///Affects the strength of reagent effects
	var/effect_str = 1
	///Used for certain chems we don't want being extracted via dialysis or being used in cryo, makes all important medical machines (dispenser, cryo etc...) refuse to interact with the reagent
	var/medbayblacklist = FALSE
	///If true allow foam and smoke to transfer reagent into dead mobs
	var/reactindeadmob = TRUE

/datum/reagent/New()
	. = ..()
	if(LAZYLEN(purge_list))
		purge_list = typecacheof(purge_list)

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	holder = null
	return ..()

/// Applies this reagent to a [/mob/living]
/datum/reagent/proc/reaction_mob(mob/living/L, method = TOUCH, volume, show_message = TRUE, touch_protection = 0)
	if(!istype(L))
		return FALSE
	if(method == VAPOR && L.reagents) //foam, spray
		var/amount = round(volume * touch_protection, 0.1)
		L.reagents.add_reagent(type, amount)

	return TRUE

/// Applies this reagent to an [/obj]
/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/// Applies this reagent to a [/turf]
/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/// Called from [/datum/reagents/proc/metabolize]
/datum/reagent/proc/on_mob_life(mob/living/L, metabolism)
	purge(L)
	current_cycle++
	holder.remove_reagent(type, custom_metabolism * L.metabolism_efficiency) //By default it slowly disappears.
	return TRUE

/// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L, metabolism)
	return

/// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/L, metabolism)
	return

/// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/L, metabolism)
	return

/// Called when an overdose starts
/datum/reagent/proc/on_overdose_start(mob/living/L, metabolism)
	if(prob(30)) //placeholder vague feedback
		to_chat(L, span_notice("You feel a little nauseous..."))
	log_combat(L, L, "has been overdosed on [name].")

/// Called when an overdose stops
/datum/reagent/proc/on_overdose_stop(mob/living/L, metabolism)
	return

/// Called when a CRITICAL overdose threshold and is trigger effects.
/datum/reagent/proc/overdose_crit_process(mob/living/L, metabolism)
	return

/// Called when a CRITICAL overdose starts.
/datum/reagent/proc/on_overdose_crit_start(mob/living/L, metabolism)
	log_combat(L, L, "has been critically overdosed on [name].")
	to_chat(L, span_danger("You feel like you took too much of [name]!"))


/// Called by [/datum/reagents/proc/conditional_update_move]
/datum/reagent/proc/on_move(atom/A)
	return

/// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

/// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/// Called by [/datum/reagents/proc/conditional_update]
/datum/reagent/proc/on_update(atom/A)
	return

/// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

/// Called when addiction hits stage1, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage1(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, span_notice("You feel like having some [name] right about now."))


/// Called when addiction hits stage2, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage2(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, span_notice("You feel like you need [name]. You just can't get enough."))


/// Called when addiction hits stage3, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage3(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, span_danger("You have an intense craving for [name]."))


/// Called when addiction hits stage4, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage4(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, span_boldannounce("You're not feeling good at all! You really need some [name]."))


///Convert reagent list to a printable string for logging etc
/proc/pretty_string_from_reagent_list(list/reagent_list)
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")

/// Called during metablism, checks to see if any chemicals need to purge other chemicals.
/datum/reagent/proc/purge(mob/living/L, metabolism)
	if(!LAZYLEN(purge_list))
		return
	var/count = LAZYLEN(purge_list)
	for(var/datum/reagent/R in L.reagents.reagent_list)
		if(count < 1)
			break
		if(is_type_in_typecache(R, purge_list))
			count--
			L.reagents.remove_reagent(R.type,purge_rate)
