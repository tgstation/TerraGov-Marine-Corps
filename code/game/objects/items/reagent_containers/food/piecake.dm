//Food items that are eaten normally and don't leave anything behind.
/obj/item/reagent_containers/food/snacks/pastries
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/items/food/piecake.dmi'
	icon_state = null

/obj/item/reagent_containers/food/snacks/sliceable/pastries
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/items/food/piecake.dmi'
	icon_state = null

/obj/item/reagent_containers/food/snacks/pastries/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#FBFFB8"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/banana = 5)
	tastes = list("pie" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/pastries/pie/throw_impact(atom/hit_atom)
	. = ..()
	if(!.)
		return
	new /obj/effect/decal/cleanable/pie_smudge(loc)
	visible_message(span_warning(" [src.name] splats."),span_warning(" You hear a splat."))
	qdel(src)

/obj/item/reagent_containers/food/snacks/pastries/berryclafoutis
	name = "Berry Clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/berryjuice = 5)
	tastes = list("pie" = 1, "blackberries" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/pastries/bearypie
	name = "beary pie"
	desc = "No brown bears, this is a good sign."
	icon_state = "bearypie"
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "meat" = 1, "salmon" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/carrotcake
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/carrotcakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/drink/carrotjuice = 10)
	filling_color = "#FFD675"
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/pastries/carrotcakeslice
	name = "Carrot Cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD675"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 2, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/braincake
	name = "Brain Cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/braincakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/medicine/alkysine = 10)
	filling_color = "#E6AEDB"
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)

/obj/item/reagent_containers/food/snacks/pastries/braincakeslice
	name = "Brain Cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#E6AEDB"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 2, "brains" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/cheesecake
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cheesecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 25)
	filling_color = "#FAF7AF"
	tastes = list("cake" = 4, "cream cheese" = 3)

/obj/item/reagent_containers/food/snacks/pastries/cheesecakeslice
	name = "Cheese Cake slice"
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAF7AF"
	bitesize = 2
	tastes = list("cake" = 4, "cream cheese" = 3)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/plaincake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/plaincakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#F7EDD5"
	tastes = list("vanilla" = 1, "sweetness" = 2,"cake" = 5)

/obj/item/reagent_containers/food/snacks/pastries/plaincakeslice
	name = "Vanilla Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#F7EDD5"
	bitesize = 2
	tastes = list("vanilla" = 1, "sweetness" = 2,"cake" = 5)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/orangecake
	name = "Orange Cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/orangecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#FADA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)

/obj/item/reagent_containers/food/snacks/pastries/orangecakeslice
	name = "Orange Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FADA8E"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 2, "oranges" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/limecake
	name = "Lime Cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/limecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#CBFA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)

/obj/item/reagent_containers/food/snacks/pastries/limecakeslice
	name = "Lime Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#CBFA8E"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 2, "unbearable sourness" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/lemoncake
	name = "Lemon Cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/lemoncakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#FAFA8E"
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)

/obj/item/reagent_containers/food/snacks/pastries/lemoncakeslice
	name = "Lemon Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#FAFA8E"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 2, "sourness" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/chocolatecake
	name = "Chocolate Cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/chocolatecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20)
	filling_color = "#805930"
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)

/obj/item/reagent_containers/food/snacks/pastries/chocolatecakeslice
	name = "Chocolate Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 1, "chocolate" = 4)


/obj/item/reagent_containers/food/snacks/sliceable/pastries/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/birthdaycakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/sprinkles = 10)
	filling_color = "#FFD6D6"
	tastes = list("cake" = 5, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/pastries/birthdaycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/birthdaycake/energy
	name = "energy cake"
	desc = "Just enough calories for a whole nuclear operative squad."
	icon_state = "energycake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/energycakeslice
	hitsound = 'sound/weapons/blade1.ogg'
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/sprinkles = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 3, "a Vlad's Salad" = 1)

/obj/item/reagent_containers/food/snacks/pastries/energycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday"
	icon_state = "energycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#FFD6D6"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/applecakes
	name = "apple cake"
	desc = "A cake centred with Apple."
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/applecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/pastries/applecakeslice
	name = "apple cake slice"
	desc = "A slice of an Apple cake."
	icon_state = "applecakeslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/pastries/sliceableslimecake
	name = "Slime cake"
	desc = "A cake made of slimes. Probably not electrified."
	icon_state = "slimecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/slimecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)

/obj/item/reagent_containers/food/snacks/pastries/slimecakeslice
	name = "Slime cake"
	desc = "A cake slice made of slimes. Only slightly better for your health."
	icon_state = "slimecake_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "slime" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/pumpkinspicecake
	name = "pumpkin spice cake"
	desc = "A hollow cake with real pumpkin."
	icon_state = "pumpkinspicecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/pumpkinspicecakesslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/pastries/pumpkinspicecakesslice
	name = "pumpkin spice cake slice"
	desc = "A spicy slice of pumpkin goodness."
	icon_state = "pumpkinspicecakeslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/bsvc
	name = "blackberry and strawberry vanilla cake"
	desc = "A plain cake, filled with assortment of blackberries and strawberries!"
	icon_state = "blackbarry_strawberries_cake_vanilla_cake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/pumpkinspicecakesslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("blackberry" = 2, "strawberries" = 2, "vanilla" = 2, "sweetness" = 2, "cake" = 3)

/obj/item/reagent_containers/food/snacks/pastries/bsvcslice
	name = "strawberry chocolate cake slice"
	desc = "Just a slice of cake with five strawberries on top. For some reason, this configuration of cake is particularly aesthetically pleasing to AIs in SELF." //yes, I know the one referenced has cherries, but I'm not implementing a new cake today.
	icon_state = "liars_slice"
	tastes = list("strawberries" = 2, "chocolate" = 2, "sweetness" = 2, "cake" = 3)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/holy_cake
	name = "angel food cake"
	desc = "A cake made for angels and chaplains alike! Contains holy water."
	icon_state = "holy_cake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/holy_cakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 3, /datum/reagent/water/holywater = 10)
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)

/obj/item/reagent_containers/food/snacks/pastries/holy_cakeslice
	name = "angel food cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "holy_cake_slice"
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)

/obj/item/reagent_containers/food/snacks/pastries/holy_cakeslice
	name = "angel food cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "holy_cake_slice"
	tastes = list("cake" = 5, "sweetness" = 1, "clouds" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/poundcake
	name = "pound cake"
	desc = "A condensed cake made for filling people up quickly."
	icon_state = "pound_cake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/poundcakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 60, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 5, "sweetness" = 1, "batter" = 1)

/obj/item/reagent_containers/food/snacks/pastries/poundcakeslice
	name = "pound cake slice"
	desc = "A slice of condensed cake made for filling people up quickly."
	icon_state = "pound_cake_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/nutriment/vitamin = 0.5)
	tastes = list("cake" = 5, "sweetness" = 5, "batter" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/hardware_cake
	name = "hardware cake"
	desc = "A quote on quote cake that is made with electronic boards and leaks acid..."
	icon_state = "hardware_cake"
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/toxin/acid = 15)
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/hardware_cakelice
	tastes = list("acid" = 3, "metal" = 4, "glass" = 5)

/obj/item/reagent_containers/food/snacks/pastries/hardware_cakelice
	name = "hardware cake slice"
	desc = "A slice of electronic boards and some acid."
	icon_state = "hardware_cake_slice"
	tastes = list("acid" = 3, "metal" = 4, "glass" = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/toxin/acid = 3)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/vanilla_cake
	name = "vanilla cake"
	desc = "A vanilla frosted cake."
	icon_state = "vanillacake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/hardware_cakelice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/sugar = 15, /datum/reagent/consumable/vanilla = 15)
	tastes = list("cake" = 1, "sugar" = 1, "vanilla" = 10)

/obj/item/reagent_containers/food/snacks/pastries/cakeslicevanilla_slice
	name = "vanilla cake slice"
	desc = "A slice of vanilla frosted cake."
	icon_state = "vanillacake_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/vanilla = 3)
	tastes = list("cake" = 1, "sugar" = 1, "vanilla" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/clown_cake
	name = "clown cake"
	desc = "A funny cake with a clown face on it."
	icon_state = "clowncake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cakesliceclown_slice
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/sugar = 15)
	tastes = list("cake" = 1, "sugar" = 1, "joy" = 10)

/obj/item/reagent_containers/food/snacks/pastries/cakesliceclown_slice
	name = "clown cake slice"
	desc = "A slice of bad jokes, and silly props."
	icon_state = "clowncake_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/sugar = 3)
	tastes = list("cake" = 1, "sugar" = 1, "joy" = 10)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/trumpet
	name = "spaceman's cake"
	desc = "A spaceman's trumpet frosted cake."
	icon_state = "trumpetcake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cakeslicetrumpet
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/drink/berryjuice = 5)
	tastes = list("cake" = 4, "violets" = 2, "jam" = 2)

/obj/item/reagent_containers/food/snacks/pastries/cakeslicetrumpet
	name = "spaceman's cake"
	desc = "A spaceman's trumpet frosted cake."
	icon_state = "trumpetcakeslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/drink/milk = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/drink/berryjuice = 1)
	tastes = list("cake" = 4, "violets" = 2, "jam" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/brioche
	name = "brioche cake"
	desc = "A ring of sweet, glazed buns."
	icon_state = "briochecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cakeslicebrioche
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("cake" = 4, "butter" = 2, "cream" = 1)

/obj/item/reagent_containers/food/snacks/pastries/cakeslicebrioche
	name = "brioche cake slice"
	desc = "Delicious sweet-bread. Who needs anything else?"
	icon_state = "briochecake_slice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("cake" = 4, "butter" = 2, "cream" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/pavlova
	name = "pavlova"
	desc = "A sweet berry pavlova. Invented in New Zealand, but named after a Russian ballerina... And scientifically proven to be the best at dinner parties!"
	icon_state = "pavlova"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cakeslicepavlova
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("meringue" = 5, "creaminess" = 1, "berries" = 1)

/obj/item/reagent_containers/food/snacks/pastries/cakeslicepavlova
	name = "pavlova slice"
	desc = "A cracked slice of pavlova stacked with berries. You even got it sliced in such a way that more berries ended up on your slice, how delightfully devilish."
	icon_state = "pavlova_slice"
	tastes = list("meringue" = 5, "creaminess" = 1, "berries" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/fruitcake
	name = "english fruitcake"
	desc = "A proper good cake, innit?"
	icon_state = "fruitcake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cakeslicefruit
	list_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/sugar = 10, /datum/reagent/consumable/cherryjelly = 5, )
	tastes = list("dried fruit" = 5, "treacle" = 2, "christmas" = 2)

/obj/item/reagent_containers/food/snacks/pastries/fruitcake
	name = "english fruitcake"
	desc = "A proper good cake, innit?"
	icon_state = "fruitcake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/cakeslicefruit
	list_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/sugar = 10, /datum/reagent/consumable/cherryjelly = 5, )
	tastes = list("dried fruit" = 5, "treacle" = 2, "christmas" = 2)

/obj/item/reagent_containers/food/snacks/pastries/fruitcake/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon_state][rand(1,3)]"

/obj/item/reagent_containers/food/snacks/pastries/cakeslicefruit
	name = "english fruitcake slice"
	desc = "A proper good slice, innit?"
	icon_state = "fruitcake_slice1"
	base_icon_state = "fruitcake_slice"
	tastes = list("dried fruit" = 5, "treacle" = 2, "christmas" = 2)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/dulcedebatata
	name = "dulce de batata slice"
	desc = "A slice of sweet dulce de batata jelly."
	icon_state = "dulcedebatataslice"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/dulcedebatataslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("jelly" = 1, "sweet potato" = 1)

/obj/item/reagent_containers/food/snacks/pastries/dulcedebatataslice
	name = "dulce de batata"
	desc = "A delicious jelly made with sweet potatoes."
	icon_state = "dulcedebatata"
	list_reagents = list(/datum/reagent/consumable/nutriment = 14, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("jelly" = 1, "sweet potato" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/baklava
	name = "baklava"
	desc = "A delightful healthy snack made of nut layers with thin bread."
	icon_state = "baklava"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/baklavaslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("nuts" = 1, "pie" = 1)

/obj/item/reagent_containers/food/snacks/pastries/baklavaslice
	name = "baklava dish"
	desc = "A portion of a delightful healthy snack made of nut layers with thin bread"
	icon_state = "baklavaslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 14, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("nuts" = 1, "pie" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/frenchsilkpie
	name = "french silk pie"
	desc = "A decadent pie made of a creamy chocolate mousse filling topped with a layer of whipped cream and chocolate shavings. Sliceable."
	icon_state = "frenchsilkpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/frenchsilkpieslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 12, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "smooth chocolate" = 1, "whipped cream" = 1)

/obj/item/reagent_containers/food/snacks/pastries/frenchsilkpieslice
	name = "french silk pie slice"
	desc = "A slice of french silk pie, filled with a chocolate mousse and topped with a layer of whipped cream and chocolate shavings. Delicious enough to make you cry."
	icon_state = "frenchsilkpieslice"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("pie" = 1, "smooth chocolate" = 1, "whipped cream" = 1)

/obj/item/reagent_containers/food/snacks/pastries/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#E0EDC5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	bitesize = 3
	tastes = list("pie" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/pastries/frostypie
	name = "frosty pie"
	desc = "Tastes like blue and cold."
	icon_state = "frostypie"
	filling_color = "#0b8c91"
	list_reagents = list(/datum/reagent/consumable/nutriment = 14, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("mint" = 1, "pie" = 1)

/obj/item/reagent_containers/food/snacks/pastries/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#FF525A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/cherryjelly = 4)
	bitesize = 3
	tastes = list("pie" = 7, "Nicole Paige Brooks" = 2)

/obj/item/reagent_containers/food/snacks/pastries/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#FFFF00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/gold = 5)
	bitesize = 3
	tastes = list("pie" = 1, "apple" = 1, "expensive metal" = 1)

/obj/item/reagent_containers/food/snacks/pastries/grapetart
	name = "grape tart"
	desc = "A tasty dessert that reminds you of the wine you didn't make."
	icon_state = "grapetart"
	trash = /obj/item/trash/plate
	filling_color = "#4e0455"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	bitesize = 3
	tastes = list("pie" = 1, "grape" = 1)

/obj/item/reagent_containers/food/snacks/pastries/mimetart
	name = "mime tart"
	desc = "..."
	icon_state = "mimetart"
	filling_color = "#e8e1e9"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/drink/nothing = 10)
	tastes = list("nothing" = 3)

/obj/item/reagent_containers/food/snacks/pastries/berrytart
	name = "berry tart"
	desc = "A tasty dessert of many different small barries on a thin pie crust."
	icon_state = "berrytart"
	filling_color = "#a46cac"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("pie" = 1, "berries" = 2)

/obj/item/reagent_containers/food/snacks/pastries/cocolavatart
	name = "chocolate lava tart"
	desc = "A tasty dessert made of chocolate, with a liquid core." //But it doesn't even contain chocolate...
	icon_state = "cocolavatart"
	filling_color = "#522700"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("pie" = 1, "dark chocolate" = 3)


/obj/item/reagent_containers/food/snacks/pastries/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("pie" = 1, "meat" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/pastries/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#FFFEE0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("pie" = 1, "tofu" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/pastries/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#FFCCCC"
	tastes = list("pie" = 1, "mushroom" = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/toxin/amatoxin = 3, /datum/reagent/consumable/psilocybin = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/pastries/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("pie" = 1, "mushroom" = 1)
	bitesize = 2


/obj/item/reagent_containers/food/snacks/pastries/plump_pie/Initialize(mapload)
	. = ..()
	var/fey = prob(10)
	if(fey)
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent(/datum/reagent/medicine/tricordrazine, 5)

/obj/item/reagent_containers/food/snacks/pastries/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43DE18"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("pie" = 1, "meat" = 1, "acid" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/sliceable/pastries/applecake
	name = "Apple Cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/applecakeslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	filling_color = "#EBF5B8"
	tastes = list ("cake" = 5, "sweetness" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/pastries/applecakeslice
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#EBF5B8"
	bitesize = 2
	tastes = list("cake" = 5, "sweetness" = 1, "apple" = 1)

/obj/item/reagent_containers/food/snacks/sliceable/pastries/pumpkinpie
	name = "Pumpkin Pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/reagent_containers/food/snacks/pastries/pumpkinpieslice
	list_reagents = list(/datum/reagent/consumable/nutriment = 15)
	filling_color = "#F5B951"
	tastes = list("pie" = 1, "pumpkin" = 1)

/obj/item/reagent_containers/food/snacks/pastries/pumpkinpieslice
	name = "Pumpkin Pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#F5B951"
	bitesize = 2
	tastes = list("pie" = 1, "pumpkin" = 1)
