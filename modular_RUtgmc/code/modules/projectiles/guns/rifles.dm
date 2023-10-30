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

//SG Target Rifle, has underbarreled spotting rifle that applies effects.

/obj/item/weapon/gun/rifle/standard_smarttargetrifle
	name = "\improper SG-62 Kauser-KT smart target rifle"
	desc = "The Kauser-KT SG-62 is a IFF-capable rifle used by the TerraGov Marine Corps, coupled with a spotting rifle that is also IFF capable of applying various bullets with specialized ordnance, this is a gun with many answers to many situations... if you have the right ammo loaded. Requires special training and it cannot turn off IFF. It uses high velocity 10x27mm for the rifle and 12x66mm ammunition for the underslung rifle."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "sg62"
	item_state = "sg62"
	caliber = CALIBER_10x27_CASELESS //codex
	max_shells = 40 //codex
	aim_slowdown = 0.85
	wield_delay = 0.65 SECONDS
	fire_sound =  'sound/weapons/guns/fire/t62.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/T42_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/T42_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/standard_smarttargetrifle
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/standard_smarttargetrifle)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/weapon/gun/rifle/standard_spottingrifle,
		/obj/item/attachable/stock/strstock,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = SKILL_SMARTGUN //Uses SG skill for the penalties.
	attachable_offset = list("muzzle_x" = 12, "muzzle_y" = 22, "rail_x" = 15, "rail_y" = 22, "under_x" = 28, "under_y" = 16, "stock_x" = 12, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/weapon/gun/rifle/standard_spottingrifle, /obj/item/attachable/stock/strstock)

	fire_delay = 0.5 SECONDS
	burst_amount = 0
	accuracy_mult_unwielded = 0.4
	accuracy_mult = 1.1
	scatter = 0
	scatter_unwielded = 20
	movement_acc_penalty_mult = 8

	placed_overlay_iconstate = "smartgun"

/obj/item/weapon/gun/rifle/standard_spottingrifle
	name = "SG-153 spotting rifle"
	desc = "An underslung spotting rifle, generally found ontop of another gun."
	icon_state = "sg153"
	icon = 'icons/Marine/gun64.dmi'
	fire_sound =  'sound/weapons/guns/fire/spottingrifle.ogg'
	caliber = CALIBER_12x7
	slot = ATTACHMENT_SLOT_UNDER
	max_shells = 5
	default_ammo_type =/obj/item/ammo_magazine/rifle/standard_spottingrifle
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/standard_spottingrifle,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/heavyrubber,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/plasmaloss,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/flak,
	)
	force = 5
	attachable_allowed = list()
	actions_types = list()
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)
	flags_gun_features = GUN_IS_ATTACHMENT|GUN_WIELDED_FIRING_ONLY|GUN_ATTACHMENT_FIRE_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	flags_attach_features = NONE
	fire_delay = 1 SECONDS
	accuracy_mult = 1.5
	pixel_shift_x = 18
	pixel_shift_y = 16

/datum/ammo/bullet/spottingrifle
	name = "smart spotting bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "spotrifle"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 50
	penetration = 25
	sundering = 5
	shell_speed = 4
	max_range = 6

/datum/ammo/bullet/spottingrifle/highimpact
	name = "smart high-impact spotting bullet"
	hud_state = "spotrifle_impact"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1 SECONDS, slowdown = 1 SECONDS, max_range = 6)

/datum/ammo/bullet/spottingrifle/heavyrubber
	name = "smart heavy-rubber spotting bullet"
	hud_state = "spotrifle_rubber"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/heavyrubber/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, slowdown = 2 SECONDS, max_range = 6)

/datum/ammo/bullet/spottingrifle/plasmaloss
	name = "smart tanglefoot spotting bullet"
	hud_state = "spotrifle_plasmaloss"
	damage = 10
	sundering = 0.5

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

/datum/ammo/bullet/spottingrifle/tungsten
	name = "smart tungsten spotting bullet"
	hud_state = "spotrifle_tungsten"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/tungsten/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stun = 0.5 SECONDS, knockback = 1 SECONDS, max_range = 6)

/datum/ammo/bullet/spottingrifle/flak
	name = "smart flak spotting bullet"
	hud_state = "spotrifle_flak"
	damage = 60
	sundering = 0.5
	airburst_multiplier = 0.5

/datum/ammo/bullet/spottingrifle/flak/on_hit_mob(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/spottingrifle/incendiary
	name = "smart incendiary spotting  bullet"
	hud_state = "spotrifle_incend"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage_type = BURN
	damage = 10
	sundering = 0.5
