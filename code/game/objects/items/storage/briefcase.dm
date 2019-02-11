/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags_atom = CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_storage_space = 16

/obj/item/storage/briefcase/New()
	..()

/obj/item/storage/briefcase/attack(mob/living/M, mob/living/user, def_zone)
	if((CLUMSY in user.mutations) && prob(50))
		var/headless = TRUE
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.has_limb(HEAD))
				headless = FALSE
				H.visible_message(user, "<span class='warning'>/the [src] slips out of [H]'s hand and hits [H.p_their()] head.</span>", "<span class='warning'>/the [src] slips out of your hand and hits your head.</span>")
				var/datum/limb/L = H.get_limb("head")
				L.take_damage(10)
		if(headless)
			user.visible_message(user, "<span class='warning'>[user] fumbles with /the [src] and whacks [user.p_them()]self.</span>", "<span class='warning'>You fumble with /the [src] and whack yourself.</span>")
			user.take_limb_damage(10)
		user.KnockOut(2)
		return FALSE

	. = ..()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.has_limb(HEAD))
			return

	if (M.stat == CONSCIOUS && M.health < 50 && prob(90) && (ishuman(M) || ismonkey(M)) && user.zone_selected == "head")
		if(ishuman(M))
			var/lawyering = M.getarmor("head", "melee")
			if(lawyering > 5 && prob(lawyering + 30))
				to_chat(M, "<span class = 'warning'>Your armor protects you from the blow to the head!</span>")
				return
		var/time = rand(2, 6)
		if (prob(75))
			M.KnockOut(time)
		else if(!M.is_mob_incapacitated())
			M.KnockDown(time)
			user.visible_message("<span class='danger'>[M] has been knocked down!</span>", "<span class='danger'>You knock [M] down!</B>", null, 5)

