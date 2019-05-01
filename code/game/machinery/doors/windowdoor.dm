/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	max_integrity = 150 //If you change this, consiter changing ../door/window/brigdoor/ health at the bottom of this .dm file
	visible = 0.0
	use_power = FALSE
	flags_atom = ON_BORDER
	opacity = FALSE
	var/obj/item/circuitboard/airlock/electronics = null
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	air_properties_vary_with_direction = 1

/obj/machinery/door/window/New()
	..()
	if (src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state

/obj/machinery/door/window/Destroy()
	density = FALSE
	playsound(src, "shatter", 50, 1)
	. = ..()

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if (!( ismob(AM) ))
		var/obj/machinery/bot/bot = AM
		if(istype(bot))
			if(density && src.check_access(bot.botcard))
				open()
				sleep(50)
				close()
		else if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(density)
				if(mecha.occupant && src.allowed(mecha.occupant))
					open()
					sleep(50)
					close()
		return
	var/mob/M = AM // we've returned by here if M is not a mob
	add_fingerprint(M)
	if (!( SSticker ))
		return
	if (src.operating)
		return
	if (src.density && M.mob_size > MOB_SIZE_SMALL && src.allowed(AM))
		open()
		if(src.check_access(null))
			sleep(50)
		else //secure doors close faster
			sleep(20)
		close()
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return TRUE

/obj/machinery/door/window/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	if(get_dir(loc, target) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/window/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return FALSE
	if (!SSticker)
		return FALSE
	if(!src.operating) //in case of emag
		src.operating = 1
	flick(text("[]opening", src.base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 25, 1)
	src.icon_state = text("[]open", src.base_state)
	sleep(10)

	src.density = FALSE

	if(operating == 1) //emag again
		src.operating = 0
	return TRUE

/obj/machinery/door/window/close()
	if (src.operating)
		return 0
	src.operating = 1
	flick(text("[]closing", src.base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 25, 1)
	src.icon_state = src.base_state

	src.density = TRUE

	sleep(10)

	src.operating = 0
	return TRUE

/obj/machinery/door/window/take_damage(var/damage)
	src.obj_integrity = max(0, src.obj_integrity - damage)
	if (src.obj_integrity <= 0)
		var/obj/item/shard/S = new(loc)
		transfer_fingerprints_to(S)
		var/obj/item/stack/cable_coil/CC = new(loc)
		transfer_fingerprints_to(CC)
		CC.amount = 2
		var/obj/item/circuitboard/airlock/ae
		if(!electronics)
			ae = new/obj/item/circuitboard/airlock( src.loc )
			if(!src.req_access)
				src.check_access()
			if(src.req_access.len)
				ae.conf_access = src.req_access
			else if (src.req_one_access.len)
				ae.conf_access = src.req_one_access
				ae.one_access = TRUE
		else
			ae = electronics
			electronics = null
			ae.loc = src.loc
		transfer_fingerprints_to(ae)
		if(operating == -1)
			ae.icon_state = "door_electronics_smoked"
			operating = 0
		src.density = FALSE
		qdel(src)
		return

/obj/machinery/door/window/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.ammo.damage)
		take_damage(round(Proj.ammo.damage / 2))
	return TRUE

//When an object is thrown at the window
/obj/machinery/door/window/hitby(AM as mob|obj)

	..()
	visible_message("<span class='danger'>The glass door was hit by [AM].</span>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	take_damage(tforce)
	//..() //Does this really need to be here twice? The parent proc doesn't even do anything yet. - Nodrak
	return


/obj/machinery/door/window/attack_ai(mob/user as mob)
	return src.attack_hand(user)

//Slashing windoors
/obj/machinery/door/window/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	M.visible_message("<span class='danger'>[M] smashes against [src]!</span>", \
	"<span class='danger'>You smash against [src]!</span>", null, 5)
	var/damage = 25
	if(M.mob_size == MOB_SIZE_BIG)
		damage = 40
	take_damage(damage)

/obj/machinery/door/window/attack_hand(mob/user)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
			visible_message("<span class='danger'>[user] smashes against the [src.name].</span>", 1)
			take_damage(25)
			return
	return try_to_activate_door(user)

/obj/machinery/door/window/attackby(obj/item/I, mob/user)

	//If it's in the process of opening/closing, ignore the click
	if (src.operating == 1)
		return

	//Emags and ninja swords? You may pass.
	if (density && istype(I, /obj/item/card/emag))
		operating = -1
		flick("[src.base_state]spark", src)
		sleep(6)
		open()
		return TRUE

	//If it's emagged, crowbar can pry electronics out.
	if (src.operating == -1 && iscrowbar(I))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
		user.visible_message("[user] removes the electronics from the windoor.", "You start to remove electronics from the windoor.")
		if (do_after(user,40, TRUE, 5, BUSY_ICON_BUILD))
			to_chat(user, "<span class='notice'>You removed the windoor electronics!</span>")

			var/obj/structure/windoor_assembly/wa = new/obj/structure/windoor_assembly(src.loc)
			if (istype(src, /obj/machinery/door/window/brigdoor))
				wa.secure = "secure_"
				wa.name = "Secure Wired Windoor Assembly"
			else
				wa.name = "Wired Windoor Assembly"
			if (src.base_state == "right" || src.base_state == "rightsecure")
				wa.facing = "r"
			wa.setDir(dir)
			wa.state = "02"
			wa.update_icon()

			var/obj/item/circuitboard/airlock/ae
			if(!electronics)
				ae = new/obj/item/circuitboard/airlock( src.loc )
				if(!src.req_access)
					src.check_access()
				if(src.req_access.len)
					ae.conf_access = src.req_access
				else if (src.req_one_access.len)
					ae.conf_access = src.req_one_access
					ae.one_access = TRUE
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
			ae.icon_state = "door_electronics_smoked"

			operating = 0
			qdel(src)
			return

	if(!(I.flags_item & NOBLUDGEON) && I.force && density) //trying to smash windoor with item
		var/aforce = I.force
		user.changeNext_move(I.attack_speed)
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
		visible_message("<span class='danger'>[src] was hit by [I].</span>")
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return TRUE
	else
		return try_to_activate_door(user)




/obj/machinery/door/window/brigdoor
	name = "Secure Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(ACCESS_MARINE_BRIG)
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)


//theseus brig doors
/obj/machinery/door/window/brigdoor/theseus
	name = "Cell"
	id = "Cell"
	max_integrity = 500

/obj/machinery/door/window/brigdoor/theseus/cell_1
	name = "Cell 1"
	id = "Cell 1"

/obj/machinery/door/window/brigdoor/theseus/cell_2
	name = "Cell 2"
	id = "Cell 2"

/obj/machinery/door/window/brigdoor/theseus/cell_3
	name = "Cell 3"
	id = "Cell 3"

/obj/machinery/door/window/brigdoor/theseus/cell_4
	name = "Cell 4"
	id = "Cell 4"

/obj/machinery/door/window/brigdoor/theseus/cell_5
	name = "Cell 5"
	id = "Cell 5"

/obj/machinery/door/window/brigdoor/theseus/cell_6
	name = "Cell 6"
	id = "Cell 6"

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"
