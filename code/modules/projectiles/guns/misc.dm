//-------------------------------------------------------
//Toy rocket launcher.

/obj/item/weapon/gun/launcher/rocket/toy //Fires dummy rockets, like a toy gun
	name = "\improper toy rocket launcher"
	desc = "Where did this come from?"
	current_mag = /obj/item/ammo_magazine/internal/launcher/rocket/toy
	gun_skill_category = GUN_SKILL_FIREARMS


//Syringe Gun

/obj/item/weapon/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 4.0
	var/list/syringes = new/list()
	var/max_syringes = 1

/obj/item/weapon/gun/syringe/examine_ammo_count(mob/user)
	if(user == loc)
		to_chat(user, span_notice("[syringes.len] / [max_syringes] syringes."))

/obj/item/weapon/gun/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I
		if(S.mode == 2)
			to_chat(user, span_warning("This syringe is broken!"))
			return

		if(length(syringes) >= max_syringes)
			to_chat(user, span_warning("[src] cannot hold more syringes."))
			return

		user.transferItemToLoc(I, src)
		syringes += I
		update_icon()
		to_chat(user, span_notice("You put the syringe in [src]."))
		to_chat(user, span_notice("[length(syringes)] / [max_syringes] syringes."))


/obj/item/weapon/gun/syringe/afterattack(obj/target, mob/user , flag)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/syringe/update_icon()
	if(syringes.len)
		icon_state = base_gun_icon
	else
		icon_state = base_gun_icon + "_e"


/obj/item/weapon/gun/syringe/Fire()
	if(syringes.len)
		INVOKE_ASYNC(src, .proc/fire_syringe, target, gun_user)
	else
		to_chat(gun_user, span_warning("[src] is empty."))

/obj/item/weapon/gun/syringe/proc/fire_syringe(atom/target, mob/user)
	if (locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/reagent_containers/syringe/S = syringes[1]
		if((!S) || (!S.reagents))	//ho boy! wot runtimes!
			return
		S.reagents.trans_to(D, S.reagents.total_volume)
		syringes -= S
		update_icon()
		qdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.name + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						log_combat(user, M, "shot", src, "Reagents: ([R])")

					else
						M.log_message("<b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[key_name(M)]</b> with a <b>[src]</b> Reagents: ([R])", LOG_ATTACK)

					M.visible_message(span_danger("[M] is hit by the syringe!"))

					if(M.can_inject())
						if(D.reagents)
							D.reagents.reaction(M, INJECT)
							D.reagents.trans_to(M, 15)
					else
						M.visible_message(span_danger("The syringe bounces off [M]!"))

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if (D) spawn(10) qdel(D)

		return

/obj/item/weapon/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to four syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 4


/obj/effect/syringe_gun_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "null"
	anchored = TRUE
	density = FALSE

/obj/effect/syringe_gun_dummy/Initialize()
	create_reagents(15)
	return ..()
