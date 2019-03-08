////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/reagent_container/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	matter = list("glass" = 150)
	container_type = AMOUNT_SKILLCHECK
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = 1
	flags_item = NOBLUDGEON
	sharp = IS_SHARP_ITEM_SIMPLE
	var/mode = SYRINGE_DRAW

/obj/item/reagent_container/syringe/New()
	. = ..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_container/syringe/on_reagent_change()
	update_icon()

/obj/item/reagent_container/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_container/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_container/syringe/attack_self(mob/user as mob)

	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/reagent_container/syringe/attack_hand()
	..()
	update_icon()

/obj/item/reagent_container/syringe/attack_paw()
	return attack_hand()

/obj/item/reagent_container/syringe/attackby(obj/item/I as obj, mob/user as mob)
	return

/obj/item/reagent_container/syringe/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, "<span class='warning'>This syringe is broken!</span>")
		return

	if (user.a_intent == INTENT_HARM && ismob(target) && target != user)
		if((CLUMSY in user.mutations) && prob(50))
			target = user
		var/mob/M = target
		if(M != user && M.stat != DEAD && M.a_intent != INTENT_HELP && !M.is_mob_incapacitated() && ((M.mind && M.mind.cm_skills && M.mind.cm_skills.cqc >= SKILL_CQC_MP) || isyautja(M))) // preds have null skills
			user.KnockDown(3)
			log_combat(M, user, "blocked", addition="using their cqc skill (syringe injection)")
			msg_admin_attack("[ADMIN_TPMONTY(usr)] got robusted by the cqc of [ADMIN_TPMONTY(M)].")
			M.visible_message("<span class='danger'>[M]'s reflexes kick in and knock [user] to the ground before they could use \the [src]'!</span>", \
				"<span class='warning'>You knock [user] to the ground before they could inject you!</span>", null, 5)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
			return

		syringestab(target, user)
		return

	var/injection_time = 30
	if(user.mind && user.mind.cm_skills)
		injection_time = max(5, 50 - 10*user.mind.cm_skills.medical)

	var/target_zone = user.zone_selected
	if(isliving(target))
		var/mob/living/L = target
		if(!L.can_inject(user, TRUE, target_zone))
			return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.holder_full())
				to_chat(user, "<span class='warning'>The syringe is full.</span>")
				return

			if(iscarbon(target))//Blood!
				var/mob/living/carbon/C = target
				var/amount = src.reagents.maximum_volume - src.reagents.total_volume
				if(C.get_blood_id() && reagents.has_reagent(C.get_blood_id()))
					to_chat(user, "<span class='warning'>There is already a blood sample in this syringe.</span>")
					return
				if(target != user)
					user.visible_message("<span class='warning'>[user] is trying to take a blood sample from [target]!</span>", \
						"<span class='danger'>You start trying to take a blood sample from [target]...</span>")
					if(!do_mob(user, target, injection_time, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
						return
				if(!C.take_blood(src, amount, user, target_zone))
					return

				on_reagent_change()
				reagents.handle_reactions()

				user.visible_message("<span clas='warning'>[user] takes a blood sample from [target == user ? "[user.p_them()]self" : "target"].</span>",
										"<span class='notice'>You take a blood sample from [target == user ? "yourself" : "target"].</span>", null, 4)

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty.")
					return

				if(!target.is_drawable())
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill the syringe with [trans] units of the solution.</span>")
			if (reagents.holder_full())
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='warning'>The syringe is empty.</span>")
				return
			if(istype(target, /obj/item/implantcase/chem))
				return

			if(!target.is_injectable() && !ismob(target))
				to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
				return
			if(target.reagents.holder_full())
				to_chat(user, "<span class='warning'>[target] is full.</span>")
				return

			if(isliving(target))
				var/mob/living/M = target
				if(M != user)
					user.visible_message("<span class='danger'>[user] is trying to inject [target]!</span>", "<span class='notice'>You start trying to inject [target]...</span>", null, 5)
					if(!do_mob(user, target, injection_time, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
						return
					if(!M.can_inject(user, FALSE, target_zone))
						return

				user.visible_message("<span class='warning'>[user] injects [target == user ? "[user.p_them()]self" : "target"] with the syringe!</span>",
									"<span class='notice'>You inject [target == user ? "yourself" : "target"] with [src]!</span>", null, 4)

				var/list/injected = list()
				for(var/datum/reagent/R in reagents.reagent_list)
					injected += R.name
				var/contained = english_list(injected)
				log_combat(user, M, "injected", src, "Reagents: [contained]")
				msg_admin_attack("[ADMIN_TPMONTY(usr)] injected [ADMIN_TPMONTY(M)] with [src.name]. Reagents: [contained].")

				reagents.reaction(target, INJECT)


			var/trans = amount_per_transfer_from_this
			if(iscarbon(target) && locate(/datum/reagent/blood) in reagents.reagent_list)
				var/mob/living/carbon/C = target
				C.inject_blood(src, amount_per_transfer_from_this)
			else
				trans = reagents.trans_to(target, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()


/obj/item/reagent_container/syringe/update_icon()
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


/obj/item/reagent_container/syringe/proc/syringestab(mob/living/target as mob, mob/living/carbon/user as mob)

	log_combat(user, target, "attacked", src, "(INTENT: [uppertext(user.a_intent)])")
	msg_admin_attack("[ADMIN_TPMONTY(usr)] attacked [ADMIN_TPMONTY(target)] with [src.name].")

	var/target_zone = get_zone_with_miss_chance(user.zone_selected, target)
	if(!target_zone)
		user.visible_message("<span class='danger'>[user] tries to stab [target] with [src], but misses!",
							"<span class='danger'>You try to stab [target] with [src], but miss!</span>", null, 5)
		return
	var/hit_area
	var/datum/limb/affecting
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		affecting = H.get_limb(target_zone)
		if(affecting.limb_status & LIMB_DESTROYED)
			to_chat(user, "What [affecting.display_name]?")
			return
		hit_area = affecting.display_name
		if((user != target) && H.check_shields(3, "the [name]"))
			return

	var/malpractice = target.getarmor(target_zone, "melee")
	if ((target != user && malpractice > 5 && prob(malpractice/2)) || !target.can_inject(user, FALSE, target_zone))
		user.visible_message("<span class='danger'>[user] tries to stab [target] [hit_area ? "in [hit_area]" : ""] with [src], but the attack is deflected by armor!</span>",
							"<span class='danger'>You try to stab [target] in [hit_area ? "in [hit_area]" : ""] with [src], but the attack is deflected by armor!</span>", null, 5)
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)
		return

	user.visible_message("<span class='danger'>[user] stabs [target] in [hit_area ? "in [hit_area]" : ""] with [src]!</span>",
						"<span class='warning'>You stab [target] in [hit_area ? "in [hit_area]" : ""] with [src]!</span>", null, 5)

	if(ishuman(target))
		affecting.take_damage(3)
	else
		target.take_limb_damage(3)

	reagents.reaction(target, INJECT)
	var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
	reagents.trans_to(target, syringestab_amount_transferred)
	desc += " It is broken."
	mode = SYRINGE_BROKEN
	add_mob_blood(target)
	add_fingerprint(usr)
	update_icon()


/obj/item/reagent_container/syringe/ld50_syringe
	name = "syringe (lethal injection)"
	desc = "A syringe used for lethal injections."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50

/obj/item/reagent_container/syringe/ld50_syringe/afterattack(obj/target, mob/user , flag)
	if(!target.reagents)
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='warning'>The syringe is full.</span>")
				return

			if(ismob(target))
				to_chat(usr, "<span class='warning'>This needle isn't designed for drawing blood.</span>")
				return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty.</span>")
					return

				if(!target.is_drawable())
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill the syringe with [trans] units of the solution.</span>")
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='warning'>[src] is empty.</span>")
				return
			if(istype(target, /obj/item/implantcase/chem))
				return
			if(!target.is_injectable() && !ismob(target))
				to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
				return
			if(target.reagents.holder_full())
				to_chat(user, "<span class='warning'>[target] is full.</span>")
				return

			var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
			if(isliving(target))
				var/mob/living/L = target
				if(!L.can_inject(user, TRUE))
					return
				user.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>")
				if(!do_mob(user, target, 300, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					return
				user.visible_message("<span class='warning'>[user] injects [target] with [src]!</span>")
				if(iscarbon(target) && locate(/datum/reagent/blood) in reagents.reagent_list)
					var/mob/living/carbon/C = L
					C.inject_blood(src, amount_per_transfer_from_this)
			else
				reagents.reaction(target, INJECT)
				trans = reagents.trans_to(target, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")
			if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()
	return


/obj/item/reagent_container/syringe/ld50_syringe/update_icon()
	var/rounded_vol = round(reagents.total_volume,50)
	if(ismob(loc))
		var/mode_t
		switch(mode)
			if (SYRINGE_DRAW)
				mode_t = "d"
			if (SYRINGE_INJECT)
				mode_t = "i"
		icon_state = "[mode_t][rounded_vol]"
	else
		icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"


////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////



/obj/item/reagent_container/syringe/inaprovaline
	name = "syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
	list_reagents = list("inaprovaline" = 15)

/obj/item/reagent_container/syringe/dylovene
	name = "syringe (dylovene)"
	desc = "Contains anti-toxins."
	list_reagents = list("dylovene" = 15)

/obj/item/reagent_container/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents. Can also be used to treat infected wounds."
	list_reagents = list("spaceacillin" = 15)

/obj/item/reagent_container/syringe/drugs
	name = "syringe (drugs)"
	desc = "Contains aggressive drugs meant for torture."
	list_reagents = list("space_drugs" = 5, "mindbreaker" = 5, "cryptobiolin" = 5)

/obj/item/reagent_container/syringe/ld50_syringe/choral
	list_reagents = list("chloralhydrate" = 50)

/obj/item/reagent_container/syringe/mixed
	name = "syringe (mixed)"
	desc = "Contains inaprovaline & dylovene."
	list_reagents = list("inaprovaline" = 7, "dylovene" = 8)