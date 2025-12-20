/obj/item/clothing/suit/resin_bodysuit
	name = "living resin bodysuit"
	desc = "Living mass of tentacles pretty much, yuck."
	//get actual sprites.
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	icon_state = "sneak"
	color = COLOR_PURPLE_GRAY
	equip_slot_flags = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING|ITEM_SLOT_UNDERWEAR

/obj/item/clothing/suit/resin_bodysuit/Initialize(mapload)
	. = ..()
	parasite_comp = AddComponent(/datum/component/parasitic_clothing)
