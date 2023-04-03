/obj/item/reagent_containers/food/snacks/sandwiches
	icon = 'icons/obj/items/burgerbread.dmi'

/obj/item/reagent_containers/food/snacks/sandwiches/breadslice/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/shard) || istype(I, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/S = new(loc)
		S.attackby(I, user, params)
		qdel(src)

/obj/item/reagent_containers/food/snacks/sandwiches/grilled_cheese_sandwich
	name = "grilled cheese sandwich"
	desc = "A warm, melty sandwich that goes perfectly with tomato soup."
	icon_state = "toastedsandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/carbon = 4)
	tastes = list("toast" = 2, "cheese" = 3, "butter" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/cheese_sandwich
	name = "cheese sandwich"
	desc = "A light snack for a warm day. ...but what if you grilled it?"
	icon_state = "sandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bread" = 1, "cheese" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich
	name = "jelly sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	tastes = list("bread" = 1, "jelly" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich/cherry
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("nothing suspicious" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/jelliedtoast
	name = "jellied toast"
	desc = "A slice of toast covered with delicious jam."
	icon_state = "jellytoast"
	tastes = list("toast" = 1, "jelly" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/blt
	name = "\improper BLT"
	desc = "A classic bacon, lettuce, and tomato sandwich."
	icon_state = "blt"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("bacon" = 3, "lettuce" = 2, "tomato" = 2, "bread" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/twobread
	name = "two bread"
	desc = "This seems awfully bitter."
	icon_state = "twobread"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("bread" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/jelliedtoast/cherry
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 8, /datum/reagent/consumable/nutriment/vitamin = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/butteredtoast
	name = "buttered toast"
	desc = "Butter lightly spread over a piece of toast."
	icon = 'icons/obj/items/food.dmi'
	icon_state = "butteredtoast"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter" = 1, "toast" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."

	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

	var/list/ingredients = list()

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/sandwich_limit = 4
	for(var/obj/item/reagent_containers/food/snacks/sandwiches/breadslice/B in ingredients)
		sandwich_limit += 4

	if(length(contents) > sandwich_limit)
		to_chat(user, span_warning("If you put anything else on \the [src] it's going to collapse."))

	else if(istype(I, /obj/item/shard))
		to_chat(user, span_notice("You hide [I] in \the [src]."))
		user.transferItemToLoc(I, src)
		update()

	else if(istype(I, /obj/item/reagent_containers/food/snacks))
		to_chat(user, span_notice("You layer [I] over \the [src]."))
		var/obj/item/reagent_containers/F = I
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.transferItemToLoc(I, src)
		ingredients += I
		update()

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/proc/update()
	var/fullname = "" //We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/reagent_containers/food/snacks/sandwiches/O in ingredients)

		i++
		if(i == 1)
			fullname += "[O.name]"
		else if(i == length(ingredients))
			fullname += " and [O.name]"
		else
			fullname += ", [O.name]"

		var/image/I = new(src.icon, "breadslice_filling")
		I.color = O.filling_color
		I.pixel_x = pick(list(-1,0,1))
		I.pixel_y = (i*2)+1
		overlays += I

	var/image/T = new(src.icon, "breadslice")
	T.pixel_x = pick(list(-1,0,1))
	T.pixel_y = (length(ingredients) * 2)+1
	overlays += T

	name = lowertext("[fullname] sandwich")
	if(length(name) > 80) name = "[pick(list("absurd","colossal","enormous","ridiculous"))] sandwich"
	w_class = CEILING(clamp((length(ingredients)/2),1,3),1)

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/Destroy()
	for(var/obj/item/O in ingredients)
		qdel(O)
	. = ..()

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/examine(mob/user)
	. = ..()
	var/obj/item/O = pick(contents)
	. += span_notice("You think you can see [O] in there.")

/obj/item/reagent_containers/food/snacks/sandwiches/csandwich/attack(mob/M as mob, mob/user as mob, def_zone)

	var/obj/item/shard
	for(var/obj/item/O in contents)
		if(istype(O,/obj/item/shard))
			shard = O
			break

	var/mob/living/H
	if(istype(M,/mob/living))
		H = M

	if(H && shard && M == user) //This needs a check for feeding the food to other people, but that could be abusable.
		to_chat(H, span_warning("You lacerate your mouth on a [shard.name] in the sandwich!"))
		H.adjustBruteLoss(5) //TODO: Target head if human.
	..()

/obj/item/reagent_containers/food/snacks/sandwiches/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	bitesize = 2
	tastes = list("meat" = 2, "cheese" = 1, "bread" = 2, "lettuce" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/carbon = 2)
	bitesize = 2
	tastes = list("toast" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/carbon = 2)
	bitesize = 2
	tastes = list("toast" = 1)

/obj/item/reagent_containers/food/snacks/burger
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bun" = 2, "beef patty" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/plain
	name = "plain burger"
	icon_state = "hburger"
	desc = "The cornerstone of every nutritious breakfast."
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/plain/Initialize(mapload)
	. = ..()
	if(prob(1))
		new/obj/effect/particle_effect/fluid/smoke(get_turf(src))
		playsound(src, 'sound/effects/smoke.ogg', 50, TRUE)
		visible_message(span_warning("Oh, ye gods! [src] is ruined! But what if...?"))
		name = "steamed ham"
		desc = pick("Ahh, CMO, welcome. I hope you're prepared for an unforgettable luncheon!",
		"And you call these steamed hams despite the fact that they are obviously microwaved?",
		"TGMC Marine Corp? At this time of shift, in this time of year, in this sector of space, localized entirely within your freezer?",
		"You know, these hamburgers taste quite similar to the ones they have at the Maltese Falcon.")

/obj/item/reagent_containers/food/snacks/sandwiches/human
	name = "human burger"
	desc = "A bloody burger."
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bun" = 2, "long pig" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	icon_state = "appendixburger"
	tastes = list("bun" = 4, "grass" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/fish
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("bun" = 4, "fish" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/tofu
	name = "tofu burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("bun" = 4, "tofu" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/cyborg_mutation_nanomachines = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 11, /datum/reagent/cyborg_mutation_nanomachines = 80, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/xeno
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bun" = 4, "acid" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/bearger
	name = "bearger"
	desc = "Best served rawr."
	icon_state = "bearger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 5)

/obj/item/reagent_containers/food/snacks/sandwiches/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 6)

/obj/item/reagent_containers/food/snacks/sandwiches/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 9, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/drink/nothing = 6)

/obj/item/reagent_containers/food/snacks/sandwiches/brain
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/medicine/mannitol = 6, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/nutriment/protein = 6)
	tastes = list("bun" = 4, "brains" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/red
	name = "red burger"
	desc = "Perfect for hiding the fact it's burnt to a crisp."
	icon_state = "cburger"
	color = COLOR_RED
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/red = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/orange
	name = "orange burger"
	desc = "Contains 0% juice."
	icon_state = "cburger"
	color = COLOR_ORANGE
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/orange = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/yellow
	name = "yellow burger"
	desc = "Bright to the last bite."
	icon_state = "cburger"
	color = COLOR_YELLOW
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/yellow = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/green
	name = "green burger"
	desc = "It's not tainted meat, it's painted meat!"
	icon_state = "cburger"
	color = COLOR_GREEN
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/green = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/blue
	name = "blue burger"
	desc = "Is this blue rare?"
	icon_state = "cburger"
	color = COLOR_BLUE
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/blue = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/purple
	name = "purple burger"
	desc = "Regal and low class at the same time."
	icon_state = "cburger"
	color = COLOR_PURPLE
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/purple = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/black
	name = "black burger"
	desc = "This is overcooked."
	icon_state = "cburger"
	color = COLOR_ALMOST_BLACK
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/black = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/white
	name = "white burger"
	desc = "Delicous Titanium!"
	icon_state = "cburger"
	color = COLOR_WHITE
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/colorful_reagent/powder/white = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/spell
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("bun" = 4, "magic" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/bigbite
	name = "big bite burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 10, /datum/reagent/consumable/nutriment/vitamin = 5)

/obj/item/reagent_containers/food/snacks/sandwiches/jelly
	name = "jelly burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	tastes = list("bun" = 4, "jelly" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/jelly/slime
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin/slimejelly = 6, /datum/reagent/consumable/nutriment/vitamin = 6)

/obj/item/reagent_containers/food/snacks/sandwiches/jelly/cherry
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/cherryjelly = 6, /datum/reagent/consumable/nutriment/vitamin = 6)

/obj/item/reagent_containers/food/snacks/sandwiches/superbite
	name = "super bite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 40, /datum/reagent/consumable/nutriment/vitamin = 12)
	tastes = list("bun" = 4, "type two diabetes" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/fivealarm
	name = "five alarm burger"
	desc = "HOT! HOT!"
	icon_state = "fivealarmburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/condensedcapsaicin = 5, /datum/reagent/consumable/nutriment/vitamin = 6)

/obj/item/reagent_containers/food/snacks/sandwiches/rat
	name = "rat burger"
	desc = "Pretty much what you'd expect..."
	icon_state = "ratburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/baseball
	name = "home run baseball burger"
	desc = "It's still warm. The steam coming off of it looks like baseball."
	icon_state = "baseball"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/baconburger
	name = "bacon burger"
	desc = "The perfect combination of all things American."
	icon_state = "baconburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bacon" = 4, "bun" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/empoweredburger
	name = "empowered burger"
	desc = "It's shockingly good, if you live off of electricity that is."
	icon_state = "empoweredburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/liquidelectricity/enriched = 6)
	tastes = list("bun" = 2, "pure electricity" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/catburger
	name = "catburger"
	desc = "Finally those cats and catpeople are worth something!"
	icon_state = "catburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bun" = 4, "meat" = 2, "cat" = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/crab
	name = "crab burger"
	desc = "A delicious patty of the crabby kind, slapped in between a bun."
	icon_state = "crabburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("bun" = 2, "crab meat" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/soylent
	name = "soylent burger"
	desc = "An eco-friendly burger made using upcycled low value biomass."
	icon_state = "soylentburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("bun" = 2, "assistant" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/rib
	name = "mcrib"
	desc = "An elusive rib shaped burger with limited availablity across the galaxy. Not as good as you remember it."
	icon_state = "mcrib"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/bbqsauce = 1)
	tastes = list("bun" = 2, "pork patty" = 4)

/obj/item/reagent_containers/food/snacks/sandwiches/mcguffin
	name = "mcguffin"
	desc = "A cheap and greasy imitation of an eggs benedict."
	icon_state = "mcguffin"
	tastes = list("muffin" = 2, "bacon" = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/eggyolk = 3, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/chicken
	name = "chicken sandwich" //Apparently the proud people of Americlapstan object to this thing being called a burger. Apparently McDonald's just calls it a burger in Europe as to not scare and confuse us.
	desc = "A delicious chicken sandwich, it is said the proceeds from this treat helps criminalize disarming people on the space frontier."
	icon_state = "chickenburger"
	tastes = list("bun" = 2, "chicken" = 4, "God's covenant" = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/mayonnaise = 3, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/cheese
	name = "cheese burger"
	desc = "This noble burger stands proudly clad in golden cheese."
	icon_state = "cheeseburger"
	tastes = list("bun" = 2, "beef patty" = 4, "cheese" = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 2)

/obj/item/reagent_containers/food/snacks/sandwiches/cheese/Initialize(mapload)
	. = ..()
	if(prob(33))
		icon_state = "cheeseburgeralt"

/obj/item/reagent_containers/food/snacks/sandwiches/crazy
	name = "crazy hamburger"
	desc = "This looks like the sort of food that a demented clown in a trenchcoat would make."
	icon_state = "crazyburger"
	tastes = list("bun" = 2, "beef patty" = 4, "cheese" = 2, "beef soaked in chili" = 3, "a smoking flare" = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/capsaicin = 3, /datum/reagent/consumable/condensedcapsaicin = 3, /datum/reagent/consumable/nutriment/vitamin = 6)

// empty burger you can customize
/obj/item/reagent_containers/food/snacks/sandwiches/empty
	name = "burger"
	icon_state = "custburg"
	tastes = list("bun")
	desc = "A crazy, custom burger made by a mad cook."

/obj/item/reagent_containers/food/snacks/sandwiches/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon = 'icons/obj/items/food.dmi'
	icon_state = "hburger"
	filling_color = "#D63C3C"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("bun" = 4, "meat" = 2)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/sandwiches/packaged_burger/attack_self(mob/user as mob)
	if (package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, span_notice("You pull off the wrapping from the squishy hamburger!"))
		package = FALSE
		icon_state = "hburger"

/obj/item/reagent_containers/food/snacks/sandwiches/packaged_burger
	name = "Packaged Cheeseburger"
	desc = "A soggy microwavable burger. There's no time given for how long to cook it. Packaged by the Nanotrasen Corporation."
	icon = 'icons/obj/items/food.dmi'
	icon_state = "burger"
	bitesize = 3
	package = TRUE
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/sodiumchloride = 2)
	tastes = list("bun" = 4, "soy protein" = 2) //Cheap fridge burgers.

// Human Burger + cheese wedge = cheeseburger
/obj/item/reagent_containers/food/snacks/sandwiches/human/burger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "You make a cheeseburger.")
		qdel(I)
		qdel(src)


// Burger + cheese wedge = cheeseburger
/obj/item/reagent_containers/food/snacks/sandwiches/monkeyburger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "You make a cheeseburger.")
		qdel(I)
		qdel(src)

/obj/item/reagent_containers/food/snacks/sandwiches/human/burger
	name = "burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("bun" = 4, "tender meat" = 2)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/sandwiches/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/items/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("bun" = 1) // the bun tastes of bun.

/obj/item/reagent_containers/food/snacks/sandwiches/bun/attackby(obj/item/I, mob/user, params)
	. = ..()
	// Bun + meatball = burger
	if(istype(I, /obj/item/reagent_containers/food/snacks/sandwiches/meatball))
		new /obj/item/reagent_containers/food/snacks/sandwiches/monkeyburger(src)
		to_chat(user, "You make a burger.")
		qdel(I)
		qdel(src)

	// Bun + cutlet = hamburger
	else if(istype(I, /obj/item/reagent_containers/food/snacks/sandwiches/cutlet))
		new /obj/item/reagent_containers/food/snacks/sandwiches/monkeyburger(src)
		to_chat(user, "You make a burger.")
		qdel(I)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(I, /obj/item/reagent_containers/food/snacks/sausage))
		new /obj/item/reagent_containers/food/snacks/hotdog(src)
		to_chat(user, "You make a hotdog.")
		qdel(I)
		qdel(src)

/obj/item/reagent_containers/food/snacks/sandwiches/bread
	name = "Bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/reagent_containers/food/snacks/sandwiches/breadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	filling_color = "#FFE396"
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/breadslice
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#D27332"
	bitesize = 2
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/creamcheesebreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#FFF896"
	tastes = list("bread" = 10, "cheese" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/creamcheesebreadslice
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFF896"
	bitesize = 2
	tastes = list("bread" = 10, "cheese" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/marinebread //meme bread for breadify smite
	name = "Bread"
	desc = "Some plain old Earthen bread. An air of penance surrounds it."
	icon = 'icons/obj/items/food.dmi'
	icon_state = "breadtg"
	list_reagents = list(/datum/reagent/consumable/nutriment = 60)
	filling_color = "#FFF896"
	bitesize = 2
	tastes = list("guilt" = 1, "salt" = 1)

/obj/item/reagent_containers/food/snacks/sandwiches/Destroy() //delete the marine trapped inside, tasty!
	for(var/i in contents)
		qdel(i)
	return ..()

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/xenomeatbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	filling_color = "#8AFF75"
	tastes = list("bread" = 10, "acid" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#8AFF75"
	bitesize = 2
	tastes = list("bread" = 10, "acid" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/bananabread
	name = "Banana-nut bread"
	desc = "A heavenly and filling treat."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/bananabreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/drink/banana = 20)
	filling_color = "#EDE5AD"
	tastes = list("bread" = 10) // bananjuice will also flavour

/obj/item/reagent_containers/food/snacks/sandwiches/bananabreadslice
	name = "Banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#EDE5AD"
	bitesize = 2
	tastes = list("bread" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/meatbreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	filling_color = "#FF7575"
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#FF7575"
	bitesize = 2
	tastes = list("bread" = 10, "meat" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/tofubread
	name = "Tofubread"
	desc = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/tofubreadslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 30)
	filling_color = "#F7FFE0"
	tastes = list("bread" = 10, "tofu" = 10)

/obj/item/reagent_containers/food/snacks/sandwiches/tofubreadslice
	name = "Tofubread slice"
	desc = "A slice of delicious tofubread."
	icon = 'icons/obj/items/burgerbread.dmi'
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#F7FFE0"
	bitesize = 2
	tastes = list("bread" = 10, "tofu" = 10)
