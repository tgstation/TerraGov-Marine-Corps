/obj/item/weapon/stunprod
	name = "electrified prodder"
	desc = "A specialised prod designed for incapacitating xenomorphic lifeforms with."
	icon_state = "stunbaton"
	item_state = "baton"
	flags_equip_slot = SLOT_WAIST
	force = 12
	throwforce = 7
	w_class = 3
	var/charges = 12
	var/status = 0
	var/mob/foundmob = "" //Used in throwing proc.

	origin_tech = "combat=2"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</b>"
		return (FIRELOSS)

/obj/item/weapon/stunprod/update_icon()
	if(status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"

/obj/item/weapon/stunprod/attack_self(mob/user as mob)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "\red You grab the [src] on the wrong side."
		user.KnockDown(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		user << "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>"
		playsound(src.loc, "sparks", 15, 1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>\The [src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/stunprod/attack(mob/M, mob/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		user << "<span class='danger'>You accidentally hit yourself with the [src]!</span>"
		user.KnockDown(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return

	if(isrobot(M))
		..()
		return

	if(user.a_intent == "hurt")
		return
	else if(!status)
		M.visible_message("<span class='warning'>[M] has been poked with [src] whilst it's turned off by [user].</span>")
		return

	if(status)
		M.KnockDown(6)
		user.lastattacked = M
		M.lastattacker = user
		charges -= 2
		M.visible_message("<span class='danger'>[M] has been prodded with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [M.name] ([M.ckey]) with [src.name]</font>"
		M.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [src.name]</font>"
		log_attack("[user.name] ([user.ckey]) stunned [M.name] ([M.ckey]) with [src.name]")

		playsound(src.loc, 'sound/weapons/Egloves.ogg', 25, 1)
		if(charges < 1)
			status = 0
			update_icon()

	add_fingerprint(user)


/obj/item/weapon/stunprod/emp_act(severity)
	switch(severity)
		if(1)
			charges = 0
		if(2)
			charges = max(0, charges - 5)
	if(charges < 1)
		status = 0
		update_icon()


/obj/item/weapon/stunprod/improved
	charges = 30
	name = "improved electrified prodder"
	desc = "A specialised prod designed for incapacitating xenomorphic lifeforms with. This one seems to be much more effective than its predecessor."
	color = "#FF6666"

	attack(mob/M, mob/user)
		..()
		M.KnockDown(14)

	examine(mob/user)
		..()
		user << "<span class='notice'>It has [charges] charges left.</span>"
