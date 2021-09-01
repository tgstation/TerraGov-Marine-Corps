/obj/effect/spawner/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything


// creates a new object and deletes itself
/obj/effect/spawner/random/Initialize()
	. = ..()

	if(!prob(spawn_nothing_percentage))
		spawn_item()

	return INITIALIZE_HINT_QDEL


// this function should return a specific item to spawn
/obj/effect/spawner/random/proc/item_to_spawn()
	return 0


// creates the random item
/obj/effect/spawner/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return (new build_path(src.loc))


/obj/effect/spawner/random/tool
	name = "Random Tool"
	icon_state = "random_tool"
	item_to_spawn()
		return pick(/obj/item/tool/screwdriver,\
					/obj/item/tool/wirecutters,\
					/obj/item/tool/weldingtool,\
					/obj/item/tool/crowbar,\
					/obj/item/tool/wrench,\
					/obj/item/stack/cable_coil,\
					/obj/item/flashlight)


/obj/effect/spawner/random/technology_scanner
	name = "Random Scanner"
	desc = "This is a random technology scanner."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "atmos"
	item_to_spawn()
		return pick(prob(5);/obj/item/t_scanner,\
					prob(2);/obj/item/radio,\
					prob(5);/obj/item/analyzer)


/obj/effect/spawner/random/powercell
	name = "Random Powercell"
	icon_state = "random_cell"
	item_to_spawn()
		return pick(prob(10);/obj/item/cell/crap,\
					prob(40);/obj/item/cell,\
					prob(40);/obj/item/cell/high,\
					prob(9);/obj/item/cell/super,\
					prob(1);/obj/item/cell/hyper)


/obj/effect/spawner/random/bomb_supply
	name = "Bomb Supply"
	icon_state = "random_scanner"
	item_to_spawn()
		return pick(/obj/item/assembly/igniter,\
					/obj/item/assembly/prox_sensor,\
					/obj/item/assembly/signaler,\
					/obj/item/multitool)


/obj/effect/spawner/random/toolbox
	name = "Random Toolbox"
	icon_state = "random_toolbox"
	item_to_spawn()
		return pick(prob(3);/obj/item/storage/toolbox/mechanical,\
					prob(2);/obj/item/storage/toolbox/electrical,\
					prob(1);/obj/item/storage/toolbox/emergency)


/obj/effect/spawner/random/tech_supply
	name = "Random Tech Supply"
	icon_state = "random_cell"
	spawn_nothing_percentage = 50
	item_to_spawn()
		return pick(prob(3);/obj/effect/spawner/random/powercell,\
					prob(2);/obj/effect/spawner/random/technology_scanner,\
					prob(1);/obj/item/packageWrap,\
					prob(2);/obj/effect/spawner/random/bomb_supply,\
					prob(1);/obj/item/tool/extinguisher,\
					prob(1);/obj/item/clothing/gloves/fyellow,\
					prob(3);/obj/item/stack/cable_coil,\
					prob(2);/obj/effect/spawner/random/toolbox,\
					prob(2);/obj/item/storage/belt/utility,\
					prob(5);/obj/effect/spawner/random/tool)

///All kinds of 'cans'. This include water bottles.
/obj/effect/spawner/random/drink_cans
	name = "Random Drink Cans"
	icon_state = "random_can"
	item_to_spawn()
		return pick(/obj/item/reagent_containers/food/drinks/cans/cola,\
					/obj/item/reagent_containers/food/drinks/cans/waterbottle,\
					/obj/item/reagent_containers/food/drinks/cans/beer,\
					/obj/item/reagent_containers/food/drinks/cans/ale,\
					/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind,\
					/obj/item/reagent_containers/food/drinks/cans/thirteenloko,\
					/obj/item/reagent_containers/food/drinks/cans/dr_gibb,\
					/obj/item/reagent_containers/food/drinks/cans/starkist,\
					/obj/item/reagent_containers/food/drinks/cans/lemon_lime,\
					/obj/item/reagent_containers/food/drinks/cans/iced_tea,\
					/obj/item/reagent_containers/food/drinks/cans/grape_juice,\
					/obj/item/reagent_containers/food/drinks/cans/tonic,\
					/obj/item/reagent_containers/food/drinks/cans/sodawater,\
					/obj/item/reagent_containers/food/drinks/cans/souto,\
					/obj/item/reagent_containers/food/drinks/cans/souto/diet,\
					/obj/item/reagent_containers/food/drinks/cans/souto/cherry,\
					/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet,\
					/obj/item/reagent_containers/food/drinks/cans/aspen,\
					/obj/item/reagent_containers/food/drinks/cans/souto/lime,\
					/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet,\
					/obj/item/reagent_containers/food/drinks/cans/souto/grape,\
					/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet,\
					/obj/item/reagent_containers/food/drinks/cans/space_up)

///Booze in a bottle. Glass. Classy.
/obj/effect/spawner/random/drink_alcohol_bottle
	name = "Random Alcoholic Drink Bottle"
	icon_state = "random_bottle"
	item_to_spawn()
		return pick(/obj/item/reagent_containers/food/drinks/bottle/gin,\
					/obj/item/reagent_containers/food/drinks/bottle/whiskey,\
					/obj/item/reagent_containers/food/drinks/bottle/sake,\
					/obj/item/reagent_containers/food/drinks/bottle/vodka,\
					/obj/item/reagent_containers/food/drinks/bottle/tequila,\
					/obj/item/reagent_containers/food/drinks/bottle/davenport,\
					/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,\
					/obj/item/reagent_containers/food/drinks/bottle/patron,\
					/obj/item/reagent_containers/food/drinks/bottle/rum,\
					/obj/item/reagent_containers/food/drinks/bottle/holywater,\
					/obj/item/reagent_containers/food/drinks/bottle/vermouth,\
					/obj/item/reagent_containers/food/drinks/bottle/kahlua,\
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,\
					/obj/item/reagent_containers/food/drinks/bottle/cognac,\
					/obj/item/reagent_containers/food/drinks/bottle/wine,\
					/obj/item/reagent_containers/food/drinks/bottle/absinthe,\
					/obj/item/reagent_containers/food/drinks/bottle/melonliquor,\
					/obj/item/reagent_containers/food/drinks/bottle/bluecuracao,\
					/obj/item/reagent_containers/food/drinks/bottle/grenadine,\
					/obj/item/reagent_containers/food/drinks/bottle/pwine)

///Stuff that's more like candies and all. Stale the hunger or buy in a vending machine.
/obj/effect/spawner/random/sugary_snack
	name = "Random Sugary Snacks"
	icon_state = "random_sugary"
	item_to_spawn()
		return pick(/obj/item/reagent_containers/food/snacks/donut,\
					/obj/item/reagent_containers/food/snacks/donut/normal,\
					/obj/item/reagent_containers/food/snacks/chocolatebar,\
					/obj/item/reagent_containers/food/snacks/chocolateegg,\
					/obj/item/reagent_containers/food/snacks/cookie,\
					/obj/item/reagent_containers/food/snacks/chips,\
					/obj/item/reagent_containers/food/snacks/candy_corn,\
					/obj/item/reagent_containers/food/snacks/candy,\
					/obj/item/reagent_containers/food/snacks/candy/donor,\
					/obj/item/reagent_containers/food/snacks/muffin,\
					/obj/item/reagent_containers/food/snacks/popcorn,\
					/obj/item/reagent_containers/food/snacks/candiedapple,\
					/obj/item/reagent_containers/food/snacks/poppypretzel,\
					/obj/item/reagent_containers/food/snacks/fortunecookie,\
					/obj/item/reagent_containers/food/snacks/jellysandwich,\
					/obj/item/reagent_containers/food/snacks/jellysandwich/cherry,\
					/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,\
					/obj/item/reagent_containers/food/snacks/enrg_bar,\
					/obj/item/reagent_containers/food/snacks/kepler_crisps,\
					/obj/item/reagent_containers/food/snacks/cracker,\
					/obj/item/reagent_containers/food/snacks/cheesiehonkers,\
					/obj/item/reagent_containers/food/snacks/spacetwinkie,\
					/obj/item/reagent_containers/food/snacks/no_raisin,\
					/obj/item/reagent_containers/food/snacks/sosjerky,\
					/obj/item/reagent_containers/food/snacks/donkpocket,\
					/obj/item/reagent_containers/food/snacks/wrapped/booniebars,\
					/obj/item/reagent_containers/food/snacks/wrapped/barcardine,\
					/obj/item/reagent_containers/food/snacks/wrapped/chunk,\
					/obj/item/reagent_containers/food/snacks/lollipop,\
					/obj/item/reagent_containers/food/snacks/appletart)

///Stuff you might expect to eat in the street.
/obj/effect/spawner/random/outdoors_snacks
	name = "Random Outdoors snack"
	icon_state = "random_outdoors_snack"
	item_to_spawn()
		return pick(/obj/item/reagent_containers/food/snacks/taco,\
					/obj/item/reagent_containers/food/snacks/hotdog,\
					/obj/item/reagent_containers/food/snacks/packaged_burrito,\
					/obj/item/reagent_containers/food/snacks/fries,\
					/obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita,\
					/obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza,\
					/obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza,\
					/obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza,\
					/obj/item/reagent_containers/food/snacks/packaged_burger,\
					/obj/item/reagent_containers/food/snacks/packaged_hdogs,\
					/obj/item/reagent_containers/food/snacks/upp/fish,\
					/obj/item/reagent_containers/food/snacks/upp/rice,\
					/obj/item/reagent_containers/food/snacks/sliceable/meatbread,\
					/obj/item/reagent_containers/food/snacks/bigbiteburger,\
					/obj/item/reagent_containers/food/snacks/enchiladas,\
					/obj/item/reagent_containers/food/snacks/cheesyfries,\
					/obj/item/reagent_containers/food/snacks/fishandchips,\
					/obj/item/reagent_containers/food/snacks/loadedbakedpotato,\
					/obj/item/reagent_containers/food/snacks/tofuburger,\
					/obj/item/reagent_containers/food/snacks/fishburger,\
					/obj/item/reagent_containers/food/snacks/xenoburger,\
					/obj/item/reagent_containers/food/snacks/fishfingers)

///All the trash.
/obj/effect/spawner/random/trash
	name = "Random trash"
	icon_state = "random_trash"
	item_to_spawn()
		return pick(/obj/item/trash/raisins,\
					/obj/item/trash/candy,\
					/obj/item/trash/cheesie,\
					/obj/item/trash/chips,\
					/obj/item/trash/popcorn,\
					/obj/item/trash/sosjerky,\
					/obj/item/trash/syndi_cakes,\
					/obj/item/trash/waffles,\
					/obj/item/trash/plate,\
					/obj/item/trash/snack_bowl,\
					/obj/item/trash/pistachios,\
					/obj/item/trash/semki,\
					/obj/item/trash/tray,\
					/obj/item/trash/candle,\
					/obj/item/trash/liquidfood,\
					/obj/item/trash/burger,\
					/obj/item/trash/buritto,\
					/obj/item/trash/hotdog,\
					/obj/item/trash/kepler,\
					/obj/item/trash/eat,\
					/obj/item/trash/fortunecookie,\
					/obj/item/trash/c_tube,\
					/obj/item/trash/cigbutt,\
					/obj/item/trash/cigbutt/cigarbutt,\
					/obj/item/trash/tgmc_tray,\
					/obj/item/trash/boonie,\
					/obj/item/trash/chunk,\
					/obj/item/trash/barcardine,\
					/obj/item/trash/mre)

