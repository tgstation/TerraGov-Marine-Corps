/obj/item/implanter
	name = "implanter"
	icon = 'icons/obj/items/implants.dmi'
	icon_state = "implanter0"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
	worn_icon_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	///The implant itself
	var/obj/item/implant/imp = null

/obj/item/implanter/Initialize(mapload, ...)
	. = ..()
	if(imp)
		imp = new imp(src)
		update_icon()

/obj/item/implanter/Destroy()
	QDEL_NULL(imp)
	return ..()

/obj/item/implanter/update_icon_state()
	. = ..()
	icon_state = "implanter[imp?"1":"0"]"

/obj/item/implanter/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "it contains [imp ? "a [imp.name]" : "no implant"]!"

/obj/item/implanter/attack(mob/target, mob/user)
	. = ..()
	if(!ishuman(target))
		return FALSE
	if(!imp)
		to_chat(user, span_warning("There is no implant in the [src]!"))
		return FALSE
	user.visible_message(span_warning("[user] is attemping to implant [target]."), span_notice("You're attemping to implant [target]."))

	if(!do_after(user, 5 SECONDS, TRUE, target, BUSY_ICON_GENERIC) || !imp)
		to_chat(user, span_notice("You failed to implant [target]."))
		return FALSE

	if(!imp.try_implant(target, user))
		to_chat(user, span_notice("You fail to implant [target]."))
		return FALSE
	target.visible_message(span_warning("[target] has been implanted by [user]."))
	log_combat(user, target, "implanted", src)
	imp = null
	update_icon()
	return TRUE

/obj/item/implanter/neurostim
	name = "neurostim implanter"
	desc = "The result of a joint project between Kaizoku, NovaMed and NTC. This implant is capable of regulating nociception and sensory function, allowing one to experience pain reduction, improved balance, and improved resistance to overstimulation and disoritentation. To encourage compliance, NTC have implimented a negative stimulus system, activated if the implant hears a (non-radio) spoken codeprhase."
	imp = /obj/item/implant/neurostim

/obj/item/implanter/chem
	name = "chem implant implanter"
	imp = /obj/item/implant/chem

/obj/item/implanter/chem/blood
	name = "blood recovery implant implanter"
	imp = /obj/item/implant/chem/blood

/obj/item/implanter/cloak
	name = "cloak implant implanter"
	desc = "A NineTails Corporation-brand cloak implant. Capable of concealing a person in the UV, infrared and visible spectrum of light for a few seconds."
	imp = /obj/item/implant/cloak

/obj/item/implanter/blade
	name = "blade implant implanter"
	desc = "A wicked-looking folding blade produced by NineTails in conjunction with NovaMed, capable of being concealed within a human's arm."
	imp = /obj/item/implant/deployitem/blade

/obj/item/implanter/suicide_dust
	name = "Self-Gibbing implant"
	imp = /obj/item/implant/suicide_dust

/obj/item/implanter/sandevistan
	name = "ChronOS enchansement package implanter"
	desc = "A NovaMed-brand cybernetic enchansement package. Overloads your central nervous system, muscles and metabolism to push your body to the limits. Careful not to overuse it."
	icon_state = "imp_spinal"
	w_class = WEIGHT_CLASS_NORMAL
	imp = /obj/item/implant/sandevistan

/obj/item/implanter/sandevistan/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/item/implanter/sandevistan/attack(mob/target, mob/user)
	. = ..()
	if(!.)
		return
	qdel(src)

/obj/item/implanter/jump_mod
	name = "fortified ankles implant"
	desc = "This augmentation enhances the users ability to jump with graphene fibre reinforcements and nanogel joint fluid capsules. Hold jump to jump higher. Made by NovaMed."
	imp = /obj/item/implant/jump_mod

/obj/effect/supply_drop/jump_mod/Initialize(mapload)
	. = ..()
	new /obj/item/implanter/jump_mod(loc)
	new /obj/item/implanter/jump_mod(loc)
	return INITIALIZE_HINT_QDEL
