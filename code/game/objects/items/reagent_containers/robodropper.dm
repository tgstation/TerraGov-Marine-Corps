
/obj/item/reagent_containers/robodropper
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10
	var/filled = 0

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[target] is full.</span>")
				return

			if(!target.is_injectable() && !ismob(target)) //You can inject humans and food but you cant remove the shit.
				to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
				return


			var/trans = 0

			if(ismob(target))
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

						visible_message("<span class='danger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>")
						addtimer(CALLBACK(reagents, /datum/reagents.proc/reaction, safe_thing, TOUCH), 5)


						to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
						if (reagents.total_volume<=0)
							filled = 0
							icon_state = "dropper[filled]"
						return


				visible_message("<span class='danger'>[user] squirts something into [target]'s eyes!</span>")
				reagents.reaction(target, TOUCH)

				var/mob/M = target
				var/list/injected = list()
				for(var/datum/reagent/R in src.reagents.reagent_list)
					injected += R.name
				var/contained = english_list(injected)
				log_combat(user, M, "squirted", src, "Reagents: [contained]")

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
