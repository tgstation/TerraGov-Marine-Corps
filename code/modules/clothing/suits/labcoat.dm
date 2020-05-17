/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat" //Is this even used for anything?
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS
	allowed = list(
		/obj/item/analyzer,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/hypospray,
		/obj/item/healthanalyzer,
		/obj/item/flashlight/pen,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/paper)
	permeability_coefficient = 0.6
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 0)
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

	verb/toggle()
		set name = "Toggle Labcoat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		//Why???
		switch(icon_state)
			if("labcoat_open")
				src.icon_state = "labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat")
				src.icon_state = "labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("red_labcoat_open")
				src.icon_state = "red_labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("red_labcoat")
				src.icon_state = "red_labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("blue_labcoat_open")
				src.icon_state = "blue_labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("blue_labcoat")
				src.icon_state = "blue_labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("purple_labcoat_open")
				src.icon_state = "purple_labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("purple_labcoat")
				src.icon_state = "purple_labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("green_labcoat_open")
				src.icon_state = "green_labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("green_labcoat")
				src.icon_state = "green_labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("orange_labcoat_open")
				src.icon_state = "orange_labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("orange_labcoat")
				src.icon_state = "orange_labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_cmo_open")
				src.icon_state = "labcoat_cmo"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_cmo")
				src.icon_state = "labcoat_cmo_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_gen_open")
				src.icon_state = "labcoat_gen"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_gen")
				src.icon_state = "labcoat_gen_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_chem_open")
				src.icon_state = "labcoat_chem"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_chem")
				src.icon_state = "labcoat_chem_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_vir_open")
				src.icon_state = "labcoat_vir"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_vir")
				src.icon_state = "labcoat_vir_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_tox_open")
				src.icon_state = "labcoat_tox"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_tox")
				src.icon_state = "labcoat_tox_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labgreen_open")
				src.icon_state = "labgreen"
				to_chat(usr, "You button up the labcoat.")
			if("labgreen")
				src.icon_state = "labgreen_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("sciencecoat_open")
				src.icon_state = "sciencecoat"
				to_chat(usr, "You button up the labcoat.")
			if("sciencecoat")
				src.icon_state = "sciencecoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			else
				to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how silly you are.")
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
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 60, "rad" = 0, "fire" = 0, "acid" = 0)

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
	flags_armor_protection = CHEST|GROIN|ARMS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS
	soft_armor = list("melee" = 15, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	siemens_coefficient = 0.7
	permeability_coefficient = 0.8
	allowed = list (/obj/item/flashlight, /obj/item/tank/emergency_oxygen)

/obj/item/clothing/suit/storage/snow_suit/doctor
	name = "doctor's snow suit"
	icon_state = "snowsuit_doctor"
	permeability_coefficient = 0.6
	soft_armor = list("melee" = 25, "bullet" = 35, "laser" = 35, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)

/obj/item/clothing/suit/storage/snow_suit/engineer
	name = "engineer's snow suit"
	icon_state = "snowsuit_engineer"
	soft_armor = list("melee" = 25, "bullet" = 35, "laser" = 35, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)
