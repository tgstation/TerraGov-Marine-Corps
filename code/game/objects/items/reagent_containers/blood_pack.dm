/obj/item/reagent_containers/blood
	name = "BloodPack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/items/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	init_reagent_flags = AMOUNT_ESTIMEE
	var/blood_type


/obj/item/reagent_containers/blood/Initialize()
	. = ..()
	if(blood_type)
		name = "BloodPack [blood_type]"
		reagents.add_reagent(/datum/reagent/blood, 200, list("donor"=null,"blood_DNA"=null,"blood_type"=blood_type))

/obj/item/reagent_containers/blood/on_reagent_change()
	update_overlays()

/obj/item/reagent_containers/blood/update_overlays()
	. = ..()

	overlays.Cut()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 9)
				filling.icon_state = "[initial(icon_state)]-10"
			if(10 to 24)
				filling.icon_state = "[initial(icon_state)]10"
			if(25 to 49)
				filling.icon_state = "[initial(icon_state)]25"
			if(50 to 74)
				filling.icon_state = "[initial(icon_state)]50"
			if(75 to 79)
				filling.icon_state = "[initial(icon_state)]75"
			if(80 to 90)
				filling.icon_state = "[initial(icon_state)]80"
			if(91 to INFINITY)
				filling.icon_state = "[initial(icon_state)]100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

	if(blood_type)
		add_overlay(image('icons/obj/items/bloodpack.dmi', "[blood_type]"))

/obj/item/reagent_containers/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/blood/OMinus
	blood_type = "O-"

/obj/item/reagent_containers/blood/empty
	name = "Empty BloodPack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
