

///***MINES***///
//Mines have an invisible "tripwire" atom that explodes when crossed
//Stepping directly on the mine will also blow it up
/obj/item/explosive/mine
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the United States Colonial Marines."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "m20"
	force = 5.0
	w_class = 2
	//layer = MOB_LAYER - 0.1 //You can't just randomly hide claymores under boxes. Booby-trapping bodies is fine though
	throwforce = 5.0
	throw_range = 6
	throw_speed = 3
	unacidable = 1
	flags_atom = FPRINT|CONDUCT

	var/iff_signal = ACCESS_IFF_MARINE
	var/triggered = 0
	var/armed = 0 //Will the mine explode or not
	var/trigger_type = "explosive" //Calls that proc
	var/obj/effect/mine_tripwire/tripwire
	/*
		"explosive"
		//"incendiary" //New bay//
	*/

	ex_act() trigger_explosion() //We don't care about how strong the explosion was.
	emp_act() trigger_explosion() //Same here. Don't care about the effect strength.

/obj/item/explosive/mine/Dispose()
	if(tripwire)
		cdel(tripwire)
		tripwire = null
	. = ..()

/obj/item/explosive/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the United States Colonial Marines. It has been modified for use by the W-Y PMC forces."
	icon_state = "m20p"
	iff_signal = ACCESS_IFF_PMC

//Arming
/obj/item/explosive/mine/attack_self(mob/living/user)
	if(locate(/obj/item/explosive/mine) in get_turf(src))
		user << "<span class='warning'>There already is a mine at this position!</span>"
		return

	if(user.loc && user.loc.density)
		user << "<span class='warning'>You can't plant a mine here.</span>"
		return

	/*if(user.z == MAIN_SHIP_Z_LEVEL || user.z == LOW_ORBIT_Z_LEVEL) // Almayer or dropship transit level
		user << "<span class='warning'>You can't plant a mine on a spaceship!</span>"
		return*/

	if(!armed)
		user.visible_message("<span class='notice'>[user] starts deploying [src].</span>", \
		"<span class='notice'>You start deploying [src].</span>")
		if(!do_after(user, 40, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='notice'>[user] stops deploying [src].</span>", \
		"<span class='notice'>You stop deploying \the [src].</span>")
			return
		user.visible_message("<span class='notice'>[user] finishes deploying [src].</span>", \
		"<span class='notice'>You finish deploying [src].</span>")
		anchored = 1
		armed = 1
		playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
		icon_state += "_armed"
		user.drop_held_item()
		dir = user.dir //The direction it is planted in is the direction the user faces at that time
		var/tripwire_loc = get_turf(get_step(loc, dir))
		tripwire = new /obj/effect/mine_tripwire(tripwire_loc)
		tripwire.linked_claymore = src

//Disarming
/obj/item/explosive/mine/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		if(anchored)
			user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", \
			"<span class='notice'>You start disarming [src].</span>")
			if(!do_after(user, 80, TRUE, 5, BUSY_ICON_FRIENDLY))
				user.visible_message("<span class='warning'>[user] stops disarming [src].", \
				"<span class='warning'>You stop disarming [src].")
				return
			user.visible_message("<span class='notice'>[user] finishes disarming [src].", \
			"<span class='notice'>You finish disarming [src].")
			anchored = 0
			armed = 0
			icon_state = copytext(icon_state,1,-6)
			if(tripwire)
				cdel(tripwire)
				tripwire = null

//Mine can also be triggered if you "cross right in front of it" (same tile)
/obj/item/explosive/mine/Crossed(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.lying)//so dragged corpses don't trigger mines.
			Bumped(A)

/obj/item/explosive/mine/Bumped(mob/living/carbon/human/H)
	if(!armed || triggered) return

	if((istype(H) && H.get_target_lock(iff_signal)) || isrobot(H)) return

	H.visible_message("<span class='danger'>\icon[src] The [name] clicks as [H] moves in front of it.</span>", \
	"<span class='danger'>\icon[src] The [name] clicks as you move in front of it.</span>", \
	"<span class='danger'>You hear a click.</span>")

	triggered = 1
	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	trigger_explosion()

//Note : May not be actual explosion depending on linked method
/obj/item/explosive/mine/proc/trigger_explosion()
	set waitfor = 0

	switch(trigger_type)
		if("explosive")
			if(tripwire)
				explosion(tripwire.loc, -1, -1, 2)
				cdel(src)

/obj/item/explosive/mine/attack_alien(mob/living/carbon/Xenomorph/M)
	if(triggered) //Mine is already set to go off
		return

	if(M.a_intent == "help") return
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1)

	//We move the tripwire randomly in either of the four cardinal directions
	triggered = 1
	if(tripwire)
		var/direction = pick(cardinal)
		var/step_direction = get_step(src, direction)
		tripwire.forceMove(step_direction)
	trigger_explosion()

/obj/item/explosive/mine/flamer_fire_act() //adding mine explosions
	var/turf/T = loc
	cdel(src)
	explosion(T, -1, -1, 2)


/obj/effect/mine_tripwire
	name = "claymore tripwire"
	anchored = 1
	mouse_opacity = 0
	invisibility = 101
	unacidable = 1 //You never know
	var/obj/item/explosive/mine/linked_claymore

/obj/effect/mine_tripwire/Dispose()
	if(linked_claymore)
		linked_claymore = null
	. = ..()

/obj/effect/mine_tripwire/Crossed(atom/A)
	if(!linked_claymore)
		cdel(src)
		return

	if(linked_claymore.triggered) //Mine is already set to go off
		return

	if(linked_claymore && ismob(A))
		linked_claymore.Bumped(A)