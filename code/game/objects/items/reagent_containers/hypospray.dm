////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_container/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/items/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	container_type = OPENCONTAINER
	flags_equip_slot = SLOT_WAIST
	var/skilllock = 1

/obj/item/reagent_container/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/reagent_container/hypospray/attack(mob/M, mob/living/user)
	if(!reagents.total_volume)
		to_chat(user, "\red [src] is empty.")
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
			to_chat(user, "\blue [trans] units injected. [reagents.total_volume] units remaining in [src].")

	return TRUE



/obj/item/reagent_container/hypospray/tricordrazine
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients. Contains tricordrazine."
	volume = 30
	list_reagents = list("tricordrazine" = 30)