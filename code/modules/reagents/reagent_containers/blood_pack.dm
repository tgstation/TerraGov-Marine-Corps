/obj/item/reagent_containers/blood
	name = "BloodPack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/items/bloodpack.dmi'
	icon_state = "empty"
	volume = 200
	reagent_flags = AMOUNT_ESTIMEE
	var/blood_type


/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	if(blood_type)
		name = "BloodPack [blood_type]"
		reagents.add_reagent(/datum/reagent/blood, 200, list("donor"=null,"blood_DNA"=null,"blood_type"=blood_type))
		update_icon()


/obj/item/reagent_containers/blood/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/blood/update_icon_state()
	. = ..()
	var/percent = PERCENT(reagents.total_volume / volume)
	switch(percent)
		if(0 to 9.9)
			icon_state = "empty"
		if(10 to 50)
			icon_state = "half"
		if(50.1 to INFINITY)
			icon_state = "full"

/obj/item/reagent_containers/blood/APlus
	name = "BloodPack A+" //so it shows up correctly in req
	blood_type = "A+"

/obj/item/reagent_containers/blood/AMinus
	name = "BloodPack A-"
	blood_type = "A-"

/obj/item/reagent_containers/blood/BPlus
	name = "BloodPack B+"
	blood_type = "B+"

/obj/item/reagent_containers/blood/BMinus
	name = "BloodPack B-"
	blood_type = "B-"

/obj/item/reagent_containers/blood/OPlus
	name = "BloodPack O+"
	blood_type = "O+"

/obj/item/reagent_containers/blood/OMinus
	name = "BloodPack O-"
	blood_type = "O-"

/obj/item/reagent_containers/blood/empty
	name = "Empty BloodPack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "empty"

/obj/item/reagent_containers/blood/random
	name = "BloodPack \[random\]"

/obj/item/reagent_containers/blood/random/Initialize(mapload)
	blood_type = pickweight(
		list(
		"A+" = 20,
		"A-" = 20,
		"B+" = 20,
		"B-" = 20,
		"O+" = 20,
		"O-" = 5,
		)
		)
	. = ..()
