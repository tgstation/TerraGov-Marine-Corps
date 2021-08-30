/obj/machinery/factory
	name = "generic root heater"
	desc = "You shouldnt be seeing this."
	icon = 'icons/obj/factory/factory_machines.dmi'
	icon_state = "heater_inactive"
	density = TRUE
	anchored = FALSE // start off unanchored so its easier to move
	resistance_flags = XENO_DAMAGEABLE
	///process type we will use to determine what step of the production process this machine will do
	var/process_type = FACTORY_MACHINE_HEATER
	///Time in ticks that this machine takes to process one item
	var/cooldown_time = 1 SECONDS
	///Curent item being processed
	var/obj/item/factory_part/held_item
	///Icon state displayed while something is being processed in the machine
	var/processiconstate = "heater"
	COOLDOWN_DECLARE(process_cooldown)

/obj/machinery/factory/Destroy()
	QDEL_NULL(held_item)
	return ..()

/obj/machinery/factory/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It is currently facing [dir2text(dir)] and [anchored ? "" : "un"]secured.")
	to_chat(user, "Processes one package every [cooldown_time*10] seconds.")

/obj/machinery/factory/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	balloon_alert("[anchored ? "" : "un"]anchored")


/obj/machinery/factory/Bumped(atom/movable/bumper)
	. = ..()
	if(!isitem(bumper))
		return
	if(!(bumper.dir & dir))//need to be bumping into the back
		return
	if(!anchored)
		return
	if(!isfactorypart(bumper))
		bumper.forceMove(get_step(src, pick(GLOB.alldirs)))//just find a random tile and throw it there to stop it from clogging
		return
	if(!COOLDOWN_CHECK(src, process_cooldown))
		return
	bumper.forceMove(src)
	held_item = bumper
	COOLDOWN_START(src, process_cooldown, cooldown_time)
	if(processiconstate)
		icon_state = processiconstate
	addtimer(CALLBACK(src, .proc/finish_process), cooldown_time)

///Once the timer for processing is over this resets the machine and spits out the new result
/obj/machinery/factory/proc/finish_process()
	var/turf/target = get_step(src, dir)
	held_item.forceMove(target)
	if(held_item.next_machine == process_type)
		held_item.advance_stage()
	held_item = null
	icon_state = initial(icon_state)

/obj/machinery/factory/heater
	name = "Industrial heater"
	desc = "An industrial level heater"

/obj/machinery/factory/flatter
	name = "Industrial flatter"
	desc = "An industrial level flatter"
	icon_state = "flatter_inactive"
	processiconstate = "flatter"
	process_type = FACTORY_MACHINE_FLATTER

/obj/machinery/factory/cutter
	name = "Industrial cutter"
	desc = "An industrial level cutter"
	icon_state = "cutter_inactive"
	processiconstate = "cutter"
	process_type = FACTORY_MACHINE_CUTTER

/obj/machinery/factory/former
	name = "Industrial former"
	desc = "An industrial level former"
	icon_state = "former_inactive"
	processiconstate = "former"
	process_type = FACTORY_MACHINE_FORMER

/obj/machinery/factory/reconstructor
	name = "Atomic reconstructor"
	desc = "An industrial level former"
	icon_state = "constructor_inactive"
	processiconstate = "constructor"
	process_type = FACTORY_MACHINE_CONSTRUCTOR
