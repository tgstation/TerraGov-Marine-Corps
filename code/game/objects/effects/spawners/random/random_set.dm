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
/obj/effect/spawner/random_set/Initialize(mapload)
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
	icon = 'icons/effects/random/weaponry.dmi'
	icon_state = "random_rifle"

	option_list = list(
		list(/obj/item/weapon/gun/rifle/standard_assaultrifle,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		),
		list(/obj/item/weapon/gun/rifle/standard_carbine,
			/obj/item/ammo_magazine/rifle/standard_carbine,
			/obj/item/ammo_magazine/rifle/standard_carbine,
			/obj/item/ammo_magazine/rifle/standard_carbine,
		),
		list(/obj/item/weapon/gun/rifle/standard_skirmishrifle,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
		),
		list(/obj/item/weapon/gun/rifle/tx11/scopeless,
			/obj/item/ammo_magazine/rifle/tx11,
			/obj/item/ammo_magazine/rifle/tx11,
			/obj/item/ammo_magazine/rifle/tx11,
		),
		list(/obj/item/weapon/gun/smg/standard_smg,
			/obj/item/ammo_magazine/smg/standard_smg,
			/obj/item/ammo_magazine/smg/standard_smg,
			/obj/item/ammo_magazine/smg/standard_smg,
		),
		list(/obj/item/weapon/gun/smg/standard_machinepistol,
			/obj/item/ammo_magazine/smg/standard_machinepistol,
			/obj/item/ammo_magazine/smg/standard_machinepistol,
			/obj/item/ammo_magazine/smg/standard_machinepistol,
		),
		list(/obj/item/weapon/gun/rifle/standard_dmr,
			/obj/item/ammo_magazine/rifle/standard_dmr,
			/obj/item/ammo_magazine/rifle/standard_dmr,
			/obj/item/ammo_magazine/rifle/standard_dmr,
		),
		list(/obj/item/weapon/gun/rifle/standard_br,
			/obj/item/ammo_magazine/rifle/standard_br,
			/obj/item/ammo_magazine/rifle/standard_br,
			/obj/item/ammo_magazine/rifle/standard_br,
		),
		list(/obj/item/weapon/gun/rifle/chambered,
			/obj/item/ammo_magazine/rifle/chamberedrifle,
			/obj/item/ammo_magazine/rifle/chamberedrifle,
			/obj/item/ammo_magazine/rifle/chamberedrifle,
		),
		list(/obj/item/weapon/gun/shotgun/pump/bolt/unscoped,
			/obj/item/ammo_magazine/rifle/bolt,
			/obj/item/ammo_magazine/rifle/bolt,
			/obj/item/ammo_magazine/rifle/bolt,
		),
		list(/obj/item/weapon/gun/shotgun/double/martini,
			/obj/item/ammo_magazine/rifle/martini,
			/obj/item/ammo_magazine/rifle/martini,
			/obj/item/ammo_magazine/rifle/martini,
		),
		list(/obj/item/weapon/gun/pistol/standard_pistol,
			/obj/item/ammo_magazine/pistol/standard_pistol,
			/obj/item/ammo_magazine/pistol/standard_pistol,
			/obj/item/ammo_magazine/pistol/standard_pistol,
		),
		list(/obj/item/weapon/gun/pistol/standard_heavypistol,
			/obj/item/ammo_magazine/pistol/standard_heavypistol,
			/obj/item/ammo_magazine/pistol/standard_heavypistol,
			/obj/item/ammo_magazine/pistol/standard_heavypistol,
		),
		list(/obj/item/weapon/gun/revolver/standard_revolver,
			/obj/item/ammo_magazine/revolver/standard_revolver,
			/obj/item/ammo_magazine/revolver/standard_revolver,
			/obj/item/ammo_magazine/revolver/standard_revolver,
		),
		list(/obj/item/weapon/gun/pistol/standard_pocketpistol,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol,
			/obj/item/ammo_magazine/pistol/standard_pocketpistol,
		),
		list(/obj/item/weapon/gun/pistol/vp70,
			/obj/item/ammo_magazine/pistol/vp70,
			/obj/item/ammo_magazine/pistol/vp70,
			/obj/item/ammo_magazine/pistol/vp70,
		),
		list(/obj/item/weapon/gun/pistol/plasma_pistol,
			/obj/item/ammo_magazine/pistol/plasma_pistol,
			/obj/item/ammo_magazine/pistol/plasma_pistol,
			/obj/item/ammo_magazine/pistol/plasma_pistol,
		),
		list(/obj/item/weapon/gun/shotgun/double/derringer,
			/obj/item/ammo_magazine/pistol/derringer,
			/obj/item/ammo_magazine/pistol/derringer,
			/obj/item/ammo_magazine/pistol/derringer,
		),
		list(/obj/item/weapon/gun/rifle/pepperball,
			/obj/item/ammo_magazine/rifle/pepperball,
			/obj/item/ammo_magazine/rifle/pepperball,
			/obj/item/ammo_magazine/rifle/pepperball,
		),
		list(/obj/item/weapon/gun/shotgun/pump/lever/repeater,
			/obj/item/ammo_magazine/packet/p4570,
			/obj/item/ammo_magazine/packet/p4570,
			/obj/item/ammo_magazine/packet/p4570,
		),
		list(/obj/item/weapon/gun/shotgun/double/marine,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
		),
		list(/obj/item/weapon/gun/rifle/standard_autoshotgun,
			/obj/item/ammo_magazine/rifle/tx15_slug,
			/obj/item/ammo_magazine/rifle/tx15_slug,
			/obj/item/ammo_magazine/rifle/tx15_slug,
		),
		list(/obj/item/weapon/gun/shotgun/combat/standardmarine,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
		),
	)

//random rifles
/obj/effect/spawner/random_set/rifle
	name = "Random rifle set spawner"
	icon = 'icons/effects/random/weaponry.dmi'
	icon_state = "random_rifle"

	option_list = list(
		list(/obj/item/weapon/gun/rifle/standard_assaultrifle,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle,
			/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		),
		list(/obj/item/weapon/gun/rifle/standard_carbine,
			/obj/item/ammo_magazine/rifle/standard_carbine,
			/obj/item/ammo_magazine/rifle/standard_carbine,
			/obj/item/ammo_magazine/rifle/standard_carbine,
		),
		list(/obj/item/weapon/gun/rifle/standard_skirmishrifle,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
			/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
		),
		list(/obj/item/weapon/gun/rifle/tx11/scopeless,
			/obj/item/ammo_magazine/rifle/tx11,
			/obj/item/ammo_magazine/rifle/tx11,
			/obj/item/ammo_magazine/rifle/tx11,
		),
	)

//random shotguns
/obj/effect/spawner/random_set/shotgun
	name = "Random shotgun set spawner"
	icon = 'icons/effects/random/weaponry.dmi'
	icon_state = "random_shotgun"

	option_list = list(
		list(/obj/item/weapon/gun/shotgun/pump/bolt/unscoped,
			/obj/item/ammo_magazine/rifle/bolt,
			/obj/item/ammo_magazine/rifle/bolt,
			/obj/item/ammo_magazine/rifle/bolt,
		),
		list(/obj/item/weapon/gun/shotgun/double/marine,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
		),
		list(/obj/item/weapon/gun/rifle/standard_autoshotgun,
			/obj/item/ammo_magazine/rifle/tx15_slug,
			/obj/item/ammo_magazine/rifle/tx15_slug,
			/obj/item/ammo_magazine/rifle/tx15_slug,
		),
		list(/obj/item/weapon/gun/shotgun/combat/standardmarine,
			/obj/item/ammo_magazine/shotgun/flechette,
			/obj/item/ammo_magazine/shotgun/flechette,
			/obj/item/ammo_magazine/shotgun/flechette,
		),
		list(/obj/item/weapon/gun/shotgun/pump/t35,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
		),
		list(/obj/item/weapon/gun/shotgun/pump/cmb,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
			/obj/item/ammo_magazine/shotgun/buckshot,
		),
	)

//random machineguns
/obj/effect/spawner/random_set/machineguns
	name = "Random machinegun set spawner"
	icon = 'icons/effects/random/weaponry.dmi'
	icon_state = "random_machinegun"

	option_list = list(
		list(/obj/item/weapon/gun/rifle/standard_gpmg,
			/obj/item/ammo_magazine/standard_gpmg,
			/obj/item/ammo_magazine/standard_gpmg,
			/obj/item/ammo_magazine/standard_gpmg,
		),
		list(/obj/item/weapon/gun/standard_mmg,
			/obj/item/ammo_magazine/standard_mmg,
			/obj/item/ammo_magazine/standard_mmg,
			/obj/item/ammo_magazine/standard_mmg,
		),
	)

//random sidearms
/obj/effect/spawner/random_set/sidearms
	name = "Random sidearm set spawner"
	icon = 'icons/effects/random/weaponry.dmi'
	icon_state = "random_sidearm"

	option_list = list(
		list(/obj/item/weapon/gun/pistol/standard_pistol,
			/obj/item/ammo_magazine/pistol/standard_pistol,
			/obj/item/ammo_magazine/pistol/standard_pistol,
			/obj/item/ammo_magazine/pistol/standard_pistol,
		),
		list(/obj/item/weapon/gun/pistol/standard_heavypistol,
			/obj/item/ammo_magazine/pistol/standard_heavypistol,
			/obj/item/ammo_magazine/pistol/standard_heavypistol,
			/obj/item/ammo_magazine/pistol/standard_heavypistol,
		),
		list(/obj/item/weapon/gun/revolver/standard_revolver,
			/obj/item/ammo_magazine/revolver/standard_revolver,
			/obj/item/ammo_magazine/revolver/standard_revolver,
			/obj/item/ammo_magazine/revolver/standard_revolver,
		),
		list(/obj/item/weapon/gun/revolver/cmb, /obj/item/ammo_magazine/revolver/cmb, /obj/item/ammo_magazine/revolver/cmb, /obj/item/ammo_magazine/revolver/cmb,),
		list(/obj/item/weapon/gun/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol, /obj/item/ammo_magazine/pistol/standard_pocketpistol,),
		list(/obj/item/weapon/gun/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70, /obj/item/ammo_magazine/pistol/vp70,),
	)
