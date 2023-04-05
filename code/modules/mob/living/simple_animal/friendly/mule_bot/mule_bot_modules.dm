/obj/item/mule_module
	name = "mule module"
	desc = "Can be used to improve a mule and specialize it"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "modkit"
	var/mob/living/simple_animal/mule_bot/attached_mule
	var/mutable_appearance/mod_overlay


/obj/item/mule_module/proc/apply(mob/living/simple_animal/mule_bot/mule)
	mule.installed_module = src
	attached_mule = mule
	src.forceMove(mule)
	return TRUE


/obj/item/mule_module/proc/unapply(delete_mod = TRUE)
	attached_mule.installed_module = null
	attached_mule = null
	if(!delete_mod)
		src.forceMove(attached_mule.loc)
	else
		qdel(src)


/obj/item/storage/mule_pack
	name = "internal storage"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_storage_space = 48
	max_w_class = 6
	storage_slots = null

/obj/item/mule_module/storage
	name = "Storage module"
	desc = "A module that allows the mule to carry various items"
	var/obj/item/storage/mule_pack/storage_pack = /obj/item/storage/mule_pack

/obj/item/mule_module/storage/Initialize(mapload, ...)
	. = ..()
	storage_pack = new(src)

/obj/item/mule_module/storage/apply(mob/living/simple_animal/mule_bot/mule)
	RegisterSignal(mule,COMSIG_ATOM_ATTACK_HAND, PROC_REF(acces_storage))
	. = ..()

/obj/item/mule_module/storage/unapply(delete_mod = TRUE)
	UnregisterSignal(attached_mule, COMSIG_ATOM_ATTACK_HAND)
	. = ..()

/obj/item/mule_module/storage/proc/acces_storage(mob/mule, mob/user)
	SIGNAL_HANDLER
	storage_pack.open(user)
