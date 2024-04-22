
/obj/item/reagent_containers/food/snacks/pie
	icon = 'icons/obj/food/piecake.dmi'
	trash = /obj/item/trash/plate
	bitesize = 3
	w_class = WEIGHT_CLASS_NORMAL
	volume = 80
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pie" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pie/plain
	name = "plain pie"
	desc = ""
	icon_state = "pie"
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/pie
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("pie" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pie/cream
	name = "banana cream pie"
	desc = ""
	icon_state = "pie"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pie" = 1)
	foodtype = GRAIN | DAIRY | SUGAR
	var/stunning = TRUE

/obj/item/reagent_containers/food/snacks/pie/cream/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if we're not being caught
		splat(hit_atom)

/obj/item/reagent_containers/food/snacks/pie/cream/proc/splat(atom/movable/hit_atom)
	if(isliving(loc)) //someone caught us!
		return
	var/turf/T = get_turf(hit_atom)
	new/obj/effect/decal/cleanable/food/pie_smudge(T)
	if(reagents && reagents.total_volume)
		reagents.reaction(hit_atom, TOUCH)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		if(stunning)
			L.Paralyze(20) //splat!
		L.adjust_blurriness(1)
		L.visible_message("<span class='warning'>[L] is creamed by [src]!</span>", "<span class='danger'>You've been creamed by [src]!</span>")
		playsound(L, "desceration", 50, TRUE)
	if(is_type_in_typecache(hit_atom, GLOB.creamable))
		hit_atom.AddComponent(/datum/component/creamed, src)
	qdel(src)

/obj/item/reagent_containers/food/snacks/pie/cream/nostun
	stunning = FALSE

/obj/item/reagent_containers/food/snacks/pie/berryclafoutis
	name = "berry clafoutis"
	desc = ""
	icon_state = "berryclafoutis"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/berryjuice = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pie" = 1, "blackberries" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/bearypie
	name = "beary pie"
	desc = ""
	icon_state = "bearypie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)
	foodtype = GRAIN | SUGAR | MEAT | FRUIT

/obj/item/reagent_containers/food/snacks/pie/meatpie
	name = "meat-pie"
	icon_state = "meatpie"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/pie/tofupie
	name = "tofu-pie"
	icon_state = "meatpie"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pie" = 1, "tofu" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pie/amanita_pie
	name = "amanita pie"
	desc = ""
	icon_state = "amanita_pie"
	bitesize = 4
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/amatoxin = 3, /datum/reagent/drug/mushroomhallucinogen = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | TOXIC | GROSS

/obj/item/reagent_containers/food/snacks/pie/plump_pie
	name = "plump pie"
	desc = ""
	icon_state = "plump_pie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pie/plump_pie/Initialize()
	. = ..()
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump pie"
		desc = ""
		bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/medicine/omnizine = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	if(fey)
		reagents.add_reagent(/datum/reagent/medicine/omnizine, 5)

/obj/item/reagent_containers/food/snacks/pie/xemeatpie
	name = "xeno-pie"
	icon_state = "xenomeatpie"
	desc = ""
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/pie/applepie
	name = "apple pie"
	desc = ""
	icon_state = "applepie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("pie" = 1, "apple" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/cherrypie
	name = "cherry pie"
	desc = ""
	icon_state = "cherrypie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("pie" = 7, "Nicole Paige Brooks" = 2)
	foodtype = GRAIN | FRUIT | SUGAR


/obj/item/reagent_containers/food/snacks/pie/pumpkinpie
	name = "pumpkin pie"
	desc = ""
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pumpkinpieslice
	name = "pumpkin pie slice"
	desc = ""
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFA500"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "pumpkin" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pie/appletart
	name = "golden apple streusel tart"
	desc = ""
	icon_state = "gappletart"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/gold = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/grapetart
	name = "grape tart"
	desc = ""
	icon_state = "grapetart"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "grape" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/mimetart
	name = "mime tart"
	desc = ""
	icon_state = "mimetart"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/nothing = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("nothing" = 3)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pie/berrytart
	name = "berry tart"
	desc = ""
	icon_state = "berrytart"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "berries" = 2)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/pie/cocolavatart
	name = "chocolate lava tart"
	desc = ""
	icon_state = "cocolavatart"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "dark chocolate" = 3)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/pie/blumpkinpie
	name = "blumpkin pie"
	desc = ""
	icon_state = "blumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/blumpkinpieslice
	slices_num = 5
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/blumpkinpieslice
	name = "blumpkin pie slice"
	desc = ""
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "blumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#1E90FF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "a mouthful of pool water" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pie/dulcedebatata
	name = "dulce de batata"
	desc = ""
	icon_state = "dulcedebatata"
	slice_path = /obj/item/reagent_containers/food/snacks/dulcedebatataslice
	slices_num = 5
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtype = GRAIN | VEGETABLES | SUGAR

/obj/item/reagent_containers/food/snacks/dulcedebatataslice
	name = "dulce de batata slice"
	desc = ""
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "dulcedebatataslice"
	trash = /obj/item/trash/plate
	filling_color = "#8B4513"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("jelly" = 1, "sweet potato" = 1)
	foodtype = GRAIN | VEGETABLES | SUGAR

/obj/item/reagent_containers/food/snacks/pie/frostypie
	name = "frosty pie"
	desc = ""
	icon_state = "frostypie"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("mint" = 1, "pie" = 1)
	foodtype = GRAIN | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/pie/baklava
	name = "baklava"
	desc = ""
	icon_state = "baklava"
	slice_path = /obj/item/reagent_containers/food/snacks/baklavaslice
	slices_num = 6
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("nuts" = 1, "pie" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/baklavaslice
	name = "baklava dish"
	desc = ""
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "baklavaslice"
	trash = /obj/item/trash/plate
	filling_color = "#1E90FF"
	tastes = list("nuts" = 1, "pie" = 1)
	foodtype = GRAIN
