

///***MINES***///
//Mines have an invisible "tripwire" atom that explodes when crossed
//Stepping directly on the mine will also blow it up
/obj/item/explosive/mine
	name = "\improper M20 Claymore anti-personnel mine"
	desc = "The M20 Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "m20"
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_range = 6
	throw_speed = 3
	resistance_flags = UNACIDABLE
	flags_atom = CONDUCT

	var/iff_signal = ACCESS_IFF_MARINE
	var/triggered = FALSE
	var/armed = FALSE //Will the mine explode or not
	var/trigger_type = "explosive" //Calls that proc
	var/obj/effect/mine_tripwire/tripwire

/obj/item/explosive/mine/ex_act()
	. = ..()
	if(!QDELETED(src))
		INVOKE_ASYNC(src, .proc/trigger_explosion)

/obj/item/explosive/mine/emp_act()
	. = ..()
	INVOKE_ASYNC(src, .proc/trigger_explosion)

/obj/item/explosive/mine/Destroy()
	QDEL_NULL(tripwire)
	. = ..()

/obj/item/explosive/mine/update_icon()
	icon_state = "[initial(icon_state)][armed ? "_armed" : ""]"

/obj/item/explosive/mine/pmc
	name = "\improper M20P Claymore anti-personnel mine"
	desc = "The M20P Claymore is a directional proximity triggered anti-personnel mine designed by Armat Systems for use by the TerraGov Marine Corps. It has been modified for use by the NT PMC forces."
	icon_state = "m20p"
	iff_signal = ACCESS_IFF_PMC

//Arming
/obj/item/explosive/mine/attack_self(mob/living/user)
	if(locate(/obj/item/explosive/mine) in get_turf(src))
		to_chat(user, "<span class='warning'>There already is a mine at this position!</span>")
		return

	if(!user.loc || user.loc.density)
		to_chat(user, "<span class='warning'>You can't plant a mine here.</span>")
		return

	if(!armed)
		user.visible_message("<span class='notice'>[user] starts deploying [src].</span>", \
		"<span class='notice'>You start deploying [src].</span>")
		if(!do_after(user, 40, TRUE, src, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='notice'>[user] stops deploying [src].</span>", \
		"<span class='notice'>You stop deploying \the [src].</span>")
			return
		user.visible_message("<span class='notice'>[user] finishes deploying [src].</span>", \
		"<span class='notice'>You finish deploying [src].</span>")
		anchored = TRUE
		armed = TRUE
		playsound(src.loc, 'sound/weapons/mine_armed.ogg', 25, 1)
		update_icon()
		user.drop_held_item()
		setDir(user.dir) //The direction it is planted in is the direction the user faces at that time
		var/tripwire_loc = get_turf(get_step(loc, dir))
		tripwire = new /obj/effect/mine_tripwire(tripwire_loc)
		tripwire.linked_claymore = src

//Disarming
/obj/item/explosive/mine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ismultitool(I) || !anchored)
		return

	user.visible_message("<span class='notice'>[user] starts disarming [src].</span>", \
	"<span class='notice'>You start disarming [src].</span>")

	if(!do_after(user, 80, TRUE, src, BUSY_ICON_FRIENDLY))
		user.visible_message("<span class='warning'>[user] stops disarming [src].", \
		"<span class='warning'>You stop disarming [src].")
		return

	user.visible_message("<span class='notice'>[user] finishes disarming [src].", \
	"<span class='notice'>You finish disarming [src].")
	anchored = FALSE
	armed = FALSE
	update_icon()
	QDEL_NULL(tripwire)

//Mine can also be triggered if you "cross right in front of it" (same tile)
/obj/item/explosive/mine/Crossed(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/L = A
		if(!L.lying)//so dragged corpses don't trigger mines.
			Bumped(A)

/obj/item/explosive/mine/Bumped(mob/living/carbon/human/H)
	. = ..()
	if(!armed || triggered)
		return

	if((istype(H) && H.get_target_lock(iff_signal)))
		return

	H.visible_message("<span class='danger'>[icon2html(src, viewers(H))] The [name] clicks as [H] moves in front of it.</span>", \
	"<span class='danger'>[icon2html(src, viewers(H))] The [name] clicks as you move in front of it.</span>", \
	"<span class='danger'>You hear a click.</span>")

	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	INVOKE_ASYNC(src, .proc/trigger_explosion)

//Note : May not be actual explosion depending on linked method
/obj/item/explosive/mine/proc/trigger_explosion()
	if(triggered)
		return
	triggered = TRUE
	switch(trigger_type)
		if("explosive")
			explosion(tripwire ? tripwire.loc : loc, -1, -1, 2)
			qdel(src)

/obj/item/explosive/mine/attack_alien(mob/living/carbon/xenomorph/M)
	if(triggered) //Mine is already set to go off
		return

	if(M.a_intent == INTENT_HELP)
		return
	M.visible_message("<span class='danger'>[M] has slashed [src]!</span>", \
	"<span class='danger'>You slash [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1)

	//We move the tripwire randomly in either of the four cardinal directions
	if(tripwire)
		var/direction = pick(GLOB.cardinals)
		var/step_direction = get_step(src, direction)
		tripwire.forceMove(step_direction)
	INVOKE_ASYNC(src, .proc/trigger_explosion)

/obj/item/explosive/mine/flamer_fire_act() //adding mine explosions
	var/turf/T = loc
	qdel(src)
	explosion(T, -1, -1, 2)


/obj/effect/mine_tripwire
	name = "claymore tripwire"
	anchored = TRUE
	mouse_opacity = 0
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = UNACIDABLE
	var/obj/item/explosive/mine/linked_claymore

/obj/effect/mine_tripwire/Destroy()
	linked_claymore = null
	. = ..()

/obj/effect/mine_tripwire/Crossed(atom/A)
	. = ..()
	if(!linked_claymore)
		qdel(src)
		return

	if(linked_claymore.triggered) //Mine is already set to go off
		return

	if(linked_claymore && isliving(A))
		linked_claymore.Bumped(A)
