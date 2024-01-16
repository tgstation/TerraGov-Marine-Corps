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
	icon_state_mini = "mag_hmg"

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
	icon_state_mini = "mag_drum_big_green"
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
	icon_state_mini = "mag_hmg"
	max_rounds = 250
	reload_delay = 5 SECONDS

/obj/item/ammo_magazine/standard_mmg
	name = "MG-27 box magazine (10x27m Caseless)"
	desc = "A box of 150 10x27mm caseless rounds for the MG-27 medium machinegun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "mag"
	icon_state_mini = "mag_drum_big_armygreen"
	flags_magazine = NONE
	caliber = CALIBER_10x27_CASELESS
	max_rounds = 150
	default_ammo = /datum/ammo/bullet/rifle/heavy
	reload_delay = 1 SECONDS

/obj/item/ammo_magazine/standard_agls
	name = "AGLS-37 HE magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless HE grenades for the AGLS-37 automatic grenade launcher."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "ags_mag"
	flags_magazine = NONE
	caliber = CALIBER_40MM
	max_rounds = 30
	default_ammo = /datum/ammo/grenade_container/ags_grenade
	reload_delay = 4 SECONDS

/obj/item/ammo_magazine/standard_agls/fragmentation
	name = "AGLS-37 Frag magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Fragmentation grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "ags_mag_frag"
	default_ammo = /datum/ammo/ags_shrapnel

/obj/item/ammo_magazine/standard_agls/incendiary
	name = "AGLS-37 WP magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless White Phosphorous grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "ags_mag_incend"
	default_ammo = /datum/ammo/ags_shrapnel/incendiary

/obj/item/ammo_magazine/standard_agls/flare
	name = "AGLS-37 Flare magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Flare grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "ags_mag_flare"
	default_ammo = /datum/ammo/grenade_container/ags_grenade/flare

/obj/item/ammo_magazine/standard_agls/cloak
	name = "AGLS-37 Cloak magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Cloak grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "ags_mag_cloak"
	default_ammo = /datum/ammo/grenade_container/ags_grenade/cloak

/obj/item/ammo_magazine/standard_agls/tanglefoot
	name = "AGLS-37 Tanglefoot magazine (40mm Caseless)"
	desc = "A box holding 30 40mm caseless Tanglefoot grenades for the AGLS-37 automatic grenade launcher."
	icon_state = "ags_mag_pgas"
	default_ammo = /datum/ammo/grenade_container/ags_grenade/tanglefoot


/obj/item/ammo_magazine/standard_atgun
	name = "AT-36 AP-HE shell (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns. Will penetrate walls and fortifications, before hitting a target and exploding, has less payload and punch than usual rounds."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/Marine/marine-atgun.dmi'
	icon_state = "tat36_shell"
	item_state = "tat36"
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

/obj/item/ammo_magazine/standard_atgun/beehive
	name = "AT-36 Beehive (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns made to mince infantry, the light payload gives it moderate speed. Turns anyone into swiss cheese."
	icon_state = "tat36_shell_beehive"
	item_state = "tat36_beehive"
	default_ammo = /datum/ammo/rocket/atgun_shell/beehive

/obj/item/ammo_magazine/standard_atgun/incend
	name = "AT-36 Napalm (37mm Shell)"
	desc = "A 37mm shell for light anti tank guns made to set the battlefield ablaze, the light payload gives it a moderate speed. Will cook any target flambé."
	icon_state = "tat36_shell_incend"
	item_state = "tat36_incend"
	default_ammo = /datum/ammo/rocket/atgun_shell/beehive/incend

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

/obj/item/ammo_magazine/auto_cannon
	name = "autocannon high-velocity magazine(20mm)"
	desc = "A box of 100 high-velocity 20mm rounds for the ATR-22 mounted autocannon. Will pierce people and cover."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-ac.dmi'
	icon_state = "ac_mag"
	item_state = "ac"
	flags_magazine = NONE
	caliber = CALIBER_20
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/auto_cannon
	reload_delay = 4 SECONDS

/obj/item/ammo_magazine/auto_cannon/flak
	name = "autocannon smart-detonating magazine(20mm)"
	desc = "A box of 80 smart-detonating 20mm rounds for the ATR-22 mounted autocannon. Will detonate upon hitting a target."
	icon_state = "ac_mag_flak"
	item_state = "ac_flak"
	default_ammo = /datum/ammo/bullet/auto_cannon/flak

/obj/item/cell/lasgun/heavy_laser
	name = "heavy-duty weapon laser cell"
	desc = "A cell with enough charge to contain energy for the TE-9001. This cannot be recharged."
	w_class = WEIGHT_CLASS_BULKY
	maxcharge = 225
	reload_delay = 5 SECONDS
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "hl_mag"

/obj/item/ammo_magazine/heavy_isg
	name = "FK-88 shell (155mm Shell)"
	desc = "A 15cm shell for the FK-88 mounted flak gun. How did you even get this?"
	icon = 'icons/Marine/marine-fkgun.dmi'
	icon_state = "isg_ammo"
	item_state = "isg_ammo"
	w_class = WEIGHT_CLASS_BULKY
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER
	caliber = CALIBER_15CM
	max_rounds = 1
	reload_delay = 8 SECONDS
	default_ammo = /datum/ammo/rocket/heavy_isg

/obj/item/ammo_magazine/heavy_isg/he
	name = "FK-88 HE shell (155mm Shell)"
	desc = "A 15cm HE shell for the FK-88 mounted flak gun. Activate in hand to swap between unguided and guided modes."
	default_ammo = /datum/ammo/rocket/heavy_isg
	var/guided = TRUE

/obj/item/ammo_magazine/heavy_isg/he/attack_hand_alternate(mob/living/user)
	if(guided)
		default_ammo = /datum/ammo/rocket/heavy_isg/unguided
		balloon_alert(user, "You swap the shell to unguided form")
		guided = FALSE
	else
		default_ammo = /datum/ammo/rocket/heavy_isg
		balloon_alert(user, "You swap the shell to guided form")
		guided = TRUE

/obj/item/ammo_magazine/heavy_isg/sabot
	name = "FK-88 APFDS shell (155mm Shell)"
	desc = "A 15cm APFDS shell for the FK-88 mounted flak gun containing a large metal dart fired at hypersonic speeds, will pierce through basically anything and onto the other side with ease. Requires a minimum range before it stabilizes to properly hit anything, will rip a clean hole through basically anything."
	icon_state = "isg_ammo_sabot"
	default_ammo = /datum/ammo/bullet/heavy_isg_apfds

///Default ammo for the ML-91 and its export variants.
/obj/item/ammo_magazine/icc_hmg
	name = "KRD-61ES magazine (10x30mm Caseless)"
	desc = "A box of 300, 10x30mm caseless tungsten rounds for the KRD-61ESmounted heavy smartgun."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "kord_mag"
	flags_magazine = NONE
	caliber = CALIBER_10X30
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/machinegun
	reload_delay = 5 SECONDS
	icon_state_mini = "mag_hmg"
