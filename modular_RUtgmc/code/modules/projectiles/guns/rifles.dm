///////////////////////////////////////////////////////////////////////
////////////////////////  T25, old version .///////////////////////////
///////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/rifle/T25
	name = "\improper T-25 smartrifle"
	desc = "The T-25 is the TGMC's current standard IFF-capable rifle. It's known for its ability to lay down quick fire support very well. Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	icon = 'modular_RUtgmc/icons/Marine/gun64.dmi'
	icon_state = "T25"
	item_state = "T25"
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/items_righthand_1.dmi',
		slot_s_store_str = 'modular_RUtgmc/icons/mob/suit_slot.dmi',
		slot_back_str = 'modular_RUtgmc/icons/mob/clothing/back.dmi',
	)
	caliber = CALIBER_10x26_CASELESS //codex
	max_shells = 80 //codex
	force = 20
	aim_slowdown = 0.5
	wield_delay = 0.9 SECONDS
	fire_sound = "gun_smartgun"
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/T25
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/T25, /obj/item/ammo_magazine/rifle/T25/extended)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/compensator,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/attachable/motiondetector,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = SKILL_SMARTGUN //Uses SG skill for the penalties.
	attachable_offset = list("muzzle_x" = 42, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 12, "stock_y" = 13)

	fire_delay = 0.2 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.5
	accuracy_mult = 1.2
	scatter = -5
	scatter_unwielded = 60


//-------------------------------------------------------
//AR-18 Carbine

/obj/item/weapon/gun/rifle/standard_carbine
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_carbine/ap,
		)

//-------------------------------------------------------
//AR-12 Assault Rifle

/obj/item/weapon/gun/rifle/standard_assaultrifle
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle/ap,
		)

//-------------------------------------------------------
//BR-64 BR

/obj/item/weapon/gun/rifle/standard_br
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_br,
		/obj/item/ammo_magazine/rifle/standard_br/ap,
		)


//-------------------------------------------------------
//AR-21 Assault Rifle

/obj/item/weapon/gun/rifle/standard_skirmishrifle
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_skirmishrifle,
		/obj/item/ammo_magazine/rifle/standard_skirmishrifle/ap,
		)

//-------------------------------------------------------
// AR-55 rifle

/obj/item/weapon/gun/rifle/tx55
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_carbine/ap,
		)

//-------------------------------------------------------
//SG Target Rifle, has underbarreled spotting rifle that applies effects.

/obj/item/weapon/gun/rifle/standard_smarttargetrifle
	fire_delay = 0.4 SECONDS

/obj/item/weapon/gun/rifle/standard_spottingrifle
	accuracy_mult = 1.5
	scatter = -5

/datum/ammo/bullet/spottingrifle
	accurate_range = 10
	max_range = 12

/datum/ammo/bullet/spottingrifle/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 3 SECONDS, slowdown = 1, max_range = 12)

/datum/ammo/bullet/spottingrifle/heavyrubber/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, slowdown = 3, max_range = 12)

/datum/ammo/bullet/spottingrifle/plasmaloss
	var/datum/effect_system/smoke_spread/smoke_system

/datum/ammo/bullet/spottingrifle/plasmaloss/on_hit_mob(mob/living/victim, obj/projectile/proj)
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/X = victim
		X.use_plasma(20 + 0.2 * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit) // This is draining 20%+20 flat per hit.
	var/datum/effect_system/smoke_spread/plasmaloss/S = new
	S.set_up(0, victim, 3)
	S.start()

/datum/ammo/bullet/spottingrifle/plasmaloss/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/T = get_turf(O)
	drop_tg_smoke(T.density ? P.loc : T)

/datum/ammo/bullet/spottingrifle/plasmaloss/on_hit_turf(turf/T, obj/projectile/P)
	drop_tg_smoke(T.density ? P.loc : T)

/datum/ammo/bullet/spottingrifle/plasmaloss/do_at_max_range(turf/T, obj/projectile/P)
	drop_tg_smoke(T.density ? P.loc : T)

/datum/ammo/bullet/spottingrifle/plasmaloss/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/plasmaloss()

/datum/ammo/bullet/spottingrifle/plasmaloss/proc/drop_tg_smoke(turf/T)
	if(T.density)
		return

	set_smoke()
	smoke_system.set_up(0, T, 3)
	smoke_system.start()
	smoke_system = null

/datum/ammo/bullet/spottingrifle/tungsten/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 2 SECONDS, knockback = 1, max_range = 12)

//-------------------------------------------------------
// MG-42 LMG

/obj/item/weapon/gun/rifle/standard_lmg
	item_icons = list(
		slot_l_hand_str = 'modular_RUtgmc/icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'modular_RUtgmc/icons/mob/items_righthand_64.dmi',
	)

//-------------------------------------------------------
// M412 PMC elite

/obj/item/weapon/gun/rifle/m412/elite
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/weapon/gun/grenade_launcher/underslung/elite,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/attachable/shoulder_mount,
	)
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness, /obj/item/weapon/gun/grenade_launcher/underslung/elite)
