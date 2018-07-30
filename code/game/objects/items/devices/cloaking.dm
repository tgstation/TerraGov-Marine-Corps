
//chameleon projector
//cloaking device

/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	origin_tech = "syndicate=4;magnets=4"
	var/chameleon_on = FALSE
	var/datum/effect_system/spark_spread/spark_system
	var/chameleon_cooldown

/obj/item/device/chameleon/New()
	..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/device/chameleon/Dispose()
	if(spark_system)
		cdel(spark_system)
		spark_system = null
	. = ..()

/obj/item/device/chameleon/dropped(mob/user)
	disrupt(user)

/obj/item/device/chameleon/equipped(mob/user, slot)
	disrupt(user)

/obj/item/device/chameleon/attack_self(mob/user)
	toggle(user)

/obj/item/device/chameleon/proc/toggle(mob/user)
	if(chameleon_cooldown >= world.time) return
	if(!ishuman(user)) return
	playsound(get_turf(src), 'sound/effects/pop.ogg', 25, 1, 3)
	chameleon_on = !chameleon_on
	chameleon_cooldown = world.time + 20
	if(chameleon_on)
		user.alpha = 25
		user << "<span class='notice'>You activate the [src].</span>"
		spark_system.start()
	else
		user.alpha = initial(user.alpha)
		user << "<span class='notice'>You deactivate the [src].</span>"
		spark_system.start()

/obj/item/device/chameleon/proc/disrupt(mob/user)
	if(chameleon_on)
		spark_system.start()
		user.alpha = initial(user.alpha)
		chameleon_cooldown = world.time + 50
		chameleon_on = FALSE




/obj/item/device/cloaking_device
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon_state = "shield0"
	var/active = 0.0
	flags_atom = FPRINT|CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"


/obj/item/device/cloaking_device/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The cloaking device is now active."
		src.icon_state = "shield1"
	else
		user << "\blue The cloaking device is now inactive."
		src.icon_state = "shield0"
	src.add_fingerprint(user)
	return

/obj/item/device/cloaking_device/emp_act(severity)
	active = 0
	icon_state = "shield0"
	..()
