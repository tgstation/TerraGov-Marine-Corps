/obj/machinery/cloning
	name = "borked cloning machine"
	desc = "this shouldn't even be here"
	bound_width = 32
	bound_height = 64
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	max_integrity = 200

	var/obj/item/reagent_containers/glass/beaker = null


/obj/machinery/cloning/relaymove(mob/user)
	user.visible_message("You hear something bang on the window of \the [src]", "The door won't budge")
	return FALSE

/**
These automatically generate marine bodies baded ona  timer.
These hold the body until taken by a ghost where they "burst" from the vat.

The vat then needs to be repaired and refilled with biomass.
*/
/obj/machinery/cloning/vats
	name = "Clone Vat"
	icon = 'icons/obj/machines/cryogenics2.dmi'
	icon_state = "cell_100"

	var/b

	var/grow_timer = 10 SECONDS
	var/mob/living/carbon/human/occupied
	var/timerid

/obj/machinery/cloning/vats/Initialize()
	. = ..()
	grow_human()


/obj/machinery/cloning/vats/Destroy()
	deltimer(timerid)
	timerid = null
	return ..()


/obj/machinery/cloning/vats/relaymove(mob/user)
	eject_user()
	return FALSE


/obj/machinery/cloning/vats/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/reagent_containers/glass/beaker))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return

		beaker = I
		if(!user.transferItemToLoc(I, src))
			return

		var/obj/item/reagent_containers/glass/beaker/B
		to_chat(user, "you refill the machine with \the [I]")
		B.reagents.trans_to(src, B.reagents.total_volume)

		user.dropItemToGround(I)
		I.forceMove(src)
		grow_human()
		return TRUE


/obj/machinery/cloning/vats/examine(mob/user)
	. = ..()
	to_chat(user, "This is a vat machine or some shit")


/obj/machinery/cloning/vats/update_icon()
	if(occupied || timerid)
		icon_state = "cell-occupied"
		return
	var/fill = round(reagents.total_volume, 25)
	icon_state = "cell_[fill]"


/obj/machinery/cloning/vats/proc/grow_human(instant = FALSE)
	if(instant)
		finish_growing_human()
		return

	timerid = addtimer(CALLBACK(src, .proc/finish_growing_human), grow_timer, TIMER_STOPPABLE)
	update_icon()


/obj/machinery/cloning/vats/proc/eject_user(silent = FALSE)
	if(!occupied)
		return

	if(!silent)
		visible_message("Ejects its contents")
	occupied.forceMove(get_step(loc, dir))
	occupied.Paralyze(10 SECONDS)
	occupied.blind_eyes(10)
	occupied.blur_eyes(15)
	occupied.disabilities &= ~NEARSIGHTED
	occupied = null


/obj/machinery/cloning/vats/proc/finish_growing_human()
	occupied = new(src)
	occupied.set_species("Human clone")
	occupied.disabilities |= NEARSIGHTED

	GLOB.offered_mob_list += occupied
	notify_ghosts("<span class='boldnotice'>A new clone is available! Name: [name]</span>", enter_link = "claim=[REF(occupied)]", source = src, action = NOTIFY_ORBIT)



/**
These use some
*/
/obj/machinery/cloning/cloner
	name = "Cloner"
