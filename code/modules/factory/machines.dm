/obj/machinery/factory
	name = "generic heater"
	desc = "You shouldnt be seeing this."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = FALSE // start off unanchored so its easier to move
	resistance_flags = XENO_DAMAGEABLE
	var/process_type = FACTORY_MACHINE_HEATER
	var/cooldown_time = 1 SECONDS
	var/obj/item/factory_part/held_item
	var/processiconstate
	COOLDOWN_DECLARE(process_cooldown)

/obj/machinery/factory/Destroy()
	QDEL_NULL(held_item)
	return ..()

/obj/machinery/factory/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It is currently facing [dir2text(dir)] and [anchored ? "" : "un"]secured.")

/obj/machinery/factory/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	user.visible_message("<span class='notice'>[user] [anchored ? "" : "un"]anchors [src]</span>" ,"<span class='notice'>You [anchored ? "" : "un"]anchor [src].</span>")


/obj/machinery/factory/Bumped(atom/movable/bumper)
	. = ..()
	if(!(bumper.dir & dir))//need to be bumping into the back
		return
	if(!anchored)
		return
	if(!isfactorypart(bumper))
		held_item.forceMove(get_step(src, pick(GLOB.alldirs)))//just find a random tile and throw it there to stop it from clogging
		return
	if(!COOLDOWN_CHECK(src, process_cooldown))
		return
	bumper.forceMove(src)
	held_item = bumper
	COOLDOWN_START(src, process_cooldown, cooldown_time)
	if(processiconstate)
		icon_state = processiconstate
	INVOKE_ASYNC(src, .proc/finish_process)

/obj/machinery/factory/proc/finish_process()
	sleep(cooldown_time)
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
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	processiconstate = "circuit_imprinter"
	process_type = FACTORY_MACHINE_FLATTER

/obj/machinery/factory/cutter
	name = "Industrial cutter"
	desc = "An industrial level cutter"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	processiconstate = "circuit_imprinter"
	process_type = FACTORY_MACHINE_CUTTER

/obj/machinery/factory/former
	name = "Industrial former"
	desc = "An industrial level former"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	processiconstate = "protolate_n"
	process_type = FACTORY_MACHINE_FORMER

/obj/item/factory_refill
	name = "generic refiller"
	desc = "you shouldnt be seeing this."
	icon = 'icons/obj/factory_refill.dmi'
	icon_state = "empty"
	///Typepath for the output machine we want to be ejecting
	var/refill_type = /obj/machinery/outputter
	///By how much we wan to refill the target machine
	var/refill_amount = 30

/obj/item/factory_refill/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It has [refill_amount] resources remaining.")

/obj/machinery/outputter
	name = "Unboxer"
	desc = "An industrial resourcing unboxer."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	resistance_flags = XENO_DAMAGEABLE
	///the amount of resouce we have left to output factory_parts
	var/production_amount_left = 0
	///Maximum amount of resource we can hold
	var/max_fill_amount = 100
	///Typepath for the result we want
	var/production_type = /obj/item/factory_part
	///Bool for whether the outputter is producing things
	var/on = FALSE

/obj/machinery/factory/outputter/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It is currently facing [dir2text(dir)], and outputting [initial(production_type.name)]. It has [production_amount_left] resources remaining.")

/obj/machinery/outputter/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	user.visible_message("<span class='notice'>[user] [anchored ? "" : "un"]anchors [src]</span>" ,"<span class='notice'>You [anchored ? "" : "un"]anchor [src].</span>")

/obj/machinery/outputter/attack_hand(mob/living/user)
	on = !on
	if(on)
		START_PROCESSING(src, SSmachines)
		visible_message("<span class='notice'>\The [src] rumbles to life.</span>")
	else
		STOP_PROCESSING(src, SSmachines)
		visible_message("<span class='notice'>\The [src] slows and becomes quiet.</span>")

/obj/machinery/outputter/attack_ai(mob/living/silicon/ai/user)
	return attack_hand(user)

/obj/machinery/outputter/process()
	if(!production_amount_left)
		visible_message("<span class='notice'>The low material light on \the [src] flashes!</span>")
		return PROCESS_KILL
	new production_type(get_step(src, dir))
	production_amount_left--

/obj/machinery/outputter/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!isfactoryrefill(I))
		return ..()
	if(!istype(src, I.refill_type))
		to_chat(user, "<span class='warning'>This type of refiller is incompatible.</span>")
		return
	var/to_refill = min(max_fill_amount - production_amount_left, I.refill_amount)
	production_amount_left += to_refill
	I.refill_amount -= to_refill
	if(I.refill_amount <= 0)
		qdel(I)

/obj/machinery/outputter/phosnade
	name = "Phosphorus resistant plate outputter"
	desc = "A machine outputting large plates with phosphorus resistant laminate."
	max_fill_amount = 70
	production_type = /obj/item/factory_part/phosnade

/obj/item/factory_refill/phosnade
	name = "Phosphorus resistant laminate plates"
	desc = "A box with what seem to be strangely colored metal plates inside. Used to refill Outputters."
	icon_state = "phosphorus"
	production_type = /obj/machinery/outputter/phosnade

/obj/machinery/outputter/m15_nade
	name = "Rounded grenade plate outputter"
	desc = "A large machine that produces plating for grenade casings."
	max_fill_amount = 120
	production_type = /obj/item/factory_part/m15_nade

/obj/item/factory_refill/phosnade
	name = "Box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Outputters."
	icon_state = "grenade"
	production_type = /obj/machinery/outputter/m15_nade
