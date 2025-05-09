//non lethal edition of SR-127
/obj/item/weapon/gun/rifle/chambered/nonlethal
	name = "\improper NTC 'Moonbeam' NL sniper rifle"
	desc = "A light framed bolt action rifle used by the NTC Specops, featuring a night vision scope... It is only able to fire non lethal rounds designed for it. In cases you wanna be an asshole. Through careful aim allows fire support from behind allies. Uses 8.6×70mm tranq magazines."
	icon = 'ntf_modular/icons/obj/items/guns/marksman64.dmi'
	icon_state = "tl127"
	worn_icon_state = "tl127"
	cock_animation = "tl127_cock"
	caliber = CALIBER_86X70 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/chamberedrifle/tranq
	wield_delay = 1 SECONDS
	aim_slowdown = 0.5
	attachable_allowed = list(
		/obj/item/attachable/scope/nightvision,
		/obj/item/attachable/stock/tl127stock,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/foldable/bipod,
	)

	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 22, "under_x" = 33, "under_y" = 16, "stock_x" = 8, "stock_y" = 12) //Will need alteration.

	starting_attachment_types = list(
		/obj/item/attachable/scope/nightvision,
		/obj/item/attachable/stock/tl127stock,
		/obj/item/attachable/suppressor,
	)
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/chamberedrifle/tranq,
	)

//SR-127 but non lethal.
/obj/item/ammo_magazine/rifle/chamberedrifle/tranq
	name = "Moonbeam NL sniper rifle magazine"
	desc = "A box magazine filled with 8.6x70mm tranq rifle rounds for the Moonbeam."
	caliber = CALIBER_86X70
	icon_state = "tl127NL"
	icon = 'ntf_modular/icons/obj/items/ammo/sniper.dmi'
	icon_state_mini = "mag_rifle_big"
	default_ammo = /datum/ammo/bullet/sniper/pfc/nl
	max_rounds = 10
	bonus_overlay = "tl127NL_mag"

/datum/ammo/bullet/sniper/pfc/nl
	name = "high caliber tranq rifle bullet"
	hud_state = "sniper_heavy"
	damage_type = STAMINA
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER
	damage = 100
	penetration = 30
	sundering = 3.5
	damage_falloff = 0.25
	damage_type = STAMINA
	shrapnel_chance = 2

/datum/ammo/bullet/sniper/pfc/nl/on_hit_mob(mob/target_mob, obj/projectile/proj)
	if(iscarbon(target_mob))
		var/mob/living/carbon/carbon_victim = target_mob
		carbon_victim.reagents.add_reagent(/datum/reagent/toxin/sleeptoxin, rand(5,8), no_overdose = TRUE)
