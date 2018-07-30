/obj/effect/spawner/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start"
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything


// creates a new object and deletes itself
/obj/effect/spawner/random/New()
	..()
	if (!prob(spawn_nothing_percentage))
		spawn_item()
	cdel(src)


// this function should return a specific item to spawn
/obj/effect/spawner/random/proc/item_to_spawn()
	return 0


// creates the random item
/obj/effect/spawner/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return (new build_path(src.loc))


/obj/effect/spawner/random/tool
	name = "Random Tool"
	desc = "This is a random tool"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "welder"
	item_to_spawn()
		return pick(/obj/item/tool/screwdriver,\
					/obj/item/tool/wirecutters,\
					/obj/item/tool/weldingtool,\
					/obj/item/tool/crowbar,\
					/obj/item/tool/wrench,\
					/obj/item/device/flashlight)


/obj/effect/spawner/random/technology_scanner
	name = "Random Scanner"
	desc = "This is a random technology scanner."
	icon = 'icons/obj/items/devices.dmi'
	icon_state = "atmos"
	item_to_spawn()
		return pick(prob(5);/obj/item/device/t_scanner,\
					prob(2);/obj/item/device/radio,\
					prob(5);/obj/item/device/analyzer)


/obj/effect/spawner/random/powercell
	name = "Random Powercell"
	desc = "This is a random powercell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_to_spawn()
		return pick(prob(10);/obj/item/cell/crap,\
					prob(40);/obj/item/cell,\
					prob(40);/obj/item/cell/high,\
					prob(9);/obj/item/cell/super,\
					prob(1);/obj/item/cell/hyper)


/obj/effect/spawner/random/bomb_supply
	name = "Bomb Supply"
	desc = "This is a random bomb supply."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"
	item_to_spawn()
		return pick(/obj/item/device/assembly/igniter,\
					/obj/item/device/assembly/prox_sensor,\
					/obj/item/device/assembly/signaler,\
					/obj/item/device/multitool)


/obj/effect/spawner/random/toolbox
	name = "Random Toolbox"
	desc = "This is a random toolbox."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "red"
	item_to_spawn()
		return pick(prob(3);/obj/item/storage/toolbox/mechanical,\
					prob(2);/obj/item/storage/toolbox/electrical,\
					prob(1);/obj/item/storage/toolbox/emergency)


/obj/effect/spawner/random/tech_supply
	name = "Random Tech Supply"
	desc = "This is a random piece of technology supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
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