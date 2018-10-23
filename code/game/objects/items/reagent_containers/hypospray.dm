////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_container/hypospray
	name = "hypospray"
	desc = "The hypospray is a sterile, air-needle reusable autoinjector for rapid administration of drugs to patients with customizable dosages. Comes complete with an internal reagent analyzer and digital labeler. Handy."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo_base"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,3,5,10,15)
	volume = 60
	possible_transfer_amounts = null
	container_type = OPENCONTAINER
	flags_equip_slot = SLOT_WAIST
	w_class = 2.0
	var/skilllock = 1

/obj/item/reagent_container/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/reagent_container/hypospray/attack(mob/M, mob/living/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class ='danger'>[src] is empty!</span>")
		return
	if (!istype(M))
		return
	if (reagents.total_volume)
		if(skilllock && user.mind && user.mind.cm_skills && user.mind.cm_skills.medical < SKILL_MEDICAL_CHEM)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to use the [src].</span>",
			"<span class='notice'>You fumble around figuring out how to use the [src].</span>")
			var/fumbling_time = SKILL_TASK_EASY
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return

		if(M != user && M.stat != DEAD && M.a_intent != "help" && !M.is_mob_incapacitated() && ((M.mind && M.mind.cm_skills && M.mind.cm_skills.cqc >= SKILL_CQC_MP) || isYautja(M))) // preds have null skills
			user.KnockDown(3)
			log_combat(M, user, "blocked", addition="using their cqc skill (hypospray injection)")
			msg_admin_attack("[user.name] ([user.ckey]) got robusted by the cqc of [M.name] ([M.key]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			M.visible_message("<span class='danger'>[M]'s reflexes kick in and knock [user] to the ground before they could use \the [src]'!</span>", \
				"<span class='warning'>You knock [user] to the ground before they inject you!</span>", null, 5)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
			return FALSE

		to_chat(user, "<span class='notice'>You inject [M] with [src]</span>.")
		to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
		playsound(loc, 'sound/items/hypospray.ogg', 50, 1)

		reagents.reaction(M, INJECT)
		if(M.reagents)

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			log_combat(user, M, "injected", src, "Reagents: [contained]")
			msg_admin_attack("[user.name] ([user.ckey]) injected [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'> [trans] units injected. [reagents.total_volume] units remaining in [src]. </span>")
			update_icon()

	return TRUE

/obj/item/reagent_container/hypospray/on_reagent_change()
	update_icon()

/obj/item/reagent_container/hypospray/pickup(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_container/hypospray/dropped(mob/user)
	. = ..()
	update_icon()

/obj/item/reagent_container/hypospray/attack_hand()
	. = ..()
	update_icon()


/obj/item/reagent_container/hypospray/advanced
	icon_state = "hypo"
	container_type = REFILLABLE|DRAINABLE
	var/core_name = "hypospray"

/obj/item/reagent_container/hypospray/advanced/tricordrazine
	list_reagents = list("tricordrazine" = 60)

/obj/item/reagent_container/hypospray/advanced/tricordrazine/New()
	. = ..()
	update_icon()


/obj/item/reagent_container/hypospray/advanced/oxycodone
	list_reagents = list("oxycodone" = 60)

/obj/item/reagent_container/hypospray/advanced/oxycodone/New()
	. = ..()
	update_icon()

/obj/item/reagent_container/hypospray/advanced/attack_self(mob/user)
	var/str = copytext(reject_bad_text(input(user,"Label text?", "Set label", "")), 1, MAX_NAME_LEN)
	if(!str || !length(str))
		to_chat(user, "<span class='notice'>Invalid text.</span>")
		return
	to_chat(user, "<span class='notice'>You label [src] as \"[str]\".</span>")
	name = "[core_name] ([str])"

/obj/item/reagent_container/hypospray/advanced/update_icon()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)			filling.icon_state = "[icon_state]-10"
			if(10 to 24) 		filling.icon_state = "[icon_state]10"
			if(25 to 49)		filling.icon_state = "[icon_state]25"
			if(50 to 74)		filling.icon_state = "[icon_state]50"
			if(75 to 79)		filling.icon_state = "[icon_state]75"
			if(80 to 90)		filling.icon_state = "[icon_state]80"
			if(91 to INFINITY)	filling.icon_state = "[icon_state]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/reagent_container/hypospray/advanced/examine(mob/user as mob)
	if(get_dist(user,src) > 2)
		to_chat(user, "<span class = 'warning'>You're too far away to see [src]'s reagent display!</span>")
		return

	if(!isnull(reagents))
		var/dat = "\n \t <span class='notice'><b>Total Reagents:</b> [reagents.total_volume]/[volume]. <b>Dosage Size:</b> [min(reagents.total_volume, amount_per_transfer_from_this)]</span></br>"
		if(reagents.reagent_list.len > 0)
			for (var/datum/reagent/R in reagents.reagent_list)
				var/percent = round(R.volume / max(0.01 , reagents.total_volume * 0.01),0.01)
				var/dose = round(min(reagents.total_volume, amount_per_transfer_from_this) * percent * 0.01,0.01)
				if(R.scannable)
					dat += "\n \t <b>[R.name]:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
				else
					dat += "\n \t <b>Unknown:</b> [R.volume]|[percent]% <b>Amount per dose:</b> [dose]</br>"
		if(dat)
			to_chat(user, "<span class = 'notice'>[src]'s reagent display shows the following contents: [dat]</span>")
	. = ..()
