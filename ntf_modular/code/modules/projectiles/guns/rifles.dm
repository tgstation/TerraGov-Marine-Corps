//non lethal edition of SR-127, meant to be slightly better.
/obj/item/weapon/gun/rifle/chambered/nonlethal
	name = "\improper NTC 'Moonbeam' NL sniper rifle"
	desc = "A light framed custom made bolt action rifle used by the NTC Specops, featuring a night vision scope... It is only able to fire non lethal rounds designed for it. In cases you wanna be an asshole. Through careful aim allows fire support from behind allies. It can have more types of attachments than standard sniper rifles. Uses 8.6×70mm magazines. Can also shoot regular ammo."
	icon = 'ntf_modular/icons/obj/items/guns/marksman64.dmi'
	gun_crosshair = 'icons/UI_Icons/gun_crosshairs/sniper.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	worn_icon_state = "moonbeam"
	worn_icon_list = list(
		slot_l_hand_str = 'ntf_modular/icons/mob/inhands/guns/marksman_left_64.dmi',
		slot_r_hand_str = 'ntf_modular/icons/mob/inhands/guns/marksman_right_64.dmi',
		slot_s_store_str = 'ntf_modular/icons/mob/clothing/back.dmi',
		slot_back_str = 'ntf_modular/icons/mob/clothing/back.dmi',
	)
	icon_state = "moonbeam"
	cock_animation = "moonbeam_cock"
	caliber = CALIBER_86X70 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/chamberedrifle/tranq
	wield_delay = 0.6 SECONDS //0.8 with stock
	cock_delay = 0.5 SECONDS
	fire_delay = 1.15 SECONDS
	aim_slowdown = 0.5
	recoil = 2 //0 with stock
	recoil_unwielded = 4 //2 with stock
	attachable_allowed = list(
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/nightvision,
		/obj/item/attachable/scope/optical,
		/obj/item/attachable/stock/tl127stock,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/stock/tl127stock/moonbeam,
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight/under,
		/obj/item/attachable/motiondetector,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
	)

	attachable_offset = list("muzzle_x" = 40, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 25, "under_x" = 33, "under_y" = 16, "stock_x" = 8, "stock_y" = 12)

	starting_attachment_types = list(
		/obj/item/attachable/scope/nightvision,
		/obj/item/attachable/stock/tl127stock/moonbeam,
		/obj/item/attachable/suppressor,
	)
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/chamberedrifle/tranq,
		/obj/item/ammo_magazine/rifle/chamberedrifle,
		/obj/item/ammo_magazine/rifle/chamberedrifle/flak,
	)

/obj/item/attachable/stock/tl127stock/moonbeam
	name = "\improper Moonbeam stock"
	desc = "A specialized stock for the Moonbeam"
	icon = 'ntf_modular/icons/obj/items/guns/attachments/stock.dmi'
	icon_state = "moonbeam"
	attach_features_flags = ATTACH_REMOVABLE
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.15
	recoil_mod = -2
	scatter_mod = -2

/obj/item/ammo_magazine/rifle/chamberedrifle/tranq
	name = "Moonbeam NL sniper rifle tranq magazine"
	desc = "A box magazine filled with 8.6x70mm tranq rifle rounds for the Moonbeam."
	caliber = CALIBER_86X70
	icon_state = "moonbeam_tranq"
	icon_state_mini = "mag_moonbeam_tranq"
	icon = 'ntf_modular/icons/obj/items/ammo/sniper.dmi'
	default_ammo = /datum/ammo/bullet/sniper/pfc/nl
	max_rounds = 10
	bonus_overlay = "moonbeam_tranq"

/datum/ammo/bullet/sniper/pfc/nl
	name = "high caliber tranq rifle bullet"
	hud_state = "sniper_heavy"
	damage_type = STAMINA
	plasma_drain = 30
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER
	damage = 120
	penetration = 30
	sundering = 3.5
	damage_falloff = 0.25
	shrapnel_chance = 2

/datum/ammo/bullet/sniper/pfc/nl/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(iscarbon(target_mob))
		var/mob/living/carbon/carbon_victim = target_mob
		carbon_victim.reagents.add_reagent(/datum/reagent/toxin/sleeptoxin, rand(5,8), no_overdose = TRUE)

/obj/item/ammo_magazine/packet/p86x70mm/tranq
	name = "box of 8.6x70mm tranq"
	desc = "A box containing 50 rounds of 8.6x70mm caseless tranq."
	caliber = CALIBER_86X70
	icon_state = "86x70mm"
	default_ammo = /datum/ammo/bullet/sniper/pfc/nl
	current_rounds = 50
	max_rounds = 50


//halter bullpup rifle
/obj/item/weapon/gun/rifle/nt_halter
	name = "\improper NT 'Halter' assault rifle"
	desc = "The standardized NTC bullpup AR design made to be used as their default primary firearm Chambered in 7.62x38mm."
	icon = 'ntf_modular/icons/obj/items/guns/rifles64.dmi'
	icon_state = "halter"
	worn_icon_state = "halter"
	worn_icon_list = list(
		slot_l_hand_str = 'ntf_modular/icons/mob/inhands/guns/rifles_left_64.dmi',
		slot_r_hand_str = 'ntf_modular/icons/mob/inhands/guns/rifles_right_64.dmi',
		slot_s_store_str = 'ntf_modular/icons/mob/clothing/back.dmi',
		slot_back_str = 'ntf_modular/icons/mob/clothing/back.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	fire_sound = 'sound/weapons/guns/fire/famas.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/m41a_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/m41a_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m41a_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m16_cocked.ogg'
	caliber = CALIBER_762X38 //codex
	max_shells = 36 //codex
	default_ammo_type = /obj/item/ammo_magazine/rifle/nt_halter
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/nt_halter,
		/obj/item/ammo_magazine/rifle/nt_halter/extended,
		/obj/item/ammo_magazine/rifle/nt_halter/drum,
		/obj/item/ammo_magazine/rifle/nt_halter/charged,
		/obj/item/ammo_magazine/rifle/nt_halter/smart,
		/obj/item/ammo_magazine/rifle/nt_halter/foxfire,
		/obj/item/ammo_magazine/rifle/nt_halter/laser,
		/obj/item/ammo_magazine/rifle/nt_halter/laser/extended,
		/obj/item/ammo_magazine/rifle/nt_halter/laser/drum,
	)
	attachable_allowed = list(
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
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet/converted,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/scope/mini,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/weapon/gun/rifle/pepperball/pepperball_mini,
		/obj/item/weapon/gun/flamer/hydro_cannon,
		/obj/item/attachable/shoulder_mount,
	)

	gun_features_flags = GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST,  GUN_FIREMODE_SEMIAUTO)
	attachable_offset = list("muzzle_x" = 51, "muzzle_y" = 19,"rail_x" = 25, "rail_y" = 23, "under_x" = 35, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)
	fire_delay = 0.2 SECONDS
	burst_delay = 0.15 SECONDS
	accuracy_mult = 1.15
	wield_delay = 0.7 SECONDS
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_slowdown = 0.3
	aim_speed_modifier = 2.5
	scatter = -1

/obj/item/weapon/gun/rifle/nt_halter/cqb
	name = "\improper NT 'Halter-CQB' carbine"
	desc = "A variant of Halter series standardized NTC bullpup AR design made into a carbine, Chambered in 7.62x38mm. This one is altered for close combat. The smaller frame make it lighter and easier to handle in close range encounters but it suffers from range reduction and overall accuracy."
	icon = 'ntf_modular/icons/obj/items/guns/rifles64.dmi'
	attachable_offset = list("muzzle_x" = 39, "muzzle_y" = 19,"rail_x" = 19, "rail_y" = 23, "under_x" = 29, "under_y" = 13, "stock_x" = 0, "stock_y" = 13)
	icon_state = "haltercqb"
	worn_icon_state = "haltercqb"
	fire_delay = 0.15 SECONDS
	burst_delay = 0.10 SECONDS
	scatter_unwielded = 6
	aim_slowdown = 0.2
	scatter = 3
	accuracy_mult = 1
	accuracy_mult_unwielded = 0.65
	wield_delay = 0.5 SECONDS
	damage_falloff_mult = 0.7

/obj/item/weapon/gun/rifle/nt_halter/cqb/elite
	name = "\improper NT 'Halter-CQB-E' carbine"
	desc = "A custom variant of Halter series though not obvious from the outside, Chambered in 7.62x38mm. This one is retrofitted with custom, expensive materials and modifications that allow it to be more accurate and shoot at more devastating velocities despite it's size and lightness."
	accuracy_mult = 1.10
	scatter = 2
	damage_mult = 1.1
	accuracy_mult_unwielded = 0.7
	scatter_unwielded = 5
	wield_delay = 0.4 SECONDS
	damage_falloff_mult = 0.65

//standard mag
/obj/item/ammo_magazine/rifle/nt_halter
	name = "\improper NT 'Halter' magazine (7.62x38mm)"
	desc = "A magazine filled with 7.62x38mm rifle rounds for the Halter series of firearms."
	caliber = CALIBER_762X38
	icon_state = "halter"
	icon = 'ntf_modular/icons/obj/items/ammo/rifle.dmi'
	bonus_overlay = "halter_mag"
	default_ammo = /datum/ammo/bullet/rifle/heavy/halter
	max_rounds = 36
	aim_speed_mod = 0.1
	wield_delay_mod = 0.1 SECONDS

/datum/ammo/bullet/rifle/heavy/halter
	name = "heavy rifle bullet"

//extended mag
/obj/item/ammo_magazine/rifle/nt_halter/extended
	name = "\improper NT 'Halter' extended magazine (7.62x38mm)"
	desc = "An extended magazine filled with 7.62x38mm rifle rounds for the Halter series of firearms."
	max_rounds = 50
	icon_state = "halter_ex"
	bonus_overlay = "halter_ex"
	aim_speed_mod = 0.2
	wield_delay_mod = 0.2 SECONDS

//extended mag
/obj/item/ammo_magazine/rifle/nt_halter/drum
	name = "\improper NT 'Halter' drum magazine (7.62x38mm)"
	desc = "An drum magazine filled with 7.62x38mm rifle rounds for the Halter series of firearms."
	max_rounds = 100
	icon_state = "halter_drum"
	bonus_overlay = "halter_drum"
	aim_speed_mod = 0.3
	wield_delay_mod = 0.3 SECONDS

//emp mag
/obj/item/ammo_magazine/rifle/nt_halter/charged
	name = "\improper NT 'Halter' charged magazine (7.62x38mm Charged)"
	desc = "A magazine filled with specialized 7.62x38mm rifle rounds to deliver a supercharged blast but loses overall power, for the Halter series of firearms. Inconsistent effect due being a nightmare to produce."
	icon_state = "halter_charged"
	bonus_overlay = "halter_charged"
	default_ammo = /datum/ammo/bullet/rifle/heavy/halter/charged

/datum/ammo/bullet/rifle/heavy/halter/charged
	name = "charged heavy rifle bullet"
	hud_state = "rifle_ap"
	damage = 20
	penetration = 10
	sundering = 2
	shrapnel_chance = 2
	bullet_color = COLOR_BRIGHT_BLUE
	var/emp_chance = 25 //spin the wheel WOOOOO

/datum/ammo/bullet/rifle/heavy/halter/charged/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	. = ..()
	if(prob(emp_chance))
		empulse(target_mob, 0, 0, 1, 2)
	if(ishuman(target_mob))
		staggerstun(target_mob, proj, stagger = 1 SECONDS, slowdown = 1)
	else
		staggerstun(target_mob, proj, stagger = 1 SECONDS, slowdown = 1)


/datum/ammo/bullet/rifle/heavy/halter/charged/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	. = ..()
	if(prob(emp_chance))
		empulse(target_obj, 0, 0, 1, 2)

/datum/ammo/bullet/rifle/heavy/halter/charged/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	. = ..()
	if(prob(emp_chance))
		empulse(target_turf, 0, 0, 1, 2)

//smart mag
/obj/item/ammo_magazine/rifle/nt_halter/smart
	name = "\improper NT 'Halter' smart magazine (7.62x38mm Smart)"
	desc = "A magazine filled with specialized 7.62x38mm rifle rounds that slightly sways to avoid friendlies but loses overall power, for the Halter series of firearms."
	icon_state = "halter_smart"
	bonus_overlay = "halter_smart"
	default_ammo = /datum/ammo/bullet/rifle/heavy/halter/smart

/datum/ammo/bullet/rifle/heavy/halter/smart
	name = "smart heavy rifle bullet"
	hud_state = "rifle_ap"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	damage = 20
	penetration = 5
	sundering = 1.15
	bullet_color = COLOR_BLUE_GRAY

//foxfire mag
/obj/item/ammo_magazine/rifle/nt_halter/foxfire
	name = "\improper NT 'Halter' foxfire magazine (7.62x38mm AP-I)"
	desc = "A magazine filled with specialized 7.62x38mm AP-I rifle rounds that pierce armor and ignite targets, for the Halter series of firearms."
	icon_state = "halter_foxfire"
	bonus_overlay = "halter_foxfire"
	default_ammo = /datum/ammo/bullet/rifle/ap/foxfire

/datum/ammo/bullet/rifle/ap/foxfire
	name = "foxfire rifle bullet"
	hud_state = "rifle_ap"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	bullet_color = COLOR_RED_LIGHT

//laser mag
/obj/item/ammo_magazine/rifle/nt_halter/laser
	name = "\improper NT 'Halter' laser magazine (7.62x38mm LE)"
	desc = "A magazine filled with specialized 7.62x38mm single shot laser emitter rounds that shoots laser bolts instead of a standard round."
	icon_state = "halter_laser"
	bonus_overlay = "halter_laser"
	default_ammo = /datum/ammo/energy/lasgun/halter

/datum/ammo/energy/lasgun/halter
	//slightly less damage than regular bullets but except laser standard sundering and bullet speed.
	name = "halter laser bolt"
	damage = 27
	bullet_color = COLOR_RED_LIGHT

//extended mag
/obj/item/ammo_magazine/rifle/nt_halter/laser/extended
	name = "\improper NT 'Halter' extended laser magazine (7.62x38mm LE)"
	desc = "An extended magazine filled with 7.62x38mm laser emitter rounds for the Halter series of firearms."
	max_rounds = 50
	icon_state = "halter_laser_ex"
	bonus_overlay = "halter_laser_drum"

//extended mag
/obj/item/ammo_magazine/rifle/nt_halter/laser/drum
	name = "\improper NT 'Halter' drum laser magazine (7.62x38mm)"
	desc = "An drum magazine filled with 7.62x38mm laser emitter rounds for the Halter series of firearms."
	max_rounds = 100
	icon_state = "halter_laser_drum"
	bonus_overlay = "halter_laser_drum"

//im not making a sprite for this im lazy
/obj/item/ammo_magazine/packet/halter
	name = "box of 7.62x38mm"
	desc = "A box containing 120 rounds of 7.62x38mm."
	caliber = CALIBER_762X38
	icon_state = "7.62"
	default_ammo = /datum/ammo/bullet/rifle/heavy/halter
	current_rounds = 120
	max_rounds = 120

/obj/item/storage/box/visual/magazine/compact/halter_assaultrifle
	name = "Halter magazine box"
	desc = "A box specifically designed to hold a large amount of Halter magazines."
	closed_overlay = "mag_box_small_overlay_ar12"

/obj/item/storage/box/visual/magazine/compact/halter_assaultrifle/Initialize(mapload, ...)
	. = ..()
	storage_datum.storage_slots = 30
	storage_datum.set_holdable(can_hold_list = list(
		/obj/item/ammo_magazine/rifle/nt_halter,
	))

/obj/item/storage/box/visual/magazine/compact/halter_assaultrifle/full
	spawn_number = 30
	spawn_type = /obj/item/ammo_magazine/rifle/nt_halter

/obj/item/storage/box/visual/magazine/compact/halter_assaultrifle_laser/full
	spawn_number = 30
	spawn_type = /obj/item/ammo_magazine/rifle/nt_halter/laser
