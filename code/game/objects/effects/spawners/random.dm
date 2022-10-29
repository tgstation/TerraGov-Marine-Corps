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


/// this function should return a specific item to spawn
/obj/effect/spawner/random/proc/item_to_spawn()
	return null


/// creates the random item
/obj/effect/spawner/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return (new build_path(src.loc))


/obj/effect/spawner/random/tool
	name = "Random Tool"
	icon_state = "random_tool"

/obj/effect/spawner/random/tool/item_to_spawn()
	return pick(/obj/item/tool/screwdriver,\
				/obj/item/tool/wirecutters,\
				/obj/item/tool/weldingtool,\
				/obj/item/tool/crowbar,\
				/obj/item/tool/wrench,\
				/obj/item/flashlight)


/obj/effect/spawner/random/technology_scanner
	name = "Random Scanner"
	desc = "This is a random technology scanner."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "atmos"

/obj/effect/spawner/random/technology_scanner/item_to_spawn()
		return pick(prob(5);/obj/item/t_scanner,\
					prob(2);/obj/item/radio,\
					prob(5);/obj/item/analyzer)


/obj/effect/spawner/random/powercell
	name = "Random Powercell"
	icon_state = "random_cell"

/obj/effect/spawner/random/powercell/item_to_spawn()
		return pick(prob(10);/obj/item/cell/crap,\
					prob(40);/obj/item/cell,\
					prob(40);/obj/item/cell/high,\
					prob(9);/obj/item/cell/super,\
					prob(1);/obj/item/cell/hyper)


/obj/effect/spawner/random/bomb_supply
	name = "Bomb Supply"
	icon_state = "random_scanner"

/obj/effect/spawner/random/bomb_supply/item_to_spawn()
		return pick(/obj/item/assembly/igniter,\
					/obj/item/assembly/prox_sensor,\
					/obj/item/assembly/signaler,\
					/obj/item/multitool)


/obj/effect/spawner/random/toolbox
	name = "Random Toolbox"
	icon_state = "random_toolbox"

/obj/effect/spawner/random/toolbox/item_to_spawn()
		return pick(prob(3);/obj/item/storage/toolbox/mechanical,\
					prob(2);/obj/item/storage/toolbox/electrical,\
					prob(1);/obj/item/storage/toolbox/emergency)


/obj/effect/spawner/random/tech_supply
	name = "Random Tech Supply"
	icon_state = "random_cell"
	spawn_nothing_percentage = 50

/obj/effect/spawner/random/tech_supply/item_to_spawn()
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

/obj/effect/spawner/random/drink_cans/item_to_spawn()
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

/obj/effect/spawner/random/drink_alcohol_bottle/item_to_spawn()
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

/obj/effect/spawner/random/sugary_snack/item_to_spawn()
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

/obj/effect/spawner/random/outdoors_snacks/item_to_spawn()
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

/obj/effect/spawner/random/trash/item_to_spawn()
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

///random civilian clothing for flavor
/obj/effect/spawner/random/clothing
	name = "Random clothing spawner"
	icon_state = "random_clothes"

/obj/effect/spawner/random/clothing/item_to_spawn()
		return pick(/obj/item/clothing/suit/bio_suit,\
					/obj/item/clothing/suit/bomber,\
					/obj/item/clothing/suit/ianshirt,\
					/obj/item/clothing/suit/radiation,\
					/obj/item/clothing/suit/space,\
					/obj/item/clothing/suit/space/rig/mining,\
					/obj/item/clothing/suit/storage/hazardvest,\
					/obj/item/clothing/suit/storage/hazardvest/lime,\
					/obj/item/clothing/suit/storage/hazardvest/blue,\
					/obj/item/clothing/suit/storage/labcoat,\
					/obj/item/clothing/suit/wcoat,\
					/obj/item/clothing/under/colonist,\
					/obj/item/clothing/under/color/black,\
					/obj/item/clothing/under/color/blackf,\
					/obj/item/clothing/under/darkred,\
					/obj/item/clothing/under/darkblue,\
					/obj/item/clothing/under/gentlesuit,\
					/obj/item/clothing/under/lawyer/female,\
					/obj/item/clothing/under/liaison_suit,\
					/obj/item/clothing/under/liaison_suit/formal,\
					/obj/item/clothing/under/pj/blue,\
					/obj/item/clothing/under/rank/cargo,\
					/obj/item/clothing/under/rank/cargotech,\
					/obj/item/clothing/under/rank/chaplain,\
					/obj/item/clothing/under/rank/det,\
					/obj/item/clothing/under/rank/engineer,\
					/obj/item/clothing/under/rank/head_of_security/alt,\
					/obj/item/clothing/under/rank/medical,\
					/obj/item/clothing/under/rank/prisoner,\
					/obj/item/clothing/under/rank/research_director/rdalt,\
					/obj/item/clothing/under/rank/ro_suit,\
					/obj/item/clothing/under/suit_jacket,\
					/obj/item/clothing/under/suit_jacket/charcoal,\
					/obj/item/clothing/under/swimsuit,\
					/obj/item/clothing/under/rank/miner)


///random civilian hats for flavor
/obj/effect/spawner/random/hats
	name = "Random hat spawner"
	icon_state = "random_hat"

/obj/effect/spawner/random/hats/item_to_spawn()
		return pick(/obj/item/clothing/head/bandanna/red,\
					/obj/item/clothing/head/beret,\
					/obj/item/clothing/head/bomb_hood/security,\
					/obj/item/clothing/head/boonie,\
					/obj/item/clothing/head/bowler,\
					/obj/item/clothing/head/bowlerhat,\
					/obj/item/clothing/head/chaplain_hood,\
					/obj/item/clothing/head/collectable/hardhat,\
					/obj/item/clothing/head/collectable/HoS,\
					/obj/item/clothing/head/collectable/rabbitears,\
					/obj/item/clothing/head/collectable/tophat,\
					/obj/item/clothing/head/collectable/welding,\
					/obj/item/clothing/head/det_hat,\
					/obj/item/clothing/head/det_hat/black,\
					/obj/item/clothing/head/hardhat,\
					/obj/item/clothing/head/hardhat/red,\
					/obj/item/clothing/head/hardhat/white,\
					/obj/item/clothing/head/headband,\
					/obj/item/clothing/head/headband/rambo,\
					/obj/item/clothing/head/headband/red,\
					/obj/item/clothing/head/headband/snake,\
					/obj/item/clothing/head/helmet,\
					/obj/item/clothing/head/helmet/durag/jungle,\
					/obj/item/clothing/head/helmet/gladiator,\
					/obj/item/clothing/head/helmet/space,\
					/obj/item/clothing/head/helmet/space/rig,\
					/obj/item/clothing/head/helmet/space/syndicate,\
					/obj/item/clothing/under/rank/head_of_security/alt,\
					/obj/item/clothing/head/powdered_wig,\
					/obj/item/clothing/head/radiation,\
					/obj/item/clothing/head/soft,\
					/obj/item/clothing/head/soft/red,\
					/obj/item/clothing/head/strawhat,\
					/obj/item/clothing/head/warning_cone,\
					/obj/item/clothing/head/collectable/paper,\
					/obj/item/clothing/head/helmet/riot
					/obj/item/clothing/head/collectable/kitty)


///random kitchen items
/obj/effect/spawner/random/kitchen
	name = "Random kitchen utensil spawner"
	icon_state = "random_utensil"

/obj/effect/spawner/random/kitchen/item_to_spawn()
		return pick(/obj/item/tool/kitchen/utensil/fork,\
					/obj/item/tool/kitchen/utensil/pfork,\
					/obj/item/tool/kitchen/utensil/spoon,\
					/obj/item/tool/kitchen/utensil/pspoon,\
					/obj/item/tool/kitchen/utensil/knife,\
					/obj/item/tool/kitchen/utensil/pknife,\
					/obj/item/tool/kitchen/rollingpin,\
					/obj/item/tool/kitchen/tray)

///random medical items
/obj/effect/spawner/random/pillbottle
	name = "Random pill bottle spawner"
	icon_state = "random_medicine"

/obj/effect/spawner/random/pillbottle/item_to_spawn()
		return pick(/obj/item/storage/pill_bottle/alkysine,\
					/obj/item/storage/pill_bottle/imidazoline,\
					/obj/item/storage/pill_bottle/bicaridine,\
					/obj/item/storage/pill_bottle/kelotane,\
					/obj/item/storage/pill_bottle/tramadol,\
					/obj/item/storage/pill_bottle/inaprovaline,\
					/obj/item/storage/pill_bottle/dylovene,\
					/obj/item/storage/pill_bottle/spaceacillin)

/obj/effect/spawner/random/surgical
	name = "Random surgical instrument spawner"
	icon_state = "random_surgical"

/obj/effect/spawner/random/surgical/item_to_spawn()
		return pick(/obj/item/tool/surgery/scalpel/manager,\
					/obj/item/tool/surgery/scalpel,\
					/obj/item/tool/surgery/hemostat,\
					/obj/item/tool/surgery/retractor,\
					/obj/item/stack/medical/heal_pack/advanced/bruise_pack,\
					/obj/item/tool/surgery/cautery,\
					/obj/item/tool/surgery/circular_saw,\
					/obj/item/tool/surgery/suture,\
					/obj/item/tool/surgery/bonegel,\
					/obj/item/tool/surgery/bonesetter,\
					/obj/item/tool/surgery/FixOVein,\
					/obj/item/stack/nanopaste)

/obj/effect/spawner/random/organ
	name = "Random surgical organ spawner"
	icon_state = "random_organ"

/obj/effect/spawner/random/organ/item_to_spawn()
		return pick(/obj/item/prop/organ/brain,\
					/obj/item/prop/organ/heart,\
					/obj/item/prop/organ/lungs,\
					/obj/item/prop/organ/kidneys,\
					/obj/item/prop/organ/eyes,\
					/obj/item/prop/organ/liver,\
					/obj/item/prop/organ/appendix)

///random cables
/obj/effect/spawner/random/cable
	name = "Random cable spawner"
	icon_state = "random_cable"

/obj/effect/spawner/random/cable/item_to_spawn()
		return pick(/obj/item/stack/cable_coil,\
					/obj/item/stack/cable_coil/cut,\
					/obj/item/stack/cable_coil/five,\
					/obj/item/stack/cable_coil/twentyfive)


///BALLISTIC WEAPONS///

///random guns
/obj/effect/spawner/random/gun //restricted to ballistic weapons available on the ship, no auto-9s here
	name = "Random ballistic ammunition spawner"
	icon_state = "random_rifle"

/obj/effect/spawner/random/gun/item_to_spawn()
		return pick(/obj/item/weapon/gun/rifle/standard_assaultrifle,\
					/obj/item/weapon/gun/rifle/standard_carbine,\
					/obj/item/weapon/gun/rifle/standard_skirmishrifle,\
					/obj/item/weapon/gun/rifle/tx11/scopeless,\
					/obj/item/weapon/gun/smg/standard_smg,\
					/obj/item/weapon/gun/smg/standard_machinepistol,\
					/obj/item/weapon/gun/rifle/standard_dmr,\
					/obj/item/weapon/gun/rifle/standard_br,\
					/obj/item/weapon/gun/rifle/chambered,\
					/obj/item/weapon/gun/shotgun/pump/bolt/unscoped,\
					/obj/item/weapon/gun/shotgun/double/martini,\
					/obj/item/weapon/gun/pistol/standard_pistol,\
					/obj/item/weapon/gun/pistol/standard_heavypistol,\
					/obj/item/weapon/gun/revolver/standard_revolver,\
					/obj/item/weapon/gun/pistol/standard_pocketpistol,\
					/obj/item/weapon/gun/pistol/vp70,\
					/obj/item/weapon/gun/pistol/plasma_pistol,\
					/obj/item/weapon/gun/shotgun/double/derringer,\
					/obj/item/weapon/gun/rifle/pepperball,\
					/obj/item/weapon/gun/shotgun/pump/lever/repeater,\
					/obj/item/weapon/gun/shotgun/double/marine,\
					/obj/item/weapon/gun/rifle/standard_autoshotgun,\
					/obj/item/weapon/gun/shotgun/combat/standardmarine)


///random shotguns
/obj/effect/spawner/random/gun/shotgun
	name = "Random shotgun spawner"
	icon_state = "random_shotgun"

/obj/effect/spawner/random/gun/shotgun/item_to_spawn()
		return pick(/obj/item/weapon/gun/shotgun/pump/lever/repeater,\
					/obj/item/weapon/gun/shotgun/pump/bolt/unscoped,\
					/obj/item/weapon/gun/shotgun/pump/cmb,\
					/obj/item/weapon/gun/shotgun/double/marine,\
					/obj/item/weapon/gun/rifle/standard_autoshotgun,\
					/obj/item/weapon/gun/shotgun/combat/standardmarine,\
					/obj/item/weapon/gun/shotgun/pump/t35)


///random machineguns
/obj/effect/spawner/random/gun/machineguns
	name = "Random machinegun spawner"
	icon_state = "random_machinegun"

/obj/effect/spawner/random/gun/machineguns/item_to_spawn()
		return pick(/obj/item/weapon/gun/rifle/standard_lmg,\
					/obj/item/weapon/gun/rifle/standard_gpmg,\
					/obj/item/weapon/gun/standard_mmg)


///random rifles
/obj/effect/spawner/random/gun/rifles
	name = "Random rifle spawner"
	icon_state = "random_rifle"

/obj/effect/spawner/random/gun/rifles/item_to_spawn()
		return pick(/obj/item/weapon/gun/rifle/standard_assaultrifle,\
					/obj/item/weapon/gun/rifle/standard_carbine,\
					/obj/item/weapon/gun/rifle/standard_skirmishrifle,\
					/obj/item/weapon/gun/rifle/tx11/scopeless)


///random sidearms
/obj/effect/spawner/random/gun/sidearms
	name = "Random sidearm spawner"
	icon_state = "random_sidearm"

/obj/effect/spawner/random/gun/sidearms/item_to_spawn()
		return pick(/obj/item/weapon/gun/pistol/standard_pistol,\
					/obj/item/weapon/gun/pistol/standard_heavypistol,\
					/obj/item/weapon/gun/revolver/standard_revolver,\
					/obj/item/weapon/gun/revolver/cmb,\
					/obj/item/weapon/gun/pistol/vp70,\
					/obj/item/weapon/gun/pistol/standard_pocketpistol)


///random melee weapons
/obj/effect/spawner/random/melee
	name = "Random melee weapons spawner"
	icon_state = "random_melee"

/obj/effect/spawner/random/melee/item_to_spawn()
		return pick(/obj/item/weapon/claymore/mercsword/machete,\
					/obj/item/weapon/combat_knife,\
					/obj/item/attachable/bayonetknife,\
					/obj/item/weapon/baseballbat,\
					/obj/item/weapon/baseballbat/metal,\
					/obj/item/weapon/broken_bottle,\
					/obj/item/tool/hatchet,\
					/obj/item/tool/kitchen/knife,\
					/obj/item/tool/kitchen/knife/butcher,\
					/obj/item/weapon/twohanded/fireaxe)


///BALLISTIC WEAPON AMMO///

///random ammunition
/obj/effect/spawner/random/ammo
	name = "Random ballistic ammunition spawner"
	icon_state = "random_ammo"

/obj/effect/spawner/random/ammo/item_to_spawn()
		return pick(/obj/item/ammo_magazine/rifle/standard_assaultrifle,\
					/obj/item/ammo_magazine/rifle/standard_carbine,\
					/obj/item/ammo_magazine/rifle/standard_skirmishrifle,\
					/obj/item/ammo_magazine/rifle/tx11,\
					/obj/item/ammo_magazine/smg/standard_smg,\
					/obj/item/ammo_magazine/smg/standard_machinepistol,\
					/obj/item/ammo_magazine/rifle/standard_dmr,\
					/obj/item/ammo_magazine/rifle/standard_br,\
					/obj/item/ammo_magazine/rifle/chamberedrifle,\
					/obj/item/ammo_magazine/rifle/bolt,\
					/obj/item/ammo_magazine/rifle/martini,\
					/obj/item/ammo_magazine/pistol/standard_pistol,\
					/obj/item/ammo_magazine/pistol/standard_heavypistol,\
					/obj/item/ammo_magazine/revolver/standard_revolver,\
					/obj/item/ammo_magazine/pistol/standard_pocketpistol,\
					/obj/item/ammo_magazine/pistol/vp70,\
					/obj/item/ammo_magazine/pistol/plasma_pistol,\
					/obj/item/ammo_magazine/pistol/derringer,\
					/obj/item/ammo_magazine/rifle/pepperball,\
					/obj/item/ammo_magazine/shotgun/flechette,\
					/obj/item/ammo_magazine/rifle/tx15_slug)


///for specific ranged weapon ammo spawners we don't spawn anything that marines couldn't get back on their ship

///random shotgun ammunition
/obj/effect/spawner/random/ammo/shotgun
	name = "Random shotgun ammunition spawner"
	icon_state = "random_shotgun_ammo"

/obj/effect/spawner/random/ammo/shotgun/item_to_spawn()
		return pick(/obj/item/ammo_magazine/shotgun/buckshot,\
					/obj/item/ammo_magazine/shotgun/flechette)


///random machinegun ammunition
/obj/effect/spawner/random/ammo/machinegun
	name = "Random machinegun ammunition spawner"
	icon_state = "random_machinegun_ammo"

/obj/effect/spawner/random/ammo/machinegun/item_to_spawn()
		return pick(/obj/item/ammo_magazine/standard_lmg,\
					/obj/item/ammo_magazine/standard_gpmg,\
					/obj/item/ammo_magazine/standard_mmg,\
					/obj/item/ammo_magazine/heavymachinegun)


///random rifle ammunition
/obj/effect/spawner/random/ammo/rifle
	name = "Random rifle ammunition spawner"
	icon_state = "random_rifle_ammo"

/obj/effect/spawner/random/ammo/rifle/item_to_spawn()
		return pick(/obj/item/ammo_magazine/rifle/standard_assaultrifle,\
					/obj/item/ammo_magazine/rifle/standard_carbine,\
					/obj/item/ammo_magazine/rifle/standard_skirmishrifle,\
					/obj/item/ammo_magazine/rifle/tx11)


///random sidearm ammunition
/obj/effect/spawner/random/ammo/sidearm
	name = "Random sidearm ammunition spawner"
	icon_state = "random_sidearm_ammo"

/obj/effect/spawner/random/ammo/sidearm/item_to_spawn()
		return pick(/obj/item/ammo_magazine/pistol/standard_pistol,\
					/obj/item/ammo_magazine/pistol/standard_heavypistol,\
					/obj/item/ammo_magazine/revolver/standard_revolver,\
					/obj/item/ammo_magazine/pistol/vp70,\
					/obj/item/ammo_magazine/pistol/derringer,\
					/obj/item/ammo_magazine/revolver/cmb,\
					/obj/item/ammo_magazine/pistol/standard_pocketpistol)


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
	spawn_nothing_percentage = 85

/obj/effect/spawner/random/plushie/fiftyfifty

/obj/effect/spawner/random/plushie/nospawnninety
	spawn_nothing_percentage = 90

/obj/effect/spawner/random/plushie/nospawnninetyfive
	spawn_nothing_percentage = 95

/obj/effect/spawner/random/plushie/nospawnninetynine
	spawn_nothing_percentage = 99

/obj/effect/spawner/random/plushie/item_to_spawn()
		return pick(/obj/item/toy/plush/moth,\
					/obj/item/toy/plush/rouny,\
					/obj/item/toy/plush/therapy_blue,\
					/obj/item/toy/plush/therapy_green,\
					/obj/item/toy/plush/therapy_yellow,\
					/obj/item/toy/plush/therapy_orange,\
					/obj/item/toy/plush/therapy_red,\
					/obj/item/toy/plush/therapy_purple)
