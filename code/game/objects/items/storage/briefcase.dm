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
	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
		user.take_limb_damage(10)
		user.KnockOut(2)
		return

	. = ..()

	log_combat(user, M, "attack", src)
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)")

	if (M.stat != DEAD && M.health < 50 && prob(90) && (ishuman(M) || ismonkey(M)) && def_zone == "head")
		if(ishuman(M))
			var/lawyering = M.getarmor(def_zone, "melee")
			if(prob(lawyering > 5 ? lawyering + 30 : 0))
				to_chat(M, "<span class = 'warning'>Your armor protects you from the blow to the head!</span>")
				return
		var/time = rand(2, 6)
		if (prob(75))
			M.KnockOut(time)
		else
			M.KnockDown(time)
		user.visible_message("<span class='danger'>[M] has been knocked down!</span>", "<span class='danger'>You knock [M] down!</B>", null, 5)

