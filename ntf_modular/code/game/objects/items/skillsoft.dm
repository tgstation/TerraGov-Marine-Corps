//trait giver item
/obj/item/skillsoft
	name = "skillsoft chip"
	desc = "A chip to insert directly into your brain (neural implant)"
	icon = 'icons/obj/items/capsules.dmi'
	icon_state = "capsule_blue"
	w_class = WEIGHT_CLASS_TINY
	var/granted_trait

/obj/item/skillsoft/attack_self(mob/living/user)
	if(!granted_trait)
		CRASH("Skillsoft has no trait.")
	if(HAS_TRAIT(user, granted_trait))
		balloon_alert(user, "nothing to learn!")
		return
	if(!do_after(user, 5 SECONDS, NONE, user))
		return
	ADD_TRAIT(user, granted_trait, "skillsoft_trait")
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)
	. = ..()

/obj/item/skillsoft/lightfooted
	name = "Skillsoft (Light Footed)"
	desc = "A skillsoft which grants a trait."
	granted_trait = TRAIT_LIGHT_STEP

