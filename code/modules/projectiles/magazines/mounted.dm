///Default ammo for the HSG-102.
/obj/item/ammo_magazine/tl102
	name = "HSG-102 drum magazine (10x30mm Caseless)"
	desc = "A box of 300, 10x30mm caseless tungsten rounds for the HSG-102 mounted heavy smartgun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mag"
	flags_magazine = NONE
	caliber = CALIBER_10X30
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 5 SECONDS
	icon_state_mini = "mag_tl102"

///This is the one that comes in the mapbound and dropship mounted version of the HSG-102, it has a stupid amount of ammo. Even more than the ammo counter can display.
/obj/item/ammo_magazine/tl102/hsg_nest
	max_rounds = 500

/obj/item/ammo_magazine/heavymachinegun
	name = "HMG-08 drum magazine (10x30mm Caseless)"
	desc = "A box of 500, 10x28mm caseless tungsten rounds for the HMG-08 mounted heavy machinegun. Is probably not going to fit in your backpack. Put it on your belt or back."
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "mg08_mag"
	flags_magazine = NONE
	caliber = CALIBER_10X28
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 10 SECONDS

/obj/item/ammo_magazine/heavymachinegun/small
	name = "HMG-08 box magazine (10x30mm Caseless)"
	desc = "A box of 250 10x28mm caseless tungsten rounds for the HMG-08 mounted heavy machinegun."
	w_class = WEIGHT_CLASS_NORMAL
	flags_equip_slot = ITEM_SLOT_BELT
	icon_state = "mg08_mag_small"
	max_rounds = 250
	reload_delay = 5 SECONDS

/obj/item/ammo_magazine/standard_mmg
	name = "MG-27 box magazine (10x27m Caseless)"
	desc = "A box of 100 10x27mm caseless rounds for the MG-27 medium machinegun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "mag"
	flags_magazine = NONE
	caliber = CALIBER_10x27_CASELESS
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/rifle/heavy
	reload_delay = 1 SECONDS

/obj/item/ammo_magazine/standard_atgun
	name = "AT-36 AP-HE shell (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns. Will penetrate walls and fortifications, before hitting a target and exploding, has less payload and punch than usual rounds."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-atgun.dmi'
	icon_state = "tat36_shell"
	item_state = "tat36"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_0.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_0.dmi',
		)
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER
	caliber = CALIBER_37MM
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/atgun_shell
	reload_delay = 2 SECONDS

/obj/item/ammo_magazine/standard_atgun/apcr
	name = "AT-36 APCR shell (37mm Shell)"
	desc = "A 37mm tungsten shell for light anti tank guns made to penetrate through just about everything, but it won't leave a big hole."
	icon_state = "tat36_shell_apcr"
	item_state = "tat36_apcr"
	default_ammo = /datum/ammo/rocket/atgun_shell/apcr

/obj/item/ammo_magazine/standard_atgun/he
	name = "AT-36 HE (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns made to destroy fortifications, the high amount of payload gives it a slow speed. But it leaves quite a hole."
	icon_state = "tat36_shell_he"
	item_state = "tat36_he"
	default_ammo = /datum/ammo/rocket/atgun_shell/he

/obj/item/ammo_magazine/heavy_minigun
	name = "MG-2005 box magazine (7.62x51mm)"
	desc = "A box of 1000 rounds for the MG-2005 mounted minigun."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "minigun"
	flags_magazine = NONE
	caliber = CALIBER_762X51
	max_rounds = 1000
	default_ammo = /datum/ammo/bullet/minigun
	reload_delay = 10 SECONDS

/obj/item/ammo_magazine/dual_cannon
	name = "dualcannon IFF Magazine(20mm)"
	desc = "A box of 150 20mm rounds for the ATR-22 mounted dualcannon."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "ac_mag"
	flags_magazine = NONE
	caliber = CALIBER_20
	max_rounds = 150
	default_ammo = /datum/ammo/bullet/dual_cannon
	reload_delay = 5 SECONDS

/obj/item/ammo_magazine/heavy_laser
	name = "heavy-duty weapon laser cell"
	desc = "A cell with enough charge to contain 15 heavy laser shots for the TE-9001. This cannot be recharged."
	w_class = WEIGHT_CLASS_BULKY
	flags_magazine = NONE
	max_rounds = 15
	default_ammo = /datum/ammo/energy/lasgun/marine/heavy_laser
	reload_delay = 5 SECONDS
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "hl_mag"

/obj/item/ammo_magazine/heavy_rr
	name = "RR-15 HE shell (75mm Shell)"
	desc = "A 75mm HE shell for the RR-15 mounted heavy recoilless rifle."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "75shell"
	item_state = "75shell"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_0.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_0.dmi',
		)
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER
	caliber = CALIBER_75MM
	max_rounds = 1
	default_ammo = /datum/ammo/rocket/heavy_rr
	reload_delay = 10 SECONDS
