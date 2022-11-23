/obj/vehicle/sealed/mecha/working
	allow_diagonal_movement = TRUE
	/// Handles an internal ore box for working mechs
	var/obj/structure/ore_box/box

/obj/vehicle/sealed/mecha/working/Destroy()
	QDEL_NULL(box)
	return ..()
