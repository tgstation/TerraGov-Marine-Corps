/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/effects/butcher.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE
	/// Callback for butchering
	var/datum/callback/butcher_callback

/datum/component/butchering/Initialize(
	speed = 8 SECONDS,
	effectiveness = 100,
	bonus_modifier = 0,
	butcher_sound = 'sound/effects/butcher.ogg',
	disabled = FALSE,
	can_be_blunt = FALSE,
	butcher_callback,
)
	src.speed = speed
	src.effectiveness = effectiveness
	src.bonus_modifier = bonus_modifier
	src.butcher_sound = butcher_sound
	if(disabled)
		src.butchering_enabled = FALSE
	src.can_be_blunt = can_be_blunt
	src.butcher_callback = butcher_callback
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/butchering/Destroy(force)
	butcher_callback = null
	return ..()

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	if(user.a_intent == INTENT_HELP)
		return
	if(M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.sharpness))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, M, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M))
		return ///Don't gib eachother! Griffing is bad!

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, span_notice("You begin to butcher [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_after(user, speed, M) && M.Adjacent(source))
		on_butchering(user, M)

/**
 * Handles a user butchering a target
 *
 * Arguments:
 * - [butcher][/mob/living]: The mob doing the butchering
 * - [target][/mob/living]: The mob being butchered
 */
/datum/component/butchering/proc/on_butchering(atom/butcher, mob/living/target)
	var/list/results = list()
	var/turf/location = target.drop_location()
	var/final_effectiveness = effectiveness - target.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance

	for(var/result_typepath in target.butcher_results)
		var/obj/remains = result_typepath
		var/amount = target.butcher_results[remains]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, span_warning("You fail to harvest some of the [initial(remains.name)] from [target]."))
				continue

			if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, span_info("You harvest some extra [initial(remains.name)] from [target]!"))
				results += new remains (location)
			results += new remains (location)

		target.butcher_results.Remove(remains) //in case you want to, say, have it drop its results on gib

	for(var/guaranteed_result_typepath in target.guaranteed_butcher_results)
		var/obj/guaranteed_remains = guaranteed_result_typepath
		var/amount = target.guaranteed_butcher_results[guaranteed_remains]
		for(var/i in 1 to amount)
			results += new guaranteed_remains (location)
		target.guaranteed_butcher_results.Remove(guaranteed_remains)

	// transfer delicious reagents to meat
	if(target.reagents)
		var/meat_produced = 0
		for(var/obj/item/food/meat/slab/target_meat in length(results))
			meat_produced += 1
		for(var/obj/item/food/meat/slab/target_meat in results)
			target.reagents.trans_to(target_meat, target.reagents.total_volume / meat_produced)
	if(butcher)
		butcher.visible_message(span_notice("[butcher] butchers [target]."), \
			span_notice("You butcher [target]."))
	butcher_callback?.Invoke(butcher, target)
	target.harvest(butcher)
	target.log_message("has been butchered by [key_name(butcher)]", LOG_ATTACK)
	target.gib()

///Enables the butchering mechanic for the mob who has equipped us.
/datum/component/butchering/proc/enable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = TRUE

///Disables the butchering mechanic for the mob who has dropped us.
/datum/component/butchering/proc/disable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = FALSE
