/**
 * Base class for all random spawners.
 */
/obj/effect/spawner/random
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "loot"
	layer = OBJ_LAYER
	/// Stops persistent lootdrop spawns from being shoved into lockers
	anchored = TRUE
	/// A list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/list/loot
	/// The subtypes AND type to combine with the loot list
	var/list/loot_type_path
	/// The subtypes (this excludes the provided path) to combine with the loot list
	var/list/loot_subtype_path
	/// How many items will be spawned
	var/spawn_loot_count = 1
	/// If the same item can be spawned twice
	var/spawn_loot_double = TRUE
	/// Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
	var/spawn_loot_split = FALSE
	/// Whether the spawner should spawn all the loot in the list
	var/spawn_all_loot = FALSE
	/// The chance for the spawner to create loot (ignores spawn_loot_count)
	var/spawn_loot_chance = 100
	/// Determines how big of a range (in tiles) we should scatter things in.
	var/spawn_scatter_radius = 0
	/// Whether the items should have a random pixel_x/y offset (maxium offset distance is ±16 pixels for x/y)
	var/spawn_random_offset = FALSE
	///does the spawned structure need to retain its direction on spawn?
	var/spawn_with_original_direction = FALSE

/obj/effect/spawner/random/Initialize(mapload)
	. = ..()
	spawn_loot()
	qdel(src)

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/random/proc/spawn_loot(lootcount_override)
	if(!prob(spawn_loot_chance))
		return

	var/list/spawn_locations = get_spawn_locations(spawn_scatter_radius)
	var/spawn_loot_count = lootcount_override ? lootcount_override : src.spawn_loot_count

	if(!spawn_locations.len)
		return

	if(spawn_all_loot)
		spawn_loot_count = INFINITY
		spawn_loot_double = FALSE

	if(loot_type_path)
		loot += typesof(loot_type_path)

	if(loot_subtype_path)
		loot += subtypesof(loot_subtype_path)

	if(!loot.len)
		return

	var/loot_spawned = 0
	while((spawn_loot_count > loot_spawned) && loot.len)
		var/lootspawn = pick_weight_recursive(loot)
		if(!spawn_loot_double)
			loot.Remove(lootspawn)
		if(!lootspawn)
			return
		var/turf/spawn_loc = loc
		if(spawn_scatter_radius > 0)
			spawn_loc = pick_n_take(spawn_locations)

		var/atom/movable/spawned_loot = new lootspawn(spawn_loc)
		if(!spawn_with_original_direction)
			spawned_loot.setDir(dir)

		if(spawn_loot_split && loot_spawned)
			spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
		else if(spawn_random_offset)
			spawned_loot.pixel_x = rand(-16, 16)
			spawned_loot.pixel_y = rand(-16, 16)
		else
			spawned_loot.pixel_x = pixel_x
			spawned_loot.pixel_y = pixel_y

		loot_spawned++

///If the spawner has a spawn_scatter_radius set, this creates a list of nearby turfs available
/obj/effect/spawner/random/proc/get_spawn_locations(radius)
	var/list/scatter_locations = list()

	for(var/turf/turf_in_view in range(radius, get_turf(src)))
		if(!turf_in_view.density)
			scatter_locations += turf_in_view

	return scatter_locations

/obj/effect/spawner/random/tool
	name = "Random Tool"
	icon_state = "random_tool"
	loot = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wrench,
		/obj/item/flashlight,
	)

/obj/effect/spawner/random/technology_scanner
	name = "Random Scanner"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "atmos"
	loot = list(
		/obj/item/t_scanner = 4,
		/obj/item/radio = 2,
		/obj/item/analyzer = 4,
	)

/obj/effect/spawner/random/powercell
	name = "Random Powercell"
	icon_state = "random_cell"
	loot = list(
		/obj/item/cell/crap = 10,
		/obj/item/cell = 40,
		/obj/item/cell/high = 40,
		/obj/item/cell/super = 9,
		/obj/item/cell/hyper = 1,
	)

/obj/effect/spawner/random/bomb_supply
	name = "Bomb Supply"
	icon_state = "random_scanner"
	loot = list(
		/obj/item/assembly/igniter,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/signaler,
		/obj/item/multitool,
	)

/obj/effect/spawner/random/toolbox
	name = "Random Toolbox"
	icon_state = "random_toolbox"
	loot = list(
		/obj/item/storage/toolbox/mechanical = 5,
		/obj/item/storage/toolbox/electrical = 3,
		/obj/item/storage/toolbox/emergency = 2,
	)

/obj/effect/spawner/random/bedsheet
	name = "bedsheet spawner"
	icon_state = "random_bedsheet"
	loot_subtype_path = /obj/item/bedsheet
	loot = list()

/obj/effect/spawner/random/tech_supply
	name = "Random Tech Supply"
	icon_state = "random_cell"
	spawn_loot_chance = 50
	loot = list(
		/obj/effect/spawner/random/powercell = 3,
		/obj/effect/spawner/random/technology_scanner = 2,
		/obj/item/packageWrap = 1,
		/obj/effect/spawner/random/bomb_supply = 2,
		/obj/item/tool/extinguisher = 1,
		/obj/item/clothing/gloves/fyellow = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/effect/spawner/random/toolbox = 2,
		/obj/item/storage/belt/utility = 2,
		/obj/effect/spawner/random/tool = 5,
	)

/obj/effect/spawner/random/structure/plastiqueexplosive
	name = "plastique explosive spawner"
	icon_state = "random_plastiqueexplosive"
	spawn_loot_chance = 45
	loot = list(
		/obj/item/explosive/plastique = 7,
		/obj/item/detpack = 2,
		/obj/item/assembly/signaler/receiver = 1,
	)

/obj/effect/spawner/random/structure/plastiqueexplosive/multiple
	spawn_loot_chance = 20
	icon_state = "random_plastiqueexplosive_multiple_two"
	spawn_loot_count = 2

/obj/effect/spawner/random/structure/plastiqueexplosive/multiple/four
	spawn_loot_chance = 10
	icon_state = "random_plastiqueexplosive_multiple_four"
	spawn_loot_count = 4

/obj/effect/spawner/random/structure/handcuffs
	name = "handcuff spawner"
	icon_state = "random_handcuffs"
	spawn_loot_chance = 85
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/restraints/handcuffs = 15,
		/obj/item/restraints/handcuffs/cable = 1,
	)

/obj/effect/spawner/random/structure/hand_labeler
	name = "hand labeler spawner"
	icon_state = "random_labeler"
	spawn_loot_chance = 90
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/tool/hand_labeler = 9,
		/obj/item/paper,
	)

/obj/effect/spawner/random/structure/handheld_lighting
	name = "handheld lighting spawner"
	icon_state = "random_lighting"
	spawn_loot_chance = 60
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/flashlight = 15,
		/obj/item/flashlight/flare = 5,
		/obj/item/flashlight/lantern = 1,
		/obj/item/flashlight/pen = 1,
	)


///All kinds of 'cans'. This include water bottles.
/obj/effect/spawner/random/drink_cans
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
/obj/effect/spawner/random/drink_alcohol_bottle
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
/obj/effect/spawner/random/sugary_snack
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
		/obj/item/reagent_containers/food/snacks/jellysandwich,
		/obj/item/reagent_containers/food/snacks/jellysandwich/cherry,
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
		/obj/item/reagent_containers/food/snacks/appletart,
	)


///Stuff you might expect to eat in the street.
/obj/effect/spawner/random/outdoors_snacks
	name = "Random Outdoors snack"
	icon_state = "random_outdoors_snack"
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/reagent_containers/food/snacks/taco,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/packaged_burrito,
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza,
		/obj/item/reagent_containers/food/snacks/packaged_burger,
		/obj/item/reagent_containers/food/snacks/packaged_hdogs,
		/obj/item/reagent_containers/food/snacks/upp/fish,
		/obj/item/reagent_containers/food/snacks/upp/rice,
		/obj/item/reagent_containers/food/snacks/sliceable/meatbread,
		/obj/item/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/reagent_containers/food/snacks/enchiladas,
		/obj/item/reagent_containers/food/snacks/cheesyfries,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/loadedbakedpotato,
		/obj/item/reagent_containers/food/snacks/tofuburger,
		/obj/item/reagent_containers/food/snacks/fishburger,
		/obj/item/reagent_containers/food/snacks/xenoburger,
		/obj/item/reagent_containers/food/snacks/fishfingers,
	)


///All the trash.
/obj/effect/spawner/random/trash
	name = "Random trash"
	icon_state = "random_trash"
	loot = list(
		/obj/item/trash/raisins,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/popcorn,
		/obj/item/trash/sosjerky,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/waffles,
		/obj/item/trash/plate,
		/obj/item/trash/snack_bowl,
		/obj/item/trash/pistachios,
		/obj/item/trash/semki,
		/obj/item/trash/tray,
		/obj/item/trash/candle,
		/obj/item/trash/liquidfood,
		/obj/item/trash/burger,
		/obj/item/trash/buritto,
		/obj/item/trash/hotdog,
		/obj/item/trash/kepler,
		/obj/item/trash/eat,
		/obj/item/trash/fortunecookie,
		/obj/item/trash/c_tube,
		/obj/item/trash/cigbutt,
		/obj/item/trash/cigbutt/cigarbutt,
		/obj/item/trash/tgmc_tray,
		/obj/item/trash/boonie,
		/obj/item/trash/chunk,
		/obj/item/trash/barcardine,
		/obj/item/trash/mre,
	)

///random civilian clothing for flavor
/obj/effect/spawner/random/clothing
	name = "Random clothing spawner"
	icon_state = "random_clothes"
	loot = list(
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bomber,
		/obj/item/clothing/suit/ianshirt,
		/obj/item/clothing/suit/radiation,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/space/rig/mining,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest/lime,
		/obj/item/clothing/suit/storage/hazardvest/blue,
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/wcoat,
		/obj/item/clothing/under/colonist,
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/under/color/blackf,
		/obj/item/clothing/under/darkred,
		/obj/item/clothing/under/darkblue,
		/obj/item/clothing/under/gentlesuit,
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/liaison_suit,
		/obj/item/clothing/under/liaison_suit/formal,
		/obj/item/clothing/under/pj/blue,
		/obj/item/clothing/under/rank/cargo,
		/obj/item/clothing/under/rank/cargotech,
		/obj/item/clothing/under/rank/chaplain,
		/obj/item/clothing/under/rank/det,
		/obj/item/clothing/under/rank/engineer,
		/obj/item/clothing/under/rank/head_of_security/alt,
		/obj/item/clothing/under/rank/medical,
		/obj/item/clothing/under/rank/prisoner,
		/obj/item/clothing/under/rank/research_director/rdalt,
		/obj/item/clothing/under/rank/ro_suit,
		/obj/item/clothing/under/suit_jacket,
		/obj/item/clothing/under/suit_jacket/charcoal,
		/obj/item/clothing/under/swimsuit,
		/obj/item/clothing/under/rank/miner,
	)


///random civilian hats for flavor
/obj/effect/spawner/random/hats
	name = "Random hat spawner"
	icon_state = "random_hat"
	loot = list(
		/obj/item/clothing/head/bandanna/red,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/bomb_hood/security,
		/obj/item/clothing/head/boonie,
		/obj/item/clothing/head/bowler,
		/obj/item/clothing/head/bowlerhat,
		/obj/item/clothing/head/chaplain_hood,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/HoS,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/det_hat,
		/obj/item/clothing/head/det_hat/black,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/hardhat/red,
		/obj/item/clothing/head/hardhat/white,
		/obj/item/clothing/head/headband,
		/obj/item/clothing/head/headband/rambo,
		/obj/item/clothing/head/headband/red,
		/obj/item/clothing/head/headband/snake,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet/durag/jungle,
		/obj/item/clothing/head/helmet/gladiator,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/head/helmet/space/syndicate,
		/obj/item/clothing/under/rank/head_of_security/alt,
		/obj/item/clothing/head/powdered_wig,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/soft,
		/obj/item/clothing/head/soft/red,
		/obj/item/clothing/head/strawhat,
		/obj/item/clothing/head/warning_cone,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/helmet/riot,
	)


///random kitchen items
/obj/effect/spawner/random/kitchen
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

///random medical items
/obj/effect/spawner/random/pillbottle
	name = "Random pill bottle spawner"
	icon_state = "random_medicine"
	spawn_loot_chance = 50
	loot = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
		/obj/item/storage/pill_bottle/imidazoline = 10,
		/obj/item/storage/pill_bottle/bicaridine = 30,
		/obj/item/storage/pill_bottle/kelotane = 30,
		/obj/item/storage/pill_bottle/tramadol = 15,
		/obj/item/storage/pill_bottle/inaprovaline = 10,
		/obj/item/storage/pill_bottle/dylovene = 15,
		/obj/item/storage/pill_bottle/spaceacillin = 10,
	)

/obj/effect/spawner/random/health_analyzer
	name = "health analyzer spawner"
	icon_state = "random_healthanalyzer"
	spawn_scatter_radius = 1
	spawn_random_offset = TRUE
	spawn_loot_chance = 35
	loot = list(
		/obj/item/healthanalyzer,
	)

/obj/effect/spawner/random/syringe
	name = "Random syringe spawner"
	icon_state = "random_syringe"
	spawn_loot_chance = 60
	loot = list(
		/obj/item/reagent_containers/syringe = 40,
		/obj/item/reagent_containers/syringe/antiviral = 30,
		/obj/item/reagent_containers/syringe/dylovene = 30,
		/obj/item/reagent_containers/syringe/inaprovaline = 30,
		/obj/item/storage/syringe_case/burn = 10,
		/obj/item/storage/syringe_case/dermaline = 10,
		/obj/item/storage/syringe_case/meraderm = 5,
		/obj/item/storage/syringe_case/oxy = 5,
		/obj/item/storage/syringe_case/tricordrazine = 5,
		/obj/item/storage/box/syringes = 1,
	)

/obj/effect/spawner/random/beaker
	name = "Random beaker spawner"
	icon_state = "random_beaker"
	spawn_loot_chance = 85
	loot = list(
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/beaker/large,
	)

/obj/effect/spawner/random/beaker/regularweighted
	loot = list(
		/obj/item/reagent_containers/glass/beaker = 8,
		/obj/item/reagent_containers/glass/beaker/large = 2,
	)

/obj/effect/spawner/random/beaker/largeweighted
	icon_state = "random_largebeaker"
	loot = list(
		/obj/item/reagent_containers/glass/beaker/large = 8,
		/obj/item/reagent_containers/glass/beaker = 2,
	)


/obj/effect/spawner/random/bloodpack
	name = "Random blood spawner"
	icon_state = "random_bloodpack"
	spawn_loot_chance = 80
	loot = list(
		/obj/item/reagent_containers/blood/empty = 95,
		/obj/item/reagent_containers/blood/AMinus = 20,
		/obj/item/reagent_containers/blood/APlus = 20,
		/obj/item/reagent_containers/blood/BMinus = 20,
		/obj/item/reagent_containers/blood/BPlus = 20,
		/obj/item/reagent_containers/blood/OPlus = 20,
		/obj/item/reagent_containers/blood/OMinus = 5,
	)

/obj/effect/spawner/random/medbelt
	name = "Random medical belt spawner"
	icon_state = "random_medbelt"
	spawn_loot_chance = 25
	loot = list(
		/obj/item/storage/belt/lifesaver = 50,
		/obj/effect/spawner/random/pillbottle = 15,
		/obj/item/storage/belt/lifesaver/quick = 10,
		/obj/item/storage/belt/lifesaver/full = 5,
	)

/obj/effect/spawner/random/engibelt
	name = "Random engi belt spawner"
	icon_state = "random_engibelt"
	spawn_loot_chance = 45
	loot = list(
		/obj/item/storage/belt/utility = 50,
		/obj/effect/spawner/random/tool = 25,
		/obj/effect/spawner/random/toolbox = 15,
		/obj/item/storage/belt/utility/full = 10,
		/obj/item/storage/belt/utility/atmostech = 10,
	)


/obj/effect/spawner/random/medhud
	name = "Random med hud spawner"
	icon_state = "random_medhud"
	spawn_loot_chance = 25
	loot = list(
		/obj/item/clothing/glasses/regular = 30,
		/obj/item/clothing/glasses/hud/health = 15,
		/obj/item/clothing/glasses/hud/medgoggles = 15,
		/obj/item/clothing/glasses/hud/medgoggles/prescription = 10,
		/obj/item/clothing/glasses/hud/medpatch = 5,
		/obj/item/clothing/glasses/hud/medsunglasses = 5,
	)


/obj/effect/spawner/random/surgical
	name = "Random surgical instrument spawner"
	icon_state = "random_surgical"
	loot = list(
		/obj/item/tool/surgery/scalpel/manager,
		/obj/item/tool/surgery/scalpel,
		/obj/item/tool/surgery/hemostat,
		/obj/item/tool/surgery/retractor,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/tool/surgery/cautery,
		/obj/item/tool/surgery/circular_saw,
		/obj/item/tool/surgery/suture,
		/obj/item/tool/surgery/bonegel,
		/obj/item/tool/surgery/bonesetter,
		/obj/item/tool/surgery/FixOVein,
		/obj/item/stack/nanopaste,
	)

/obj/effect/spawner/random/organ
	name = "Random surgical organ spawner"
	icon_state = "random_organ"
	loot = list(
		/obj/item/prop/organ/brain,
		/obj/item/prop/organ/heart,
		/obj/item/prop/organ/lungs,
		/obj/item/prop/organ/kidneys,
		/obj/item/prop/organ/eyes,
		/obj/item/prop/organ/liver,
		/obj/item/prop/organ/appendix,
	)

///random cables
/obj/effect/spawner/random/cable
	name = "Random cable spawner"
	icon_state = "random_cable"
	spawn_random_offset = TRUE
	spawn_loot_chance = 90
	loot = list(
		/obj/item/stack/cable_coil = 75,
		/obj/item/stack/cable_coil/cut = 30,
		/obj/item/stack/cable_coil/twentyfive = 25,
		/obj/item/stack/cable_coil/five = 10,
	)

/obj/effect/spawner/random/shard
	name = "Random shard spawner"
	icon_state = "random_shard"
	spawn_random_offset = TRUE
	spawn_loot_count = 2
	spawn_scatter_radius = 1
	spawn_loot_chance = 90
	loot = list(
		/obj/item/shard = 6,
		/obj/effect/decal/cleanable/glass = 2,
	)

/obj/effect/spawner/random/seeds
	name = "Random seed spawner"
	icon_state = "random_seed"
	spawn_loot_chance = 90
	loot = list(
		/obj/item/seeds/appleseed,
		/obj/item/seeds/bananaseed,
		/obj/item/seeds/cocoapodseed,
		/obj/item/seeds/grapeseed,
		/obj/item/seeds/orangeseed,
		/obj/item/seeds/sugarcaneseed,
		/obj/item/seeds/wheatseed,
		/obj/item/seeds/watermelonseed,
		/obj/item/seeds/chiliseed,
		/obj/item/seeds/cornseed,
		/obj/item/seeds/lemonseed,
		/obj/item/seeds/peanutseed,
		/obj/item/seeds/poppyseed,
		/obj/item/seeds/pumpkinseed,
		/obj/item/seeds/carrotseed,
		/obj/item/seeds/wheatseed,
		/obj/item/seeds/tomatoseed,
	)

/obj/effect/spawner/random/computercircuit
	name = "Random computer circuit spawner"
	icon_state = "random_ccircuit"
	spawn_loot_chance = 75
	loot_subtype_path = /obj/item/circuitboard/computer
	loot = list()

/obj/effect/spawner/random/cigarettes
	name = "Random cigarette spawner"
	icon_state = "random_cigarette"
	spawn_random_offset = TRUE
	spawn_scatter_radius = 1
	loot = list(
		/obj/item/storage/fancy/cigarettes/dromedaryco = 30,
		/obj/item/storage/fancy/cigarettes/kpack = 25,
		/obj/item/storage/fancy/cigarettes/lady_finger = 25,
		/obj/item/storage/fancy/cigarettes/luckystars = 25,
		/obj/item/storage/fancy/chemrettes = 15,
		/obj/item/storage/fancy/cigar = 15,
	)

/obj/effect/spawner/random/medbottle
	name = "Random medical reagent bottle spawner"
	icon_state = "random_medbottle"
	spawn_loot_chance = 50
	loot = list(
		/obj/item/reagent_containers/glass/bottle/bicaridine = 30,
		/obj/item/reagent_containers/glass/bottle/kelotane = 30,
		/obj/item/reagent_containers/glass/bottle/dylovene = 30,
		/obj/item/reagent_containers/glass/bottle/spaceacillin = 15,
		/obj/item/reagent_containers/glass/bottle/dermaline = 15,
		/obj/item/reagent_containers/glass/bottle/tramadol = 10,
		/obj/item/reagent_containers/glass/bottle/tricordrazine = 5,
		/obj/item/reagent_containers/glass/bottle/oxycodone = 5,
		/obj/item/reagent_containers/glass/bottle/meralyne = 5,
		/obj/item/reagent_containers/glass/bottle/lemoline = 5,
		/obj/item/reagent_containers/glass/bottle/meraderm = 1,
	)

///BALLISTIC WEAPONS///

///random guns
/obj/effect/spawner/random/gun //restricted to ballistic weapons available on the ship, no auto-9s here
	name = "Random ballistic ammunition spawner"
	icon_state = "random_rifle"
	loot = list(
		/obj/item/weapon/gun/rifle/standard_assaultrifle,
		/obj/item/weapon/gun/rifle/standard_carbine,
		/obj/item/weapon/gun/rifle/standard_skirmishrifle,
		/obj/item/weapon/gun/rifle/tx11/scopeless,
		/obj/item/weapon/gun/smg/standard_smg,
		/obj/item/weapon/gun/smg/standard_machinepistol,
		/obj/item/weapon/gun/rifle/standard_dmr,
		/obj/item/weapon/gun/rifle/standard_br,
		/obj/item/weapon/gun/rifle/chambered,
		/obj/item/weapon/gun/shotgun/pump/bolt/unscoped,
		/obj/item/weapon/gun/shotgun/double/martini,
		/obj/item/weapon/gun/pistol/standard_pistol,
		/obj/item/weapon/gun/pistol/standard_heavypistol,
		/obj/item/weapon/gun/revolver/standard_revolver,
		/obj/item/weapon/gun/pistol/standard_pocketpistol,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/double/derringer,
		/obj/item/weapon/gun/rifle/pepperball,
		/obj/item/weapon/gun/shotgun/pump/lever/repeater,
		/obj/item/weapon/gun/shotgun/double/marine,
		/obj/item/weapon/gun/rifle/standard_autoshotgun,
		/obj/item/weapon/gun/shotgun/combat/standardmarine,
	)


///random shotguns
/obj/effect/spawner/random/gun/shotgun
	name = "Random shotgun spawner"
	icon_state = "random_shotgun"
	loot = list(
		/obj/item/weapon/gun/shotgun/pump/lever/repeater,
		/obj/item/weapon/gun/shotgun/pump/bolt/unscoped,
		/obj/item/weapon/gun/shotgun/pump/cmb,
		/obj/item/weapon/gun/shotgun/double/marine,
		/obj/item/weapon/gun/rifle/standard_autoshotgun,
		/obj/item/weapon/gun/shotgun/combat/standardmarine,
		/obj/item/weapon/gun/shotgun/pump/t35,
	)

/obj/effect/spawner/random/gun/egun
	name = "Random energy gun spawner"
	icon_state = "random_egun"
	loot = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle = 25,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_sniper = 25,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine = 25,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser = 25,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = 25,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/tesla = 5,
		/obj/item/weapon/gun/energy/lasgun/M43 = 5,
	)

/obj/effect/spawner/random/gun/egun/lowchance
	spawn_loot_chance = 20

///random machineguns
/obj/effect/spawner/random/gun/machineguns
	name = "Random machinegun spawner"
	icon_state = "random_machinegun"
	loot = list(
		/obj/item/weapon/gun/rifle/standard_lmg,
		/obj/item/weapon/gun/rifle/standard_gpmg,
		/obj/item/weapon/gun/standard_mmg,
	)


///random rifles
/obj/effect/spawner/random/gun/rifles
	name = "Random rifle spawner"
	icon_state = "random_rifle"
	loot = list(
		/obj/item/weapon/gun/rifle/standard_assaultrifle,
		/obj/item/weapon/gun/rifle/standard_carbine,
		/obj/item/weapon/gun/rifle/standard_skirmishrifle,
		/obj/item/weapon/gun/rifle/tx11/scopeless,
	)


///random sidearms
/obj/effect/spawner/random/gun/sidearms
	name = "Random sidearm spawner"
	icon_state = "random_sidearm"
	loot = list(
		/obj/item/weapon/gun/pistol/standard_pistol,
		/obj/item/weapon/gun/pistol/standard_heavypistol,
		/obj/item/weapon/gun/revolver/standard_revolver,
		/obj/item/weapon/gun/revolver/cmb,
		/obj/item/weapon/gun/pistol/vp70,
		/obj/item/weapon/gun/pistol/standard_pocketpistol,
	)


///random melee weapons
/obj/effect/spawner/random/melee
	name = "Random melee weapons spawner"
	icon_state = "random_melee"
	loot = list(
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonetknife,
		/obj/item/weapon/baseballbat,
		/obj/item/weapon/baseballbat/metal,
		/obj/item/weapon/broken_bottle,
		/obj/item/tool/hatchet,
		/obj/item/tool/kitchen/knife,
		/obj/item/tool/kitchen/knife/butcher,
		/obj/item/weapon/twohanded/fireaxe,
	)


///BALLISTIC WEAPON AMMO///

///random ammunition
/obj/effect/spawner/random/ammo
	name = "Random ballistic ammunition spawner"
	icon_state = "random_ammo"
	loot = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
		/obj/item/ammo_magazine/rifle/tx11,
		/obj/item/ammo_magazine/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_machinepistol,
		/obj/item/ammo_magazine/rifle/standard_dmr,
		/obj/item/ammo_magazine/rifle/standard_br,
		/obj/item/ammo_magazine/rifle/chamberedrifle,
		/obj/item/ammo_magazine/rifle/bolt,
		/obj/item/ammo_magazine/rifle/martini,
		/obj/item/ammo_magazine/pistol/standard_pistol,
		/obj/item/ammo_magazine/pistol/standard_heavypistol,
		/obj/item/ammo_magazine/revolver/standard_revolver,
		/obj/item/ammo_magazine/pistol/standard_pocketpistol,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/plasma_pistol,
		/obj/item/ammo_magazine/pistol/derringer,
		/obj/item/ammo_magazine/rifle/pepperball,
		/obj/item/ammo_magazine/shotgun/flechette,
		/obj/item/ammo_magazine/rifle/tx15_slug,
	)


///for specific ranged weapon ammo spawners we don't spawn anything that marines couldn't get back on their ship

///random shotgun ammunition
/obj/effect/spawner/random/ammo/shotgun
	name = "Random shotgun ammunition spawner"
	icon_state = "random_shotgun_ammo"
	loot = list(
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/ammo_magazine/shotgun/flechette,
	)


///random machinegun ammunition
/obj/effect/spawner/random/ammo/machinegun
	name = "Random machinegun ammunition spawner"
	icon_state = "random_machinegun_ammo"
	loot = list(
		/obj/item/ammo_magazine/standard_lmg,
		/obj/item/ammo_magazine/standard_gpmg,
		/obj/item/ammo_magazine/standard_mmg,
		/obj/item/ammo_magazine/heavymachinegun,
	)


///random rifle ammunition
/obj/effect/spawner/random/ammo/rifle
	name = "Random rifle ammunition spawner"
	icon_state = "random_rifle_ammo"
	loot = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
		/obj/item/ammo_magazine/rifle/tx11,
	)


///random sidearm ammunition
/obj/effect/spawner/random/ammo/sidearm
	name = "Random sidearm ammunition spawner"
	icon_state = "random_sidearm_ammo"
	loot = list(
		/obj/item/ammo_magazine/pistol/standard_pistol,
		/obj/item/ammo_magazine/pistol/standard_heavypistol,
		/obj/item/ammo_magazine/revolver/standard_revolver,
		/obj/item/ammo_magazine/pistol/vp70,
		/obj/item/ammo_magazine/pistol/derringer,
		/obj/item/ammo_magazine/revolver/cmb,
		/obj/item/ammo_magazine/pistol/standard_pocketpistol,
	)


//Random spawners for multiple grouped items such as a gun and it's associated ammo

/obj/effect/spawner/random_set
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	/// this variable determines the likelyhood that this random object will not spawn anything
	var/spawn_nothing_percentage = 0
	///the list of what actually gets spawned
	var/list/spawned_gear_list
	///this is formatted as a list, which itself contains any number of lists. Each set of items that should be spawned together must be added as a list in option_list. One of those lists will be randomly chosen to spawn.
	var/list/option_list

// creates a new set of objects and deletes itself
/obj/effect/spawner/random_set/Initialize()
	. = ..()
	if(!prob(spawn_nothing_percentage))
		var/choice = rand(1, length(option_list)) //chooses an item on the option_list
		spawned_gear_list = option_list[choice] //sets it as the thing(s) to spawn
		for(var/typepath in spawned_gear_list)
			if(spawned_gear_list[typepath])
				new typepath(loc, spawned_gear_list[typepath])
			else
				new typepath(loc)
	return INITIALIZE_HINT_QDEL

//restricted to ballistic weapons available on the ship, no auto-9s here
/obj/effect/spawner/random_set/gun
	name = "Random ballistic weapon set spawner"
	icon_state = "random_rifle"

	option_list = list(
		list(/obj/item/weapon/gun/rifle/standard_assaultrifle, /obj/item/ammo_magazine/rifle/standard_assaultrifle, /obj/item/ammo_magazine/rifle/standard_assaultrifle, /obj/item/ammo_magazine/rifle/standard_assaultrifle,),
		list(/obj/item/weapon/gun/rifle/standard_carbine, /obj/item/ammo_magazine/rifle/standard_carbine, /obj/item/ammo_magazine/rifle/standard_carbine, /obj/item/ammo_magazine/rifle/standard_carbine,),
		list(/obj/item/weapon/gun/rifle/standard_skirmishrifle, /obj/item/ammo_magazine/rifle/standard_skirmishrifle, /obj/item/ammo_magazine/rifle/standard_skirmishrifle, /obj/item/ammo_magazine/rifle/standard_skirmishrifle,),
		list(/obj/item/weapon/gun/rifle/tx11/scopeless, /obj/item/ammo_magazine/rifle/tx11, /obj/item/ammo_magazine/rifle/tx11, /obj/item/ammo_magazine/rifle/tx11,),
		list(/obj/item/weapon/gun/smg/standard_smg, /obj/item/ammo_magazine/smg/standard_smg, /obj/item/ammo_magazine/smg/standard_smg, /obj/item/ammo_magazine/smg/standard_smg,),
		list(/obj/item/weapon/gun/smg/standard_machinepistol, /obj/item/ammo_magazine/smg/standard_machinepistol, /obj/item/ammo_magazine/smg/standard_machinepistol, /obj/item/ammo_magazine/smg/standard_machinepistol,),
		list(/obj/item/weapon/gun/rifle/standard_dmr, /obj/item/ammo_magazine/rifle/standard_dmr, /obj/item/ammo_magazine/rifle/standard_dmr, /obj/item/ammo_magazine/rifle/standard_dmr,),
		list(/obj/item/weapon/gun/rifle/standard_br, /obj/item/ammo_magazine/rifle/standard_br, /obj/item/ammo_magazine/rifle/standard_br, /obj/item/ammo_magazine/rifle/standard_br,),
		list(/obj/item/weapon/gun/rifle/chambered, /obj/item/ammo_magazine/rifle/chamberedrifle, /obj/item/ammo_magazine/rifle/chamberedrifle, /obj/item/ammo_magazine/rifle/chamberedrifle,),
		list(/obj/item/weapon/gun/shotgun/pump/bolt/unscoped, /obj/item/ammo_magazine/rifle/bolt, /obj/item/ammo_magazine/rifle/bolt, /obj/item/ammo_magazine/rifle/bolt,),
		list(/obj/item/weapon/gun/shotgun/double/martini, /obj/item/ammo_magazine/rifle/martini, /obj/item/ammo_magazine/rifle/martini, /obj/item/ammo_magazine/rifle/martini,),
		list(/obj/item/weapon/gun/pistol/standard_pistol, /obj/item/ammo_magazine/pistol/standard_pistol, /obj/item/ammo_magazine/pistol/standard_pistol, /obj/item/ammo_magazine/pistol/standard_pistol,),
		list(/obj/item/weapon/gun/pistol/standard_heavypistol, /obj/item/ammo_magazine/pistol/standard_heavypistol, /obj/item/ammo_magazine/pistol/standard_heavypistol, /obj/item/ammo_magazine/pistol/standard_heavypistol,),
		list(/obj/item/weapon/gun/revolver/standard_revolver, /obj/item/ammo_magazine/revolver/standard_revolver, /obj/item/ammo_magazine/revolver/standard_revolver, /obj/item/ammo_magazine/revolver/standard_revolver,),
		list(/obj/item/weapon/gun/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol,),
		list(/obj/item/weapon/gun/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70,),
		list(/obj/item/weapon/gun/pistol/plasma_pistol, /obj/item/ammo_magazine/pistol/plasma_pistol, /obj/item/ammo_magazine/pistol/plasma_pistol, /obj/item/ammo_magazine/pistol/plasma_pistol,),
		list(/obj/item/weapon/gun/shotgun/double/derringer, /obj/item/ammo_magazine/pistol/derringer, /obj/item/ammo_magazine/pistol/derringer, /obj/item/ammo_magazine/pistol/derringer,),
		list(/obj/item/weapon/gun/rifle/pepperball, /obj/item/ammo_magazine/rifle/pepperball, /obj/item/ammo_magazine/rifle/pepperball, /obj/item/ammo_magazine/rifle/pepperball,),
		list(/obj/item/weapon/gun/shotgun/pump/lever/repeater, /obj/item/ammo_magazine/packet/p4570, /obj/item/ammo_magazine/packet/p4570, /obj/item/ammo_magazine/packet/p4570,),
		list(/obj/item/weapon/gun/shotgun/double/marine, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot,),
		list(/obj/item/weapon/gun/rifle/standard_autoshotgun, /obj/item/ammo_magazine/rifle/tx15_slug, /obj/item/ammo_magazine/rifle/tx15_slug, /obj/item/ammo_magazine/rifle/tx15_slug,),
		list(/obj/item/weapon/gun/shotgun/combat/standardmarine, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot,),
	)

//random rifles
/obj/effect/spawner/random_set/rifle
	name = "Random rifle set spawner"
	icon_state = "random_rifle"

	option_list = list(
		list(/obj/item/weapon/gun/rifle/standard_assaultrifle, /obj/item/ammo_magazine/rifle/standard_assaultrifle, /obj/item/ammo_magazine/rifle/standard_assaultrifle, /obj/item/ammo_magazine/rifle/standard_assaultrifle,),
		list(/obj/item/weapon/gun/rifle/standard_carbine, /obj/item/ammo_magazine/rifle/standard_carbine, /obj/item/ammo_magazine/rifle/standard_carbine, /obj/item/ammo_magazine/rifle/standard_carbine,),
		list(/obj/item/weapon/gun/rifle/standard_skirmishrifle, /obj/item/ammo_magazine/rifle/standard_skirmishrifle, /obj/item/ammo_magazine/rifle/standard_skirmishrifle, /obj/item/ammo_magazine/rifle/standard_skirmishrifle,),
		list(/obj/item/weapon/gun/rifle/tx11/scopeless, /obj/item/ammo_magazine/rifle/tx11, /obj/item/ammo_magazine/rifle/tx11, /obj/item/ammo_magazine/rifle/tx11,),
	)

//random shotguns
/obj/effect/spawner/random_set/shotgun
	name = "Random shotgun set spawner"
	icon_state = "random_shotgun"

	option_list = list(
		list(/obj/item/weapon/gun/shotgun/pump/bolt/unscoped, /obj/item/ammo_magazine/rifle/bolt, /obj/item/ammo_magazine/rifle/bolt, /obj/item/ammo_magazine/rifle/bolt,),
		list(/obj/item/weapon/gun/shotgun/double/marine, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot,),
		list(/obj/item/weapon/gun/rifle/standard_autoshotgun, /obj/item/ammo_magazine/rifle/tx15_slug, /obj/item/ammo_magazine/rifle/tx15_slug, /obj/item/ammo_magazine/rifle/tx15_slug,),
		list(/obj/item/weapon/gun/shotgun/combat/standardmarine, /obj/item/ammo_magazine/shotgun/flechette, /obj/item/ammo_magazine/shotgun/flechette, /obj/item/ammo_magazine/shotgun/flechette,),
		list(/obj/item/weapon/gun/shotgun/pump/t35, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot,),
		list(/obj/item/weapon/gun/shotgun/pump/cmb, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot, /obj/item/ammo_magazine/shotgun/buckshot,),
	)

//random machineguns
/obj/effect/spawner/random_set/machineguns
	name = "Random machinegun set spawner"
	icon_state = "random_machinegun"

	option_list = list(
		list(/obj/item/weapon/gun/rifle/standard_gpmg, /obj/item/ammo_magazine/standard_gpmg, /obj/item/ammo_magazine/standard_gpmg, /obj/item/ammo_magazine/standard_gpmg,),
		list(/obj/item/weapon/gun/standard_mmg, /obj/item/ammo_magazine/standard_mmg, /obj/item/ammo_magazine/standard_mmg, /obj/item/ammo_magazine/standard_mmg,),
	)

//random sidearms
/obj/effect/spawner/random_set/sidearms
	name = "Random sidearm set spawner"
	icon_state = "random_sidearm"

	option_list = list(
		list(/obj/item/weapon/gun/pistol/standard_pistol, /obj/item/ammo_magazine/pistol/standard_pistol, /obj/item/ammo_magazine/pistol/standard_pistol, /obj/item/ammo_magazine/pistol/standard_pistol,),
		list(/obj/item/weapon/gun/pistol/standard_heavypistol, /obj/item/ammo_magazine/pistol/standard_heavypistol, /obj/item/ammo_magazine/pistol/standard_heavypistol, /obj/item/ammo_magazine/pistol/standard_heavypistol,),
		list(/obj/item/weapon/gun/revolver/standard_revolver, /obj/item/ammo_magazine/revolver/standard_revolver, /obj/item/ammo_magazine/revolver/standard_revolver, /obj/item/ammo_magazine/revolver/standard_revolver,),
		list(/obj/item/weapon/gun/revolver/cmb, /obj/item/ammo_magazine/revolver/cmb, /obj/item/ammo_magazine/revolver/cmb, /obj/item/ammo_magazine/revolver/cmb,),
		list(/obj/item/weapon/gun/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol,),
		list(/obj/item/weapon/gun/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70,),
	)

//random plushie spawner
/obj/effect/spawner/random/plushie
	name = "Random plush spawner"
	icon_state = "random_plush"
	spawn_loot_chance = 15
	loot = list(
		/obj/item/toy/plush/moth,
		/obj/item/toy/plush/rouny,
		/obj/item/toy/plush/therapy_blue,
		/obj/item/toy/plush/therapy_green,
		/obj/item/toy/plush/therapy_yellow,
		/obj/item/toy/plush/therapy_orange,
		/obj/item/toy/plush/therapy_red,
		/obj/item/toy/plush/therapy_purple,
	)

/obj/effect/spawner/random/plushie/fiftyfifty
	spawn_loot_chance = 50
/obj/effect/spawner/random/plushie/nospawnninety
	spawn_loot_chance = 10

/obj/effect/spawner/random/plushie/nospawnninetyfive
	spawn_loot_chance = 5

/obj/effect/spawner/random/plushie/nospawnninetynine
	spawn_loot_chance = 1

/obj/effect/spawner/random/plant
	name = "Random potted plant spawner"
	icon_state = "random_plant"
	loot = list(
		/obj/structure/flora/pottedplant,
		/obj/structure/flora/pottedplant/one,
		/obj/structure/flora/pottedplant/two,
		/obj/structure/flora/pottedplant/three,
		/obj/structure/flora/pottedplant/four,
		/obj/structure/flora/pottedplant/five,
		/obj/structure/flora/pottedplant/six,
		/obj/structure/flora/pottedplant/seven,
		/obj/structure/flora/pottedplant/eight,
		/obj/structure/flora/pottedplant/ten,
		/obj/structure/flora/pottedplant/eleven,
		/obj/structure/flora/pottedplant/twelve,
		/obj/structure/flora/pottedplant/thirteen,
		/obj/structure/flora/pottedplant/fourteen,
		/obj/structure/flora/pottedplant/fifteen,
		/obj/structure/flora/pottedplant/sixteen,
		/obj/structure/flora/pottedplant/seventeen,
		/obj/structure/flora/pottedplant/eighteen,
		/obj/structure/flora/pottedplant/twenty,
		/obj/structure/flora/pottedplant/twentyone,
		/obj/structure/flora/pottedplant/twentytwo,
		/obj/structure/flora/pottedplant/twentythree,
		/obj/structure/flora/pottedplant/twentyfour,
		/obj/structure/flora/pottedplant/twentyfive,
	)

/obj/effect/spawner/random/metal
	name = "metal spawner"
	icon_state = "random_metal"
	spawn_loot_chance = 80
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/stack/sheet/metal = 70,
		/obj/item/stack/sheet/metal/small_stack = 55,
		/obj/item/stack/sheet/metal/medium_stack = 10,
		/obj/item/stack/sheet/metal/large_stack = 2,
	)

/obj/effect/spawner/random/plasteel
	name = "plasteel spawner"
	icon_state = "random_plasteel"
	spawn_loot_chance = 75
	loot = list(
		/obj/item/stack/sheet/plasteel = 55,
		/obj/item/stack/sheet/plasteel/small_stack = 35,
		/obj/item/stack/sheet/plasteel/medium_stack = 10,
		/obj/item/stack/sheet/plasteel/large_stack = 3,
	)

/obj/effect/spawner/random/wood
	name = "wood spawner"
	icon_state = "random_wood"
	spawn_loot_chance = 80
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/stack/sheet/wood = 15,
		/obj/item/stack/sheet/wood/large_stack = 5,
	)

/obj/effect/spawner/random/glass
	name = "glass spawner"
	icon_state = "random_glass"
	spawn_loot_chance = 90
	loot = list(
		/obj/item/stack/sheet/glass = 25,
		/obj/item/stack/sheet/glass/large_stack = 1,
	)

/obj/effect/spawner/random/firstaid
	name = "firstaid spawner"
	icon_state = "random_medkit"
	spawn_loot_chance = 35
	loot = list(
		/obj/item/storage/firstaid/regular = 30,
		/obj/item/storage/firstaid/fire = 15,
		/obj/item/storage/firstaid/o2 = 10,
		/obj/item/storage/firstaid/toxin = 10,
		/obj/item/storage/firstaid/adv = 5,
	)

/obj/effect/spawner/random/folder
	name = "folder spawner"
	icon_state = "random_folder"
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/folder/black = 15,
		/obj/item/folder/black_random = 15,
		/obj/item/folder/white = 15,
		/obj/item/folder/red = 10,
		/obj/item/folder/yellow = 10,
		/obj/item/folder/blue = 10,
		/obj/item/folder/grape = 5,
	)

/obj/effect/spawner/random/greytide
	name = "greytide spawner"
	icon_state = "random_greytide"
	spawn_loot_chance = 25
	spawn_loot_count = 2
	loot = list(
		/obj/effect/landmark/corpsespawner/assistant/regular = 15,
		/obj/item/clothing/under/color/grey = 10,
		/obj/item/clothing/shoes/black = 10,
		/obj/item/storage/backpack/satchel/norm = 10,
		/obj/item/clothing/suit/armor/vest = 10,
		/obj/effect/spawner/random/toolbox = 5,
		/obj/item/storage/belt/utility = 5,
		/obj/effect/spawner/random/insulatedgloves = 5,
		/obj/effect/spawner/random/decal/blood = 5,
		/obj/item/card/id/guest = 5,
		/obj/item/weapon/twohanded/fireaxe = 1,
		/obj/item/storage/belt/utility/full = 1,
	)

/obj/effect/spawner/random/sunglasses
	name = "sunglasses spawner"
	icon_state = "random_sunglasses"
	spawn_random_offset = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/item/clothing/glasses/sunglasses/big = 10,
		/obj/item/clothing/glasses/sunglasses/aviator = 15,
		/obj/item/clothing/glasses/sunglasses/aviator/yellow = 15,
		/obj/item/clothing/glasses/sunglasses/big/prescription = 10,
		/obj/item/clothing/glasses/sunglasses/blindfold = 15,
		/obj/item/clothing/glasses/sunglasses/fake = 15,
		/obj/item/clothing/glasses/sunglasses/fake/prescription = 15,
		/obj/item/clothing/glasses/sunglasses/fake/big = 10,
		/obj/item/clothing/glasses/sunglasses/sechud = 3,
	)

/obj/effect/spawner/random/prizemecha
	name = "random toy mecha"
	icon_state = "random_durand"
	loot_type_path = /obj/item/toy/prize
	loot = list()

/obj/effect/spawner/random/insulatedgloves
	name = "insulated glove spawner"
	icon_state = "random_insuls"
	spawn_scatter_radius = 1
	spawn_random_offset = TRUE
	spawn_loot_chance = 65
	loot = list(
		/obj/item/clothing/gloves/fyellow = 85,
		/obj/item/clothing/gloves/yellow = 15,
	)

/obj/effect/spawner/random/coloredgloves
	name = "colored glove spawner"
	icon_state = "random_gloves"
	spawn_scatter_radius = 1
	spawn_random_offset = TRUE
	spawn_loot_chance = 80
	loot = list(
		/obj/item/clothing/gloves/black = 30,
		/obj/item/clothing/gloves/blue = 30,
		/obj/item/clothing/gloves/brown = 30,
		/obj/item/clothing/gloves/light_brown = 30,
		/obj/item/clothing/gloves/green = 30,
		/obj/item/clothing/gloves/grey = 30,
		/obj/item/clothing/gloves/latex = 30,
		/obj/item/clothing/gloves/orange = 30,
		/obj/item/clothing/gloves/purple = 30,
		/obj/item/clothing/gloves/rainbow = 30,
		/obj/item/clothing/gloves/red = 30,
		/obj/item/clothing/gloves/white = 30,
		/obj/item/clothing/gloves/yellow = 5,
	)

/obj/effect/spawner/random/coloredgloves/latex
	icon_state = "random_latex_gloves"
	loot = list(
		/obj/item/clothing/gloves/latex = 30,
		/obj/effect/spawner/random/coloredgloves = 1,
	)


/obj/effect/spawner/random/assemblies
	name = "random assembly spawner"
	icon_state = "random_assembly"
	loot_subtype_path = /obj/item/assembly
	loot = list()

/obj/effect/spawner/random/weapon_recharger
	name = "random weapon recharger"
	icon_state = "random_wrecharger"
	spawn_loot_chance = 45
	loot = list(
		/obj/structure/prop/mainship/weapon_recharger,
	)

/obj/effect/spawner/random/cigar
	name = "random cigar spawner"
	icon_state = "random_cigar"
	spawn_loot_chance = 75
	loot = list(
		/obj/item/clothing/mask/cigarette/cigar/cohiba,
		/obj/item/clothing/mask/cigarette/cigar/havana,
		/obj/item/clothing/mask/cigarette/cigar,
	)

/obj/effect/spawner/random/paperbin
	name = "random paperbin spawner"
	icon_state = "random_paperbin"
	spawn_loot_chance = 85
	loot = list(
		/obj/structure/paper_bin = 9,
		/obj/item/paper = 1,
	)

/obj/effect/spawner/random/clipboard
	name = "random clipboard spawner"
	icon_state = "random_clipboard"
	spawn_loot_chance = 65
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/clipboard = 8,
		/obj/item/paper = 2,
	)

/obj/effect/spawner/random/radio
	name = "radio spawner"
	icon_state = "random_radio"
	spawn_loot_chance = 35
	loot = list(
		/obj/item/radio/survivor,
	)

/obj/effect/spawner/random/mineral
	name = "mineral spawner"
	icon_state = "random_mineral"
	spawn_loot_chance = 70
	loot_subtype_path = /obj/item/stack/sheet/mineral
	loot = list()

///STRUCTURE SPAWNERS BELOW THIS LINE

/obj/effect/spawner/random/structure/grille
	name = "grille spawner"
	icon_state = "random_grille"
	spawn_loot_chance = 90
	loot = list( // 80% chance normal grille, 10% chance of broken, 10% chance of nothing
		/obj/structure/grille = 8,
		/obj/structure/grille/broken = 1,
	)

/obj/effect/spawner/random/structure/wood_barricade //does not support any direction but south, so only use on wood barricades facing south
	name = "wood barricade spawner"
	icon_state = "random_wood_barricade"
	spawn_loot_chance = 30
	loot = list(
		/obj/effect/spawner/random/wood = 6,
		/obj/structure/barricade/wooden = 4,
	)

/obj/effect/spawner/random/structure/closet
	name = "closet spawner"
	icon_state = "random_closet"
	spawn_loot_chance = 80
	loot = list(
		/obj/structure/closet/emcloset,
		/obj/structure/closet/emcloset/legacy,
		/obj/structure/closet/firecloset,
		/obj/structure/closet/firecloset/full,
		/obj/structure/closet/gimmick/russian,
		/obj/structure/closet/gmcloset,
		/obj/structure/closet/jcloset,
		/obj/structure/closet/l3closet,
		/obj/structure/closet/l3closet/general,
		/obj/structure/closet/l3closet/janitor,
		/obj/structure/closet/l3closet/scientist,
		/obj/structure/closet/l3closet/security,
		/obj/structure/closet/l3closet/virology,
		/obj/structure/closet/lasertag,
		/obj/structure/closet/lasertag/blue,
		/obj/structure/closet/lasertag/red,
		/obj/structure/closet/lasertag,
		/obj/structure/closet/malf,
		/obj/structure/closet/malf/suits,
		/obj/structure/closet/masks,
		/obj/structure/closet/open,
		/obj/structure/closet/radiation,
	)

/obj/effect/spawner/random/structure/closet/regular
	spawn_loot_chance = 90
	loot = list(
		/obj/structure/closet = 20,
		/obj/effect/spawner/random/structure/closet = 1,
	)

/obj/effect/spawner/random/structure/security_closet
	name = "security closet spawner"
	icon_state = "random_security_closet"
	spawn_loot_chance = 80
	loot = list(
		/obj/structure/closet/secure_closet/security,
	)

/obj/effect/spawner/random/structure/rad_closet
	name = "radiation closet spawner"
	icon_state = "random_radsuit"
	spawn_loot_chance = 90
	loot = list(
		/obj/structure/closet/radiation = 9,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/fire_closet
	name = "radiation closet spawner"
	icon_state = "random_firecloset"
	spawn_loot_chance = 85
	loot = list(
		/obj/structure/closet/firecloset = 9,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/cabinet
	name = "cabinet or wood spawner"
	icon_state = "random_cabinet"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/closet/cabinet = 85,
		/obj/effect/spawner/random/wood = 15,
	)


/obj/effect/spawner/random/structure/medicalcloset
	name = "medical closet spawner"
	icon_state = "random_medical_closet"
	spawn_loot_chance = 65
	loot = list(
		/obj/structure/closet/secure_closet/medical2 = 90,
		/obj/structure/closet/secure_closet/medical_doctor = 40,
		/obj/structure/closet/secure_closet/medical1/colony = 20,
		/obj/structure/closet/secure_closet/chemical/colony = 20,
		/obj/structure/closet/secure_closet/medical3/colony = 5,
		/obj/structure/closet/secure_closet/CMO = 1,
	)

/obj/effect/spawner/random/structure/securecloset
	name = "secure closet spawner"
	icon_state = "random_secure_closet"
	spawn_loot_chance = 65
	loot = list(
		/obj/structure/closet/secure_closet = 70,
		/obj/structure/closet/secure_closet/animal = 50,
		/obj/structure/closet/secure_closet/atmos_personal = 50,
		/obj/structure/closet/secure_closet/bar = 50,
		/obj/structure/closet/secure_closet/chemical/colony = 50,
		/obj/structure/closet/secure_closet/courtroom = 50,
		/obj/structure/closet/secure_closet/detective = 50,
		/obj/structure/closet/secure_closet/engineering_personal = 50,
		/obj/structure/closet/secure_closet/engineering_welding = 50,
		/obj/structure/closet/secure_closet/hydroponics = 50,
		/obj/structure/closet/secure_closet/hos = 50,
		/obj/structure/closet/secure_closet/marshal = 50,
		/obj/structure/closet/secure_closet/miner = 50,
		/obj/structure/closet/secure_closet/security/cargo = 50,
		/obj/structure/closet/secure_closet/scientist = 50,
		/obj/structure/closet/secure_closet/engineering_electrical = 30,
		/obj/structure/closet/secure_closet/CMO = 10,
		/obj/structure/closet/secure_closet/RD = 10,
		/obj/structure/closet/secure_closet/engineering_chief = 10,
	)

/obj/effect/spawner/random/structure/securecloset/regular
	icon_state = "random_regular_secure"
	spawn_loot_chance = 85
	loot = list(
		/obj/structure/closet/secure_closet = 40,
		/obj/effect/spawner/random/metal = 2,
		/obj/effect/spawner/random/structure/securecloset = 1,
	)

/obj/effect/spawner/random/structure/emcloset
	name = "emergency closet spawner"
	icon_state = "random_emcloset"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/closet/emcloset = 9,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/random_piano
	name = "random piano spawner"
	icon_state = "random_piano"
	loot = list(
		/obj/structure/device/broken_piano,
		/obj/structure/device/piano/full,
	)

/obj/effect/spawner/random/structure/status_display
	name = "random status display spawner"
	icon_state = "random_status_display"
	spawn_loot_chance = 95
	loot = list(
		/obj/machinery/status_display,
	)

/obj/effect/spawner/random/structure/random_tank_holder
	name = "random tankholder spawner"
	icon_state = "random_tank_holder"
	loot = list(
		/obj/structure/tankholder,
		/obj/structure/tankholder/oxygen,
		/obj/structure/tankholder/oxygentwo,
		/obj/structure/tankholder/oxygenthree,
		/obj/structure/tankholder/generic,
		/obj/structure/tankholder/extinguisher,
		/obj/structure/tankholder/foamextinguisher,
		/obj/structure/tankholder/anesthetic,
		/obj/structure/tankholder/emergencyoxygen,
		/obj/structure/tankholder/emergencyoxygentwo,
	)

/obj/effect/spawner/random/structure/random_broken_computer
	name = "random broken computer spawner"
	icon_state = "random_broke_computer"
	loot = list(
		/obj/structure/prop/computer/broken = 20,
		/obj/structure/prop/computer/broken/two = 5,
		/obj/structure/prop/computer/broken/three = 20,
		/obj/structure/prop/computer/broken/four = 5,
		/obj/structure/prop/computer/broken/five = 20,
		/obj/structure/prop/computer/broken/six = 20,
		/obj/structure/prop/computer/broken/seven = 1,
		/obj/structure/prop/computer/broken/eight = 50,
		/obj/structure/prop/computer/broken/nine = 40,
	)

/obj/effect/spawner/random/structure/random_broken_computer/genetics
	loot = list(
		/obj/machinery/prop/mainship/computer/dna = 75,
		/obj/effect/spawner/random/structure/random_broken_computer = 25,
	)

/obj/effect/spawner/random/structure/random_broken_computer/crewmonitor
	loot = list(
		/obj/machinery/computer/crew = 65,
		/obj/effect/spawner/random/structure/random_broken_computer = 35,
	)

/obj/effect/spawner/random/structure/random_broken_computer/solars
	loot = list(
		/obj/machinery/computer/solars= 80,
		/obj/effect/spawner/random/structure/random_broken_computer = 20,
	)

/obj/effect/spawner/random/structure/random_broken_computer/rdconsole
	loot = list(
		/obj/machinery/computer/rdconsole = 85,
		/obj/effect/spawner/random/structure/random_broken_computer = 15,
	)

/obj/effect/spawner/random/structure/random_broken_computer/medicalrecords
	loot = list(
		/obj/machinery/computer/med_data = 75,
		/obj/effect/spawner/random/structure/random_broken_computer = 25,
	)

/obj/effect/spawner/random/structure/random_broken_computer/intel
	icon_state = "random_intel_computer"
	loot = list(
		/obj/machinery/computer/intel_computer = 90,
		/obj/effect/spawner/random/structure/random_broken_computer = 10,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small
	icon_state = "random_broke_computer_small"
	loot = list(
		/obj/structure/prop/computer/broken/eleven = 20,
		/obj/structure/prop/computer/broken/fifteen = 5,
		/obj/structure/prop/computer/broken/ten = 20,
		/obj/structure/prop/computer/broken/sixteen = 5,
		/obj/structure/prop/computer/broken/nineteen = 5,
		/obj/structure/prop/computer/broken/fourteen = 20,
		/obj/structure/prop/computer/broken/twelve = 20,
		/obj/structure/prop/computer/broken/seventeen = 1,
		/obj/structure/prop/computer/broken/thirteen = 50,
		/obj/structure/prop/computer/broken/eighteen = 40,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small/meddata
	loot = list(
		/obj/machinery/computer/med_data/laptop = 85,
		/obj/effect/spawner/random/structure/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small/security
	loot = list(
		/obj/machinery/computer/security = 65,
		/obj/effect/spawner/random/structure/random_broken_computer/small = 35,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small/securityrecords
	loot = list(
		/obj/machinery/computer/security = 85,
		/obj/effect/spawner/random/structure/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small/stationalert
	loot = list(
		/obj/machinery/computer/station_alert = 85,
		/obj/effect/spawner/random/structure/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small/atmosalert
	loot = list(
		/obj/machinery/computer/atmos_alert = 85,
		/obj/effect/spawner/random/structure/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/structure/random_broken_computer/small/operatingcomputer
	loot = list(
		/obj/machinery/computer/operating = 85,
		/obj/effect/spawner/random/structure/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/structure/filingcabinet
	name = "filing cabinet or metal spawner"
	icon_state = "random_filingcabinet"
	spawn_loot_chance = 50
	loot = list(
		/obj/item/stack/sheet/metal,
		/obj/structure/filingcabinet,
	)

/obj/effect/spawner/random/structure/photocopier
	name = "filing photocopier or metal spawner"
	icon_state = "random_photocopier"
	spawn_loot_chance = 45
	loot = list(
		/obj/item/stack/sheet/metal,
		/obj/machinery/photocopier,
	)

/obj/effect/spawner/random/structure/filingcabinet/chestdrawer
	icon_state = "random_chestdrawers"
	loot = list(
		/obj/item/stack/sheet/metal,
		/obj/structure/filingcabinet/chestdrawer,
	)

/obj/effect/spawner/random/structure/powergenerator
	name = "generator spawner"
	icon_state = "random_generator"
	spawn_loot_chance = 75
	loot = list(
		/obj/machinery/power/port_gen/pacman = 9,
		/obj/machinery/power/port_gen/pacman/mrs = 1,
	)

/obj/effect/spawner/random/structure/girder
	name = "girder spawner"
	icon_state = "random_girder"
	spawn_loot_chance = 65
	loot = list(
		/obj/structure/girder = 3,
		/obj/structure/girder/displaced = 7,
		/obj/structure/girder/reinforced = 1,
	)

/obj/effect/spawner/random/structure/crate
	name = "crate spawner"
	icon_state = "random_crate"
	spawn_loot_chance = 75
	loot = list(
		/obj/structure/closet/crate,
		/obj/structure/closet/crate/freezer,
		/obj/structure/closet/crate/freezer/rations,
		/obj/structure/closet/crate/hydroponics,
		/obj/structure/closet/crate/hydroponics/prespawned,
		/obj/structure/closet/crate/internals,
		/obj/structure/closet/crate/medical,
		/obj/structure/closet/crate/plastic,
		/obj/structure/closet/crate/radiation,
		/obj/structure/closet/crate/science,
		/obj/structure/closet/crate/solar,
		/obj/structure/closet/crate/trashcart,
	)

/obj/effect/spawner/random/structure/canister
	name = "air canister spawner"
	icon_state = "random_canister"
	loot = list(
		/obj/machinery/portable_atmospherics/canister/air = 4,
		/obj/machinery/portable_atmospherics/canister/oxygen = 1,
	)

/obj/effect/spawner/random/structure/suit_storage
	name = "suit storage spawner"
	icon_state = "random_suit_storage"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/prop/mainship/suit_storage_prop = 9,
		/obj/effect/spawner/random/metal = 1,
	)

/obj/effect/spawner/random/structure/tank_dispenser
	name = "tank dispenser spawner"
	icon_state = "random_dispenser"
	loot = list(
		/obj/structure/dispenser/oxygen,
		/obj/structure/dispenser/phoron,
	)

/obj/effect/spawner/random/structure/tank_dispenser/oxygenweighted
	loot = list(
		/obj/structure/dispenser/oxygen = 8,
		/obj/structure/dispenser/phoron = 2,
	)

/obj/effect/spawner/random/structure/tank_dispenser/phoronweighted
	loot = list(
		/obj/structure/dispenser/phoron = 8,
		/obj/structure/dispenser/oxygen = 2,
	)

/obj/effect/spawner/random/structure/tank
	name = "tank spawner"
	icon_state = "random_watertank"
	loot = list(
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/reagent_dispensers/watertank,
	)

/obj/effect/spawner/random/structure/tank/fuelweighted
	name = "fuel weighted tank spawner"
	icon_state = "random_weldtank"
	loot = list(
		/obj/structure/reagent_dispensers/fueltank = 8,
		/obj/structure/reagent_dispensers/watertank = 2,
	)

/obj/effect/spawner/random/structure/tank/waterweighted
	name = "water weighted tank spawner"
	icon_state = "random_watertank"
	loot = list(
		/obj/structure/reagent_dispensers/fueltank = 3,
		/obj/structure/reagent_dispensers/watertank = 7,
	)

/obj/effect/spawner/random/structure/atmospherics_portable
	name = "portable atmospherics machine spawner"
	icon_state = "random_heater"
	loot = list(
		/obj/machinery/space_heater = 8,
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1,
	)

/obj/effect/spawner/random/structure/table_or_rack
	name = "table or rack spawner"
	icon_state = "random_rack_or_table_spawner"
	loot = list(
		/obj/effect/spawner/random/structure/table,
		/obj/structure/rack,
	)

/obj/effect/spawner/random/structure/table
	name = "table spawner"
	icon_state = "random_table"
	spawn_loot_chance = 75
	loot_subtype_path = /obj/structure/table
	loot = list()

/obj/effect/spawner/random/structure/wooden_table
	name = "wood table spawner"
	icon_state = "random_wood_table"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/table/woodentable = 99,
		/obj/effect/spawner/random/wood = 1,
	)

/obj/effect/spawner/random/structure/broken_reinforced_window
	name = "broken reinforced window spawner"
	icon_state = "random_col_rwindow"
	spawn_loot_chance = 60
	loot = list(
		/obj/structure/window_frame/colony/reinforced/weakened = 9,
		/obj/structure/window/framed/colony/reinforced = 1,
	)

/obj/effect/spawner/random/structure/broken_window
	name = "broken window spawner"
	icon_state = "random_col_window"
	spawn_loot_chance = 50
	loot = list(
		/obj/structure/window_frame/colony = 9,
		/obj/structure/window/framed/colony = 1,
	)

/obj/effect/spawner/random/structure/barrel
	name = "barrel spawner"
	icon_state = "random_barrel"
	loot = list(
		/obj/structure/largecrate/random/barrel/blue = 20,
		/obj/structure/largecrate/random/barrel/green = 20,
		/obj/structure/largecrate/random/barrel/red = 20,
		/obj/structure/largecrate/random/barrel/white = 20,
		/obj/structure/largecrate/random/barrel/yellow = 20,
		/obj/structure/largecrate/random/barrel/red = 10,
		/obj/structure/reagent_dispensers/fueltank/barrel = 1,
	)

/obj/effect/spawner/random/structure/curtain
	name = "curtain spawner"
	icon_state = "random_curtain"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/curtain/temple = 90,
		/obj/structure/curtain/open/temple = 10,
	)

/obj/effect/spawner/random/structure/chair_or_metal //only works for south facing chairs due to lack of proper directional spawning
	name = "chair or metal spawner"
	icon_state = "random_chair"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/chair_or_metal/north //only works for south facing chairs due to lack of proper directional spawning
	name = "chair or metal spawner"
	icon_state = "random_chair_north"
	spawn_loot_chance = 95
	spawn_with_original_direction = TRUE
	loot = list(
		/obj/structure/bed/chair/north = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/chair_or_metal/west //only works for south facing chairs due to lack of proper directional spawning
	name = "chair or metal spawner"
	icon_state = "random_chair_west"
	spawn_loot_chance = 95
	spawn_with_original_direction = TRUE
	loot = list(
		/obj/structure/bed/chair/west = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/chair_or_metal/east //only works for south facing chairs due to lack of proper directional spawning
	name = "chair or metal spawner"
	icon_state = "random_chair_east"
	spawn_loot_chance = 95
	spawn_with_original_direction = TRUE
	loot = list(
		/obj/structure/bed/chair/east = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/light = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/dark //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/dark = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/east //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair_east"
	spawn_with_original_direction = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/light/east = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/dark/east //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair_east"
	spawn_with_original_direction = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/dark/east = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/west //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair_west"
	spawn_with_original_direction = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/light/west = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/dark/west //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair_west"
	spawn_with_original_direction = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/dark/west = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/north //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair_north"
	spawn_with_original_direction = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/light/north = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/office_chair_or_metal/dark/north //only works for south facing chairs due to lack of proper directional spawning
	name = "office chair or metal spawner"
	icon_state = "random_office_chair_north"
	spawn_with_original_direction = TRUE
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/bed/chair/office/dark/north = 10,
		/obj/item/stack/sheet/metal = 1,
	)

/obj/effect/spawner/random/structure/stool //only works for south facing chairs due to lack of proper directional spawning
	name = "stool spawner"
	icon_state = "random_stool"
	spawn_loot_chance = 95
	loot = list()

/obj/effect/spawner/random/structure/machine_frame
	name = "machine frame spawner"
	icon_state = "random_frame"
	spawn_loot_chance = 50
	loot = list(
		/obj/machinery/constructable_frame,
		/obj/machinery/constructable_frame/state_2,
		/obj/structure/prop/machine_frame3,
		/obj/structure/computer3frame,
		/obj/item/frame/rack,
	)

/obj/effect/spawner/random/structure/broken_ship_window
	name = "broken ship window spawner"
	icon_state = "random_ship_window"
	spawn_loot_chance = 80
	loot = list(
		/obj/structure/window_frame/mainship = 10,
		/obj/structure/window/framed/mainship = 1,
	)

/obj/effect/spawner/random/structure/directional_window
	icon_state = "random_rwindow"
	spawn_loot_chance = 95
	loot = list(
		/obj/structure/window/reinforced = 35,
		/obj/effect/spawner/random/shard = 1,
	)

/obj/effect/spawner/random/structure/directional_window/north
	icon_state = "random_rwindow_north"
	spawn_with_original_direction = TRUE
	loot = list(
		/obj/structure/window/reinforced/north = 35,
		/obj/effect/spawner/random/shard = 1,
	)

/obj/effect/spawner/random/structure/directional_window/east
	icon_state = "random_rwindow_east"
	spawn_with_original_direction = TRUE
	loot = list(
		/obj/structure/window/reinforced/east = 35,
		/obj/effect/spawner/random/shard = 1,
	)

/obj/effect/spawner/random/structure/directional_window/west
	icon_state = "random_rwindow_west"
	spawn_with_original_direction = TRUE
	loot = list(
		/obj/structure/window/reinforced/west = 35,
		/obj/effect/spawner/random/shard = 1,
	)

/obj/effect/spawner/random/structure/dead_ai
	name = "dead ai spawner"
	icon_state = "random_dead_ai"
	spawn_loot_chance = 15
	loot = list(
		/obj/structure/prop/mainship/deadai,
	)

/obj/effect/spawner/random/structure/cryo
	name = "cryo spawner"
	icon_state = "random_cryo"
	spawn_loot_chance = 45
	loot = list(
		/obj/machinery/atmospherics/components/unary/cryo_cell = 7,
		/obj/effect/spawner/random/structure/machine_frame = 2,
		/obj/effect/spawner/random/metal = 1,
	)

/obj/effect/spawner/random/structure/disposal
	name = "disposal spawner"
	icon_state = "random_disposal"
	spawn_loot_chance = 90
	loot = list(
		/obj/machinery/disposal = 9,
		/obj/item/stack/sheet/metal = 1,
		/obj/effect/spawner/random/metal = 1,
	)

/obj/effect/spawner/random/structure/hydrotray
	name = "hydro tray spawner"
	icon_state = "random_hydrotray"
	spawn_loot_chance = 65
	loot = list(
		/obj/machinery/portable_atmospherics/hydroponics/slashable = 8,
		/obj/effect/spawner/random/seeds = 1,
		/obj/effect/spawner/random/structure/machine_frame = 1,
	)

/obj/effect/spawner/random/structure/microwave
	name = "microwave spawner"
	icon_state = "random_microwave"
	spawn_loot_chance = 85
	loot = list(
		/obj/machinery/microwave = 8,
		/obj/effect/spawner/random/outdoors_snacks = 2,
	)

/obj/effect/spawner/random/structure/rollerbed
	name = "rollerbed spawner"
	icon_state = "random_rollerbed"
	spawn_loot_chance = 85
	spawn_scatter_radius = 1
	loot = list(
		/obj/structure/bed/roller = 90,
		/obj/effect/spawner/random/decal/blood = 9,
		/obj/structure/bed/medevac_stretcher = 1,
	)

/obj/effect/spawner/random/structure/ivdrip
	name = "iv drip spawner"
	icon_state = "random_ivdrip"
	spawn_loot_chance = 50
	loot = list(
		/obj/machinery/iv_drip = 90,
		/obj/effect/spawner/random/decal/blood = 9,
		/obj/structure/bed/medevac_stretcher = 1,
	)

//RANDOM EFFECTS AND DECALS

/obj/effect/spawner/random/decal/blood
	name = "random blood spawner"
	icon_state = "random_blood_splatter"
	spawn_loot_chance = 85
	spawn_scatter_radius = 1
	loot = list(
		/obj/effect/decal/cleanable/blood,
	)

/obj/effect/spawner/random/decal/out_of_bounds
	name = "random out of bounds spawner"
	icon_state = "random_oob"
	spawn_scatter_radius = 1
	spawn_loot_count = 3
	loot = list(
		/obj/effect/step_trigger/teleporter/random = 7,
		/obj/effect/spawner/random/decal/out_of_bounds/rangetwo = 3,
	)

/obj/effect/spawner/random/decal/out_of_bounds/rangetwo
	spawn_scatter_radius = 2
	spawn_loot_count = 6
