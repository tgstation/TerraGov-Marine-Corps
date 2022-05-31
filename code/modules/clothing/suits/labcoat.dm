/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat_open"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS
	pockets = /obj/item/storage/internal/modular/medical
	permeability_coefficient = 0.6
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 0)
	allowed = list(
		/obj/item/stack/medical,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/healthanalyzer,
		/obj/item/flashlight,
		/obj/item/radio,
		/obj/item/tank/emergency_oxygen,
	)

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
				src.item_state = "labcoat"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat")
				src.icon_state = "labcoat_open"
				src.item_state = "labcoat_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_cmo_open")
				src.icon_state = "labcoat_cmo"
				src.item_state = "labcoat_cmo"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_cmo")
				src.icon_state = "labcoat_cmo_open"
				src.item_state = "labcoat_cmo_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_gen_open")
				src.icon_state = "labcoat_gen"
				src.item_state = "labcoat_gen"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_gen")
				src.icon_state = "labcoat_gen_open"
				src.item_state = "labcoat_gen_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_chem_open")
				src.icon_state = "labcoat_chem"
				src.item_state = "labcoat_chem"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_chem")
				src.icon_state = "labcoat_chem_open"
				src.item_state = "labcoat_chem_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_viro_open")
				src.icon_state = "labcoat_viro"
				src.item_state = "labcoat_viro"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_viro")
				src.icon_state = "labcoat_viro_open"
				src.item_state = "labcoat_viro_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_sci_open")
				src.icon_state = "labcoat_sci"
				src.item_state = "labcoat_sci"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_sci")
				src.icon_state = "labcoat_sci_open"
				src.item_state = "labcoat_sci_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_mad_open")
				src.icon_state = "labcoat_mad"
				src.item_state = "labcoat_mad"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_mad")
				src.icon_state = "labcoat_mad_open"
				src.item_state = "labcoat_mad_open"
				to_chat(usr, "You unbutton the labcoat.")
			if("labcoat_researcher_open")
				src.icon_state = "labcoat_researcher"
				src.item_state = "labcoat_researcher"
				to_chat(usr, "You button up the labcoat.")
			if("labcoat_researcher")
				src.icon_state = "labcoat_researcher_open"
				src.item_state = "labcoat_researcher_open"
				to_chat(usr, "You unbutton the labcoat.")
			else
				to_chat(usr, "You attempt to button-up the velcro on your [src], before promptly realising how silly you are.")
				return
		update_clothing_icon()	//so our overlays update

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo_open"

/obj/item/clothing/suit/storage/labcoat/mad
	name = "The Mad's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labcoat_mad_open"
	item_state = "labcoat_mad_open"

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "Geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen_open"
	item_state = "labcoat_gen_open"

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "Chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem_open"
	item_state = "labcoat_chem_open"

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "Virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_viro_open"
	item_state = "labcoat_viro_open"

/obj/item/clothing/suit/storage/labcoat/science
	name = "Scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_sci_open"
	item_state = "labcoat_sci_open"

/obj/item/clothing/suit/storage/labcoat/researcher
	name = "Researcher's labcoat"
	desc = "A high quality labcoat, seemingly worn by scholars and researchers alike. It has a distinct rough feel to it, and goads you towards adventure."
	icon_state = "labcoat_researcher_open"
	item_state = "labcoat_researcher_open"
