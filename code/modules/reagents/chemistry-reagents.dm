//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/specific_heat = SPECIFIC_HEAT_DEFAULT	//J/(K*mol)
	var/taste_description = "metaphorical salt"
	var/taste_multi = 1 //how this taste compares to others. Higher values means it is more noticable
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data
	var/current_cycle = 0
	var/volume = 0						//pretend this is moles
	var/custom_metabolism = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/overdosed = 0 // You fucked up and this is now triggering its side effects.
	var/overdosed_crit = 0 //You done it big time, purge that shit quick.
	var/overdose_threshold = 0
	var/overdose_crit_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/scannable = 0 //shows up on health analyzers
	var/self_consuming = FALSE
	var/spray_warning = FALSE //whether spraying that reagent creates an admin message.
	var/color = "#000000" // rgb: 0, 0, 0
	var/can_synth = TRUE // can this reagent be synthesized? (example: odysseus syringe gun)
	var/list/datum/reagent/purge_list = list() //Does this purge any specific chems?
	var/purge_rate = 0 //rate at which it purges specific chems
	var/trait_flags

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)
	if(method == VAPOR && L.reagents) //foam, spray
		var/amount = round(volume * touch_protection, 0.1)
		if(amount >= 0.5)
			L.reagents.add_reagent(id, amount)

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/L, metabolism)
	purge(L)
	current_cycle++
	holder.remove_reagent(id, custom_metabolism * L.metabolism_efficiency) //By default it slowly disappears.
	return TRUE

// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L, metabolism)
	return

// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/L, metabolism)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/L, metabolism)
	return

/datum/reagent/proc/on_overdose_start(mob/living/L, metabolism)
	if(prob(30)) //placeholder vague feedback
		to_chat(L, "<span class='notice'>You feel a little nauseous...</span>")
	log_combat(L, L, "has been overdosed on [name].")
	return

// Similar to the above, but for CRITICAL overdose effects.
/datum/reagent/proc/overdose_crit_process(mob/living/L, metabolism)
	return

/datum/reagent/proc/on_overdose_crit_start(mob/living/L, metabolism)
	log_combat(L, L, "has been critically overdosed on [name].")
	to_chat(L, "<span class='danger'>You feel like you took too much of [name]!</span>")
	return

/datum/reagent/proc/on_move(atom/A)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_update(atom/A)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, "<span class='notice'>You feel like having some [name] right about now.</span>")
	return

/datum/reagent/proc/addiction_act_stage2(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, "<span class='notice'>You feel like you need [name]. You just can't get enough.</span>")
	return

/datum/reagent/proc/addiction_act_stage3(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, "<span class='danger'>You have an intense craving for [name].</span>")
	return

/datum/reagent/proc/addiction_act_stage4(mob/living/L, metabolism)
	if(prob(30))
		to_chat(L, "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>")
	return

/proc/pretty_string_from_reagent_list(list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")

/datum/reagent/proc/purge(mob/living/L, metabolism)
	if(length(purge_list))
		var/count = length(purge_list)
		for(var/datum/reagent/R in L.reagents.reagent_list)
			if(count < 1)
				break
			if(is_type_in_list(R, purge_list))
				count--
				L.reagents.remove_reagent(R.id,purge_rate)
