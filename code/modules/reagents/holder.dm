#define CHEMICAL_QUANTISATION_LEVEL 0.0001 //stops floating point errors causing issues with checking reagent amounts

/datum/reagents
	/// The reagents being held
	var/list/datum/reagent/reagent_list = list()
	/// Current volume of all the reagents
	var/total_volume = 0
	/// Max volume of this holder
	var/maximum_volume = 100
	/// The atom this holder is attached to
	var/datum/weakref/my_atom
	/// Current temp of the holder volume
	var/chem_temp = 150
	/// unused
	var/last_tick = 1
	/// see [/datum/reagents/proc/metabolize] for usage
	var/addiction_tick = 1
	/// currently addicted reagents
	var/list/datum/reagent/addiction_list = list()
	/// various flags, see code\__DEFINES\reagents.dm
	var/reagent_flags

/datum/reagents/New(maximum = 100, new_flags)
	maximum_volume = maximum

	reagent_flags = new_flags

/datum/reagents/Destroy()
	for(var/datum/reagent/reagent AS in reagent_list)
		qdel(reagent)
	reagent_list = null
	var/atom/holder_atom = get_holder()
	if(holder_atom && holder_atom.reagents == src)
		holder_atom.reagents = null
	return ..()

/**
 * Used in attack logs for reagents in pills and such
 *
 * Arguments:
 * * external_list - list of reagent types = amounts
 */
/datum/reagents/proc/log_list(external_list)
	if((external_list && !length(external_list)) || !length(reagent_list))
		return "no reagents"

	var/list/data = list()
	if(external_list)
		for(var/r in external_list)
			data += "[r] ([round(external_list[r], 0.1)]u)"
	else
		for(var/r in reagent_list) //no reagents will be left behind
			var/datum/reagent/R = r
			data += "[R.type] ([round(R.volume, 0.1)]u)"
			//Using types because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)


/// Remove an amount of reagents without caring about what they are
/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_transfered = 0
	var/current_list_element= 1
	var/initial_list_length = length(cached_reagents) //stored here because removing can cause some reagents to be deleted, ergo length change.

	current_list_element = rand(1, length(cached_reagents))

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !length(cached_reagents))
			break

		if(current_list_element > length(cached_reagents))
			current_list_element = 1

		var/datum/reagent/R = cached_reagents[current_list_element]
		//double round to keep it at a somewhat even spread relative to amount without getting funky numbers.
		var/remove_amt = min(
			amount - total_transfered,
			round(amount / rand(2, initial_list_length), round(amount/10,0.01))
		)
		//min ensures we don't go over amount.
		remove_reagent(R.type, remove_amt)

		current_list_element++
		total_transfered += remove_amt
		update_total()

	handle_reactions()
	return total_transfered

/// Removes all reagents from this holder
/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.type, R.volume * part)

		update_total()
		handle_reactions()
		return amount

/// Get the name of the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			name = R.name

	return name

/// Get the id of the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/max_type
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			max_type = R.type

	return max_type

/// Get a reference to the reagent there is the most of in this holder
/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R

	return master

/**
 * Transfer some stuff from this holder to a target object
 *
 * Arguments:
 * * obj/target - Target to attempt transfer to
 * * amount - amount of reagent volume to transfer
 * * multiplier - multiplies amount of each reagent by this number
 * * preserve_data - if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
 * * no_react - passed through to [/datum/reagents/proc/add_reagent]
 * * mob/transfered_by - used for logging
 * * remove_blacklisted - skips transferring of reagents with can_synth = FALSE
 * * method - passed through to [/datum/reagents/proc/react_single] and [/datum/reagent/proc/on_transfer]
 * * show_message - passed through to [/datum/reagents/proc/react_single]
 * * round_robin - if round_robin=TRUE, so transfer 5 from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15 instead of 13.3333, 13.3333 13.3333. Good if you hate floating point errors
 */
/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier=1, preserve_data=1, no_react = 0)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	var/list/cached_reagents = reagent_list
	if (!target || !total_volume)
		return
	if (amount < 0)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/transfer_amount = T.volume * part
		if(preserve_data)
			trans_data = copy_data(T)
		R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, no_react = 1) //we only handle reaction after every reagent has been transfered.
		remove_reagent(T.type, transfer_amount)

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/// Copies the reagents to the target object
/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(amount < 0)
		return
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/copy_amount = T.volume * part
		if(preserve_data)
			trans_data = T.data
		R.add_reagent(T.type, copy_amount * multiplier, trans_data)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount


/// Transfer a specific reagent id to the target object
/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for(var/CR in cached_reagents)
		var/datum/reagent/current_reagent = CR
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.type, amount, trans_data, src.chem_temp)
			remove_reagent(current_reagent.type, amount)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/**
 * Triggers metabolizing the reagents in this holder
 *
 * Arguments:
 * * mob/living/carbon/C - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
 * * can_overdose - Allows overdosing
 * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
 */
/datum/reagents/proc/metabolize(mob/living/L, can_overdose = FALSE , liverless = FALSE) //last two vars do nothing for the time being.
	var/list/cached_reagents = reagent_list
	var/list/cached_addictions = addiction_list
	var/quirks
	if(L)
		expose_temperature(L.bodytemperature, 0.25)
		quirks = L.get_reagent_tags()
	var/need_mob_update = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(!R || QDELETED(R.holder))
			continue
		if(liverless && !R.self_consuming) //need to be metabolized
			continue
		if(!L)
			L = R.holder.get_holder()
			quirks = L.get_reagent_tags()
		if(L.reagent_check(R) != TRUE)
			if(can_overdose)
				if(R.overdose_threshold)
					if(R.volume > R.overdose_threshold && !R.overdosed)
						R.overdosed = TRUE
						need_mob_update += R.on_overdose_start(L, quirks)
				if(R.overdose_crit_threshold)
					if(R.volume > R.overdose_crit_threshold && !R.overdosed_crit)
						R.overdosed_crit = TRUE
						need_mob_update += R.on_overdose_crit_start(L, quirks)
				if(R.addiction_threshold)
					if(R.volume > R.addiction_threshold && !is_type_in_list(R, cached_addictions))
						var/datum/reagent/new_reagent = new R.type()
						cached_addictions.Add(new_reagent)
				if(R.volume <= R.overdose_threshold && R.overdosed && R.overdose_threshold)
					R.overdosed = FALSE
					need_mob_update += R.on_overdose_stop(L, quirks)
				if(R.volume <= R.overdose_crit_threshold && R.overdosed_crit && R.overdose_crit_threshold)
					R.overdosed_crit = FALSE
				if(R.overdosed)
					need_mob_update += R.overdose_process(L, quirks) //Small OD
				if(R.overdosed_crit)
					need_mob_update += R.overdose_crit_process(L, quirks) //Big OD
				if(is_type_in_list(R, cached_addictions))
					for(var/addiction in cached_addictions)
						var/datum/reagent/A = addiction
						if(istype(R, A))
							A.addiction_stage = -15 //you're satisfied for a good while
			need_mob_update += R.on_mob_life(L, quirks)

	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in cached_addictions)
				var/datum/reagent/R = addiction
				if(L && R)
					R.addiction_stage++
					switch(R.addiction_stage)
						if(1 to 38)
							need_mob_update += R.addiction_act_stage1(L, quirks)
						if(38 to 76)
							need_mob_update += R.addiction_act_stage2(L, quirks)
						if(76 to 114)
							need_mob_update += R.addiction_act_stage3(L, quirks)
						if(114 to 152)
							need_mob_update += R.addiction_act_stage4(L, quirks)
						if(152 to INFINITY)
							to_chat(L, span_notice("You feel like you've gotten over your need for [R.name]."))
							cached_addictions.Remove(R)
		addiction_tick++
	if(!QDELETED(L) && need_mob_update)
		L.updatehealth()
	update_total()

/datum/reagents/proc/conditional_update_move(atom/A, running = FALSE)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_move(A, running)
	update_total()


/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_update(A)
	update_total(A)


/datum/reagents/proc/handle_reactions()
	if(CHECK_BITFIELD(reagent_flags, NO_REACT))
		return //Yup, no reactions here. No siree.
	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list
	var/datum/cached_my_atom = get_holder()

	var/reaction_occured = TRUE
	while(reaction_occured)
		reaction_occured = FALSE
		var/list/possible_reactions = list()
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			for(var/reaction in cached_reactions[R.type]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/list/cached_required_reagents = C.required_reagents
				var/total_required_reagents = length(cached_required_reagents)
				var/total_matching_reagents = 0
				var/list/cached_required_catalysts = C.required_catalysts
				var/total_required_catalysts = length(cached_required_catalysts)
				var/total_matching_catalysts= 0
				var/matching_container = FALSE
				var/matching_other = FALSE
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = FALSE

				for(var/B in cached_required_reagents)
					if(!has_reagent(B, cached_required_reagents[B]))
						break
					total_matching_reagents++
				for(var/B in cached_required_catalysts)
					if(!has_reagent(B, cached_required_catalysts[B]))
						break
					total_matching_catalysts++
				if(cached_my_atom)
					if(!C.required_container)
						matching_container = TRUE

					else
						if(cached_my_atom.type == C.required_container)
							matching_container = TRUE
					if (isliving(cached_my_atom) && !C.mob_react) //Makes it so some chemical reactions don't occur in mobs
						return
					if(!C.required_other)
						matching_other = TRUE

				else
					if(!C.required_container)
						matching_container = TRUE
					if(!C.required_other)
						matching_other = TRUE

				if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))
					meets_temp_requirement = TRUE

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && meets_temp_requirement)
					possible_reactions += C


		if(length(possible_reactions))
			var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
			//select the reaction with the most extreme temperature requirements
			for(var/V in possible_reactions)
				var/datum/chemical_reaction/competitor = V
				if(selected_reaction.is_cold_recipe) //if there are no recipe conflicts, everything in possible_reactions will have this same value for is_cold_reaction. warranty void if assumption not met.
					if(competitor.required_temp <= selected_reaction.required_temp)
						selected_reaction = competitor
				else
					if(competitor.required_temp >= selected_reaction.required_temp)
						selected_reaction = competitor
			var/list/cached_required_reagents = selected_reaction.required_reagents
			var/list/cached_results = selected_reaction.results
			var/list/multiplier = INFINITY
			for(var/B in cached_required_reagents)
				multiplier = min(multiplier, round(get_reagent_amount(B) / cached_required_reagents[B]))

			for(var/B in cached_required_reagents)
				remove_reagent(B, (multiplier * cached_required_reagents[B]))

			for(var/P in selected_reaction.results)
				multiplier = max(multiplier, 1) //This shouldn't happen...
				SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)
				add_reagent(P, cached_results[P]*multiplier, null, chem_temp)

			var/list/seen = viewers(4, get_turf(cached_my_atom))
			var/iconhtml = icon2html(cached_my_atom, seen)
			if(cached_my_atom)
				if(!ismob(cached_my_atom)) //no bubbling mobs
					if(selected_reaction.mix_sound)
						playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 30, 1)

					for(var/mob/M in seen)
						to_chat(M, span_notice("[iconhtml] [selected_reaction.mix_message]"))

			selected_reaction.on_reaction(src, multiplier)
			reaction_occured = 1

	update_total()
	return 0


/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type != reagent)
			del_reagent(R.type)
			update_total()


///Remove a reagent datum with the type provided from this container. True if one is removed, false otherwise.
/datum/reagents/proc/del_reagent(type_to_remove)
	var/datum/reagent/reagent_to_remove = locate(type_to_remove) in reagent_list
	if(!reagent_to_remove)
		return FALSE
	SEND_SIGNAL(src, COMSIG_REAGENT_DELETING, type_to_remove)
	var/atom/holder_atom = get_holder()
	if(isliving(holder_atom))
		var/mob/living/L = holder_atom
		reagent_to_remove.on_mob_delete(L, L.get_reagent_tags())
	reagent_list -= reagent_to_remove
	qdel(reagent_to_remove)
	update_total()
	holder_atom?.on_reagent_change(DEL_REAGENT)
	return TRUE


/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume < 0.1)
			del_reagent(R.type)
		else
			total_volume += R.volume

	return 0


/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		del_reagent(R.type)
	return 0



/datum/reagents/proc/reaction(atom/A, method=TOUCH, volume_modifier=1, show_message = 1)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if (isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else
		return
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		switch(react_type)
			if("LIVING")
				var/mob/living/L = A
				if(!R.reactindeadmob && L.stat == DEAD)
					return
				var/touch_protection = 0
				if(method == VAPOR)
					touch_protection = CLAMP01(1 -  L.get_permeability_protection())
				R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
			if("TURF")
				R.reaction_turf(A, R.volume * volume_modifier, show_message)
			if("OBJ")
				R.reaction_obj(A, R.volume * volume_modifier, show_message)

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

/datum/reagents/proc/specific_heat()
	. = 0
	var/cached_amount = total_volume	//cache amount
	var/list/cached_reagents = reagent_list	//cace reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * (R.volume / cached_amount)

/datum/reagents/proc/adjust_thermal_energy(J, min_temp = 2.7, max_temp = 1000)
	var/S = specific_heat()
	chem_temp = clamp(chem_temp * (J / (S * total_volume)), 2.7, 1000)

/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = 300, no_react = 0, safety = 0, no_overdose = FALSE)
	if(!isnum(amount) || !amount || amount <= 0)
		return FALSE

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(!D)
		stack_trace("[get_holder()] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE

	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
		if(no_overdose)
			var/overdose = D.overdose_threshold
			amount = clamp(amount,0,overdose - get_reagent_amount(reagent) )
		if(amount<=0)
			return FALSE
	var/new_total = cached_total + amount
	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list
	var/atom/cached_atom = get_holder()

	//Equalize temperature - Not using specific_heat() as it's just some still unused physical chemistry.
	var/specific_heat = 0
	var/thermal_energy = 0
	for(var/i in cached_reagents)
		var/datum/reagent/R = i
		specific_heat += R.specific_heat * (R.volume / new_total)
		thermal_energy += R.specific_heat * R.volume * cached_temp
	specific_heat += D.specific_heat * (amount / new_total)
	thermal_energy += D.specific_heat * amount * reagtemp
	chem_temp = thermal_energy / (specific_heat * new_total)
	////

	//add the reagent to the existing if it exists
	var/datum/reagent/existing_reagent = locate(reagent) in cached_reagents
	if(existing_reagent)
		existing_reagent.volume += amount
		update_total()
		if(cached_atom)
			cached_atom.on_reagent_change(ADD_REAGENT)
		existing_reagent.on_merge(data, amount)
		if(!no_react)
			handle_reactions()
		return TRUE

	//otherwise make a new one
	SEND_SIGNAL(src, COMSIG_NEW_REAGENT_ADD, reagent, amount)
	var/datum/reagent/R = new D.type(data)
	cached_reagents += R
	R.holder = src
	R.volume = amount
	if(data)
		R.data = data
		R.on_new(data)

	if(isliving(cached_atom))
		var/mob/living/L = cached_atom
		R.on_mob_add(cached_atom, L.get_reagent_tags()) //Must occur before it could possibly run on_mob_delete
	update_total()
	if(cached_atom)
		cached_atom.on_reagent_change(ADD_REAGENT)
	if(!no_react)
		handle_reactions()
	return TRUE

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) //// Like add_reagent but you can enter a list. Format it like this: list(/datum/reagent/toxin = 10, /datum/reagent/consumable/ethanol/beer = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/datum/reagents/proc/remove_reagent(reagent, amount)
	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")

	if(!isnum(amount) || amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list
	var/atom/cached_holder_atom = get_holder()

	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if(R.type == reagent)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = clamp(amount, 0, R.volume) //P.S. Change it with the define when the other PR is merged.
			R.volume -= amount
			update_total()
			cached_holder_atom?.on_reagent_change(REM_REAGENT)
			return TRUE

	return FALSE

/datum/reagents/proc/has_reagent(reagent, amount = -1)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			if(!amount)
				return R
			else
				if(round(R.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					return R
				else
					return 0
	return 0

/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type == reagent)
			return round(R.volume, CHEMICAL_QUANTISATION_LEVEL)

	return 0


/datum/reagents/proc/get_reagent(reagent_id)
	for(var/X in reagent_list)
		var/datum/reagent/R = X
		if(R.type == reagent_id)
			return R


/datum/reagents/proc/get_reagents()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount))
		return 1
	var/list/cached_reagents = reagent_list
	var/has_removed_reagent = 0

	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.type, amount)

	return has_removed_reagent



//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			return R.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			R.data = new_data

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if (!current_reagent || !current_reagent.data)
		return null
	if (!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	return trans_data


/datum/reagents/proc/generate_taste_message(minimum_percent=15	)
	// the lower the minimum percent, the more sensitive the message is.
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_multi)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_multi * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_multi
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		//TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(percent > minimum_percent * 2 || percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")

/datum/reagents/proc/expose_temperature(temperature, coeff=0.02)
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	chem_temp = round(chem_temp)
	handle_reactions()

///Getter proc for our atom holder
/datum/reagents/proc/get_holder()
	return my_atom?.resolve()

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol, new_flags, list/init_reagents, data)
	if(reagents)
		qdel(reagents)
	reagents = new (max_vol, new_flags)
	reagents.my_atom = WEAKREF(src)
	if(init_reagents)
		reagents.add_reagent_list(init_reagents, data)

/proc/get_random_reagent_id()	// Returns a random reagent ID minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!length(random_reagents))
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth))
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent
