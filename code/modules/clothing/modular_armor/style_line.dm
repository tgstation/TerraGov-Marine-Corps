// ***************************************
// *********** Modular Style Line
// ***************************************
/obj/item/clothing/suit/modular/style
	name = "\improper Drip"
	desc = "They got that drip, doe."
	item_map_variant_flags = NONE
	allowed_uniform_type = /obj/item/clothing/under
	slowdown = -0.5
	icon = 'icons/obj/clothing/suits/marine_suits.dmi'
	worn_icon_list = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_suits.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
	attachments_allowed = list(
// Armor Modules
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/chemsystem,
		/obj/item/armor_module/module/knight,
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/module/eshield/absorbant/energy,
		/obj/item/armor_module/module/eshield/absorbant/ballistic,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/module/eshield/som/overclocked,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/knight/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/module/mirage,
		/obj/item/armor_module/module/armorlock,
// Storage Modules
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/general/som,
		/obj/item/armor_module/storage/engineering/som,
		/obj/item/armor_module/storage/medical/som,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
// Equalizer Modules
		/obj/item/armor_module/module/style/light_armor,
		/obj/item/armor_module/module/style/medium_armor,
		/obj/item/armor_module/module/style/heavy_armor,
	)

	var/codex_info = {"<BR>This item is part of the <b>Style Line.</b><BR>
	<BR>The <b>Style Line</b> is a line of equipment designed to provide as much style as possible without compromising the user's protection.
	This line of equipment accepts <b>Equalizer modules</b>, which allow the user to alter any given piece of equipment's protection according to their preferences.<BR>"}

/obj/item/clothing/suit/modular/style/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/clothing/suit/modular/style/leather_jacket
	name = "\improper leather jacket"
	desc = "A fashionable jacket. Get them with style."
	icon_state = "leather_jacket"
	worn_icon_state = "leather_jacket_worn"
	icon_state_variants = list(
		"normal",
		"webbing",
	)
	current_variant = "normal"
	greyscale_colors = ARMOR_PALETTE_BLACK
	greyscale_config = /datum/greyscale_config/duster/leather_jacket
	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/clothing/suit/modular/style/duster
	name = "\improper duster"
	desc = "A light, loose-fitting colorable long coat, for those that want to have more style."
	icon_state = "duster"
	worn_icon_state = "duster_worn"
	greyscale_colors = ARMOR_PALETTE_BLACK
	greyscale_config = /datum/greyscale_config/duster
	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	colorable_allowed = PRESET_COLORS_ALLOWED

// ***************************************
//  Modular hats
/obj/item/clothing/head/modular/style
	name = "\improper Nice Hat"
	desc = "Nice hat bro. How did you find this?"
	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	attachments_allowed = list(
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/stylehat_badge,
		/obj/item/armor_module/armor/stylehat_badge/classic,
		/obj/item/armor_module/armor/stylehat_badge/ushanka,
	)
	attachments_by_slot = list(
		ATTACHMENT_SLOT_VISOR,
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_HEAD_MODULE,
		ATTACHMENT_SLOT_BADGE,
		ATTACHMENT_SLOT_CAPE_HIGHLIGHT,
	)

	greyscale_config = /datum/greyscale_config/style_hat
	colorable_allowed = PRESET_COLORS_ALLOWED

	visorless_offset_y = 0

	inv_hide_flags = NONE

	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)



//marine hats
/obj/item/clothing/head/modular/style/beret
	name = "NTC beret"
	desc = "A hat used by the NTC, typically considered the most iconic military headgear. Often reserved for higher ranking officers, they occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon_state = "beret_inhand"
	worn_icon_state = "beret"
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/stylehat_badge)
	inv_hide_flags = HIDE_EXCESS_HAIR


/obj/item/clothing/head/modular/style/classic_beret
	name = "NTC beret (classic)"
	desc = "A hat used by the NTC, typically considered the most iconic military headgear. Often reserved for higher ranking officers, they occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts. This one is in a classic style."
	icon_state = "classic_beret_inhand"
	worn_icon_state = "classic_beret"
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/stylehat_badge/classic)
	inv_hide_flags = HIDE_EXCESS_HAIR

/obj/item/clothing/head/modular/style/boonie
	name = "NTC boonie"
	desc = "A boonie hat used by the NTC, purpose made for operations in enviroments with a lot of sun, or dense vegetation."
	icon_state = "boonie_inhand"
	worn_icon_state = "boonie"
	inv_hide_flags = HIDE_EXCESS_HAIR

/obj/item/clothing/head/modular/style/cap
	name = "NTC cap"
	desc = "A common patrol cap used by the NTC, stylish and comes in many colors. Mostly useful to keep the sun and officers away."
	icon_state = "cap_inhand"
	worn_icon_state = "cap"
	inv_hide_flags = HIDE_EXCESS_HAIR


/obj/item/clothing/head/modular/style/slouchhat
	name = "NTC slouch hat"
	desc = "A slouch hat, makes you feel down under, doesn't it? Has 'PROPERTY OF THE NTC' markings under the hat."
	icon_state = "slouch_inhand"
	worn_icon_state = "slouch"
	inv_hide_flags = HIDE_EXCESS_HAIR

/obj/item/clothing/head/modular/style/ushanka
	name = "NTC ushanka"
	desc = "A comfortable ushanka used by the NTC. Will keep you warm in even the most harshest artic enviroments."
	icon_state = "ushanka_inhand"
	worn_icon_state = "ushanka"
	starting_attachments = list(/obj/item/armor_module/storage/helmet, /obj/item/armor_module/armor/stylehat_badge/ushanka)
	inv_hide_flags = HIDE_EXCESS_HAIR


/obj/item/clothing/head/modular/style/campaignhat
	name = "NTC campaign hat"
	desc = "A campaign hat, you can feel the menacing aura that this hat erodes just by looking at it."
	icon_state = "campaign_inhand"
	worn_icon_state = "campaign"
	inv_hide_flags = HIDE_EXCESS_HAIR


/obj/item/clothing/head/modular/style/beanie
	name = "NTC beanie"
	desc = "A beanie, just looking at it makes you feel like an 'Oussama', or in better terms- A modern phenomenon of people suddenly needing to bench once they put on a beanie."
	icon_state = "beanie_inhand"
	worn_icon_state = "beanie"
	inv_hide_flags = HIDE_EXCESS_HAIR

/obj/item/clothing/head/modular/style/headband
	name = "NTC headband"
	desc = "A headband. Will keep the sweat off your eyes and also keep you looking cool."
	icon_state = "headband_inhand"
	worn_icon_state = "headband"


/obj/item/clothing/head/modular/style/bandana
	name = "NTC bandana"
	desc = "A bandana that goes on your head. Has NTC markings on the back tie, and it seems that the knot will never come undone somehow."
	icon_state = "headbandana_inhand"
	worn_icon_state = "headbandana"
	inv_hide_flags = HIDE_EXCESS_HAIR

// style masks
/obj/item/clothing/mask/gas/modular/skimask
	name = "ski mask"
	desc = "A stylish skimask, can be recolored. Makes you feel like an operator just looking at it."
	icon_state = "ski_inhand"
	worn_icon_state = "ski"
	inv_hide_flags = HIDEALLHAIR|HIDEEARS
	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	greyscale_config = /datum/greyscale_config/style_hat


/obj/item/clothing/mask/gas/modular/coofmask
	name = "combat face cloth covering"
	desc = "The CFCC is a prime and readied, yet stylish facemask ready to... cover your face."
	icon_state = "coof_inhand"
	worn_icon_state = "coof"
	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	greyscale_config = /datum/greyscale_config/style_hat

// ***************************************
// Barrier Armors / NTF changes

/obj/item/clothing/suit/modular/style/barrier
	slowdown = 0.1
	icon = 'ntf_modular/icons/obj/clothing/suits/barrier_armor.dmi'
	worn_icon_list = list(slot_wear_suit_str = 'ntf_modular/icons/obj/clothing/suits/barrier_armor.dmi')
	attachments_by_slot = list(
		ATTACHMENT_SLOT_CHESTPLATE,
		ATTACHMENT_SLOT_SHOULDER,
		ATTACHMENT_SLOT_KNEE,
		ATTACHMENT_SLOT_MODULE,
		ATTACHMENT_SLOT_STORAGE,
		ATTACHMENT_SLOT_BADGE,
		ATTACHMENT_SLOT_BELT,
	)
	attachments_allowed = list(
// Armor Modules
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/chemsystem,
		/obj/item/armor_module/module/knight,
		/obj/item/armor_module/module/eshield/barrier/light,
		/obj/item/armor_module/module/eshield/barrier/medium,
		/obj/item/armor_module/module/eshield/barrier/heavy,
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/module/eshield/som,
		/obj/item/armor_module/module/eshield/som/overclocked,
		/obj/item/armor_module/module/mimir_environment_protection/som,
		/obj/item/armor_module/module/knight/som,
		/obj/item/armor_module/module/tyr_extra_armor/som,
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/armor_module/module/valkyrie_autodoc/som,
		/obj/item/armor_module/module/mirage,
		/obj/item/armor_module/module/armorlock,
// Storage Modules
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/general/som,
		/obj/item/armor_module/storage/engineering/som,
		/obj/item/armor_module/storage/medical/som,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/armor/badge,
// Equalizer Modules
		/obj/item/armor_module/module/style/light_armor,
		/obj/item/armor_module/module/style/medium_armor,
		/obj/item/armor_module/module/style/heavy_armor,
	)

/obj/item/clothing/suit/modular/style/barrier/lightbarrier
	name = "\improper light barrier armor"
	icon_state = "barrier_light"
	worn_icon_state = "barrier_light_worn"
	desc = "A small, intricate, adjustable collar/pendant fitted with a miniature, highly efficient forcefield projector. It's incredibly light and convenient, the shield coil stable enough to rapidly recharge the protective barrier around the user. Made by Nine Tails Corp."
	starting_attachments = list(/obj/item/armor_module/module/eshield/barrier/light)

/obj/item/clothing/suit/modular/style/barrier/mediumbarrier
	name = "\improper medium barrier armor"
	desc = "A chest-mounted shield projector that comes in a package along with a set of capacitor sleeves and thigh bands. It's efficiency is comparable to standard arrowhead modules, though the additional capacitors provide greater durability. Made by Nine Tails Corp."
	icon_state = "barrier_medium"
	worn_icon_state = "barrier_medium_worn"
	starting_attachments = list(/obj/item/armor_module/module/eshield/barrier/medium)
	icon = 'ntf_modular/icons/obj/clothing/suits/barrier_armor.dmi'


/obj/item/clothing/suit/modular/style/barrier/heavybarrier
	name = "\improper heavy barrier armor"
	desc = "A lightweight shield generator that can loosely be considered armor"
	icon_state = "barrier_heavy"
	worn_icon_state = "barrier_heavy_worn"
	starting_attachments = list(/obj/item/armor_module/module/eshield/barrier/heavy)
	icon = 'ntf_modular/icons/obj/clothing/suits/barrier_armor.dmi'
