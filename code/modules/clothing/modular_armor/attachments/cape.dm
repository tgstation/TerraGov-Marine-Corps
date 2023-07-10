#define HIGHLIGHT_VARIANTS "highlight_variants"
#define HOOD "hood"

/obj/item/armor_module/armor/cape
	name = "6E Chameleon cape"
	desc = "A chromatic cape to improve on the design of the 7E badge, this cape is capable of two colors, for all your fashion needs. It also is equipped with thermal insulators so it will double as a blanket. \n Interact with facepaint to color and change variant. Attaches onto a uniform. Activate it to toggle the hood."
	icon_state = "cape"
	slot = ATTACHMENT_SLOT_CAPE
	attachment_layer = CAPE_LAYER
	prefered_slot = SLOT_W_UNIFORM
	greyscale_config = /datum/greyscale_config/cape
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB|ATTACH_ACTIVATION
	attach_delay = 0 SECONDS
	detach_delay = 0 SECONDS
	secondary_color = TRUE
	attachments_by_slot = list(ATTACHMENT_SLOT_CAPE_HIGHLIGHT)
	starting_attachments = list(/obj/item/armor_module/armor/cape_highlight)
	attachments_allowed = list(
		/obj/item/armor_module/armor/cape_highlight,
		/obj/item/armor_module/armor/cape_highlight/kama,
	)
	colorable_allowed = PRESET_COLORS_ALLOWED|ICON_STATE_VARIANTS_ALLOWED
	current_variant = "normal"
	icon_state_variants = list(
		"scarf round" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"scarf tied" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"scarf" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(
				"scarf",
			),
		),
		"striped" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"geist" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"ghille" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"ghille (left)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"ghille (right)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"ghille (alt)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"drifter" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"normal" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(
				"normal"
			),
		),
		"short" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(
				"short"
			),
		),
		"short (old)" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(),
		),
		"shredded" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(
				"shredded"
			),
		),
		"half" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(
				"half"
			),
		),
		"full" = list(
			HOOD = TRUE,
			HIGHLIGHT_VARIANTS = list(
				"full"
			),
		),
		"back" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"back"
			),
		),
		"cover" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"cover"
			),
		),
		"cover (alt)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"cover (alt)"
			),
		),
		"overlord" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"overlord"
			),
		),
		"overlord (alt 1)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"overlord (alt)"
			),
		),
		"overlord (alt 2)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"overlord (alt 2)"
			),
		),
		"shoal" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"shoal"
			),
		),
		"shoal (back)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"shoal (back)"
			),
		),
		"shoal (alt)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"shoal (alt)"
			),
		),
		"star" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"star"
			),
		),
		"rapier (right)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"rapier (right)"
			),
		),
		"rapier (left)" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"rapier (left)"
			),
		),
		"jacket" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"jacket"
			),
		),
	)

	///True if the hood is up, false if not.
	var/hood = FALSE

/obj/item/armor_module/armor/cape/update_icon_state()
	var/obj/item/armor_module/highlight = attachments_by_slot[ATTACHMENT_SLOT_CAPE_HIGHLIGHT]
	if(hood)
		icon_state = initial(icon_state) + "_[current_variant]_h"
		item_state = initial(item_state) + "_[current_variant]_h"
		highlight?.icon_state = initial(highlight.icon_state) + "_[highlight.current_variant]_h"
	else
		icon_state = initial(icon_state) + "_[current_variant]"
		item_state = initial(item_state) + "_[current_variant]"
		highlight?.icon_state = initial(highlight.icon_state) + "_[highlight.current_variant]"
	if(parent)
		parent.update_clothing_icon()
	highlight?.update_icon()

/obj/item/armor_module/armor/cape/activate(mob/living/user)
	. = ..()
	hood = !hood
	update_icon()
	update_greyscale()
	user.update_inv_w_uniform()


/obj/item/armor_module/armor/cape/color_item(obj/item/facepaint/paint, mob/user)
	var/old_variant = current_variant
	. = ..()
	if(old_variant == current_variant)
		return
	if(parent)
		UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	icon_state_variants[current_variant][HOOD] ? ENABLE_BITFIELD(flags_attach_features, ATTACH_ACTIVATION) : DISABLE_BITFIELD(flags_attach_features, ATTACH_ACTIVATION)
	if(CHECK_BITFIELD(flags_attach_features, ATTACH_ACTIVATION) && parent)
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_actions))
	var/obj/item/armor_module/highlight = attachments_by_slot[ATTACHMENT_SLOT_CAPE_HIGHLIGHT]
	if(!icon_state_variants[current_variant][HOOD])
		hood = FALSE
		highlight?.icon_state = initial(highlight.icon_state) + "_[highlight.current_variant]"
		if(ishuman(parent?.loc))
			LAZYREMOVE(actions_types, /datum/action/item_action/toggle)
			var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in actions
			old_action?.remove_action(user)
			actions = null
	if(!icon_state_variants[old_variant][HOOD] && icon_state_variants[current_variant][HOOD] && ishuman(parent?.loc))
		LAZYADD(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/new_action = new(src)
		if(toggle_signal)
			new_action.keybinding_signals = list(KEYBINDING_NORMAL = toggle_signal)
		new_action.give_action(user)
	highlight.current_variant = "none"
	highlight.icon_state_variants = icon_state_variants[current_variant][HIGHLIGHT_VARIANTS]
	highlight.icon_state_variants.Add("none")
	ENABLE_BITFIELD(highlight.colorable_allowed, PRESET_COLORS_ALLOWED)
	update_icon()
	update_greyscale()
	highlight.update_icon()
	highlight.update_greyscale()
	user.update_inv_w_uniform()

/obj/item/armor_module/armor/cape/kama
	name = "6E Chameleon kama"
	desc = "A chromatic kama to improve on the design of the 7E badge, this kama is capable of two colors, for all your fashion needs. Hanged from the belt, it serves to flourish the lower extremities.  \n Interact with facepaint to color. Attaches onto a uniform."
	slot = ATTACHMENT_SLOT_KAMA
	attachment_layer = KAMA_LAYER
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	colorable_allowed = PRESET_COLORS_ALLOWED
	starting_attachments = list(/obj/item/armor_module/armor/cape_highlight/kama)
	greyscale_config = /datum/greyscale_config/cape
	icon_state_variants = list(
		"kama" = list(
			HOOD = FALSE,
			HIGHLIGHT_VARIANTS = list(
				"kama",
			),
		),
	)
	current_variant = "kama"


/obj/item/armor_module/armor/cape_highlight
	name = "Cape Highlight"
	desc = "A cape to improve on the design of the 7E badge, this cape is capable of six colors, for all your fashion needs. This variation of the cape functions more as a scarf. \n Interact with facepaint to color. Attaches onto a uniform. Activate it to toggle the hood."
	icon_state = "highlight"
	slot = ATTACHMENT_SLOT_CAPE_HIGHLIGHT
	flags_attach_features = ATTACH_SAME_ICON|ATTACH_APPLY_ON_MOB
	colorable_allowed = PRESET_COLORS_ALLOWED|ICON_STATE_VARIANTS_ALLOWED|COLOR_WHEEL_ALLOWED
	greyscale_config = /datum/greyscale_config/cape_highlight
	secondary_color = TRUE
	greyscale_colors = VISOR_PALETTE_GOLD
	flags_item_map_variant = NONE
	colorable_colors = VISOR_PALETTES_LIST
	current_variant = "none"
	icon_state_variants = list(
		"none",
		"normal",
	)

/obj/item/armor_module/armor/cape_highlight/handle_color(datum/source, mob/user, list/obj/item/secondaries)
	if(current_variant == "none" && (length(icon_state_variants) == 1))
		return
	return ..()



/obj/item/armor_module/armor/cape_highlight/kama
	greyscale_config = /datum/greyscale_config/cape_highlight
	colorable_allowed = PRESET_COLORS_ALLOWED
	current_variant = "kama"
	icon_state_variants = list()

