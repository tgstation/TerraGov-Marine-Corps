/*
Cloning shit

*/
/obj/machinery/cloning
	name = "broken cloning machine"
	bound_width = 32
	bound_height = 64
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 200

	resistance_flags = UNACIDABLE | INDESTRUCTIBLE // For now, we should work out how we want xenos to counter this


/obj/machinery/cloning/relaymove(mob/user)
	user.visible_message("You hear something bang on the window of \the [src]", "The door won't budge")
	return FALSE


/obj/item/reagent_containers/glass/bucket/xeno_blood
	list_reagents = list(/datum/reagent/blood/xeno_blood = 120)

/obj/item/reagent_containers/glass/beaker/biomass
	list_reagents = list(/datum/reagent/medicine/biomass/ = 60)


/**
These automatically generate marine bodies baded ona  timer.
These hold the body until taken by a ghost where they "burst" from the vat.

The vat then needs to be repaired and refilled with biomass.
*/
/obj/machinery/cloning_console/vats
	name = "Clone Vats Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scannerconsole"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 3
	resistance_flags = UNACIDABLE | INDESTRUCTIBLE // For now, we should work out how we want xenos to counter this

	var/obj/machinery/cloning/vats/linked_machine


/obj/machinery/cloning_console/vats/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.a_intent != INTENT_HELP)
		return

	if(!linked_machine)
		// Try to find the machine nearby
		linked_machine = locate() in range(1)
		if(!linked_machine)
			visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps in error, 'connection not available'.</span>")
			return TRUE

		visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps as its boots up and connects to \the [linked_machine]</span>")
		return TRUE

	if(linked_machine.occupant || linked_machine.timerid)
		visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps in error, 'already processing clone'.</span>")
		return TRUE

	if(!linked_machine.beaker || linked_machine.beaker.reagents.total_volume < linked_machine.biomass_required)
		visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps in error, 'not enough biomass'.</span>")
		return TRUE

	visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> whirls as it starts to create a new clone.</span>")
	linked_machine.grow_human()


/obj/machinery/cloning/vats
	name = "Clone Vat"
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "cell_100"
	use_power = IDLE_POWER_USE
	idle_power_usage = 900

	var/timerid
	var/mob/living/carbon/human/occupant
	var/obj/item/reagent_containers/glass/beaker

	var/biomass_required = 40
	var/grow_timer = 10 SECONDS


/obj/machinery/cloning/vats/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/beaker/biomass


/obj/machinery/cloning/vats/Destroy()
	deltimer(timerid)
	timerid = null

	// Force tthe clone out, if they have a client
	if(occupant?.client)
		eject_user()

	QDEL_NULL(occupant)
	QDEL_NULL(beaker)
	return ..()


/obj/machinery/cloning/vats/relaymove(mob/user)
	eject_user()
	return FALSE


/obj/machinery/cloning/vats/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(user.a_intent == INTENT_HARM)
		user.visible_message("<span class='notice'>[src] bangs on the glass</span>", "<span class='notice'>You bang on the glass</span>")
		return TRUE

	if(!beaker)
		return

	if(timerid || occupant) // You need to stop the process or remove the human first.
		to_chat(user, "<span class='notice'>You can't get to the beaker while the machine growing a clone.</span>")
		return

	beaker.forceMove(drop_location())
	user.put_in_hands(beaker)
	beaker = null

	update_icon()

	return TRUE


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

		update_icon()

		return TRUE


/obj/machinery/cloning/vats/examine(mob/user)
	. = ..()
	if(!beaker)
		to_chat(user, "<span class='notice'>It doesn't have a beaker attached</span>")
		return
	if(timerid)
		to_chat(user, "<span class='notice'>There is something weird inside</span>")
		return
	if(occupant)
		to_chat(user, "<span class='notice'>It looks like there is a human in there!</span>")
		return


/obj/machinery/cloning/vats/update_icon()
	if(!beaker)
		icon_state = "cell_0"
		return
	if(occupant || timerid)
		icon_state = "cell_growing"
		return
	var/amount = clamp(round(beaker.reagents.total_volume / biomass_required, 25), 0, 100)
	icon_state = "cell_[amount]"


/obj/machinery/cloning/vats/proc/grow_human(instant = FALSE)
	// Ensure we cleanup the beaker contents
	if(beaker)
		beaker.reagents.remove_all(biomass_required)

	if(instant)
		finish_growing_human()
		return

	timerid = addtimer(CALLBACK(src, .proc/finish_growing_human), grow_timer, TIMER_STOPPABLE)
	update_icon()


/obj/machinery/cloning/vats/proc/eject_user(silent = FALSE)
	if(!occupant)
		return

	if(!silent)
		visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> ejects the freshly spawned clone.</span>")
	occupant.forceMove(get_step(loc, dir))
	occupant.Paralyze(10 SECONDS)
	occupant.disabilities &= ~(BLIND | DEAF)
	occupant.set_blindness(10, TRUE)
	to_chat(occupant, {"
<span class='notice'>You are a frestly spawned clone, you appear as a Squad marine, but nothing more.
You remember nothing of your past life.

You are weak, best rest up and get your strength before fighting.</span>"})

	occupant = null
	update_icon()


/obj/machinery/cloning/vats/proc/finish_growing_human()
	occupant = new(src)
	occupant.faction = "TerraGov"
	occupant.fully_replace_character_name(occupant.real_name, "CS-[occupant.gender == MALE ? "F": "M"]-[rand(111,999)]")
	occupant.set_species("Human clone")
	occupant.disabilities |= (BLIND & DEAF)
	// Blindness needs to be fixed, but that is for another PR.
	// Blindness doenst't trigger with just the disability, you need to set_blindness (which we do when you spawn)

	GLOB.offered_mob_list += occupant
	notify_ghosts("<span class='boldnotice'>A new clone is available! Name: [name]</span>", enter_link = "claim=[REF(occupant)]", source = src, action = NOTIFY_ORBIT)

	// Cleanup the timers
	deltimer(timerid)
	timerid = null

