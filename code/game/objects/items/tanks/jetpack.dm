/obj/item/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = WEIGHT_CLASS_BULKY
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/backpacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/backpacks_right.dmi',
	)
	worn_icon_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	worn_icon_state = "jetpack-void"


/obj/item/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	worn_icon_state = "jetpack"


/obj/item/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	worn_icon_state = "jetpack-black"
