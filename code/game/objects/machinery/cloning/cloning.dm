/**
Marine cloning.

These act as a respawn mechanic growning a body and offering it up to ghosts.
*/
/obj/machinery/cloning
	name = "broken cloning machine"
	bound_width = 32
	bound_height = 64
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 200
	COOLDOWN_DECLARE(relay_cooldown)

/obj/machinery/cloning/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSmachines, src) // Registered for power usage

/obj/machinery/cloning/relaymove(mob/user)
	if(COOLDOWN_CHECK(src, relay_cooldown))
		return
	COOLDOWN_START(src, relay_cooldown, 2 SECONDS)
	user.visible_message("You hear something bang on the window of \the [src]", "The door won't budge")
	return FALSE


/obj/item/reagent_containers/glass/bucket/xeno_blood
	list_reagents = list(/datum/reagent/blood/xeno_blood = 120)

/obj/item/reagent_containers/glass/beaker/biomass
	list_reagents = list(/datum/reagent/medicine/biomass = 60)


/**
 *These automatically generate marine bodies based on a timer.
 *These hold the body until taken by a ghost where they "burst" from the vat.
 *
 *The vat then needs to be repaired and refilled with biomass.
 */
/obj/machinery/cloning_console/vats
	name = "Clone Vats Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "body_scannerconsole"
	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	resistance_flags = UNACIDABLE | INDESTRUCTIBLE // For now, we should work out how we want xenos to counter this

	var/obj/machinery/cloning/vats/linked_machine
	var/obj/item/radio/headset/mainship/mcom/radio //God forgive me

/obj/machinery/cloning_console/vats/Initialize()
	. = ..()
	radio = new(src)
	radio.use_command = FALSE
	radio.command = FALSE

/obj/machinery/cloning_console/vats/Destroy()
	QDEL_NULL(radio)
	if(linked_machine)
		linked_machine.linked_console = null
		linked_machine = null
	return ..()


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

		linked_machine.linked_console = src
		visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps as its boots up and connects to \the [linked_machine]</span>")
		return TRUE

	if(linked_machine.occupant || linked_machine.timerid)
		visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps in error, 'already processing clone'.</span>")
		return TRUE

	if(!linked_machine.beaker || linked_machine.beaker.reagents.total_volume < linked_machine.biomass_required)
		visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> beeps in error, 'not enough biomass'.</span>")
		return TRUE


	linked_machine.grow_human()


/obj/machinery/cloning/vats
	name = "Clone Vat"
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "cell_0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 3000
	active_power_usage = 30000

	var/timerid
	var/mob/living/carbon/human/occupant
	var/obj/item/reagent_containers/glass/beaker
	var/obj/machinery/cloning_console/vats/linked_console

	var/biomass_required = 40
	var/grow_timer = 15 MINUTES


/obj/machinery/cloning/vats/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/beaker/biomass
	update_icon()


/obj/machinery/cloning/vats/Destroy()
	if(timerid)
		deltimer(timerid)
		timerid = null

	// Force tthe clone out, if they have a client
	if(occupant)
		eject_user()

	QDEL_NULL(beaker)
	linked_console?.linked_machine = null
	linked_console = null
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


/obj/machinery/cloning/vats/attackby(obj/item/hit_by, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(istype(hit_by, /obj/item/reagent_containers/glass/beaker))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return

		// Check if the beaker contains anything other than biomass juice
		for(var/instance in hit_by.reagents.reagent_list)
			var/datum/reagent/regent = instance
			if(!istype(regent, /datum/reagent/medicine/biomass) && !istype(regent, /datum/reagent/medicine/biomass/xeno))
				to_chat(user, "<span class='warning'>\The [src] rejects the beaker due to incompatible contents.</span>")
				return

		beaker = hit_by
		if(!user.transferItemToLoc(hit_by, src))
			return

		update_icon()

		return TRUE


/obj/machinery/cloning/vats/examine(mob/user)
	. = ..()
	if(!beaker)
		to_chat(user, "<span class='notice'>It doesn't have a beaker attached.</span>")
		return
	if(timerid)
		to_chat(user, "<span class='notice'>There is something weird inside.</span>")
		return
	if(occupant)
		to_chat(user, "<span class='notice'>It looks like there is a human in there!</span>")
		return


/obj/machinery/cloning/vats/update_icon_state()
	if(!beaker)
		icon_state = "cell_0"
		return
	if(occupant || timerid)
		icon_state = "cell_growing"
		return
	var/amount = clamp(round(beaker.reagents.total_volume / biomass_required, 25), 0, 100)
	icon_state = "cell_[amount]"


/obj/machinery/cloning/vats/proc/grow_human(instant = FALSE)
	use_power = ACTIVE_POWER_USE
	// Ensure we cleanup the beaker contents
	if(beaker)
		beaker.reagents.remove_all(biomass_required)

	if(instant)
		finish_growing_human()
		return

	visible_message("[icon2html(src, viewers(src))] <span><b>[src]</b> whirls as it starts to create a new clone.</span>")
	timerid = addtimer(CALLBACK(src, .proc/finish_growing_human), grow_timer, TIMER_STOPPABLE)
	update_icon()


/obj/machinery/cloning/vats/proc/finish_growing_human()
	use_power = IDLE_POWER_USE
	occupant = new(src)
	var/datum/job/job_instance = SSjob.GetJobType(/datum/job/terragov/squad/vatgrown)
	occupant.apply_assigned_role_to_spawn(job_instance)
	occupant.set_species("Early Vat-Grown Human")
	occupant.fully_replace_character_name(occupant.real_name, occupant.species.random_name(occupant.gender))
	occupant.disabilities |= (BLIND & DEAF)
	occupant.set_blindness(10) // Temp fix until blindness is fixed.
	// Blindness doenst't trigger with just the disability, you need to set_blindness

	GLOB.offered_mob_list += occupant
	notify_ghosts("<span class='boldnotice'>A new clone is available! Name: [name]</span>", enter_link = "claim=[REF(occupant)]", source = src, action = NOTIFY_ORBIT)

	// Cleanup the timers
	timerid = null


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
	occupant.vomit()
	linked_console.radio.talk_into(src, "<b>New clone: [occupant] has been grown in [src] at: [get_area(src)].</b>", RADIO_CHANNEL_MEDICAL)
	linked_console.radio.talk_into(src, "<b>New clone: [occupant] has been grown in [src] at: [get_area(src)]. Please move the fresh clone to a squad using the squad distribution console.</b>", RADIO_CHANNEL_COMMAND)
	occupant = null
	update_icon()
