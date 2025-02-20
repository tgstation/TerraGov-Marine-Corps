/obj/item/reagent_containers
	name = "Container"
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 5
	/// The maximum amount of reagents per transfer that will be moved out of this reagent container.
	var/amount_per_transfer_from_this = 5
	/// The different possible amounts of reagent to transfer out of the container
	var/list/possible_transfer_amounts = list(5,10,15,25,30)
	/// The maximum amount of reagents this container can hold
	var/volume = 30
	/// Reagent flags, a few examples being if the container is open or not, if its transparent, if you can inject stuff in and out of the container, and so on
	var/reagent_flags
	///Can liquify/grind pills without needing fluid to dissolve.
	var/liquifier = FALSE
	///List of reagents to add
	var/list/list_reagents
	///Whether we can restock this in a vendor without it having its starting reagents
	var/free_refills = TRUE

	/**
	 * The different thresholds at which the reagent fill overlay will change. See medical/reagent_fillings.dmi.
	 *
	 * Should be a list of integers which correspond to a reagent unit threshold.
	 * If null, no automatic fill overlays are generated.
	 *
	 * For example, list(0) will mean it will gain a the overlay with any reagents present. This overlay is "overlayname0".
	 * list(0, 10) whill have two overlay options, for 0-10 units ("overlayname0") and 10+ units ("overlayname10").
	 */
	var/list/fill_icon_thresholds = null
	/// The optional custom name for the reagent fill icon_state prefix
	/// If not set, uses the current icon state.
	var/fill_icon_state = null
	/// The icon file to take fill icon appearances from
	var/fill_icon = 'icons/obj/reagents/reagent_fillings.dmi'

/obj/item/reagent_containers/Initialize(mapload)
	. = ..()
	create_reagents(volume, reagent_flags, list_reagents)
	if(!possible_transfer_amounts)
		verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/attack_hand_alternate(mob/living/user)
	. = ..()
	change_transfer_amount(user)

/obj/item/reagent_containers/attack_self(mob/living/user)
	. = ..()
	afterattack(user, user) //If player uses the container, use it on themselves

/obj/item/reagent_containers/attack_self_alternate(mob/living/user)
	. = ..()
	change_transfer_amount(user)

/obj/item/reagent_containers/unique_action(mob/user, special_treatment)
	. = ..()
	change_transfer_amount(user)

///Opens a tgui_input_list and changes the transfer_amount of our container based on our selection
/obj/item/reagent_containers/proc/change_transfer_amount(mob/living/user)
	if(!possible_transfer_amounts)
		return FALSE
	var/result = tgui_input_list(user, "Amount per transfer from this:","[src]", possible_transfer_amounts)
	if(result)
		amount_per_transfer_from_this = result
	return TRUE

/obj/item/reagent_containers/verb/set_APTFT()
	set name = "Set transfer amount"
	set category = "IC.Object"
	set src in view(1)

	change_transfer_amount(usr)

//returns a text listing the reagents (and their volume) in the atom. Used by Attack logs for reagents in pills
/obj/item/reagent_containers/proc/get_reagent_list_text()
	if(reagents.reagent_list && length(reagents.reagent_list))
		var/datum/reagent/R = reagents.reagent_list[1]
		. = "[R.name]([R.volume]u)"
		if(length(reagents.reagent_list) < 2) return
		for (var/i = 2, i <= length(reagents.reagent_list), i++)
			R = reagents.reagent_list[i]
			if(!R) continue
			. += "; [R.name]([R.volume]u)"
	else
		. = "No reagents"

///True if this object currently contains at least its starting reagents, false otherwise. Extra reagents are ignored.
/obj/item/reagent_containers/proc/has_initial_reagents()
	for(var/reagent_to_check in list_reagents)
		if(reagents.get_reagent_amount(reagent_to_check) != list_reagents[reagent_to_check])
			return FALSE
	return TRUE

/obj/item/reagent_containers/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_add))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/obj/item/reagent_containers/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_QDELETING))
	return NONE

/// Updates the icon of the container when the reagents change. Eats signal args
/obj/item/reagent_containers/proc/on_reagent_add(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_appearance()
	return NONE

/obj/item/reagent_containers/update_overlays()
	. = ..()
	if(!fill_icon_thresholds)
		return
	if(!reagents.total_volume)
		return

	var/fill_name = fill_icon_state ? fill_icon_state : icon_state
	var/mutable_appearance/filling = mutable_appearance(fill_icon, "[fill_name][fill_icon_thresholds[1]]")

	var/percent = round((reagents.total_volume / volume) * 100)
	for(var/i in 1 to fill_icon_thresholds.len)
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == fill_icon_thresholds.len) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"

	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

///Splashes atom/target with whatever reagents are contained
/obj/item/reagent_containers/proc/try_splash(mob/living/user, atom/target)
	if(!is_open_container()) //Can't splash stuff from a sealed container. I dare you to try.
		to_chat(user, span_warning("An airtight seal prevents you from splashing the solution!"))
		return

	if(ismob(target) && target.reagents && reagents.total_volume)
		to_chat(user, span_notice("You splash the solution onto [target]."))
		playsound(target, 'sound/effects/slosh.ogg', 25, 1)

		var/mob/living/M = target
		var/list/injected = list()
		for(var/datum/reagent/R in src.reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		log_combat(user, M, "splashed", src, "Reagents: [contained]")
		record_reagent_consumption(reagents.total_volume, injected, user, M)

		visible_message(span_warning("[target] has been splashed with something by [user]!"))
		reagents.reaction(target, TOUCH)
		addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, clear_reagents)), 5)
		return


	else if(reagents.total_volume)
		to_chat(user, span_notice("You splash the solution onto [target]."))
		playsound(target, 'sound/effects/slosh.ogg', 25, 1)
		reagents.reaction(target, TOUCH)
		addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, clear_reagents)), 5)
		return
