////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_container/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	w_class = WEIGHT_CLASS_TINY
	volume = 5
	init_reagent_flags = TRANSPARENT
	var/filled = 0

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents || !flag) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[target] is full.</span>")
				return

			if(!target.is_injectable() && !ismob(target)) //You can inject humans and food but you cant remove the shit.
				to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
				return

			var/trans = 0

			if(ismob(target))

				var/time = 20 //2/3rds the time of a syringe
				visible_message("<span class='danger'>[user] is trying to squirt something into [target]'s eyes!</span>")

				if(!do_mob(user, target, time, BUSY_ICON_HOSTILE))
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

						visible_message("<span class='danger'>[user] tries to squirt something into [target]s eyes, but fails!</span>")
						addtimer(CALLBACK(reagents, /datum/reagents.proc/reaction, safe_thing, TOUCH), 5)

						to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
						if (src.reagents.total_volume<=0)
							filled = 0
							icon_state = "dropper[filled]"
						return

				visible_message("<span class='danger'>[user] squirts something into [target]'s eyes!</span>")
				src.reagents.reaction(target, TOUCH)

				var/mob/living/M = target

				var/list/injected = list()
				for(var/datum/reagent/R in src.reagents.reagent_list)
					injected += R.name
				var/contained = english_list(injected)
				log_combat(user, M, "squirted", src, "Reagents: [contained]")
				msg_admin_attack("[ADMIN_TPMONTY(usr)] squirted [ADMIN_TPMONTY(M)] with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]).")

			trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
			if (src.reagents.total_volume<=0)
				filled = 0
				icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
				to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target].</span>")
				return

			if(!target.reagents.total_volume)
				to_chat(user, "<span class='warning'>[target] is empty.</span>")
				return

			var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>You fill the dropper with [trans] units of the solution.</span>")

			filled = 1
			icon_state = "dropper[filled]"

		return

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////
