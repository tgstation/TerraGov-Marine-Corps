/obj/item/attachable/stock/t500stock
	name = "R-500 stock"
	desc = "Cool stock for cool revolver."
	flags_attach_features = ATTACH_REMOVABLE
	wield_delay_mod = 0.2 SECONDS
	delay_mod = -0.4 SECONDS
	icon = 'modular_RUtgmc/icons/Marine/attachments_64.dmi'
	icon_state = "stock"
	size_mod = 1
	accuracy_mod = 0.15
	recoil_mod = -1
	recoil_unwielded_mod = 1
	scatter_mod = -2
	scatter_unwielded_mod = 5
	melee_mod = 10
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/t500barrel
	name = "R-500 extended barrel"
	desc = "Cool barrel for cool revolver"
	slot = ATTACHMENT_SLOT_MUZZLE
	delay_mod = -0.4 SECONDS
	icon = 'modular_RUtgmc/icons/Marine/attachments_64.dmi'
	icon_state = "barrel"
	attach_shell_speed_mod = 1
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	scatter_mod = -3
	scatter_unwielded_mod = 3
	recoil_unwielded_mod = 1
	size_mod = 1
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/t500barrelshort
	name = "R-500 compensator"
	desc = "Cool compensator for cool revolver"
	slot = ATTACHMENT_SLOT_MUZZLE
	delay_mod = -0.2 SECONDS
	icon = 'modular_RUtgmc/icons/Marine/attachments_64.dmi'
	icon_state = "shortbarrel"
	scatter_mod = -2
	recoil_mod = -0.5
	scatter_unwielded_mod = -5
	recoil_unwielded_mod = -1
	accuracy_unwielded_mod = 0.15
	size_mod = 0.5
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/lace/t500
	name = "R-500 lace"
	icon = 'modular_RUtgmc/icons/Marine/attachments_64.dmi'
	slot = ATTACHMENT_SLOT_STOCK
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/scope/unremovable/laser_sniper_scope
	name = "Terra Experimental laser sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the Terra Experimental laser sniper rifle otherwise known as TE-S abbreviated, allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon = 'modular_RUtgmc/icons/Marine/marine-weapons.dmi'
	icon_state = "tes"

/obj/item/attachable/bayonetknife
	icon = 'modular_RUtgmc/icons/Marine/marine-weapons.dmi'
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/inhands/weapons/melee_right.dmi',
	)
