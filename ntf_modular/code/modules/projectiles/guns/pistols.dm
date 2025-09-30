/obj/item/weapon/gun/pistol/xmdivider/ntc
	name = "\improper NT/105 'Unity' Revolver"
	desc = "NTC's special production replica of Intertech's one of a kind 'Divider' revolver, named Unity after reverse engineering a sample. Fires .357 and .357 Foxfire rounds, This model has no burst fire but it has greater stopping power than it's original. They indeed let it get into enemy hands."
	icon = 'ntf_modular/icons/obj/items/guns/pistols.dmi'
	icon_state = "nt105"
	worn_icon_state = "nt105"
	caliber = CALIBER_357 //codex
	max_shells = 6
	default_ammo_type = /obj/item/ammo_magazine/pistol/ntunity
	allowed_ammo_types = list(/obj/item/ammo_magazine/pistol/xmdivider, /obj/item/ammo_magazine/pistol/xmdivider/ap, /obj/item/ammo_magazine/pistol/ntunity)
	force = 8
	actions_types = null
	attachable_allowed = list(
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/lace,
	)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 20, "rail_x" = 17, "rail_y" = 22, "under_x" = 29, "under_y" = 15, "stock_x" = 10, "stock_y" = 18)
	burst_amount = 1
	//gonna adjust for no burst fire.
	windup_delay = 0.3 SECONDS
	fire_delay = 0.3 SECONDS
	scatter_unwielded = 4
	scatter = 1.5
	damage_mult = 1.2
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	recoil = 3
	//no red dot, holo sight instead.
	accuracy_mult_unwielded = 0.95
	accuracy_mult = 1.2
	aim_speed_modifier = 0.50
	holstered_underlay_icon = 'ntf_modular/icons/obj/items/storage/holster.dmi'

//XM104 cylinder placed in pistols
/obj/item/ammo_magazine/pistol/ntunity
	name = "\improper NT105 'Unity' Foxfire cylinder (.357)"
	desc = "CC/104 cylinder loaded with custom .357 armor-piercing incendiary rounds."
	icon = 'ntf_modular/icons/obj/items/ammo/pistol.dmi' //same icon as parent so using that mag wont fuck the color illusion
	default_ammo = /datum/ammo/bullet/revolver/heavy/foxfire
	max_rounds = 6
	caliber = CALIBER_357
	icon_state = "nt105"
	icon_state_mini = "nt105"
	bonus_overlay = "nt105_fox"

/datum/ammo/bullet/revolver/heavy/foxfire
	name = "armor-piercing foxfire heavy revolver bullet"
	handful_amount = 6
	damage = 50
	penetration = 15
	sundering = 5
	ammo_behavior_flags = AMMO_INCENDIARY|AMMO_BALLISTIC

//mom i want a mateba, we got a mateba at home, mateba at home:
/datum/ammo/bullet/revolver/heavy/foxfire/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
    if(ishuman(target_mob))
        staggerstun(target_mob, proj, paralyze = 0, stun = 1 SECONDS, stagger = 1 SECONDS, slowdown = 1, knockback = 1)
    else
        staggerstun(target_mob, proj, paralyze = 1 SECONDS, stagger = 1 SECONDS, slowdown = 1, knockback = 1)
