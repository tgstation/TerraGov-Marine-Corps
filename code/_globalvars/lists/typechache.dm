//please store common type caches here.
//type caches should only be stored here if used in mutiple places or likely to be used in mutiple places.

//Note: typecache can only replace istype if you know for sure the thing is at least a datum.

GLOBAL_LIST_INIT(typecache_mob, typecacheof(/mob))

GLOBAL_LIST_INIT(typecache_living, typecacheof(/mob/living))

GLOBAL_LIST_INIT(ignored_atoms, typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /obj/effect/particle_effect/sparks, /obj/effect/DPtarget, /obj/effect/supplypod_selector)))

GLOBAL_LIST_INIT(hvh_restricted_items_list, typecacheof(list(
	/obj/item/armor_module/module/ballistic_armor,
	/obj/item/attachable/scope,
	/obj/item/clothing/suit/modular/xenonauten,
)))
