/obj/item/clothing/under/marine/veteran/freelancer/mothellian
	name = "mothellian fatigues"
	desc = "A set of loose fitting fatigues, perfect for a Mothellian Republican.  Smells faintly like Lavender."


/obj/item/clothing/under/marine/veteran/freelancer/mothellian/veteran
	starting_attachments = list(/obj/item/armor_module/storage/uniform/holster/vp)

/obj/item/clothing/under/dress/maid
	name = "maid costume"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	worn_icon_list = list(
		slot_w_uniform_str = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi',
	)
	desc = "Maid in China."
	icon_state = "maid"

/obj/item/clothing/under/dress/maid/sexy
	name = "sexy maid costume"
	desc = "You must be a bit risque teasing all of them in a maid uniform!"
	icon_state = "sexymaid"

/obj/item/clothing/under/schoolgirl
	name = "schoolgirl costume"
	desc = "Looks like some kind of schoolgirl cosplay outfit."
	icon_state = "schoolgirl"

/obj/item/clothing/under/dress/dress_firepink
	name = "pink flame dress"
	desc = "A small black dress with pink flames print on it."
	icon_state = "dress_firepink"

/obj/item/clothing/under/cheerleader
	name = "cheerleader outfit"
	desc = "A white cheerleader's outfit."
	icon_state = "white_cheer"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'

/obj/item/clothing/under/cheerleader/yellow
	name = "yellow cheerleader outfit"
	desc = "A yellow cheerleader's outfit."
	icon_state = "yellow_cheer"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'

/obj/item/clothing/under/cheerleader/purple
	name = "purple cheerleader outfit"
	desc = "A pueple cheerleader's outfit."
	icon_state = "purple_cheer"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'

/obj/item/clothing/under/dress/dress_yellow
	name = "yellow dress"
	desc = "A flirty little yellow dress."
	icon_state = "bridesmaid"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'

/obj/item/clothing/under/dress/black_tango
	name = "black tango dress"
	desc = "A black tango dress."
	icon_state = "black_tango"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'

/obj/item/clothing/under/dress/plaid_purple
	name = "purple plaid skirt"

/obj/item/clothing/under/tdf
	name = "\improper NTF uniform"
	desc = "The standard uniform of NTF PMC personnel. A very easy to recognize design with its distinct red to represent the NTF."
	icon = 'ntf_modular/icons/obj/clothing/uniforms/ert_uniforms.dmi'
	worn_icon_list = list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/ert_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/uniforms_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/uniforms_right.dmi',
	)

/obj/item/clothing/under/marine_skirt
	name = "\improper ArcherCorp-brand combat jumpskirt"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform- Wait, a fucking combat skirt?"
	siemens_coefficient = 0.9
	icon = 'ntf_modular/icons/obj/clothing/uniforms/marine_uniforms.dmi'
	icon_state = "marine_jumpskirt"
	worn_icon_list =list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
	has_sensor = 2
	adjustment_variants = list(
		"Rolled Sleeves" = "_d",
		"No Sleeves" = "_h",
		"No Top" = "_r",
	)

/obj/item/clothing/under/marine/hyperscale_skirt
	name = "\improper 8E Chameleon ArcherCorp-brand jumpskirt"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform BUT colorable with facepaint! Comes in skirts now."
	icon_state = "hyperscale_marine_jumpskirt"
	worn_icon_state = "hyperscale_marine_jumpskirt"
	greyscale_colors = ARMOR_PALETTE_BLACK
	greyscale_config = /datum/greyscale_config/marine_uniform/skirt
	colorable_colors = ARMOR_PALETTES_LIST
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED|PRESET_COLORS_ALLOWED

/datum/greyscale_config/marine_uniform/skirt
	icon_file = 'ntf_modular/icons/mob/modular/marine_uniform.dmi'
	json_config = 'ntf_modular/code/datums/greyscale/json_configs/marine_uniform.json'

/obj/item/clothing/under/marine/squad/neck/alpha_skirt
	name = "\improper NTF Alpha skirtleneck"
	desc = "A standard issued NTF turtleneck colored red- OH COME ON"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/marine_uniforms.dmi'
	icon_state = "alpha_merc_skirt"
	worn_icon_list =list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)

/obj/item/clothing/under/marine/squad/neck/delta_skirt
	name = "\improper NTF Delta skirtleneck"
	desc = "A standard issued NTF turtleneck colored blue- OH COME ON"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/marine_uniforms.dmi'
	icon_state = "delta_merc_skirt"
	worn_icon_list =list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)

/obj/item/clothing/under/marine/squad/neck/charlie_skirt
	name = "\improper NTF Charlie skirtleneck"
	desc = "A standard issued NTF turtleneck colored purple- OH COME ON"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/marine_uniforms.dmi'
	icon_state = "charlie_merc_skirt"
	worn_icon_list =list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)

/obj/item/clothing/under/marine/squad/neck/bravo_skirt
	name = "\improper NTF Bravo skirtleneck"
	desc = "A standard issued NTF turtleneck colored yellow- OH COME ON"
	icon = 'ntf_modular/icons/obj/clothing/uniforms/marine_uniforms.dmi'
	icon_state = "bravo_merc_skirt"
	worn_icon_list =list(
		slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
