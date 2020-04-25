/obj/machinery/cloning
	name = "borked cloning machine"
	desc = "this shouldn't even be here"
	bound_width = 32
	bound_height = 64
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 200

	var/obj/item/reagent_containers/glass/beaker = null


/obj/machinery/cloning/relaymove(mob/user)
	user.visible_message("You hear something bang on the window of \the [src]", "The door won't budge")
	return FALSE


/obj/item/reagent_containers/glass/beaker/biomass
	list_reagents = list(/datum/reagent/medicine/biomass = 60)


/**
These automatically generate marine bodies baded ona  timer.
These hold the body until taken by a ghost where they "burst" from the vat.

The vat then needs to be repaired and refilled with biomass.
*/
/obj/machinery/cloning/vats
	name = "Clone Vat"
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "cell_100"

	var/biomass_required = 40

	var/grow_timer = 10 SECONDS
	var/mob/living/carbon/human/occupied
	var/timerid

/obj/machinery/cloning/vats/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/beaker/biomass
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

	if(!ispath(I, /obj/item/reagent_containers/glass/beaker))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return

		// Check if the beaker contains anything other than biomass juice
		for(var/datum/reagent/R in I.reagents.reagent_list)
			if(!istype(R, /datum/reagent/medicine/biomass))
				to_chat(world, "That beaker contains some shit that won't work.")
				return

		beaker = I
		if(!user.transferItemToLoc(I, src))
			return

		grow_human()
		return TRUE


/obj/machinery/cloning/vats/examine(mob/user)
	. = ..()
	to_chat(user, "This is a vat machine or some shit")


/obj/machinery/cloning/vats/update_icon()
	if(!beaker)
		icon_state = "cell_0"
		return
	if(occupied || timerid)
		icon_state = "cell_growing"
		return
	var/amount = clamp(round(beaker.reagents.total_volume / biomass_required, 25), 0, 100)
	icon_state = "cell_[amount]"


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
		visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> ejects the freshly spawned clone.</span>")
	occupied.forceMove(get_step(loc, dir))
	occupied.Paralyze(10 SECONDS)
	occupied.blind_eyes(10)
	occupied.blur_eyes(15)
	occupied.disabilities &= ~NEARSIGHTED
	to_chat(occupied, {"<span class='notice'>You are a frestly spawned clone, you appear as a Squad marine, but nothing more.<br />
		You remember nothing of your past life.<br /><br />

		You are weak, best rest up and get your strength before fighting.</span>"})

	occupied = null
	update_icon()



/obj/machinery/cloning/vats/proc/remove_beaker()
	if(!beaker)
		return

	beaker.forceMove(get_step(loc, dir))
	beaker = null
	update_icon()


/obj/machinery/cloning/vats/proc/finish_growing_human()
	occupied = new(src)
	occupied.set_species("Human clone")
	occupied.disabilities |= NEARSIGHTED

	GLOB.offered_mob_list += occupied
	notify_ghosts("<span class='boldnotice'>A new clone is available! Name: [name]</span>", enter_link = "claim=[REF(occupied)]", source = src, action = NOTIFY_ORBIT)

	// Cleanup the timers
	deltimer(timerid)
	timerid = null


/**
These use some
*/
/obj/machinery/cloning/cloner
	name = "Cloner"
