/obj/effect/spawner/random/food_or_drink
	name = "Random base food or drink spawner"
	icon = 'icons/effects/random/food_or_drink.dmi'
	icon_state = "random_burger"
	loot = list(
		/obj/structure/prop/mainship/errorprop,
	)

/obj/effect/spawner/random/food_or_drink/donut
	name = "Random donut spawner"
	icon_state = "random_donut"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/reagent_containers/food/snacks/donut/normal = 70, //we could use loot_subtype_path to include all donuts automatically but then we couldn't adjust probabilities
		/obj/item/reagent_containers/food/snacks/donut/jelly = 15,
		/obj/item/reagent_containers/food/snacks/donut/cherryjelly = 10,
		/obj/item/reagent_containers/food/snacks/donut/berry = 10,
		/obj/item/reagent_containers/food/snacks/donut/trumpet = 10,
		/obj/item/reagent_containers/food/snacks/donut/apple = 10,
		/obj/item/reagent_containers/food/snacks/donut/caramel = 10,
		/obj/item/reagent_containers/food/snacks/donut/choco = 15,
		/obj/item/reagent_containers/food/snacks/donut/blumpkin = 10,
		/obj/item/reagent_containers/food/snacks/donut/bungo = 10,
		/obj/item/reagent_containers/food/snacks/donut/matcha = 10,
		/obj/item/reagent_containers/food/snacks/donut/laugh = 10,
		/obj/item/reagent_containers/food/snacks/donut/jelly/trumpet = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/apple = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/caramel = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/choco = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/blumpkin = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/bungo = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/matcha = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/laugh = 5,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/plain = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/berry = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/trumpet = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/apple = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/caramel = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/choco = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/blumpkin = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/bungo = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/matcha = 1,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/laugh = 1,
		/obj/item/reagent_containers/food/snacks/donut/chaos = 1,
		/obj/item/reagent_containers/food/snacks/donut/meat = 1,
	)

/obj/effect/spawner/random/food_or_drink/burger
	name = "Random burger spawner"
	icon_state = "random_burger"
	spawn_loot_chance = 95
	loot = list(
		/obj/effect/spawner/random/food_or_drink/burger/normal = 95,
		/obj/effect/spawner/random/food_or_drink/burger/weird = 5,
	)

/obj/effect/spawner/random/food_or_drink/burger/bunweighted
	name = "Random burger bun spawner"
	icon_state = "random_burger_bun"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/reagent_containers/food/snacks/burger/bun = 95,
		/obj/effect/spawner/random/food_or_drink/burger = 5,
	)

/obj/effect/spawner/random/food_or_drink/burger/normal
	name = "Random normal burger spawner"
	icon_state = "random_burger_normal"
	loot = list(
		/obj/item/reagent_containers/food/snacks/burger/plain = 40,
		/obj/item/reagent_containers/food/snacks/burger/cheese = 20,
		/obj/item/reagent_containers/food/snacks/burger/baconburger = 10,
		/obj/item/reagent_containers/food/snacks/burger/chicken = 10,
		/obj/item/reagent_containers/food/snacks/burger/fishburger = 10,
		/obj/item/reagent_containers/food/snacks/burger/superbite = 5,
		/obj/item/reagent_containers/food/snacks/burger/fivealarm = 5,
	)

/obj/effect/spawner/random/food_or_drink/burger/weird
	name = "Random weird burger spawner"
	icon_state = "random_burger_weird"
	loot = list(
		/obj/item/reagent_containers/food/snacks/burger/tofu,
		/obj/item/reagent_containers/food/snacks/burger/roburger,
		/obj/item/reagent_containers/food/snacks/burger/roburgerbig,
		/obj/item/reagent_containers/food/snacks/burger/appendix,
		/obj/item/reagent_containers/food/snacks/burger/xeno,
		/obj/item/reagent_containers/food/snacks/burger/human,
		/obj/item/reagent_containers/food/snacks/burger/bearger,
		/obj/item/reagent_containers/food/snacks/burger/clown,
		/obj/item/reagent_containers/food/snacks/burger/mime,
		/obj/item/reagent_containers/food/snacks/burger/brain,
		/obj/item/reagent_containers/food/snacks/burger/spell,
		/obj/item/reagent_containers/food/snacks/burger/jelly,
		/obj/item/reagent_containers/food/snacks/burger/jelly/cherry,
		/obj/item/reagent_containers/food/snacks/burger/jelly/slime,
		/obj/item/reagent_containers/food/snacks/burger/rat,
		/obj/item/reagent_containers/food/snacks/burger/baseball,
		/obj/item/reagent_containers/food/snacks/burger/empoweredburger,
		/obj/item/reagent_containers/food/snacks/burger/catburger,
		/obj/item/reagent_containers/food/snacks/burger/crab,
		/obj/item/reagent_containers/food/snacks/burger/soylent,
		/obj/item/reagent_containers/food/snacks/burger/crazy,
		/obj/item/reagent_containers/food/snacks/burger/ghostburger,
		/obj/item/reagent_containers/food/snacks/burger/bun,
	)

/obj/effect/spawner/random/food_or_drink/packagedbar
	name = "Random food bar spawner"
	icon_state = "random_foodbar"
	loot = list(
		/obj/item/reagent_containers/food/snacks/wrapped/booniebars = 26,
		/obj/item/reagent_containers/food/snacks/wrapped/chunk = 26,
		/obj/item/reagent_containers/food/snacks/wrapped/barcardine = 26,
		/obj/item/reagent_containers/food/snacks/wrapped/proteinbar = 12,
		/obj/item/reagent_containers/food/snacks/candy = 5,
		/obj/item/reagent_containers/food/snacks/enrg_bar = 5,
	)

/obj/effect/spawner/random/food_or_drink/packagedbar/candyweighted
	name = "Random candy bar spawner"
	icon_state = "random_foodbar_candy"
	loot = list(
		/obj/item/reagent_containers/food/snacks/candy = 75,
		/obj/item/reagent_containers/food/snacks/wrapped/proteinbar = 10,
		/obj/item/reagent_containers/food/snacks/wrapped/booniebars = 5,
		/obj/item/reagent_containers/food/snacks/wrapped/chunk = 5,
		/obj/item/reagent_containers/food/snacks/wrapped/barcardine = 5,
	)

/obj/effect/spawner/random/food_or_drink/cheesewedge
	name = "Random cheese wedge spawner"
	icon_state = "random_cheesewedge"
	loot = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge = 80,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel = 10,
		/obj/item/reagent_containers/food/snacks/baked_cheese = 5,
		/obj/item/reagent_containers/food/snacks/baked_cheese_platter = 5,
	)

/obj/effect/spawner/random/food_or_drink/kitchenknife
	name = "Random kitchen knife spawner"
	icon_state = "random_knife"
	loot = list(
		/obj/item/tool/kitchen/knife = 9,
		/obj/item/tool/kitchen/knife/butcher = 1,
	)

/obj/effect/spawner/random/food_or_drink/kitchenknife/butcherweighted
	name = "Random kitchen knife spawner"
	icon_state = "random_knife_butcher"
	loot = list(
		/obj/item/tool/kitchen/knife/butcher = 9,
		/obj/item/tool/kitchen/knife = 1,
	)

/obj/effect/spawner/random/food_or_drink/kitchen
	name = "Random kitchen utensil spawner"
	icon_state = "random_utensil"
	loot = list(
		/obj/item/tool/kitchen/utensil/fork = 20,
		/obj/item/tool/kitchen/utensil/pfork = 20,
		/obj/item/tool/kitchen/utensil/spoon = 20,
		/obj/item/tool/kitchen/utensil/pspoon = 20,
		/obj/item/tool/kitchen/utensil/knife = 20,
		/obj/item/tool/kitchen/utensil/pknife = 20,
		/obj/item/tool/kitchen/rollingpin = 10,
		/obj/item/tool/kitchen/tray = 5,
	)

/obj/effect/spawner/random/food_or_drink/drink_cans
	name = "Random Drink Cans"
	icon_state = "random_can"
	loot = list(
		/obj/item/reagent_containers/food/drinks/cans/cola,
		/obj/item/reagent_containers/food/drinks/cans/waterbottle,
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/reagent_containers/food/drinks/cans/ale,
		/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind,
		/obj/item/reagent_containers/food/drinks/cans/thirteenloko,
		/obj/item/reagent_containers/food/drinks/cans/dr_gibb,
		/obj/item/reagent_containers/food/drinks/cans/starkist,
		/obj/item/reagent_containers/food/drinks/cans/lemon_lime,
		/obj/item/reagent_containers/food/drinks/cans/iced_tea,
		/obj/item/reagent_containers/food/drinks/cans/grape_juice,
		/obj/item/reagent_containers/food/drinks/cans/tonic,
		/obj/item/reagent_containers/food/drinks/cans/sodawater,
		/obj/item/reagent_containers/food/drinks/cans/souto,
		/obj/item/reagent_containers/food/drinks/cans/souto/diet,
		/obj/item/reagent_containers/food/drinks/cans/souto/cherry,
		/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet,
		/obj/item/reagent_containers/food/drinks/cans/aspen,
		/obj/item/reagent_containers/food/drinks/cans/souto/lime,
		/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet,
		/obj/item/reagent_containers/food/drinks/cans/souto/grape,
		/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet,
		/obj/item/reagent_containers/food/drinks/cans/space_up,
	)


///Booze in a bottle. Glass. Classy.
/obj/effect/spawner/random/food_or_drink/drink_alcohol_bottle
	name = "Random Alcoholic Drink Bottle"
	icon_state = "random_bottle"
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/gin,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey,
		/obj/item/reagent_containers/food/drinks/bottle/sake,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/tequila,
		/obj/item/reagent_containers/food/drinks/bottle/davenport,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
		/obj/item/reagent_containers/food/drinks/bottle/patron,
		/obj/item/reagent_containers/food/drinks/bottle/rum,
		/obj/item/reagent_containers/food/drinks/bottle/holywater,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth,
		/obj/item/reagent_containers/food/drinks/bottle/kahlua,
		/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
		/obj/item/reagent_containers/food/drinks/bottle/cognac,
		/obj/item/reagent_containers/food/drinks/bottle/wine,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe,
		/obj/item/reagent_containers/food/drinks/bottle/melonliquor,
		/obj/item/reagent_containers/food/drinks/bottle/bluecuracao,
		/obj/item/reagent_containers/food/drinks/bottle/grenadine,
		/obj/item/reagent_containers/food/drinks/bottle/pwine,
	)

///Stuff that's more like candies and all. Stale the hunger or buy in a vending machine.
/obj/effect/spawner/random/food_or_drink/sugary_snack
	name = "Random Sugary Snacks"
	icon_state = "random_sugary"
	loot = list(
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/reagent_containers/food/snacks/donut/normal,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolateegg,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/chips,
		/obj/item/reagent_containers/food/snacks/candy_corn,
		/obj/item/reagent_containers/food/snacks/candy,
		/obj/item/reagent_containers/food/snacks/candy/donor,
		/obj/item/reagent_containers/food/snacks/muffin,
		/obj/item/reagent_containers/food/snacks/popcorn,
		/obj/item/reagent_containers/food/snacks/candiedapple,
		/obj/item/reagent_containers/food/snacks/poppypretzel,
		/obj/item/reagent_containers/food/snacks/fortunecookie,
		/obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich,
		/obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich/cherry,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,
		/obj/item/reagent_containers/food/snacks/enrg_bar,
		/obj/item/reagent_containers/food/snacks/kepler_crisps,
		/obj/item/reagent_containers/food/snacks/cracker,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/reagent_containers/food/snacks/no_raisin,
		/obj/item/reagent_containers/food/snacks/sosjerky,
		/obj/item/reagent_containers/food/snacks/donkpocket,
		/obj/item/reagent_containers/food/snacks/wrapped/booniebars,
		/obj/item/reagent_containers/food/snacks/wrapped/barcardine,
		/obj/item/reagent_containers/food/snacks/wrapped/chunk,
		/obj/item/reagent_containers/food/snacks/lollipop,
		/obj/item/reagent_containers/food/snacks/pastries/appletart,
	)


///Stuff you might expect to eat in the street.
/obj/effect/spawner/random/food_or_drink/outdoors_snacks
	name = "Random Outdoors snack"
	icon_state = "random_outdoors_snack"
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/reagent_containers/food/snacks/mexican/taco,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/packaged_burrito,
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/margherita,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/meatpizza,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/mushroompizza,
		/obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/vegetablepizza,
		/obj/item/reagent_containers/food/snacks/burger/packaged_burger,
		/obj/item/reagent_containers/food/snacks/packaged_hdogs,
		/obj/item/reagent_containers/food/snacks/upp/fish,
		/obj/item/reagent_containers/food/snacks/upp/rice,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread,
		/obj/item/reagent_containers/food/snacks/burger/bigbite,
		/obj/item/reagent_containers/food/snacks/mexican/enchiladas,
		/obj/item/reagent_containers/food/snacks/cheesyfries,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/loadedbakedpotato,
		/obj/item/reagent_containers/food/snacks/burger/tofu,
		/obj/item/reagent_containers/food/snacks/burger/fishburger,
		/obj/item/reagent_containers/food/snacks/burger/xeno,
		/obj/item/reagent_containers/food/snacks/fishfingers,
	)

/obj/effect/spawner/random/food_or_drink/beer
	name = "beer spawner"
	icon_state = "random_beer"
	loot = list(
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/reagent_containers/food/drinks/cans/ale,
		/obj/item/reagent_containers/food/drinks/cans/thirteenloko,
		/obj/item/reagent_containers/food/drinks/cans/aspen,
		/obj/item/reagent_containers/food/drinks/bottle/gin,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey,
		/obj/item/reagent_containers/food/drinks/bottle/tequila,
		/obj/item/reagent_containers/food/drinks/bottle/vodka,
		/obj/item/reagent_containers/food/drinks/bottle/vermouth,
		/obj/item/reagent_containers/food/drinks/bottle/rum,
		/obj/item/reagent_containers/food/drinks/bottle/wine,
		/obj/item/reagent_containers/food/drinks/bottle/cognac,
		/obj/item/reagent_containers/food/drinks/bottle/kahlua,
		/obj/item/reagent_containers/food/drinks/cans/tonic,
		/obj/item/reagent_containers/food/drinks/cans/sodawater,
		/obj/item/reagent_containers/food/drinks/flask/barflask,
		/obj/item/reagent_containers/food/drinks/flask/vacuumflask,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/reagent_containers/food/drinks/ice,
		/obj/item/reagent_containers/food/drinks/bottle/melonliquor,
		/obj/item/reagent_containers/food/drinks/bottle/bluecuracao,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe,
		/obj/item/reagent_containers/food/drinks/bottle/grenadine,
		/obj/item/reagent_containers/food/drinks/cans/aspen,
		/obj/item/reagent_containers/food/drinks/bottle/davenport,
		/obj/item/reagent_containers/food/drinks/tea,
	)

/obj/effect/spawner/random/food_or_drink/beer/oscaroutpost
	loot = list(
		/obj/item/reagent_containers/food/drinks/cans/beer = 95,
		/obj/effect/spawner/random/food_or_drink/beer = 5,
	)

/obj/effect/spawner/random/food_or_drink/beer/whiskeyoutpost
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 95,
		/obj/effect/spawner/random/food_or_drink/beer = 5,
	)

/obj/effect/spawner/random/food_or_drink/wine
	icon_state = "random_winebottle"
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/wine = 95,
		/obj/effect/spawner/random/food_or_drink/beer = 5,
	)

/obj/effect/spawner/random/food_or_drink/bread
	name = "Random bread spawner"
	icon_state = "random_bread"
	loot = list(
		/obj/item/reagent_containers/food/snacks/baguette = 45,
		/obj/item/reagent_containers/food/snacks/sandwiches/bread = 10,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 5,
		/obj/item/reagent_containers/food/snacks/sandwiches/meatbreadslice = 5,
		/obj/item/reagent_containers/food/snacks/sandwiches/toastedsandwich = 5,
		/obj/effect/spawner/random/food_or_drink/burger = 5,
	)
