/obj/item/reagent_containers/food/snacks/meat
	var/subjectname = ""
	var/subjectjob = null

/obj/item/reagent_containers/food/snacks/meat/slab
	name = "meat"
	desc = ""
	dried_type = /obj/item/reagent_containers/food/snacks/sosjerky/healthy
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/cooking_oil = 2) //Meat has fats that a food processor can process into cooking oil
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/plain
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain
	slices_num = 3
	filling_color = "#FF0000"
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/initialize_slice(obj/item/reagent_containers/food/snacks/meat/rawcutlet/slice, reagents_per_slice)
	..()
	var/mutable_appearance/filling = mutable_appearance(icon, "rawcutlet_coloration")
	filling.color = filling_color
	slice.add_overlay(filling)
	slice.filling_color = filling_color
	slice.name = "[name] cutlet"
/obj/item/reagent_containers/food/snacks/meat/slab/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	S.name = "[name] steak"

///////////////////////////////////// HUMAN MEATS //////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/slab/human
	name = "meat"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/plain/human
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/initialize_slice(obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human/slice, reagents_per_slice)
	..()
	slice.subjectname = subjectname
	slice.subjectjob = subjectjob
	if(subjectname)
		slice.name = "raw [subjectname] cutlet"
	else if(subjectjob)
		slice.name = "raw [subjectjob] cutlet"

/obj/item/reagent_containers/food/snacks/meat/slab/human/initialize_cooked_food(obj/item/reagent_containers/food/snacks/meat/S, cooking_efficiency)
	..()
	S.subjectname = subjectname
	S.subjectjob = subjectjob
	if(subjectname)
		S.name = "[subjectname] meatsteak"
	else if(subjectjob)
		S.name = "[subjectjob] meatsteak"


/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	icon_state = "slimemeat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin/slimejelly = 3)
	filling_color = "#00FFFF"
	tastes = list("slime" = 1, "jelly" = 1)
	foodtype = MEAT | RAW | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem
	icon_state = "golemmeat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/iron = 3)
	filling_color = "#A9A9A9"
	tastes = list("rock" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = ""
	filling_color = "#66CDAA"
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = ""
	filling_color = "#6B8E23"
	tastes = list("meat" = 4, "scales" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	icon_state = "plantmeat"
	desc = ""
	filling_color = "#E9967A"
	tastes = list("salad" = 1, "wood" = 1)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = ""
	filling_color = "#202020"
	tastes = list("darkness" = 1, "meat" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	icon_state = "flymeat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/uranium = 3)
	tastes = list("maggots" = 1, "the inside of a reactor" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	icon_state = "mothmeat"
	desc = ""
	filling_color = "#BF896B"
	tastes = list("dust" = 1, "powder" = 1, "meat" = 2)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	name = "bone"
	icon_state = "skeletonmeat"
	desc = ""
	filling_color = "#F0F0F0"
	tastes = list("bone" = 1)
	slice_path = null  //can't slice a bone into cutlets
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	name = " meat (rotten)"
	icon_state = "rottenmeat"
	desc = ""
	filling_color = "#6B8E23"
	tastes = list("brains" = 1, "meat" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ethereal
	icon_state = "etherealmeat"
	desc = ""
	filling_color = "#97ee63"
	list_reagents = list(/datum/reagent/consumable/liquidelectricity = 3)
	tastes = list("pure electricity" = 2, "meat" = 1)
	foodtype = RAW | MEAT | TOXIC

////////////////////////////////////// OTHER MEATS ////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/slab/synthmeat
	name = "synthmeat"
	desc = ""
	foodtype = RAW | MEAT //hurr durr chemicals we're harmed in the production of this meat thus its non-vegan.

/obj/item/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	desc = ""
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/monkey
	name = "monkey meat"
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/mouse
	name = "mouse meat"
	desc = ""
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/corgi
	name = "corgi meat"
	desc = ""
	tastes = list("meat" = 4, "a fondness for wearing hats" = 1)
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/pug
	name = "pug meat"
	desc = ""
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/killertomato
	name = "killer tomato meat"
	desc = ""
	icon_state = "tomatomeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	filling_color = "#FF0000"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/killertomato
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/killertomato
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/slab/bear
	name = "bear meat"
	desc = ""
	icon_state = "bearmeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/medicine/morphine = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/cooking_oil = 6)
	filling_color = "#FFB6C1"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/bear
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/bear
	tastes = list("meat" = 1, "salmon" = 1)
	foodtype = RAW | MEAT


/obj/item/reagent_containers/food/snacks/meat/slab/xeno
	name = "xeno meat"
	desc = ""
	icon_state = "xenomeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	bitesize = 4
	filling_color = "#32CD32"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/xeno
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/xeno
	tastes = list("meat" = 1, "acid" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/spider
	name = "spider meat"
	desc = ""
	icon_state = "spidermeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#7CFC00"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/spider
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/spider
	tastes = list("cobwebs" = 1)
	foodtype = RAW | MEAT | TOXIC


/obj/item/reagent_containers/food/snacks/meat/slab/goliath
	name = "goliath meat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/toxin = 5, /datum/reagent/consumable/cooking_oil = 3)
	icon_state = "goliathmeat"
	tastes = list("meat" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/goliath/burn()
	visible_message("<span class='notice'>[src] finishes cooking!</span>")
	new /obj/item/reagent_containers/food/snacks/meat/steak/goliath(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/meat/slab/meatwheat
	name = "meatwheat clump"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/blood = 5, /datum/reagent/consumable/cooking_oil = 1)
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4
	tastes = list("meat" = 1, "wheat" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/meat/slab/gorilla
	name = "gorilla meat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 5) //Plenty of fat!

/obj/item/reagent_containers/food/snacks/meat/rawbacon
	name = "raw piece of bacon"
	desc = ""
	icon_state = "bacon"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/bacon
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cooking_oil = 3)
	filling_color = "#B22222"
	tastes = list("bacon" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/bacon
	name = "piece of bacon"
	desc = ""
	icon_state = "baconcooked"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 2)
	filling_color = "#854817"
	tastes = list("bacon" = 1)
	foodtype = MEAT | BREAKFAST

/obj/item/reagent_containers/food/snacks/meat/slab/gondola
	name = "gondola meat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/tranquility = 5, /datum/reagent/consumable/cooking_oil = 3)
	tastes = list("meat" = 4, "tranquility" = 1)
	filling_color = "#9A6750"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/gondola
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/gondola
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/penguin
	name = "penguin meat"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/cooking_oil = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/penguin
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/penguin
	filling_color = "#B22222"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcrab
	name = "raw crab meat"
	desc = ""
	icon_state = "crabmeatraw"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/crab
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cooking_oil = 3)
	filling_color = "#EAD079"
	tastes = list("raw crab" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/crab
	name = "crab meat"
	desc = ""
	icon_state = "crabmeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/cooking_oil = 2)
	filling_color = "#DFB73A"
	tastes = list("crab" = 1)
	foodtype = MEAT

////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/steak
	name = "steak"
	desc = ""
	icon_state = "meatsteak"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	trash = /obj/item/trash/plate
	filling_color = "#B22222"
	foodtype = MEAT
	tastes = list("meat" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/steak/killertomato
	name = "killer tomato steak"
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/steak/bear
	name = "bear steak"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/xeno
	name = "xeno steak"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/spider
	name = "spider steak"
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/goliath
	name = "goliath steak"
	desc = ""
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash = null
	tastes = list("meat" = 1, "rock" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/gondola
	name = "gondola steak"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/penguin
	name = "penguin steak"
	tastes = list("beef" = 1, "cod fish" = 1)

//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////

//Raw cutlets

/obj/item/reagent_containers/food/snacks/meat/rawcutlet
	name = "raw cutlet"
	desc = ""
	icon_state = "rawcutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	filling_color = "#B22222"
	tastes = list("meat" = 1)
//	var/meat_type = "meat"
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	if(subjectname)
		S.name = "[subjectname] [initial(S.name)]"
	else if(subjectjob)
		S.name = "[subjectjob] [initial(S.name)]"

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/killertomato
	name = "raw killer tomato cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/bear
	name = "raw bear cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/xeno
	name = "raw xeno cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/spider
	name = "raw spider cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/spider
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/gondola
	name = "raw gondola cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/gondola
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/penguin
	name = "raw penguin cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/penguin
	tastes = list("beef" = 1, "cod fish" = 1)

//Cooked cutlets

/obj/item/reagent_containers/food/snacks/meat/cutlet
	name = "cutlet"
	desc = ""
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#B22222"
	tastes = list("meat" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato
	name = "killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	name = "bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	name = "xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/spider
	name = "spider cutlet"
	tastes = list("cobwebs" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/gondola
	name = "gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/penguin
	name = "penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)
