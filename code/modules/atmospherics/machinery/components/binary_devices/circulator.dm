//node2, air2, network2 correspond to input
//node1, air1, network1 correspond to output
#define CIRCULATOR_HOT 0
#define CIRCULATOR_COLD 1

/obj/machinery/atmospherics/components/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger."
	icon_state = "circ-off-0"

	var/active = FALSE

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	density = TRUE


	var/flipped = 0
	var/mode = CIRCULATOR_HOT


//default cold circ for mappers
/obj/machinery/atmospherics/components/binary/circulator/cold
	mode = CIRCULATOR_COLD


/obj/machinery/atmospherics/components/binary/circulator/update_icon_state()
	. = ..()
	if(!is_operational())
		icon_state = "circ-p-[flipped]"
	else
		icon_state = "circ-off-[flipped]"

/obj/machinery/atmospherics/components/binary/circulator/wrench_act(mob/living/user, obj/item/I)
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return
	anchored = !anchored
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	to_chat(user, span_notice("You [anchored?"secure":"unsecure"] [src]."))


	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]

	if(node1)
		node1.disconnect(src)
		nodes[1] = null
		nullifyPipenet(parents[1])
	if(node2)
		node2.disconnect(src)
		nodes[2] = null
		nullifyPipenet(parents[2])

	if(anchored)
		SetInitDirections()
		atmosinit()
		node1 = nodes[1]
		if(node1)
			node1.atmosinit()
			node1.addMember(src)
		node2 = nodes[2]
		if(node2)
			node2.atmosinit()
			node2.addMember(src)
		build_network()

	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/SetInitDirections()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = EAST|WEST
		if(EAST, WEST)
			initialize_directions = NORTH|SOUTH

/obj/machinery/atmospherics/components/binary/circulator/getNodeConnects()
	if(flipped)
		return list(turn(dir, 270), turn(dir, 90))
	return list(turn(dir, 90), turn(dir, 270))

/obj/machinery/atmospherics/components/binary/circulator/can_be_node(obj/machinery/atmospherics/target)
	if(anchored)
		return ..(target)
	return FALSE

/obj/machinery/atmospherics/components/binary/circulator/multitool_act(mob/living/user, obj/item/I)
	mode = !mode
	to_chat(user, span_notice("You set [src] to [mode?"cold":"hot"] mode."))
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
	playsound(src.loc, 'sound/items/screwdriver.ogg', 25, 1)
	to_chat(user, span_notice("You [CHECK_BITFIELD(machine_stat, PANEL_OPEN)?"open":"close"] the panel on [src]."))
	return TRUE

/obj/machinery/atmospherics/components/binary/circulator/setPipingLayer(new_layer)
	..()
	pixel_x = 0
	pixel_y = 0

/obj/machinery/atmospherics/components/binary/circulator/verb/circulator_flip()
	set name = "Flip"
	set category = "IC.Object"
	set src in oview(1)

	if(!ishuman(usr))
		return

	if(anchored)
		to_chat(usr, span_danger("[src] is anchored!"))
		return

	flipped = !flipped
	to_chat(usr, span_notice("You flip [src]."))
	update_icon()
