/obj/machinery/factory
	name = "generic root heater"
	desc = "You shouldnt be seeing this."
	icon = 'icons/obj/factory/factory_machines.dmi'
	icon_state = "heater_inactive"
	density = TRUE
	anchored = FALSE // start off unanchored so its easier to move
	resistance_flags = XENO_DAMAGEABLE
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	///process type we will use to determine what step of the production process this machine will do
	var/process_type = FACTORY_MACHINE_HEATER
	///Time in ticks that this machine takes to process one item
	var/cooldown_time = 1 SECONDS
	///Curent item being processed
	var/obj/item/factory_part/held_item
	///Icon state displayed while something is being processed in the machine
	var/processiconstate = "heater"
	COOLDOWN_DECLARE(process_cooldown)

/obj/machinery/factory/Initialize()
	. = ..()
	add_overlay(image(icon, "direction_arrow"))

/obj/machinery/factory/Destroy()
	QDEL_NULL(held_item)
	return ..()

/obj/machinery/factory/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "It is currently facing [dir2text(dir)] and [anchored ? "" : "un"]secured."
	. += "Processes one package every [cooldown_time*10] seconds."

/obj/machinery/factory/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	balloon_alert(user, "[anchored ? "" : "un"]anchored")
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

/obj/machinery/factory/screwdriver_act(mob/living/user, obj/item/I)
	setDir(turn(dir, 90))
	balloon_alert(user, "Facing [dir2text(dir)]")

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
	if(processiconstate && icon_state != processiconstate)//avoid resetting the animation
		icon_state = processiconstate
	addtimer(CALLBACK(src, .proc/finish_process), cooldown_time)

///Once the timer for processing is over this resets the machine and spits out the new result
/obj/machinery/factory/proc/finish_process()
	var/turf/target = get_step(src, dir)
	held_item.forceMove(target)
	if(held_item.next_machine == process_type)
		held_item.advance_stage()
	if(!locate(held_item.type) in get_step(src, REVERSE_DIR(dir)))
		icon_state = initial(icon_state)
	held_item = null

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
	icon_state = "reconstructor_inactive"
	processiconstate = "reconstructor"
	process_type = FACTORY_MACHINE_CONSTRUCTOR
