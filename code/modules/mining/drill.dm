/obj/machinery/mining
	icon = 'icons/obj/mining_drill.dmi'
	anchored = FALSE
	use_power = 0 //The drill takes power directly from a cell.
	density = TRUE
	layer = ABOVE_MOB_LAYER //So it draws over mobs in the tile north of it.

/obj/machinery/mining/drill
	name = "mining drill head"
	desc = "An enormous drill."
	icon_state = "mining_drill"

/obj/machinery/mining/drill/braced
	anchored = TRUE
	icon_state = "mining_drill_braced"

/obj/machinery/mining/brace
	name = "mining drill brace"
	desc = "A machinery brace for an industrial drill. It looks easily two feet thick."
	icon_state = "mining_brace"

/obj/machinery/mining/brace/active
	name = "active mining drill brace"
	icon_state = "mining_brace_active"
	anchored = TRUE
	
