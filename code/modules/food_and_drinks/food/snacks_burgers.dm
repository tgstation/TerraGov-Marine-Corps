/obj/item/reagent_containers/food/snacks/burger
	filling_color = "#CD853F"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bun" = 4)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/plain
	name = "burger"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/plain/Initialize()
	. = ..()
	if(prob(1))
		new/obj/effect/particle_effect/smoke(get_turf(src))
		playsound(src, 'sound/blank.ogg', 50, TRUE)
		visible_message("<span class='warning'>Oh, ye gods! [src] is ruined! But what if...?</span>")
		name = "steamed ham"
		desc = pick("Ahh, Head of Personnel, welcome. I hope you're prepared for an unforgettable luncheon!",
		"And you call these steamed hams despite the fact that they are obviously microwaved?",
		"Aurora Station 13? At this time of shift, in this time of year, in this sector of space, localized entirely within your freezer?",
		"You know, these hamburgers taste quite similar to the ones they have at the Maltese Falcon.")
		tastes = list("fast food hamburger" = 1)

/obj/item/reagent_containers/food/snacks/burger/human
	var/subjectname = ""
	var/subjectjob = null
	name = "human burger"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4)
	foodtype = MEAT | GRAIN | GROSS

/obj/item/reagent_containers/food/snacks/burger/human/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/snacks/meat/M = locate(/obj/item/reagent_containers/food/snacks/meat/steak/plain/human) in contents
	if(M)
		subjectname = M.subjectname
		subjectjob = M.subjectjob
		if(subjectname)
			name = "[subjectname] burger"
		else if(subjectjob)
			name = "[subjectjob] burger"
		qdel(M)


/obj/item/reagent_containers/food/snacks/burger/corgi
	name = "corgi burger"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/appendix
	name = "appendix burger"
	desc = ""
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	icon_state = "appendixburger"
	tastes = list("bun" = 4, "grass" = 2)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/fish
	name = "fillet -o- carp sandwich"
	desc = ""
	icon_state = "fishburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("bun" = 4, "fish" = 4)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/tofu
	name = "tofu burger"
	desc = ""
	icon_state = "tofuburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bun" = 4, "tofu" = 4)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = ""
	icon_state = "roburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/nanomachines = 2, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/nanomachines = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/roburgerbig
	name = "roburger"
	desc = ""
	icon_state = "roburger"
	volume = 120
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/nanomachines = 70, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/nanomachines = 70, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/xeno
	name = "xenoburger"
	desc = ""
	icon_state = "xburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("bun" = 4, "acid" = 4)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/bearger
	name = "bearger"
	desc = ""
	icon_state = "bearger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 6)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/clown
	name = "clown burger"
	desc = ""
	icon_state = "clownburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/banana = 6)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/burger/mime
	name = "mime burger"
	desc = ""
	icon_state = "mimeburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/nothing = 6)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/burger/brain
	name = "brainburger"
	desc = ""
	icon_state = "brainburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/medicine/mannitol = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/medicine/mannitol = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bun" = 4, "brains" = 2)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/ghost
	name = "ghost burger"
	desc = ""
	alpha = 125
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 12)
	tastes = list("bun" = 4, "ectoplasm" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/burger/red
	name = "red burger"
	desc = ""
	icon_state = "cburger"
	color = "#DA0000FF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/red = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/orange
	name = "orange burger"
	desc = ""
	icon_state = "cburger"
	color = "#FF9300FF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/orange = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/yellow
	name = "yellow burger"
	desc = ""
	icon_state = "cburger"
	color = "#FFF200FF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/yellow = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/green
	name = "green burger"
	desc = ""
	icon_state = "cburger"
	color = "#A8E61DFF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/green = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/blue
	name = "blue burger"
	desc = ""
	icon_state = "cburger"
	color = "#00B7EFFF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/blue = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/purple
	name = "purple burger"
	desc = ""
	icon_state = "cburger"
	color = "#DA00FFFF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/purple = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/black
	name = "black burger"
	desc = ""
	icon_state = "cburger"
	color = "#1C1C1C"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/black = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/white
	name = "white burger"
	desc = ""
	icon_state = "cburger"
	color = "#FFFFFF"
	bonus_reagents = list(/datum/reagent/colorful_reagent/powder/white = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/spell
	name = "spell burger"
	desc = ""
	icon_state = "spellburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("bun" = 4, "magic" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/bigbite
	name = "big bite burger"
	desc = ""
	icon_state = "bigbiteburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 2)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/jelly
	name = "jelly burger"
	desc = ""
	icon_state = "jellyburger"
	tastes = list("bun" = 4, "jelly" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/jelly/slime
	bonus_reagents = list(/datum/reagent/toxin/slimejelly = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/slimejelly = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/jelly/cherry
	bonus_reagents = list(/datum/reagent/consumable/cherryjelly = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/cherryjelly = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/burger/superbite
	name = "super bite burger"
	desc = ""
	icon_state = "superbiteburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 40, /datum/reagent/consumable/nutriment/vitamin = 5)
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 7
	volume = 100
	tastes = list("bun" = 4, "type two diabetes" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/fivealarm
	name = "five alarm burger"
	desc = ""
	icon_state = "fivealarmburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/condensedcapsaicin = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/rat
	name = "rat burger"
	desc = ""
	icon_state = "ratburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/baseball
	name = "home run baseball burger"
	desc = ""
	icon_state = "baseball"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | GROSS

/obj/item/reagent_containers/food/snacks/burger/baconburger
	name = "bacon burger"
	desc = ""
	icon_state = "baconburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bun" = 4, "bacon" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/empoweredburger
	name = "empowered burger"
	desc = ""
	icon_state = "empoweredburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/liquidelectricity = 5)
	tastes = list("bun" = 2, "pure electricity" = 4)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/crab
	name = "crab burger"
	desc = ""
	icon_state = "crabburger"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("bun" = 2, "crab meat" = 4)
	foodtype = GRAIN | MEAT
