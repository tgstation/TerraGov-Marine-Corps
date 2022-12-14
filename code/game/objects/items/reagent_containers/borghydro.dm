
/obj/item/reagent_containers/borghypo
	name = "Robot Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 2 //Time it takes for shots to recharge (in seconds)

	var/list/reagent_ids = list(/datum/reagent/medicine/tricordrazine, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane, /datum/reagent/medicine/dexalinplus, /datum/reagent/medicine/dylovene, /datum/reagent/medicine/inaprovaline, /datum/reagent/medicine/tramadol, /datum/reagent/medicine/imidazoline, /datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/quickclot)
	var/list/reagent_volumes = list()
	var/list/reagent_names = list()

/obj/item/reagent_containers/borghypo/Initialize()
	. = ..()

	for(var/T in reagent_ids)
		reagent_volumes[T] = volume
		var/datum/reagent/R = GLOB.chemical_reagents_list[T]
		reagent_names += R.name

	START_PROCESSING(SSobj, src)


/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg+
	if(++charge_tick < recharge_time)
		return 0
	charge_tick = 0

	return 1

/obj/item/reagent_containers/borghypo/attack(mob/living/M as mob, mob/user as mob)
	if(!istype(M))
		return

	if(!reagent_volumes[reagent_ids[mode]])
		to_chat(user, span_warning("The injector is empty."))
		return

	to_chat(user, span_notice(" You inject [M] with the injector."))
	to_chat(M, span_notice(" [user] injects you with the injector."))
	playsound(loc, 'sound/items/hypospray.ogg', 50, 1)

	reagents.reaction(M, INJECT)
	if(M.reagents)
		var/t = min(amount_per_transfer_from_this, reagent_volumes[reagent_ids[mode]])
		M.reagents.add_reagent(reagent_ids[mode], t)
		reagent_volumes[reagent_ids[mode]] -= t
		// to_chat(user, span_notice("[t] units injected. [reagent_volumes[reagent_ids[mode]]] units remaining."))
		to_chat(user, span_notice(" [t] units of <span class='warning'> [reagent_ids[mode]] <span class='notice'> injected for a total of <span class='warning'> [round(M.reagents.get_reagent_amount(reagent_ids[mode]))]<span class='notice'>. [reagent_volumes[reagent_ids[mode]]] units remaining."))

/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	var/selection = tgui_input_list(user, "Please select a reagent:", "Reagent", reagent_ids)
	if(!selection)
		return
	var/datum/reagent/R = GLOB.chemical_reagents_list[selection]
	to_chat(user, span_notice(" Synthesizer is now producing '[R.name]'."))
	mode = reagent_ids.Find(selection)
	playsound(src.loc, 'sound/effects/pop.ogg', 15, 0)


/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	if (user != loc)
		return

	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]

	. += span_notice("It is currently producing [R.name] and has [reagent_volumes[reagent_ids[mode]]] out of [volume] units left.")
