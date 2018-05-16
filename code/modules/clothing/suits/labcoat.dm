/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat" //Is this even used for anything?
	blood_overlay_type = "coat"
	flags_armor_protection = UPPER_TORSO|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_container/dropper,/obj/item/reagent_container/syringe,/obj/item/reagent_container/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/reagent_container/glass/bottle,/obj/item/reagent_container/glass/beaker,/obj/item/reagent_container/pill,/obj/item/storage/pill_bottle,/obj/item/paper)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

	verb/toggle()
		set name = "Toggle Labcoat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.is_mob_restrained())
			return 0

		//Why???
		switch(icon_state)
			if("labcoat_open")
				src.icon_state = "labcoat"
				usr << "You button up the labcoat."
			if("labcoat")
				src.icon_state = "labcoat_open"
				usr << "You unbutton the labcoat."
			if("red_labcoat_open")
				src.icon_state = "red_labcoat"
				usr << "You button up the labcoat."
			if("red_labcoat")
				src.icon_state = "red_labcoat_open"
				usr << "You unbutton the labcoat."
			if("blue_labcoat_open")
				src.icon_state = "blue_labcoat"
				usr << "You button up the labcoat."
			if("blue_labcoat")
				src.icon_state = "blue_labcoat_open"
				usr << "You unbutton the labcoat."
			if("purple_labcoat_open")
				src.icon_state = "purple_labcoat"
				usr << "You button up the labcoat."
			if("purple_labcoat")
				src.icon_state = "purple_labcoat_open"
				usr << "You unbutton the labcoat."
			if("green_labcoat_open")
				src.icon_state = "green_labcoat"
				usr << "You button up the labcoat."
			if("green_labcoat")
				src.icon_state = "green_labcoat_open"
				usr << "You unbutton the labcoat."
			if("orange_labcoat_open")
				src.icon_state = "orange_labcoat"
				usr << "You button up the labcoat."
			if("orange_labcoat")
				src.icon_state = "orange_labcoat_open"
				usr << "You unbutton the labcoat."
			if("labcoat_cmo_open")
				src.icon_state = "labcoat_cmo"
				usr << "You button up the labcoat."
			if("labcoat_cmo")
				src.icon_state = "labcoat_cmo_open"
				usr << "You unbutton the labcoat."
			if("labcoat_gen_open")
				src.icon_state = "labcoat_gen"
				usr << "You button up the labcoat."
			if("labcoat_gen")
				src.icon_state = "labcoat_gen_open"
				usr << "You unbutton the labcoat."
			if("labcoat_chem_open")
				src.icon_state = "labcoat_chem"
				usr << "You button up the labcoat."
			if("labcoat_chem")
				src.icon_state = "labcoat_chem_open"
				usr << "You unbutton the labcoat."
			if("labcoat_vir_open")
				src.icon_state = "labcoat_vir"
				usr << "You button up the labcoat."
			if("labcoat_vir")
				src.icon_state = "labcoat_vir_open"
				usr << "You unbutton the labcoat."
			if("labcoat_tox_open")
				src.icon_state = "labcoat_tox"
				usr << "You button up the labcoat."
			if("labcoat_tox")
				src.icon_state = "labcoat_tox_open"
				usr << "You unbutton the labcoat."
			if("labgreen_open")
				src.icon_state = "labgreen"
				usr << "You button up the labcoat."
			if("labgreen")
				src.icon_state = "labgreen_open"
				usr << "You unbutton the labcoat."
			if("sciencecoat_open")
				src.icon_state = "sciencecoat"
				usr << "You button up the labcoat."
			if("sciencecoat")
				src.icon_state = "sciencecoat_open"
				usr << "You unbutton the labcoat."
			else
				usr << "You attempt to button-up the velcro on your [src], before promptly realising how silly you are."
				return
		update_clothing_icon()	//so our overlays update

/obj/item/clothing/suit/storage/labcoat/red
	name = "red labcoat"
	desc = "A suit that protects against minor chemical spills. This one is red."
	icon_state = "red_labcoat_open"
	item_state = "red_labcoat"

/obj/item/clothing/suit/storage/labcoat/blue
	name = "blue labcoat"
	desc = "A suit that protects against minor chemical spills. This one is blue."
	icon_state = "blue_labcoat_open"
	item_state = "blue_labcoat"

/obj/item/clothing/suit/storage/labcoat/purple
	name = "purple labcoat"
	desc = "A suit that protects against minor chemical spills. This one is purple."
	icon_state = "purple_labcoat_open"
	item_state = "purple_labcoat"

/obj/item/clothing/suit/storage/labcoat/orange
	name = "orange labcoat"
	desc = "A suit that protects against minor chemical spills. This one is orange."
	icon_state = "orange_labcoat_open"
	item_state = "orange_labcoat"

/obj/item/clothing/suit/storage/labcoat/green
	name = "green labcoat"
	desc = "A suit that protects against minor chemical spills. This one is green."
	icon_state = "green_labcoat_open"
	item_state = "green_labcoat"

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo"

/obj/item/clothing/suit/storage/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labgreen_open"
	item_state = "labgreen"

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "Geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen_open"

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "Chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem_open"

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "Virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir_open"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 0)

/obj/item/clothing/suit/storage/labcoat/science
	name = "Scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox_open"

/obj/item/clothing/suit/storage/labcoat/officer
	//name = "Medical officer's labcoat"
	icon_state = "labcoatg"
	item_state = "labcoatg"

/obj/item/clothing/suit/storage/labcoat/researcher
	name = "researcher's labcoat"
	desc = "A high quality labcoat, seemingly worn by scholars and researchers alike. It has a distinct leathery feel to it, and goads you towards adventure."
	icon_state = "sciencecoat_open"
	item_state = "sciencecoat_open"






/obj/item/clothing/suit/storage/snow_suit
	name = "snow suit"
	desc = "A standard snow suit. It can protect the wearer from extreme cold."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "snowsuit_alpha"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 15, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	blood_overlay_type = "armor"
	siemens_coefficient = 0.7
	allowed = list (/obj/item/device/flashlight, /obj/item/tank/emergency_oxygen)

/obj/item/clothing/suit/storage/snow_suit/doctor
	name = "doctor's snow suit"
	icon_state = "snowsuit_doctor"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/snow_suit/engineer
	name = "engineer's snow suit"
	icon_state = "snowsuit_engineer"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)
