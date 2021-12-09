
//////////// Stock attachments ////////////////////////////


/obj/item/attachable/stock //Generic stock parent and related things.
	name = "default stock"
	desc = "Default parent object, not meant for use."
	icon_state = "stock"
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.2 SECONDS
	melee_mod = 5
	size_mod = 2
	pixel_shift_x = 30
	pixel_shift_y = 14

/obj/item/attachable/stock/irremoveable
	wield_delay_mod = 0 SECONDS
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/shotgun
	name = "\improper shotgun stock"
	desc = "A non-standard heavy wooden stock for the old V10 shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.3 SECONDS
	icon_state = "stock"
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -15

/obj/item/attachable/stock/tactical
	name = "\improper MK221 tactical stock"
	desc = "A sturdy polymer stock for the MK221 shotgun. Supplied in limited numbers and moderately encumbering, it provides an ergonomic surface to ease perceived recoil and usability."
	icon_state = "tactical_stock"
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -15

/obj/item/attachable/stock/scout
	name = "\improper ZX-76 tactical stock"
	desc = "A standard polymer stock for the ZX-76 assault shotgun. Designed for maximum ease of use in close quarters."
	icon_state = "zx_stock"
	wield_delay_mod = 0
	flags_attach_features = NONE
	accuracy_mod = 0.05
	recoil_mod = -2
	scatter_mod = -5

/obj/item/attachable/stock/mosin
	name = "mosin wooden stock"
	desc = "A non-standard long wooden stock for Slavic firearms."
	icon_state = "mosinstock"
	wield_delay_mod = 0.6 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/irremoveable/ppsh
	name = "PPSh-17b submachinegun wooden stock"
	desc = "A long wooden stock for a PPSh-17b submachinegun"
	icon_state = "ppshstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/irremoveable/t27
	name = "T-27 Body"
	desc = "A stock for a T-27 MMG."
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "t27body"
	pixel_shift_x = 15
	pixel_shift_y = 0

/obj/item/attachable/stock/irremoveable/pal12
	name = "Paladin-12 pump shotgun stock"
	desc = "A standard light stock for the Paladin-12 shotgun."
	icon_state = "pal12stock"

/obj/item/attachable/stock/m16
	name = "M16 composite stock"
	desc = "A composite stock securely fit to the M16 platform. Disassembly required to remove, not recommended."
	icon_state = "m16stock"
	wield_delay_mod = 0.5 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE

/obj/item/attachable/stock/ak47
	name = "AK-47 wooden stock"
	desc = "A metallic stock with a wooden paint coating, made to fit the AK-47 replica."
	icon_state = "ak47stock"
	wield_delay_mod = 0.4 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE


/obj/item/attachable/stock/rifle
	name = "\improper M412 solid stock"
	desc = "A common stock used by the M412 pulse rifle series, used for long rifles. This stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.2 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "riflestock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	accuracy_mod = 0.05
	recoil_mod = -3
	scatter_mod = -10
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/irremoveable/rifle
	name = "\improper M412 solid stock"
	icon_state = "riflestock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/sx16
	name = "\improper SX-16 stock"
	desc = "The standard stock for the SX-16. Can be removed to make the gun smaller and easier to wield."
	icon_state = "sx16stock"
	wield_delay_mod = 0.4 SECONDS
	size_mod = 1
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/tx15
	name = "\improper TX-15 stock"
	desc = "The standard stock for the TX-15. Cannot be removed."
	icon_state = "tx15stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t29stock
	name = "T-29 stock"
	desc = "A standard machinegun stock."
	icon_state = "t29stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/revolver
	name = "\improper M44 magnum sharpshooter stock"
	desc = "A wooden stock modified for use on a 44-magnum. Increases accuracy and reduces recoil at the expense of handling and agility."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.2 SECONDS
	size_mod = 2
	icon_state = "44stock"
	pixel_shift_x = 35
	pixel_shift_y = 19
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1
	accuracy_unwielded_mod = 0.05
	recoil_unwielded_mod = -2
	scatter_unwielded_mod = -5


/obj/item/attachable/stock/lasgun
	name = "\improper M43 Sunfury lasgun stock"
	desc = "The standard stock for the M43 Sunfury lasgun."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = null
	icon_state = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	flags_attach_features = NONE

/obj/item/attachable/stock/lasgun/practice
	name = "\improper M43-P Sunfury lasgun stock"
	desc = "The standard stock for the M43-P Sunfury lasgun, seems the stock is made out of plastic."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = null
	melee_mod = 0
	icon_state = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	flags_attach_features = NONE

/obj/item/attachable/stock/br
	name = "\improper T-64 stock"
	desc = "A specialized stock for the T-64."
	icon_state = "brstock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t18stock
	name = "\improper T-18 stock"
	desc = "A specialized stock for the T-18."
	icon_state = "t18stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/tl127stock
	name = "\improper TL-127 stock"
	desc = "A irremovable TL-127 sniper rifle stock."
	icon_state = "tl127stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t12stock
	name = "\improper T-12 stock"
	desc = "A specialized stock for the T-12."
	icon_state = "t12stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t42stock
	name = "\improper T-42 stock"
	desc = "A specialized stock for the T-42."
	icon_state = "t42stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t19stock
	name = "\improper T-19 machinepistol stock"
	desc = "A submachinegun stock distributed in small numbers to TGMC forces. Compatible with the T-19, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "t19stock"
	pixel_shift_x = 39
	pixel_shift_y = 11
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -10
	scatter_unwielded_mod = -10

/obj/item/attachable/stock/t35stock
	name = "\improper T-35 stock"
	desc = "A non-standard heavy stock for the T-35 shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.4 SECONDS
	icon_state = "t35stock"
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20

/obj/item/attachable/stock/t39stock
	name = "\improper T-39 stock"
	desc = "A specialized stock for the T-35."
	icon_state = "t39stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t60stock
	name = "T-60 stock"
	desc = "A irremovable T-60 general purpose machinegun stock."
	icon_state = "t60stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t70stock
	name = "\improper T-70 stock"
	desc = "A irremovable T-70 grenade launcher stock."
	icon_state = "t70stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t84stock
	name = "\improper TL-84 stock"
	desc = "A irremovable TL-84 flamer stock."
	icon_state = "tl84stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/irremoveable/m41a
	name = "HK-11 stock"
	icon_state = "m41a"

/obj/item/attachable/stock/irremoveable/tx11
	name = "TX-11 stock"
	icon_state = "tx11stock"
