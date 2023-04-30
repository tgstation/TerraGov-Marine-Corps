/obj/item/armor_module/greyscale/cape
	name = "6E chameleon cape (long)"
	desc = "A chromatic cape to improve on the design of the 7E badge, this cape is capable of two colors, for all your fashion needs. It also is equipped with thermal insulators so it will double as a blanket. \n Interact with facepaint to color. Attaches onto a uniform. Activate it to toggle the hood."
	icon_state = "cape"
	slot = ATTACHMENT_SLOT_CAPE
	attachment_layer = CAPE_LAYER
	prefered_slot = SLOT_W_UNIFORM
	greyscale_config = /datum/greyscale_config/cape
	greyscale_colors = COLOR_VERY_LIGHT_GRAY
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB|ATTACH_ACTIVATION
	attach_delay = 0 SECONDS
	detach_delay = 0 SECONDS
	secondary_color = TRUE
	attachments_by_slot = list(ATTACHMENT_SLOT_CAPE_HIGHLIGHT)
	starting_attachments = list(/obj/item/armor_module/greyscale/cape_highlight)
	///True if the hood is up, false if not.
	var/hood = FALSE

/obj/item/armor_module/greyscale/cape/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/attachment_handler, \
	attachments_by_slot, \
	list(
		/obj/item/armor_module/greyscale/cape_highlight,
		/obj/item/armor_module/greyscale/cape_highlight/half,
		/obj/item/armor_module/greyscale/cape_highlight/short,
		/obj/item/armor_module/greyscale/cape_highlight/scarf,
	), \
	starting_attachments = starting_attachments)

/obj/item/armor_module/greyscale/cape/activate(mob/living/user)
	. = ..()
	hood = !hood
	update_icon()
	user.update_inv_w_uniform()

/obj/item/armor_module/greyscale/cape/update_icon()
	if(hood)
		icon_state = "[initial(icon_state)]_hood"
	else
		icon_state = initial(icon_state)
	return ..()


/obj/item/armor_module/greyscale/cape/half
	name = "6E chameleon cape (half)"
	desc = "This version of the 6E cape only has one color. However, it is five percent cheaper. It also is equipped with thermal insulators so it will double as a blanket. \n Interact with facepaint to color. Attaches onto a uniform."
	icon_state = "cape_half"
	greyscale_config = /datum/greyscale_config/cape/half
	starting_attachments = list(/obj/item/armor_module/greyscale/cape_highlight/half)

/obj/item/armor_module/greyscale/cape/scarf
	name = "6E chameleon cape (scarf)"
	desc = "A cape to improve on the design of the 7E badge, this cape is capable of two colors, for all your fashion needs. This variation of the cape functions more as a scarf. \n Interact with facepaint to color. Attaches onto a uniform. Activate it to toggle the hood."
	icon_state = "scarf"
	greyscale_config = /datum/greyscale_config/cape/scarf
	starting_attachments = list(/obj/item/armor_module/greyscale/cape_highlight/scarf)

/obj/item/armor_module/greyscale/cape/short
	name = "6E chameleon cape (short)"
	icon_state = "cape_short"
	greyscale_config = /datum/greyscale_config/cape/short
	starting_attachments = list(/obj/item/armor_module/greyscale/cape_highlight/short)

/obj/item/armor_module/greyscale/cape_highlight
	name = "Cape Highlight"
	desc = "A cape to improve on the design of the 7E badge, this cape is capable of six colors, for all your fashion needs. This variation of the cape functions more as a scarf. \n Interact with facepaint to color. Attaches onto a uniform. Activate it to toggle the hood."
	icon_state = "highlight"
	slot = ATTACHMENT_SLOT_CAPE_HIGHLIGHT
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	icon_state = "cape_highlight"
	greyscale_config = /datum/greyscale_config/cape
	greyscale_colors = COLOR_MAROON
	secondary_color = TRUE

/obj/item/armor_module/greyscale/cape_highlight/half
	icon_state = "cape_half_highlight"
	greyscale_config = /datum/greyscale_config/cape/half

/obj/item/armor_module/greyscale/cape_highlight/short
	icon_state = "cape_short_highlight"
	greyscale_config = /datum/greyscale_config/cape/short

/obj/item/armor_module/greyscale/cape_highlight/scarf
	icon_state = "scarf_highlight"
	greyscale_config = /datum/greyscale_config/cape/scarf
