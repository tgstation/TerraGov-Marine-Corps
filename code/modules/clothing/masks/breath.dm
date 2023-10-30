/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags_inventory = COVERMOUTH
	flags_armor_protection = NONE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50

	var/hanging = 0

/obj/item/clothing/mask/breath/verb/toggle()
	set category = "Object"
	set name = "Adjust mask"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(!src.hanging)
			src.hanging = !src.hanging
			gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
			flags_inventory &= ~(COVERMOUTH)
			icon_state = "breathdown"
			to_chat(usr, "Your mask is now hanging on your neck.")

		else
			src.hanging = !src.hanging
			gas_transfer_coefficient = 0.10
			flags_inventory |= COVERMOUTH
			icon_state = "breath"
			to_chat(usr, "You pull the mask up to cover your face.")
		update_clothing_icon()

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "medical"
	permeability_coefficient = 0.01



//REBREATHER

/obj/item/clothing/mask/rebreather
	name = "rebreather"
	desc = "A close-fitting device that instantly heats or cools down air when you inhale so it doesn't damage your lungs."
	icon_state = "rebreather"
	item_state = "rebreather"
	flags_armor_protection = NONE
	flags_inventory = COVERMOUTH|COVEREYES|BLOCKGASEFFECT
	flags_inv_hide = HIDELOWHAIR
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/mask/rebreather/scarf
	name = "heat absorbent coif"
	desc = "A close-fitting cap that covers the top, back, and sides of the head. Can also be adjusted to cover the lower part of the face so it keeps the user warm in harsh conditions."
	icon_state = "coif"
	item_state = "coif"
	flags_inv_hide = HIDEALLHAIR|HIDEEARS
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/mask/rebreather/scarf/freelancer
	item_state = "coif_fl"

/obj/item/clothing/mask/bandanna
	name = "tan bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Desert Tan"
	icon_state = "bandanna"
	item_state = "bandanna"
	flags_armor_protection = FACE
	flags_inv_hide = HIDEFACE
	flags_inventory = COVERMOUTH|BLOCKGASEFFECT
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01

/obj/item/clothing/mask/bandanna/verb/toggle()
	set category = "Object"
	set name = "Adjust bandanna"
	set src in usr

	if(usr.incapacitated())
		return

	active = !active
	icon_state = "[initial(icon_state)][!active ? "_down" : ""]"
	flags_armor_protection ^= initial(flags_armor_protection)
	flags_inv_hide ^= initial(flags_inv_hide)
	flags_inventory ^= initial(flags_inventory)
	to_chat(usr, "You [active ? "pull [src] up to cover your face" : "pull [src] off your face"].")

	update_clothing_icon()

	update_action_button_icons()

/obj/item/clothing/mask/bandanna/green
	name = "green bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Jungle Green"
	icon_state = "m_bandanna"
	item_state = "m_bandanna"

/obj/item/clothing/mask/bandanna/white
	name = "white bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Snow White"
	icon_state = "s_bandanna"
	item_state = "s_bandanna"

/obj/item/clothing/mask/bandanna/black
	name = "black bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is Spec Ops Black"
	icon_state = "k_bandanna"
	item_state = "k_bandanna"

/obj/item/clothing/mask/bandanna/skull
	name = "skull bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is black with a white Skull on it."
	icon_state = "skull_bandanna"
	item_state = "skull_bandanna"

/obj/item/clothing/mask/bandanna/alpha
	name = "red bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Cherry Red."
	icon_state = "alpha_bandanna"
	item_state = "alpha_bandanna"

/obj/item/clothing/mask/bandanna/bravo
	name = "yellow bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Banana Yellow."
	icon_state = "bravo_bandanna"
	item_state = "bravo_bandanna"

/obj/item/clothing/mask/bandanna/charlie
	name = "purple bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Grape Purple."
	icon_state = "charlie_bandanna"
	item_state = "charlie_bandanna"

/obj/item/clothing/mask/bandanna/delta
	name = "blue bandanna"
	desc = "A colored, resilient, and insulating cloth to cover your face from the elements. This one is colored Blueberry Blue."
	icon_state = "delta_bandanna"
	item_state = "delta_bandanna"
