/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "breath"
	flags_inventory = COVERMOUTH|ALLOWINTERNALS
	flags_armor_protection = 0
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/masks.dmi'
		)

	var/hanging = 0

	verb/toggle()
		set category = "Object"
		set name = "Adjust mask"
		set src in usr

		if(usr.canmove && !usr.stat && !usr.is_mob_restrained())
			if(!src.hanging)
				src.hanging = !src.hanging
				gas_transfer_coefficient = 1 //gas is now escaping to the turf and vice versa
				flags_inventory &= ~(COVERMOUTH|ALLOWINTERNALS)
				icon_state = "breathdown"
				usr << "Your mask is now hanging on your neck."

			else
				src.hanging = !src.hanging
				gas_transfer_coefficient = 0.10
				flags_inventory |= COVERMOUTH|ALLOWINTERNALS
				icon_state = "breath"
				usr << "You pull the mask up to cover your face."
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
	w_class = 2
	flags_armor_protection = 0
	flags_inventory = COVERMOUTH|ALLOWREBREATH
	flags_inv_hide = HIDELOWHAIR

/obj/item/clothing/mask/rebreather/scarf
	name = "heat absorbent coif"
	desc = "A close-fitting cap that covers the top, back, and sides of the head. Can also be adjusted to cover the lower part of the face so it keeps the user warm in harsh conditions."
	icon_state = "coif"
	item_state = "coif"
	flags_inventory = COVERMOUTH|ALLOWREBREATH
	flags_inv_hide = HIDEALLHAIR|HIDEEARS
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
