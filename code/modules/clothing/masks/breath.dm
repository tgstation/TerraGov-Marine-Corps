/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	worn_icon_state = "breath"
	inventory_flags = COVERMOUTH
	armor_protection_flags = NONE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50

	var/hanging = 0

/obj/item/clothing/mask/breath/verb/toggle()
	set category = "IC.Object"
	set name = "Adjust mask"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(!src.hanging)
			src.hanging = !src.hanging
			gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
			inventory_flags &= ~(COVERMOUTH)
			icon_state = "breathdown"
			to_chat(usr, "Your mask is now hanging on your neck.")

		else
			src.hanging = !src.hanging
			gas_transfer_coefficient = 0.10
			inventory_flags |= COVERMOUTH
			icon_state = "breath"
			to_chat(usr, "You pull the mask up to cover your face.")
		update_clothing_icon()

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	worn_icon_state = "medical"
	permeability_coefficient = 0.01



//REBREATHER

/obj/item/clothing/mask/rebreather
	name = "rebreather"
	desc = "A close-fitting device that instantly heats or cools down air when you inhale so it doesn't damage your lungs."
	icon_state = "rebreather"
	worn_icon_state = "rebreather"
	armor_protection_flags = NONE
	inventory_flags = COVERMOUTH|COVEREYES|BLOCKGASEFFECT
	inv_hide_flags = HIDELOWHAIR
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/mask/rebreather/scarf
	name = "heat absorbent coif"
	desc = "A close-fitting cap that covers the top, back, and sides of the head. Can also be adjusted to cover the lower part of the face so it keeps the user warm in harsh conditions."
	icon_state = "coif"
	worn_icon_state = "coif"
	inv_hide_flags = HIDEALLHAIR|HIDEEARS
	cold_protection_flags = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/mask/rebreather/scarf/freelancer
	worn_icon_state = "coif_fl"

/obj/item/clothing/mask/bandanna
	name = "tan bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Desert Tan"
	icon_state = "bandanna"
	worn_icon_state = "bandanna"
	armor_protection_flags = FACE
	inv_hide_flags = HIDEFACE
	inventory_flags = COVERMOUTH|BLOCKGASEFFECT
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/mask/bandanna/verb/toggle()
	set category = "IC.Object"
	set name = "Adjust bandanna"
	set src in usr

	if(usr.incapacitated())
		return

	active = !active
	icon_state = "[initial(icon_state)][!active ? "_down" : ""]"
	armor_protection_flags ^= initial(armor_protection_flags)
	inv_hide_flags ^= initial(inv_hide_flags)
	inventory_flags ^= initial(inventory_flags)
	to_chat(usr, "You [active ? "pull [src] up to cover your face" : "pull [src] off your face"].")

	update_clothing_icon()

	update_action_button_icons()

/obj/item/clothing/mask/bandanna/green
	name = "green bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Jungle Green"
	icon_state = "m_bandanna"
	worn_icon_state = "m_bandanna"

/obj/item/clothing/mask/bandanna/white
	name = "white bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Snow White"
	icon_state = "s_bandanna"
	worn_icon_state = "s_bandanna"

/obj/item/clothing/mask/bandanna/black
	name = "black bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Spec Ops Black"
	icon_state = "k_bandanna"
	worn_icon_state = "k_bandanna"

/obj/item/clothing/mask/bandanna/skull
	name = "skull bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is black with a white Skull on it."
	icon_state = "skull_bandanna"
	worn_icon_state = "skull_bandanna"

/obj/item/clothing/mask/bandanna/alpha
	name = "red bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Cherry Red."
	icon_state = "alpha_bandanna"
	worn_icon_state = "alpha_bandanna"

/obj/item/clothing/mask/bandanna/bravo
	name = "yellow bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Banana Yellow."
	icon_state = "bravo_bandanna"
	worn_icon_state = "bravo_bandanna"

/obj/item/clothing/mask/bandanna/charlie
	name = "purple bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Grape Purple."
	icon_state = "charlie_bandanna"
	worn_icon_state = "charlie_bandanna"

/obj/item/clothing/mask/bandanna/delta
	name = "blue bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Blueberry Blue."
	icon_state = "delta_bandanna"
	worn_icon_state = "delta_bandanna"
