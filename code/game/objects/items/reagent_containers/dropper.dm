////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	w_class = WEIGHT_CLASS_TINY
	volume = 5
	init_reagent_flags = TRANSPARENT
	var/filled = 0

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user , flag)
	if(!target.reagents || !flag)
		return

	if(filled)

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			balloon_alert(user, "Can't, full")
			return

		if(!target.is_injectable() && !ismob(target)) //You can inject humans and food but you cant remove the shit.
			balloon_alert(user, "Cannot fill object")
			return

		var/trans = 0

		if(ismob(target))

			var/time = 20 //2/3rds the time of a syringe
			visible_message(span_danger("[user] is trying to squirt something into [target]'s eyes!"))

			if(!do_after(user, time, NONE, target, BUSY_ICON_HOSTILE))
				return

			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = null
				if( victim.wear_mask )
					if ( victim.wear_mask.flags_inventory & COVEREYES )
						safe_thing = victim.wear_mask
				if( victim.head )
					if ( victim.head.flags_inventory & COVEREYES )
						safe_thing = victim.head
				if(victim.glasses)
					if ( !safe_thing )
						safe_thing = victim.glasses

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)
					trans = src.reagents.trans_to(safe_thing, amount_per_transfer_from_this)

					visible_message(span_danger("[user] tries to squirt something into [target]s eyes, but fails!"))
					addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, reaction), safe_thing, TOUCH), 5)

					balloon_alert(user, "transfers [trans] units")
					if (src.reagents.total_volume<=0)
						filled = 0
						icon_state = "dropper[filled]"
					return

			visible_message(span_danger("[user] squirts something into [target]'s eyes!"))
			src.reagents.reaction(target, TOUCH)

			var/mob/living/M = target

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			log_combat(user, M, "squirted", src, "Reagents: [contained]")
			record_reagent_consumption(min(amount_per_transfer_from_this, reagents.total_volume), reagents.reagent_list, user, M)

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		balloon_alert(user, "transfers [trans] units")
		if (src.reagents.total_volume<=0)
			filled = 0
			icon_state = "dropper[filled]"

	else

		if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
			balloon_alert(user, "Can't remove reagents")
			return

		if(!target.reagents.total_volume)
			balloon_alert(user, "Empty")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

		balloon_alert(user, "Fills the dropper with [trans] units")

		filled = 1
		icon_state = "dropper[filled]"

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////
