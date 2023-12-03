////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/obj/items/syringe.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
	item_state = "syringe_0"
	icon_state = "0"
	init_reagent_flags = AMOUNT_SKILLCHECK
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = WEIGHT_CLASS_TINY
	flags_item = NOBLUDGEON
	sharp = IS_SHARP_ITEM_SIMPLE
	var/mode = SYRINGE_DRAW

/obj/item/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user as mob)

	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/reagent_containers/syringe/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	update_icon()

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	return

/obj/item/reagent_containers/syringe/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, span_warning("This syringe is broken!"))
		return

	if (user.a_intent == INTENT_HARM && ismob(target) && isliving(user))
		syringestab(target, user)
		return

	var/injection_time = max(0.5 SECONDS, 5 SECONDS - 1 SECONDS * user.skills.getRating(SKILL_MEDICAL))

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.holder_full())
				to_chat(user, span_warning("The syringe is full."))
				return

			if(ismob(target))//Blood!
				if(iscarbon(target))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
					var/amount = src.reagents.maximum_volume - src.reagents.total_volume
					var/mob/living/carbon/T = target
					if(T.get_blood_id() && reagents.has_reagent(T.get_blood_id()))
						to_chat(user, span_warning("There is already a blood sample in this syringe."))
						return
					if(!T.blood_type)
						to_chat(user, span_warning("You are unable to locate any blood."))
						return

					if(ishuman(T))
						var/mob/living/carbon/human/H = T
						if(H.species.species_flags & NO_BLOOD)
							to_chat(user, span_warning("You are unable to locate any blood."))
							return
						else
							T.take_blood(src,amount)
					else
						T.take_blood(src,amount)

					on_reagent_change()
					reagents.handle_reactions()
					user.visible_message("<span clas='warning'>[user] takes a blood sample from [target].</span>",
										span_notice("You take a blood sample from [target]."), null, 4)

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty.")
					return

				if(!target.is_drawable())
					to_chat(user, span_warning("You cannot directly remove reagents from this object."))
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, span_notice("You fill the syringe with [trans] units of the solution."))
			if (reagents.holder_full())
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, span_warning("The syringe is empty."))
				return

			if(!target.is_injectable() && !ismob(target))
				to_chat(user, span_warning("You cannot directly fill this object."))
				return
			if(target.reagents.holder_full())
				to_chat(user, span_warning("[target] is full."))
				return

			if(ismob(target))
				if(target != user)

					if(ishuman(target))

						var/mob/living/carbon/human/H = target
						if(H.wear_suit)
							if(istype(H.wear_suit,/obj/item/clothing/suit/space))
								injection_time = 6 SECONDS
							else if(!H.can_inject(user, 1))
								return

					else if(isliving(target))

						var/mob/living/M = target
						if(!M.can_inject(user, 1))
							return

					if(injection_time != 6 SECONDS)
						user.visible_message(span_danger("[user] is trying to inject [target]!"))
					else
						user.visible_message(span_danger("[user] begins hunting for an injection port on [target]'s suit!"))

					if(!do_after(user, injection_time, NONE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
						return

					user.visible_message(span_warning("[user] injects [target] with the syringe!"))

					if(istype(target,/mob/living))
						var/mob/living/M = target
						var/list/injected = list()
						for(var/datum/reagent/R in reagents.reagent_list)
							injected += R.name
						var/contained = english_list(injected)
						log_combat(user, M, "injected", src, "Reagents: [contained]")
						record_reagent_consumption(min(10, reagents.total_volume), reagents.reagent_list, user, M)

				reagents.reaction(target, INJECT)


			var/trans = amount_per_transfer_from_this
			if(iscarbon(target) && locate(/datum/reagent/blood) in reagents.reagent_list)
				var/mob/living/carbon/C = target
				C.inject_blood(src, amount_per_transfer_from_this)
			else
				trans = reagents.trans_to(target, amount_per_transfer_from_this)

			to_chat(user, span_notice("You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."))
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()


/obj/item/reagent_containers/syringe/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		overlays.Cut()
		return
	var/rounded_vol = round(reagents.total_volume,5)
	overlays.Cut()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling


/obj/item/reagent_containers/syringe/proc/syringestab(mob/living/carbon/target as mob, mob/living/carbon/user as mob)

	log_combat(user, target, "attacked", src, "(INTENT: [uppertext(user.a_intent)])")

	if(ishuman(target))

		var/target_zone = ran_zone(check_zone(user.zone_selected, target))
		var/datum/limb/affecting = target:get_limb(target_zone)

		if (!affecting)
			return
		if(affecting.limb_status & LIMB_DESTROYED)
			to_chat(user, "What [affecting.display_name]?")
			return
		var/hit_area = affecting.display_name

		var/mob/living/carbon/human/H = target
		if((user != target) && !H.check_shields(COMBAT_TOUCH_ATTACK, 14, "melee"))
			return

		if (target != user && !prob(target.modify_by_armor(100, MELEE, penetration, target_zone)))
			visible_message(span_danger("[user] tries to stab [target] in \the [hit_area] with [src], but the attack is deflected by armor!"))
			user.temporarilyRemoveItemFromInventory(src)
			qdel(src)
			return

		visible_message(span_danger("[user] stabs [target] in \the [hit_area] with [src]!"))

		if(affecting.take_damage_limb(3))
			target:UpdateDamageIcon()

	else
		visible_message(span_danger("[user] stabs [target] with [src]!"))
		target.take_limb_damage(3)// 7 is the same as crowbar punch

	reagents.reaction(target, INJECT)
	var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
	reagents.trans_to(target, syringestab_amount_transferred)
	desc += " It is broken."
	mode = SYRINGE_BROKEN
	add_mob_blood(target)
	update_icon()


/obj/item/reagent_containers/syringe/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50

/obj/item/reagent_containers/syringe/ld50_syringe/afterattack(obj/target, mob/user , flag)
	if(!target.reagents)
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, span_warning("The syringe is full."))
				return

			if(ismob(target))
				if(iscarbon(target))//I Do not want it to suck 50 units out of people
					to_chat(usr, span_warning("This needle isn't designed for drawing blood."))
					return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, span_warning("[target] is empty."))
					return

				if(!target.is_drawable())
					to_chat(user, span_warning("You cannot directly remove reagents from this object."))
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, span_notice("You fill the syringe with [trans] units of the solution."))
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, span_warning("[src] is empty."))
				return

			if(!target.is_injectable() && !ismob(target))
				to_chat(user, span_warning("You cannot directly fill this object."))
				return
			if(target.reagents.holder_full())
				to_chat(user, span_warning("[target] is full."))
				return

			if(ismob(target) && target != user)
				user.visible_message(span_danger("[user] is trying to inject [target] with a giant syringe!"))
				if(!do_after(user, 30 SECONDS, NONE, target, BUSY_ICON_DANGER, BUSY_ICON_DANGER))
					return
				user.visible_message(span_warning("[user] injects [target] with a giant syringe!"))
			spawn(5)
				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				if(iscarbon(target) && locate(/datum/reagent/blood) in reagents.reagent_list)
					var/mob/living/carbon/C = target
					C.inject_blood(src, amount_per_transfer_from_this)
				else
					reagents.reaction(target, INJECT)
					trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, span_notice("You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."))
				if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////



/obj/item/reagent_containers/syringe/inaprovaline
	name = "syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 15)

/obj/item/reagent_containers/syringe/inaprovaline/Initialize(mapload)
	. = ..()
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/reagent_containers/syringe/dylovene
	name = "syringe (dylovene)"
	desc = "Contains anti-toxins."
	list_reagents = list(/datum/reagent/medicine/dylovene = 15)

/obj/item/reagent_containers/syringe/dylovene/Initialize(mapload)
	. = ..()
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents. Can also be used to treat infected wounds."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 15)

/obj/item/reagent_containers/syringe/antiviral/Initialize(mapload)
	. = ..()
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/reagent_containers/syringe/drugs
	name = "syringe (drugs)"
	desc = "Contains aggressive drugs meant for torture."
	list_reagents = list(/datum/reagent/space_drugs = 5, /datum/reagent/toxin/mindbreaker = 5, /datum/reagent/cryptobiolin = 5)

/obj/item/reagent_containers/syringe/drugs/Initialize(mapload)
	. = ..()
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/reagent_containers/syringe/ld50_syringe/choral
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 50)

/obj/item/reagent_containers/syringe/ld50_syringe/choral/Initialize(mapload)
	. = ..()
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/reagent_containers/syringe/mixed
	name = "syringe (mixed)"
	desc = "Contains inaprovaline & dylovene."
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 7, /datum/reagent/medicine/dylovene = 8)

/obj/item/reagent_containers/syringe/mixed/Initialize(mapload)
	. = ..()
	mode = SYRINGE_INJECT
	update_icon()
