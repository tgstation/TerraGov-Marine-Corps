/obj/item/reagent_container/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	w_class = 1
	volume = 5
	container_type = TRANSPARENT

/obj/item/reagent_container/dropper/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(reagents.total_volume > 0)
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[target] is full.</span>")
			return

		if(!target.is_injectable() && !isliving(target))
			to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
			return

		var/trans = 0
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)

		if(isliving(target))

			var/mob/living/M = target
			var/obj/item/safe_thing = null
			var/eyes = M.has_eyes() ? TRUE : FALSE
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.are_eyes_covered(check_mask = FALSE, check_head = FALSE))
					safe_thing = H.glasses
				if(H.are_eyes_covered(check_head = FALSE, check_eyes = FALSE))
					safe_thing = H.wear_mask
				if(H.are_eyes_covered(check_mask = FALSE, check_eyes = FALSE))
					safe_thing = H.head
			else if(ismonkey(M))
				var/mob/living/carbon/monkey/B = M
				if(B.are_eyes_covered(check_head = FALSE, check_eyes = FALSE))
					safe_thing = B.wear_mask

			if(safe_thing)
				if(!safe_thing.reagents)
					safe_thing.create_reagents(100)

				reagents.reaction(safe_thing, TOUCH, fraction)
				trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this)

				M.visible_message("<span class='danger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>", \
									"<span class='danger'>[user] tries to squirt something [eyes ? "into your eyes" : "on your face"], but fails!</span>")

				to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution.</span>")
				update_icon()
				return

			reagents.reaction(M, TOUCH, amount_per_transfer_from_this)

			var/R
			if(reagents)
				for(var/datum/reagent/A in src.reagents.reagent_list)
					R += A.id + " ("
					R += num2text(A.volume/volume * amount_per_transfer_from_this) + "),"
			log_combat(user, M, "squirted", R)
			msg_admin_attack("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) squirted [key_name(M)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[M]'>FLW</a>) with [src.name]. Reagents: [R] (INTENT: [uppertext(user.a_intent)])")

			user.visible_message("<span class='danger'>[user] squirts something [eyes ? "into [target]'s eyes" : "on [target]'s face"]!</span>", \
								"<span class='danger'>[user] squirts something [eyes ? "into your eyes" : "on your face"]!</span>")

			if(eyes) //if they have eyes, otherwise won't absorb the chem.
				trans = reagents.trans_to(target, amount_per_transfer_from_this)
			else
				trans = reagents.remove_all(amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution.</span>")

	else

		if(!target.is_drawable(FALSE)) //No drawing from mobs here
			to_chat(user, "<span class='notice'>You cannot directly remove reagents from [target].</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the solution.</span>")

	update_icon()

/obj/item/reagent_container/dropper/update_icon()
	var/filled = reagents.total_volume > 0 ? 1 : 0
	icon_state = "dropper[filled]"
