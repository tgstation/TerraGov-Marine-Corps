/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"

	var/g_amount = 0
	var/gold_amount = 0
	var/diamond_amount = 0
	var/uranium_amount = 0
	var/max_material_amount = 75000.0

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 2500


/obj/machinery/r_n_d/circuit_imprinter/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/circuit_imprinter(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/reagent_container/glass/beaker(src)
	component_parts += new /obj/item/reagent_container/glass/beaker(src)
	RefreshParts()


/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/reagent_container/glass/G in component_parts)
		T += G.reagents.maximum_volume
	create_reagents(T, REFILLABLE)
	T = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_amount = T * 75000.0


/obj/machinery/r_n_d/circuit_imprinter/proc/TotalMaterials()
	return g_amount + gold_amount + diamond_amount + uranium_amount


/obj/machinery/r_n_d/circuit_imprinter/attackby(obj/item/O, mob/user)
	if (shocked)
		shock(user,50)
	if (isscrewdriver(O))
		if (!opened)
			opened = 1
			if(linked_console)
				linked_console.linked_imprinter = null
				linked_console = null
			icon_state = "circuit_imprinter_t"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			opened = 0
			icon_state = "circuit_imprinter"
			to_chat(user, "You close the maintenance hatch of [src].")
		return
	if (opened)
		if(iscrowbar(O))
			playsound(src.loc, 'sound/items/crowbar.ogg', 25, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/reagent_container/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			if(g_amount >= 3750)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / 3750)
			if(gold_amount >= 2000)
				var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold(src.loc)
				G.amount = round(gold_amount / 2000)
			if(diamond_amount >= 2000)
				var/obj/item/stack/sheet/mineral/diamond/G = new /obj/item/stack/sheet/mineral/diamond(src.loc)
				G.amount = round(diamond_amount / 2000)
			if(uranium_amount >= 2000)
				var/obj/item/stack/sheet/mineral/uranium/G = new /obj/item/stack/sheet/mineral/uranium(src.loc)
				G.amount = round(uranium_amount / 2000)
			qdel(src)
			return 1
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return 1
	if (disabled)
		to_chat(user, "\The [name] appears to not be working!")
		return
	if (!linked_console)
		to_chat(user, "\The [name] must be linked to an R&D console first!")
		return 1
	if (O.is_open_container())
		return 0
	if (!istype(O, /obj/item/stack/sheet/glass) && !istype(O, /obj/item/stack/sheet/mineral/gold) && !istype(O, /obj/item/stack/sheet/mineral/diamond) && !istype(O, /obj/item/stack/sheet/mineral/uranium))
		to_chat(user, "<span class='warning'>You cannot insert this item into the [name]!</span>")
		return 1
	if (machine_stat)
		return 1
	if (busy)
		to_chat(user, "<span class='warning'>The [name] is busy. Please wait for completion of previous operation.</span>")
		return 1
	var/obj/item/stack/sheet/stack = O
	if ((TotalMaterials() + stack.perunit) > max_material_amount)
		to_chat(user, "<span class='warning'>The [name] is full. Please remove glass from the protolathe in order to insert more.</span>")
		return 1

	var/amount = round(input("How many sheets do you want to add?") as num)
	if(amount < 0)
		amount = 0
	if(amount == 0)
		return
	if(amount > stack.amount)
		amount = min(stack.amount, round((max_material_amount-TotalMaterials())/stack.perunit))

	busy = 1
	use_power(max(1000, (3750*amount/10)))
	var/stacktype = stack.type
	if(do_after(usr, 15, TRUE, src))
		stack.use(amount)
		to_chat(user, "<span class='notice'>You add [amount] sheets to the [src.name].</span>")
		switch(stacktype)
			if(/obj/item/stack/sheet/glass)
				g_amount += amount * 3750
			if(/obj/item/stack/sheet/mineral/gold)
				gold_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/diamond)
				diamond_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/uranium)
				uranium_amount += amount * 2000
	busy = 0
	src.updateUsrDialog()


//This is to stop these machines being hackable via clicking.
/obj/machinery/r_n_d/circuit_imprinter/attack_hand(mob/living/user)
	return TRUE
