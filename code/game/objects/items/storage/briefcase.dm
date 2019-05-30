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

/obj/item/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	//..()

	log_combat(user, M, "attack", src)
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)")

	if (M.stat < 2 && M.health < 50 && prob(90))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/P = H.head
			if(istype(P) && P.flags_inventory & BLOCKSHARPOBJ && prob(80))
				to_chat(M, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
				return
		var/time = rand(2, 6)
		if (prob(75))
			M.KnockOut(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='danger'>[] has been knocked unconscious!</span>", M), 1, "<span class='warning'> You hear someone fall.</span>", 2)
	else
		to_chat(M, text("<span class='warning'> [] tried to knock you unconcious!</span>",user))
		M.adjust_blurriness(3)

	return
