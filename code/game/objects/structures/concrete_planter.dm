/obj/structure/concrete_planter
	name = "concrete seated planter"
	desc = "A decorative concrete planter."
	icon = 'icons/obj/structures/prop/concrete_planter.dmi'
	icon_state = "planter"
	density = TRUE
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	coverage = 80

/obj/structure/concrete_planter/Initialize(mapload)
	. = ..()
	setDir(dir)
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/concrete_planter/setDir(newdir)
	. = ..()
	if(dir & (EAST|WEST))
		pixel_x = -4
		bound_width = 32
		bound_height = 64
	else
		pixel_y = -7
		bound_width = 64
		bound_height = 32

/obj/structure/concrete_planter/seat
	name = "concrete seated planter"
	desc = "A decorative concrete planter with seating attached. The seats are fitted with synthetic leather, they've faded in time."
	icon_state = "planter_seats"

/obj/structure/concrete_planter/double_seat
	name = "concrete seated planter"
	desc = "A decorative concrete planter with seating attached on both sides. The seats are fitted with synthetic leather, they've faded in time."
	icon_state = "planter_double_seats"
