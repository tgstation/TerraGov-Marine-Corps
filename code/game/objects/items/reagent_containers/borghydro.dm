
/obj/item/reagent_container/borghypo
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

	var/list/reagent_ids = list("tricordrazine", "bicaridine", "kelotane", "dexalinplus", "dylovene", "inaprovaline", "tramadol", "imidazoline", "spaceacillin", "quickclot")
	var/list/reagent_volumes = list()
	var/list/reagent_names = list()

/obj/item/reagent_container/borghypo/New()
	..()

	for(var/T in reagent_ids)
		reagent_volumes[T] = volume
		var/datum/reagent/R = GLOB.chemical_reagents_list[T]
		reagent_names += R.name

	START_PROCESSING(SSobj, src)


/obj/item/reagent_container/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/reagent_container/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg+
	if(++charge_tick < recharge_time)
		return 0
	charge_tick = 0

	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			for(var/T in reagent_ids)
				if(reagent_volumes[T] < volume)
					R.cell.use(charge_cost)
					reagent_volumes[T] = min(reagent_volumes[T] + 5, volume)
	return 1

/obj/item/reagent_container/borghypo/attack(mob/living/M as mob, mob/user as mob)
	if(!istype(M))
		return

	if(!reagent_volumes[reagent_ids[mode]])
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return

	to_chat(user, "<span class='notice'> You inject [M] with the injector.</span>")
	to_chat(M, "<span class='notice'> [user] injects you with the injector.</span>")
	playsound(loc, 'sound/items/hypospray.ogg', 50, 1)

	reagents.reaction(M, INJECT)
	if(M.reagents)
		var/t = min(amount_per_transfer_from_this, reagent_volumes[reagent_ids[mode]])
		M.reagents.add_reagent(reagent_ids[mode], t)
		reagent_volumes[reagent_ids[mode]] -= t
		// to_chat(user, "<span class='notice'>[t] units injected. [reagent_volumes[reagent_ids[mode]]] units remaining.</span>")
		to_chat(user, "<span class='notice'> [t] units of <span class='warning'> [reagent_ids[mode]] <span class='notice'> injected for a total of <span class='warning'> [round(M.reagents.get_reagent_amount(reagent_ids[mode]))]<span class='notice'>. [reagent_volumes[reagent_ids[mode]]] units remaining.</span>")

	return

/obj/item/reagent_container/borghypo/attack_self(mob/user as mob)
	var/selection = input("Please select a reagent:", "Reagent", null) as null|anything in reagent_ids
	if(!selection) return
	var/datum/reagent/R = GLOB.chemical_reagents_list[selection]
	to_chat(user, "<span class='notice'> Synthesizer is now producing '[R.name]'.</span>")
	mode = reagent_ids.Find(selection)
	playsound(src.loc, 'sound/effects/pop.ogg', 15, 0)
	return

/obj/item/reagent_container/borghypo/examine(mob/user)
	..()
	if (user != loc) return

	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent_ids[mode]]

	to_chat(user, "<span class='notice'>It is currently producing [R.name] and has [reagent_volumes[reagent_ids[mode]]] out of [volume] units left.</span>")
