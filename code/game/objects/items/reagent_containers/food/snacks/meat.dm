/obj/item/reagent_container/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	health = 180
	filling_color = "#FF1C1C"
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 3

/obj/item/reagent_container/food/snacks/meat/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/tool/kitchen/knife))
		new /obj/item/reagent_container/food/snacks/rawcutlet(src)
		new /obj/item/reagent_container/food/snacks/rawcutlet(src)
		new /obj/item/reagent_container/food/snacks/rawcutlet(src)
		user << "You cut the meat in thin strips."
		cdel(src)
	else
		..()

/obj/item/reagent_container/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/reagent_container/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null


/obj/item/reagent_container/food/snacks/meat/monkey
	//same as plain meat

/obj/item/reagent_container/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."