/obj/machinery/factory
	name = "Industrial heater"
	desc = "A industrial strength heater."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	var/process_type = FACTORY_MACHINE_HEATER
	var/cooldown_time = 1 SECONDS
	var/obj/item/factory_part/held_item
	COOLDOWN_DECLARE(process_cooldown)

/obj/machinery/factory/Destroy()
	QDEL_NULL(held_item)
	return ..()

/obj/machinery/factory/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It is currently facing [dir2text(dir)]")

/obj/machinery/factory/Bumped(atom/movable/bumper)
	. = ..()
	if(!(bumper.dir & dir))//need to be bumping into the back
		return
	if(!isfactorypart(bumper))
		var/selecteddir = pick(GLOB.alldirs)//just find a random tile and throw it there to stop it from clogging
		var/turf/target = get_step(src, selecteddir)
		held_item.forceMove(target)
		return
	if(!COOLDOWN_CHECK(src, process_cooldown))
		return
	bumper.forceMove(src)
	held_item = bumper
	COOLDOWN_START(src, process_cooldown, cooldown_time)
	INVOKE_ASYNC(src, .proc/finish_process)

/obj/machinery/factory/proc/finish_process()
	sleep(cooldown_time)
	var/turf/target = get_step(src, dir)
	held_item.forceMove(target)
	if(held_item.next_machine == process_type)
		held_item.advance_stage()
	held_item = null

/obj/machinery/factory/flatter
	name = "Industrial heater"
	desc = "An industrial level flatter"
	icon_state = "furnace"
	process_type = FACTORY_MACHINE_FLATTER

/obj/machinery/factory/stamper
	name = "Industrial stamper"
	desc = "An industrial level stamper"
	icon_state = "furnace"
	process_type = FACTORY_MACHINE_STAMPER

/obj/machinery/factory/former
	name = "Industrial former"
	desc = "An industrial level former"
	icon_state = "furnace"
	process_type = FACTORY_MACHINE_FORMER
