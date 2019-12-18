/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags_atom = CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 3
	max_storage_space = 16

/obj/item/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	//..()

	log_combat(user, M, "attack", src)

	if (M.stat < 2 && M.health < 50 && prob(90))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/P = H.head
			if(istype(P) && P.flags_inventory & BLOCKSHARPOBJ && prob(80))
				to_chat(M, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
				return
		var/time = rand(40, 80)
		if (prob(75))
			M.Unconscious(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		visible_message("span class='danger'>[M] has been knocked unconscious!</span>", null, "<span class='warning'> You hear someone fall.</span>")
	else
		to_chat(M, text("<span class='warning'> [] tried to knock you unconcious!</span>",user))
		M.adjust_blurriness(3)

	return
