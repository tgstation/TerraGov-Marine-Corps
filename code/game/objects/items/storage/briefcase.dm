/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags_atom = FPRINT|CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_storage_space = 16

/obj/item/storage/briefcase/New()
	..()

/obj/item/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	//..()

	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_limb_damage(10)
		user.KnockOut(2)
		return


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)")

	if (M.stat < 2 && M.health < 50 && prob(90))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/P = H.head
			if(istype(P) && P.flags_inventory & BLOCKSHARPOBJ && prob(80))
				M << "\red The helmet protects you from being hit hard in the head!"
				return
		var/time = rand(2, 6)
		if (prob(75))
			M.KnockOut(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
	else
		M << text("\red [] tried to knock you unconcious!",user)
		M.eye_blurry += 3

	return
