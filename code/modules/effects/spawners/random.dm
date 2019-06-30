/obj/effect/spawner/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything


// creates a new object and deletes itself
/obj/effect/spawner/random/New()
	..()
	if (!prob(spawn_nothing_percentage))
		spawn_item()
	qdel(src)


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