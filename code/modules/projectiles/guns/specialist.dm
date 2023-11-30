/*
This file contains:

Sniper rifles
Miniguns
Pepperball gun
Rocket launchers

*/


/*-------------------------------------------------------
SNIPER RIFLES
Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

Because this parent type did not exist
Note that this means that snipers will have a slowdown of 3, due to the scope
*/
/obj/item/weapon/gun/rifle/sniper
	aim_slowdown = 1
	gun_skill_category = SKILL_RIFLES
	wield_delay = 1 SECONDS

//Pow! Headshot

/obj/item/weapon/gun/rifle/sniper/antimaterial
	name = "\improper SR-26 scoped rifle"
	desc = "The SR-26 is an IFF capable sniper rifle which is mostly used by long range marksmen. It excels in long-range combat situations and support sniping. It has a laser designator installed, and the scope itself has IFF integrated into it. Uses specialized 10x28 caseless rounds made to work with the guns odd IFF-scope system.  \nIt has an integrated Target Marker and a Laser Targeting system.\n\"Peace Through Superior Firepower\"."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t26"
	item_state = "t26"
	max_shells = 15 //codex
	caliber = CALIBER_10X28
	fire_sound = 'sound/weapons/guns/fire/sniper.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/sniper
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper/incendiary,
		/obj/item/ammo_magazine/sniper/flak,
	)
	force = 12
	wield_delay = 12 //Ends up being 1.6 seconds due to scope
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	var/targetmarker_on = FALSE
	var/targetmarker_primed = FALSE
	var/mob/living/carbon/laser_target = null
	var/image/LT = null
	var/obj/item/binoculars/tactical/integrated_laze = null
	attachable_allowed = list(
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/antimaterial,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/sniperbarrel,
		/obj/item/attachable/scope/pmc,
		/obj/item/attachable/shoulder_mount,
	)
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	starting_attachment_types = list(/obj/item/attachable/scope/antimaterial, /obj/item/attachable/sniperbarrel)

	fire_delay = 2.5 SECONDS
	burst_amount = 1
	accuracy_mult = 1.1
	recoil = 2
	scatter = 0
	movement_acc_penalty_mult = 8

	placed_overlay_iconstate = "antimat"



/obj/item/weapon/gun/rifle/sniper/antimaterial/Initialize(mapload)
	. = ..()
	LT = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-LASER_LAYER)
	integrated_laze = new(src)

/obj/item/weapon/gun/rifle/sniper/antimaterial/do_fire(obj/object_to_fire)
	if(targetmarker_primed)
		if(!iscarbon(target))
			return
		if(laser_target)
			deactivate_laser_target()
		if(target.apply_laser())
			activate_laser_target(target, gun_user)
		return
	if(!QDELETED(laser_target))
		target = laser_target
	return ..()


/obj/item/weapon/gun/rifle/sniper/antimaterial/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl"))
		return FALSE
	integrated_laze.acquire_target(object, user)
	return TRUE


/atom/proc/apply_laser()
	return FALSE

/mob/living/carbon/human/apply_laser()
	overlays_standing[LASER_LAYER] = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-LASER_LAYER)
	apply_overlay(LASER_LAYER)
	return TRUE

/mob/living/carbon/xenomorph/apply_laser()
	overlays_standing[X_LASER_LAYER] = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-X_LASER_LAYER)
	apply_overlay(X_LASER_LAYER)
	return TRUE

/mob/living/carbon/proc/remove_laser()
	return FALSE

/mob/living/carbon/human/remove_laser()
	remove_overlay(LASER_LAYER)
	return TRUE

/mob/living/carbon/xenomorph/remove_laser()
	remove_overlay(X_LASER_LAYER)
	return TRUE

/obj/item/weapon/gun/rifle/sniper/antimaterial/unique_action(mob/user)
	if(!targetmarker_primed && !targetmarker_on)
		return laser_on(user)
	return laser_off(user)

/obj/item/weapon/gun/rifle/sniper/antimaterial/Destroy()
	laser_off()
	QDEL_NULL(integrated_laze)
	return ..()

/obj/item/weapon/gun/rifle/sniper/antimaterial/dropped()
	laser_off()
	. = ..()

/obj/item/weapon/gun/rifle/sniper/antimaterial/process()
	var/obj/item/attachable/scope = LAZYACCESS(attachments_by_slot, ATTACHMENT_SLOT_RAIL)
	if(!scope.zoom)
		laser_off()
		return
	var/mob/living/user = loc
	if(!istype(user))
		laser_off()
		return
	if(!laser_target)
		laser_off(user)
		playsound(user,'sound/machines/click.ogg', 25, 1)
		return
	if(!line_of_sight(user, laser_target, 24))
		laser_off()
		to_chat(user, span_danger("You lose sight of your target!"))
		playsound(user,'sound/machines/click.ogg', 25, 1)

/obj/item/weapon/gun/rifle/sniper/antimaterial/zoom(mob/living/user, tileoffset = 11, viewsize = 12) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	. = ..()
	var/obj/item/attachable/scope = LAZYACCESS(attachments_by_slot, ATTACHMENT_SLOT_RAIL)
	if(!scope.zoom && (targetmarker_on || targetmarker_primed) )
		laser_off(user)

/atom/proc/sniper_target(atom/A)
	return FALSE

/obj/item/weapon/gun/rifle/sniper/antimaterial/sniper_target(atom/A)
	if(!laser_target)
		return FALSE
	if(A == laser_target)
		return laser_target
	else
		return TRUE

/obj/item/weapon/gun/rifle/sniper/antimaterial/proc/activate_laser_target(atom/target, mob/living/user)
	laser_target = target
	to_chat(user, span_danger("You focus your target marker on [target]!"))
	targetmarker_primed = FALSE
	targetmarker_on = TRUE
	RegisterSignal(src, COMSIG_PROJ_SCANTURF, PROC_REF(scan_turf_for_target))
	START_PROCESSING(SSobj, src)
	accuracy_mult += 0.50 //We get a big accuracy bonus vs the lasered target


/obj/item/weapon/gun/rifle/sniper/antimaterial/proc/deactivate_laser_target()
	UnregisterSignal(src, COMSIG_PROJ_SCANTURF)
	laser_target.remove_laser()
	laser_target = null


/obj/item/weapon/gun/rifle/sniper/antimaterial/proc/scan_turf_for_target(datum/source, turf/target_turf)
	SIGNAL_HANDLER
	if(QDELETED(laser_target) || !isturf(laser_target.loc))
		return NONE
	if(get_turf(laser_target) == target_turf)
		return COMPONENT_PROJ_SCANTURF_TARGETFOUND
	return COMPONENT_PROJ_SCANTURF_TURFCLEAR


/obj/item/weapon/gun/rifle/sniper/antimaterial/proc/laser_on(mob/user)
	var/obj/item/attachable/scope = LAZYACCESS(attachments_by_slot, ATTACHMENT_SLOT_RAIL)
	if(!scope.zoom) //Can only use and prime the laser targeter when zoomed.
		to_chat(user, span_warning("You must be zoomed in to use your target marker!"))
		return TRUE
	targetmarker_primed = TRUE //We prime the target laser
	RegisterSignal(user, COMSIG_ITEM_UNZOOM, PROC_REF(laser_off))
	if(user?.client)
		user.client.click_intercept = src
		to_chat(user, span_notice("<b>You activate your target marker and take careful aim.</b>"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/antimaterial/proc/laser_off(mob/user)
	SIGNAL_HANDLER
	if(laser_target)
		deactivate_laser_target()
		accuracy_mult -= 0.50 //We lose a big accuracy bonus vs the now unlasered target
		STOP_PROCESSING(SSobj, src)
		targetmarker_on = FALSE
	targetmarker_primed = FALSE
	if(user)
		UnregisterSignal(user, COMSIG_ITEM_UNZOOM)
	if(user?.client)
		user.client.click_intercept = null
		to_chat(user, span_notice("<b>You deactivate your target marker.</b>"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper SR-42 anti-tank sniper rifle"
	desc = "A high end mag-rail heavy sniper rifle from Nanotrasen chambered in the heaviest ammo available, 10x99mm Caseless."
	icon_state = "m42c"
	item_state = "m42c"
	max_shells = 6 //codex
	caliber = CALIBER_10X99
	fire_sound = 'sound/weapons/guns/fire/sniper_heavy.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_heavy_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_heavy_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/sniper_heavy_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/sniper/elite
	allowed_ammo_types = list(/obj/item/ammo_magazine/sniper/elite)
	force = 17
	attachable_allowed = list()
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)
	flags_item_map_variant = NONE
	attachable_allowed = list(
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/antimaterial,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/sniperbarrel,
		/obj/item/attachable/scope/pmc,
	)
	starting_attachment_types = list(/obj/item/attachable/scope/pmc, /obj/item/attachable/sniperbarrel)

	fire_delay = 1.5 SECONDS
	accuracy_mult = 1.2
	recoil = 5
	burst_amount = 1
	movement_acc_penalty_mult = 7

//SVD //Based on the Dragunov sniper rifle.

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper SR-33 Dragunov sniper rifle"
	desc = "A semiautomatic sniper rifle, famed for it's marksmanship, and is built from the ground up for it. Fires 7.62x54mmR rounds."
	icon = 'icons/Marine/gun64.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)

	inhand_x_dimension = 64
	inhand_y_dimension = 32
	icon_state = "svd"
	item_state = "svd"
	max_shells = 10 //codex
	caliber = CALIBER_762X54 //codex
	fire_sound = "svd_fire"
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/svd_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/svd_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/svd_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/sniper/svd
	allowed_ammo_types = list(/obj/item/ammo_magazine/sniper/svd)
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/slavic,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 21, "under_x" = 32, "under_y" = 14, "stock_x" = 20, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/scope/slavic)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.8 SECONDS
	aim_speed_modifier = 0.75

	fire_delay = 1.2 SECONDS
	burst_amount = 1
	accuracy_mult = 1
	scatter = -5
	recoil = -1
	wield_delay = 1.8 SECONDS
	movement_acc_penalty_mult = 6



//Based off the XM-8. BR-8 rifle

/obj/item/weapon/gun/rifle/tx8
	name = "\improper BR-8 scout rifle"
	desc ="The BR-8 is a light specialized scout rifle, mostly used by light infantry and scouts. It's designed to be useable at all ranges by being very adaptable to different situations due to the ability to use different ammo types. Has IFF.  Takes specialized overpressured 10x28mm rounds."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "tx8"
	item_state = "tx8"
	max_shells = 25 //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = CALIBER_10X28_CASELESS //codex
	fire_sound = 'sound/weapons/guns/fire/t64.ogg'
	unload_sound = 'sound/weapons/guns/interact/m4ra_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m4ra_cocked.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/tx8
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/tx8,
		/obj/item/ammo_magazine/rifle/tx8/incendiary,
		/obj/item/ammo_magazine/rifle/tx8/impact,
	)
	force = 16
	aim_slowdown = 0.45
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
		/obj/item/attachable/bayonetknife/som,
		/obj/item/attachable/compensator,
		/obj/item/attachable/scope,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/scope/marine,
		/obj/item/attachable/angledgrip,
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/weapon/gun/shotgun/combat/masterkey,
		/obj/item/weapon/gun/flamer/mini_flamer,
		/obj/item/weapon/gun/grenade_launcher/underslung,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 18,"rail_x" = 18, "rail_y" = 24, "under_x" = 31, "under_y" = 15, "stock_x" = 24, "stock_y" = 13)


	fire_delay = 0.4 SECONDS
	burst_amount = 1
	accuracy_mult = 1.2
	scatter = -3
	recoil = 2

/obj/item/weapon/gun/rifle/tx8/scout
	starting_attachment_types = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/verticalgrip,
	)

//-------------------------------------------------------
// MINIGUN

/obj/item/weapon/gun/minigun
	name = "\improper MG-100 Vindicator Minigun"
	desc = "A six barreled rotary machine gun, The ultimate in man-portable firepower, capable of laying down high velocity armor piercing rounds this thing will no doubt pack a punch.. If you don't kill all your friends with it, you can use the stablizing system of the Powerpack to fire aimed fire, but you'll move incredibly slowly."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "minigun"
	item_state = "minigun"
	fire_animation = "minigun_fire"
	max_shells = 500 //codex
	caliber = CALIBER_762X51 //codex
	load_method = MAGAZINE //codex
	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'
	unload_sound = 'sound/weapons/guns/interact/minigun_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	default_ammo_type = null
	allowed_ammo_types = list(/obj/item/ammo_magazine/minigun_powerpack)
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	wield_delay = 12
	gun_skill_category = SKILL_FIREARMS
	aim_slowdown = 0.8
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_allowed = list(/obj/item/attachable/flashlight, /obj/item/attachable/magnetic_harness)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 12)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 12

	fire_delay = 0.15 SECONDS
	windup_delay = 0.4 SECONDS
	windup_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	scatter = 5
	recoil = 2
	recoil_unwielded = 4
	damage_falloff_mult = 0.5
	movement_acc_penalty_mult = 4

	obj_flags = AUTOBALANCE_CHECK

/obj/item/weapon/gun/minigun/Initialize(mapload)
	. = ..()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.miniguns_in_use += src

/obj/item/weapon/gun/minigun/Destroy()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.miniguns_in_use -= src
	return ..()

/obj/item/weapon/gun/minigun/magharness
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/minigun/valhalla
	obj_flags = NONE

// SG minigun

/obj/item/weapon/gun/minigun/smart_minigun
	name = "\improper SG-85 smart handheld gatling gun"
	desc = "A true monster of providing supportive suppresing fire, the SG-85 is the TGMC's IFF-capable minigun for heavy fire support duty. Boasting a higher firerate than any other handheld weapon. It is chambered in 10x26 caseless."
	icon_state = "minigun_sg"
	item_state = "minigun_sg"
	fire_animation = "minigun_sg_fire"
	max_shells = 1000 //codex
	caliber = CALIBER_10x26_CASELESS //codex
	allowed_ammo_types = list(/obj/item/ammo_magazine/minigun_powerpack/smartgun)
	wield_delay = 1.5 SECONDS
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_skill_category = SKILL_SMARTGUN
	attachable_allowed = list(/obj/item/attachable/flashlight, /obj/item/attachable/magnetic_harness, /obj/item/attachable/motiondetector)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 19, "rail_y" = 29, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 12) //Only has rail attachments so only the rail variables are properly aligned
	aim_slowdown = 1.2
	actions_types = list()

	fire_delay = 0.1 SECONDS
	scatter = -5
	recoil = 0
	recoil_unwielded = 4

	obj_flags = NONE

/obj/item/weapon/gun/minigun/smart_minigun/motion_detector
	starting_attachment_types = list(/obj/item/attachable/motiondetector)

// PEPPERBALL GUN

//-------------------------------------------------------
//PB-12

/obj/item/weapon/gun/rifle/pepperball
	name = "\improper PB-12 pepperball gun"
	desc = "The PB-12 is ostensibly riot control device used by the TGMC in spiffy colors, working through a SAN ball that sends a short acting neutralizing chemical to knock out it's target, or weaken them. Guranteed to work on just about everything. Uses SAN Ball Holders as magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "pepperball"
	item_state = "pepperball"
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	max_shells = 100 //codex
	caliber = CALIBER_PEPPERBALL
	fire_sound = "gun_fb12" // idk why i called it "fb-12", ah too late now
	default_ammo_type = /obj/item/ammo_magazine/rifle/pepperball
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/pepperball)
	force = 30 // two shots weeds as it has no bayonet
	wield_delay = 0.5 SECONDS // Very fast to put up.
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list(
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/flashlight,
		/obj/item/weapon/gun/flamer/hydro_cannon/pepperball,
		/obj/item/attachable/magnetic_harness,
	) // One

	starting_attachment_types = list(/obj/item/weapon/gun/flamer/hydro_cannon/pepperball)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 0.1

	flags_gun_features = GUN_AMMO_COUNTER

	fire_delay = 0.1 SECONDS
	burst_amount = 1
	accuracy_mult = 1
	recoil = 0
	accuracy_mult_unwielded = 0.75
	scatter = -1
	scatter_unwielded = 2

	placed_overlay_iconstate = "pepper"

/obj/item/weapon/gun/flamer/hydro_cannon/pepperball
	name = "coaxial watercannon"
	desc = "For the quenching of unfortunate mistakes."
	icon_state = "hydrocannon_pepper"



/obj/item/weapon/gun/rifle/pepperball/pepperball_mini
	name = "mini pepperball gun"
	desc = "An attachable version of the PB-12 pepperball gun. It has a smaller magazine size and has a slower rate of fire."
	icon_state = "pepperball_mini"
	slot = ATTACHMENT_SLOT_UNDER
	max_shells = 20
	default_ammo_type = /obj/item/ammo_magazine/rifle/pepperball/pepperball_mini
	allowed_ammo_types = list(/obj/item/ammo_magazine/rifle/pepperball/pepperball_mini)
	force = 5
	attachable_allowed = list()
	starting_attachment_types = list()
	actions_types = list()
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	flags_gun_features = GUN_IS_ATTACHMENT | GUN_WIELDED_FIRING_ONLY | GUN_ATTACHMENT_FIRE_ONLY | GUN_AMMO_COUNTER
	fire_delay = 0.2 SECONDS
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	pixel_shift_x = 18
	pixel_shift_y = 16

	wield_delay_mod = 0.2 SECONDS

/particles/backblast
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 100
	spawning = 100
	lifespan = 0.7 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	drift = generator(GEN_CIRCLE, 0, 5)
	scale = 0.3
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.5)

//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket
	name = "\improper RL-5 rocket launcher"
	desc = "The RL-5 is the primary anti-armor used around the galaxy. Used to take out light-tanks and enemy structures, the RL-5 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	default_ammo_type = /obj/item/ammo_magazine/rocket
	allowed_ammo_types = list(/obj/item/ammo_magazine/rocket)
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 12
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1.75
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_AUTO_EJECT_LOCKED
	gun_skill_category = SKILL_FIREARMS
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100
	placed_overlay_iconstate = "sadar"
	windup_delay = 0.4 SECONDS
	///removes backblast damage if false
	var/backblastdamage = TRUE

//Adding in the rocket backblast. The tile behind the specialist gets blasted hard enough to down and slightly wound anyone
/obj/item/weapon/gun/launcher/rocket/apply_gun_modifiers(obj/projectile/projectile_to_fire, atom/target)
	. = ..()
	var/turf/blast_source = get_turf(src)
	var/thrown_dir = REVERSE_DIR(get_dir(blast_source, target))
	var/turf/backblast_loc = get_step(blast_source, thrown_dir)
	var/angle = Get_Angle(loc, target)
	var/x_component = sin(angle) * -30
	var/y_component = cos(angle) * -30
	var/obj/effect/abstract/particle_holder/backblast = new(blast_source, /particles/backblast)
	backblast.particles.velocity = list(x_component, y_component)
	addtimer(VARSET_CALLBACK(backblast.particles, count, 0), 5)
	QDEL_IN(backblast, 0.7 SECONDS)

	if(!backblastdamage)
		return
	for(var/mob/living/carbon/victim in backblast_loc)
		if(victim.lying_angle || victim.stat == DEAD) //Have to be standing up to get the fun stuff
			continue
		victim.adjustBruteLoss(15) //The shockwave hurts, quite a bit. It can knock unarmored targets unconscious in real life
		victim.Paralyze(6 SECONDS) //For good measure
		victim.emote("pain")
		victim.throw_at(get_step(backblast_loc, thrown_dir), 1, 2)


//-------------------------------------------------------
//RL-152 RPG

/obj/item/weapon/gun/launcher/rocket/sadar
	name = "\improper RL-152 sadar rocket launcher"
	desc = "The RL-152 is the primary anti-armor weapon of the TGMC. Used to take out light-tanks and enemy structures, the RL-152 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "sadar"
	item_state = "sadar"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
		slot_s_store_str = 'icons/mob/items_suit_slot_64.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	worn_x_dimension = 64
	max_shells = 1
	caliber = CALIBER_84MM
	load_method = SINGLE_CASING
	default_ammo_type = /obj/item/ammo_magazine/rocket/sadar
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rocket/sadar,
		/obj/item/ammo_magazine/rocket/sadar/unguided,
		/obj/item/ammo_magazine/rocket/sadar/ap,
		/obj/item/ammo_magazine/rocket/sadar/wp,
		/obj/item/ammo_magazine/rocket/sadar/wp/unguided,
	)
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 12
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1.75
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SHOWS_LOADED|GUN_SMOKE_PARTICLES

	gun_skill_category = SKILL_FIREARMS
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 21, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

	obj_flags = AUTOBALANCE_CHECK

/obj/item/weapon/gun/launcher/rocket/sadar/Initialize(mapload, spawn_empty)
	. = ..()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.sadar_in_use += src

/obj/item/weapon/gun/launcher/rocket/sadar/Destroy()
	if(obj_flags & AUTOBALANCE_CHECK)
		SSmonitor.stats.sadar_in_use -= src
	return ..()

/obj/item/weapon/gun/launcher/rocket/sadar/do_fire(obj/object_to_fire)
	. = ..()
	if(!.)
		return FALSE
	gun_user?.record_war_crime()

/obj/item/weapon/gun/launcher/rocket/sadar/valhalla
	obj_flags = NONE

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/weapon/gun/launcher/rocket/m57a4
	name = "\improper RL-57A quad thermobaric launcher"
	desc = "The RL-57A is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "m57a4"
	item_state = "m57a4"
	max_shells = 4 //codex
	caliber = CALIBER_ROCKETARRAY //codex
	load_method = MAGAZINE //codex
	default_ammo_type = /obj/item/ammo_magazine/rocket/m57a4/ds
	allowed_ammo_types = list(/obj/item/ammo_magazine/rocket/m57a4/ds, /obj/item/ammo_magazine/rocket/m57a4)
	aim_slowdown = 2.75
	attachable_allowed = list(
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)
	general_codex_key = "explosive weapons"

	fire_delay = 0.6 SECONDS
	burst_delay = 0.4 SECONDS
	burst_amount = 4
	accuracy_mult = 0.8

	placed_overlay_iconstate = "thermo"

/obj/item/weapon/gun/launcher/rocket/m57a4/do_fire(obj/object_to_fire)
	. = ..()
	if(!.)
		return FALSE
	gun_user?.record_war_crime()

/obj/item/weapon/gun/launcher/rocket/m57a4/deathsquad
	attachable_allowed = list(
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
		/obj/item/attachable/magnetic_harness,
	)
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/launcher/rocket/m57a4/t57
	name = "\improper RL-57 quad thermobaric launcher"
	desc = "The RL-57 is posssibly the most awful man portable weapon. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles with nearly no force to the rocket. Enough said."
	icon_state = "t57"
	item_state = "t57"
	default_ammo_type = /obj/item/ammo_magazine/rocket/m57a4
	allowed_ammo_types = list(/obj/item/ammo_magazine/rocket/m57a4)

/obj/item/weapon/gun/launcher/rocket/m57a4/t57/unloaded
	default_ammo_type = null

//-------------------------------------------------------
//RL-160 Recoilless Rifle. Its effectively an RPG codewise.

/obj/item/weapon/gun/launcher/rocket/recoillessrifle
	name = "\improper RL-160 recoilless rifle"
	desc = "The RL-160 recoilless rifle is a long range explosive ordanance device used by the TGMC used to fire explosive shells at far distances. Uses a variety of 67mm shells designed for various purposes."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t160"
	item_state = "t160"
	max_shells = 1 //codex
	caliber = CALIBER_67MM //codex
	load_method = SINGLE_CASING //codex
	default_ammo_type = /obj/item/ammo_magazine/rocket/recoilless
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rocket/recoilless,
		/obj/item/ammo_magazine/rocket/recoilless/light,
		/obj/item/ammo_magazine/rocket/recoilless/low_impact,
		/obj/item/ammo_magazine/rocket/recoilless/smoke,
		/obj/item/ammo_magazine/rocket/recoilless/cloak,
		/obj/item/ammo_magazine/rocket/recoilless/plasmaloss,
		/obj/item/ammo_magazine/rocket/recoilless/heat,
		/obj/item/ammo_magazine/rocket/recoilless/heam,
	)
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	wield_delay = 1 SECONDS
	recoil = 1
	wield_penalty = 1.6 SECONDS
	aim_slowdown = 1
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
	)

	gun_skill_category = SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

/obj/item/weapon/gun/launcher/rocket/recoillessrifle/low_impact
	default_ammo_type = /obj/item/ammo_magazine/rocket/recoilless/low_impact

/obj/item/weapon/gun/launcher/rocket/recoillessrifle/heam
	default_ammo_type = /obj/item/ammo_magazine/rocket/recoilless/heam

//-------------------------------------------------------
//Disposable RPG

/obj/item/weapon/gun/launcher/rocket/oneuse
	name = "\improper RL-72 disposable rocket launcher"
	desc = "This is the premier disposable rocket launcher used throughout the galaxy, it cannot be reloaded or unloaded on the field. This one fires an 84mm explosive rocket. Spacebar to shorten or extend it to make it storeable or fireable, respectively."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t72"
	item_state = "t72"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	w_class = WEIGHT_CLASS_NORMAL
	default_ammo_type = /obj/item/ammo_magazine/rocket/oneuse
	allowed_ammo_types = list(/obj/item/ammo_magazine/rocket/oneuse)
	reciever_flags = AMMO_RECIEVER_CLOSED|AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT_LOCKED
	flags_equip_slot = ITEM_SLOT_BELT
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_SMOKE_PARTICLES
	attachable_allowed = list(/obj/item/attachable/magnetic_harness)
	/// Indicates extension state of the launcher. True: Fireable and unable to fit in storage. False: Able to fit in storage but must be extended to fire.
	var/extended = FALSE

	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

/obj/item/weapon/gun/launcher/rocket/oneuse/Initialize(mapload, spawn_empty)
	. = ..(mapload, FALSE)

// Do a short windup, swap the extension status of the rocket if successful, then swap the flags.
/obj/item/weapon/gun/launcher/rocket/oneuse/unique_action(mob/living/user)
	playsound(user, 'sound/weapons/guns/misc/oneuse_deploy.ogg', 25, 1)
	if(!do_after(user, 20, NONE, src, BUSY_ICON_DANGER))
		return
	extended = !extended
	if(!extended)
		w_class = WEIGHT_CLASS_NORMAL
		flags_gun_features |= GUN_DEPLOYED_FIRE_ONLY
	else
		w_class = WEIGHT_CLASS_BULKY
		flags_gun_features &= ~GUN_DEPLOYED_FIRE_ONLY
	update_icon()

/obj/item/weapon/gun/launcher/rocket/oneuse/update_icon_state()
	if(extended)
		icon_state = "[base_gun_icon]_extended"
	else
		icon_state = base_gun_icon

/obj/item/weapon/gun/launcher/rocket/oneuse/update_item_state()
	var/current_state = item_state

	item_state = "[base_gun_icon][extended ? "_extended" : ""][flags_item & WIELDED ? "_w" : ""]"

	if(current_state != item_state && ishuman(gun_user))
		var/mob/living/carbon/human/human_user = gun_user
		if(src == human_user.l_hand)
			human_user.update_inv_l_hand()
		else if (src == human_user.r_hand)
			human_user.update_inv_r_hand()

//SOM RPG
/obj/item/weapon/gun/launcher/rocket/som
	name = "\improper V-71 rocket launcher"
	desc = "The V-71 is a man portable rocket propelled grenade launcher employed by the SOM. It's design has changed little over centuries and is light weight and cheap to manufacture, while capable of firing a wide variety of 84mm rockets to provide excellent tactical flexibility."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "rpg"
	item_state = "rpg"
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SHOWS_LOADED|GUN_SMOKE_PARTICLES
	caliber = CALIBER_84MM //codex
	load_method = MAGAZINE //codex
	default_ammo_type = /obj/item/ammo_magazine/rocket/som
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rocket/som,
		/obj/item/ammo_magazine/rocket/som/light,
		/obj/item/ammo_magazine/rocket/som/rad,
		/obj/item/ammo_magazine/rocket/som/incendiary,
		/obj/item/ammo_magazine/rocket/som/heat,
		/obj/item/ammo_magazine/rocket/som/thermobaric,
	)
	wield_delay = 1 SECONDS
	aim_slowdown = 1
	attachable_allowed = list()
	reload_sound = 'sound/weapons/guns/interact/rpg_load.ogg'
	unload_sound = 'sound/weapons/guns/interact/rpg_load.ogg'
	fire_sound = "rpg_fire"

	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	windup_delay = 0.6 SECONDS
	recoil = 2
	scatter = -1
	movement_acc_penalty_mult = 5 //You shouldn't fire this on the move

/obj/item/weapon/gun/launcher/rocket/som/do_fire(obj/object_to_fire)
	. = ..()
	if(!.)
		return FALSE
	if(istype(in_chamber, /obj/item/ammo_magazine/rocket/som/thermobaric || /obj/item/ammo_magazine/rocket/som/rad || /obj/item/ammo_magazine/rocket/som/incendiary))
		gun_user?.record_war_crime()

/obj/item/weapon/gun/launcher/rocket/som/rad
	default_ammo_type = /obj/item/ammo_magazine/rocket/som/rad

/obj/item/weapon/gun/launcher/rocket/som/heat
	default_ammo_type = /obj/item/ammo_magazine/rocket/som/heat

//ICC RPG
/obj/item/weapon/gun/launcher/rocket/icc
	name = "\improper MP-IRL rocket launcher"
	desc = "The Man Portable-Infantry Rocket Launcher is a man portable warhead launcher employed by the ICC. Being capable of firing a wide variety of 83m rear-mounted rockets to provide excellent tactical flexibility in a compact package."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "iccrpg"
	item_state = "iccrpg"
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_SHOWS_LOADED|GUN_SMOKE_PARTICLES
	caliber = CALIBER_84MM //codex
	load_method = MAGAZINE //codex
	default_ammo_type = /obj/item/ammo_magazine/rocket/icc
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rocket/icc,
		/obj/item/ammo_magazine/rocket/icc/light,
		/obj/item/ammo_magazine/rocket/icc/heat,
		/obj/item/ammo_magazine/rocket/icc/thermobaric,
	)
	wield_delay = 1 SECONDS
	aim_slowdown = 1
	attachable_allowed = list()
	reload_sound = 'sound/weapons/guns/interact/rpg_load.ogg'
	unload_sound = 'sound/weapons/guns/interact/rpg_load.ogg'
	fire_sound = "rpg_fire"

	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	windup_delay = 0.6 SECONDS
	recoil = 2
	scatter = -1
	movement_acc_penalty_mult = 5 //You shouldn't fire this on the move

/obj/item/weapon/gun/launcher/rocket/icc/do_fire(obj/object_to_fire)
	. = ..()
	if(!.)
		return FALSE
	if(istype(in_chamber, /obj/item/ammo_magazine/rocket/icc/thermobaric))
		gun_user?.record_war_crime()

//-------------------------------------------------------
//RG-220 Railgun

/obj/item/weapon/gun/rifle/railgun
	name = "\improper RG-220 railgun"
	desc = "The RG-220 is a specialized heavy duty railgun made to shred through hard armor to allow for follow up attacks. Uses specialized canisters to reload."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "railgun"
	item_state = "railgun"
	max_shells = 3 //codex
	caliber = CALIBER_RAILGUN
	fire_sound = 'sound/weapons/guns/fire/railgun.ogg'
	fire_rattle = 'sound/weapons/guns/fire/railgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/railgun
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/railgun,
		/obj/item/ammo_magazine/railgun/smart,
		/obj/item/ammo_magazine/railgun/hvap,
	)
	force = 40
	wield_delay = 1 SECONDS //You're not quick drawing this.
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 31, "rail_y" = 23, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/marine,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_AMMO_COUNTER
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE

	fire_delay = 3 SECONDS
	burst_amount = 1
	accuracy_mult = 2
	recoil = 3
	scatter = 0
	movement_acc_penalty_mult = 6

/obj/item/weapon/gun/rifle/railgun/unloaded
	default_ammo_type = null

//-------------------------------------------------------
//ML-120 Coilgun

/obj/item/weapon/gun/rifle/icc_coilgun
	name = "\improper ML-120 coilgun"
	desc = "The ML-120 coilgun is the most commonly seen coilgun in ICCAF use, firing magnetic projecitles at a incredibly high velocity. It requires some windup but will penetrate walls, your foes, and your friendlies too. So watch out... Uses specialized canisters to reload."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "ml120"
	item_state = "ml120"
	max_shells = 5 //codex
	caliber = CALIBER_RAILGUN
	fire_sound = 'sound/weapons/guns/fire/railgun.ogg'
	fire_rattle = 'sound/weapons/guns/fire/railgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	default_ammo_type = /obj/item/ammo_magazine/rifle/icc_coilgun
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/rifle/icc_coilgun,
	)
	force = 40
	wield_delay = 1 SECONDS //You're not quick drawing this.
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 31, "rail_y" = 23, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/reddot,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE

	fire_delay = 1 SECONDS
	windup_delay = 0.5 SECONDS
	burst_amount = 1
	accuracy_mult = 2
	recoil = 0
	scatter = 0
	movement_acc_penalty_mult = 6
