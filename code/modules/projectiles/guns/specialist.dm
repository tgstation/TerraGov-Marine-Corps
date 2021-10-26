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
	gun_skill_category = GUN_SKILL_RIFLES
	wield_delay = 1 SECONDS

//Pow! Headshot

/obj/item/weapon/gun/rifle/sniper/antimaterial
	name = "\improper T-26 scoped rifle"
	desc = "The T-26 is an IFF capable sniper rifle which is mostly used by long range marksmen. It excels in long-range combat situations and support sniping. It has a laser designator installed, and the scope itself has IFF integrated into it. Uses specialized 10x28 caseless rounds made to work with the guns odd IFF-scope system.  \nIt has an integrated Target Marker and a Laser Targeting system.\n\"Peace Through Superior Firepower\"."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t26"
	item_state = "t26"
	max_shells = 15 //codex
	caliber = CALIBER_10X28
	fire_sound = 'sound/weapons/guns/fire/sniper.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	current_mag = /obj/item/ammo_magazine/sniper
	force = 12
	wield_delay = 12 //Ends up being 1.6 seconds due to scope
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	var/targetmarker_on = FALSE
	var/targetmarker_primed = FALSE
	var/mob/living/carbon/laser_target = null
	var/image/LT = null
	var/obj/item/binoculars/tactical/integrated_laze = null
	attachable_allowed = list(
		/obj/item/attachable/bipod,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/antimaterial,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/sniperbarrel,
		/obj/item/attachable/scope/pmc,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF
	starting_attachment_types = list(/obj/item/attachable/scope/antimaterial, /obj/item/attachable/sniperbarrel)

	fire_delay = 2.5 SECONDS
	burst_amount = 1
	accuracy_mult = 1.50
	recoil = 2

	placed_overlay_iconstate = "antimat"


/obj/item/weapon/gun/rifle/sniper/antimaterial/Initialize()
	. = ..()
	LT = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-LASER_LAYER)
	integrated_laze = new(src)

/obj/item/weapon/gun/rifle/sniper/antimaterial/Fire()
	if(!able_to_fire(gun_user))
		return
	if(gun_on_cooldown(gun_user))
		return
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

/obj/item/weapon/gun/rifle/sniper/antimaterial/cock(mob/user)
	return TRUE

/obj/item/weapon/gun/rifle/sniper/antimaterial/unique_action(mob/user)
	. = ..()
	if(!.)
		return
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
	if(!can_see(user, laser_target, length=24))
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
	RegisterSignal(src, COMSIG_PROJ_SCANTURF, .proc/scan_turf_for_target)
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
	if(user?.client)
		user.client.click_intercept = src
		to_chat(user, span_notice("<b>You activate your target marker and take careful aim.</b>"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/antimaterial/proc/laser_off(mob/user)
	if(targetmarker_on)
		if(laser_target)
			deactivate_laser_target()
		accuracy_mult -= 0.50 //We lose a big accuracy bonus vs the now unlasered target
		STOP_PROCESSING(SSobj, src)
		targetmarker_on = FALSE
	targetmarker_primed = FALSE
	if(user?.client)
		user.client.click_intercept = null
		to_chat(user, span_notice("<b>You deactivate your target marker.</b>"))
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C anti-tank sniper rifle"
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
	current_mag = /obj/item/ammo_magazine/sniper/elite
	force = 17
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)
	flags_item_map_variant = NONE
	attachable_allowed = list(
		/obj/item/attachable/bipod,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/scope/antimaterial,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/sniperbarrel,
		/obj/item/attachable/scope/pmc,
	)
	starting_attachment_types = list(/obj/item/attachable/scope/pmc, /obj/item/attachable/sniperbarrel)

	fire_delay = 1.5 SECONDS
	accuracy_mult = 1.50
	scatter = 15
	recoil = 5
	burst_amount = 1


/obj/item/weapon/gun/rifle/sniper/elite/simulate_recoil(total_recoil = 0, mob/user)
	. = ..()
	if(.)
		var/mob/living/carbon/human/PMC_sniper = user
		if(PMC_sniper.lying_angle == 0 && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC) && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/veteran))
			PMC_sniper.visible_message(span_warning("[PMC_sniper] is blown backwards from the recoil of the [src]!"),span_highdanger("You are knocked prone by the blowback!"))
			step(PMC_sniper,turn(PMC_sniper.dir,180))
			PMC_sniper.Paralyze(10 SECONDS)

//SVD //Based on the Dragunov sniper rifle.

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper SVD Dragunov-033 sniper rifle"
	desc = "A semiautomatic sniper rifle, famed for it's marksmanship, and is built from the ground up for it. Fires 7.62x54mmR rounds."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "svd"
	item_state = "svd"
	max_shells = 10 //codex
	caliber = CALIBER_762X54 //codex
	fire_sound = 'sound/weapons/guns/fire/svd.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/svd_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/svd_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/svd_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/svd
	type_of_casings = "cartridge"
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/slavic,
		/obj/item/attachable/slavicbarrel,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 22, "rail_y" = 22, "under_x" = 24, "under_y" = 13, "stock_x" = 20, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/scope/slavic, /obj/item/attachable/slavicbarrel)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.8 SECONDS
	aim_speed_modifier = 0.75

	fire_delay = 1.2 SECONDS
	burst_amount = 1
	accuracy_mult = 0.95
	scatter = -20
	recoil = -1
	wield_delay = 1.8 SECONDS



//Based off the XM-8. TX-8 rifle

/obj/item/weapon/gun/rifle/tx8
	name = "\improper TX-8 scout rifle"
	desc ="The TX-8 is a light specialized scout rifle, mostly used by light infantry and scouts. It's designed to be useable at all ranges by being very adaptable to different situations due to the ability to use different ammo types. Has IFF.  Takes specialized overpressured 10x28mm rounds."
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
	current_mag = /obj/item/ammo_magazine/rifle/tx8
	force = 16
	aim_slowdown = 0.45
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonetknife,
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

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER|GUN_IFF
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = GUN_SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 44, "muzzle_y" = 18,"rail_x" = 16, "rail_y" = 25, "under_x" = 27, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)


	fire_delay = 0.4 SECONDS
	burst_amount = 1
	accuracy_mult = 1.4
	scatter = -15
	recoil = 2


//-------------------------------------------------------
// MINIGUN

/obj/item/weapon/gun/minigun
	name = "\improper T-100 Minigun"
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
	current_mag = /obj/item/ammo_magazine/internal/minigun
	type_of_casings = "cartridge"
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	wield_delay = 12
	var/shells_fired_max = 50 //minigun only; once you fire # of shells, it will attempt to reload automatically. If you start the reload, the counter resets.
	var/shells_fired_now = 0 //The actual counter used. shells_fired_max is what it is compared to.

	gun_skill_category = GUN_SKILL_FIREARMS
	aim_slowdown = 0.8
	flags_gun_features = GUN_INTERNAL_MAG|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_allowed = list(/obj/item/attachable/flashlight, /obj/item/attachable/magnetic_harness)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 12)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.1 SECONDS
	aim_speed_modifier = 12

	fire_delay = 0.15 SECONDS
	scatter = 10
	recoil = 2
	recoil_unwielded = 4
	damage_falloff_mult = 0.5



/obj/item/weapon/gun/minigun/Initialize()
	. = ..()
	SSmonitor.stats.miniguns_in_use += src

/obj/item/weapon/gun/minigun/Destroy()
	SSmonitor.stats.miniguns_in_use -= src
	return ..()


/obj/item/weapon/gun/minigun/examine_ammo_count(mob/user)
	to_chat(user, "[current_mag?.current_rounds ? "Ammo counter shows [current_mag.current_rounds] round\s remaining." : "It's dry."]")

//The minigun needs to wind up to fire.
/obj/item/weapon/gun/minigun/Fire()
	if(!able_to_fire(gun_user))
		return
	if(windup_checked == WEAPON_WINDUP_NOT_CHECKED)
		playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
		INVOKE_ASYNC(src, .proc/do_windup)
		return
	else if (windup_checked == WEAPON_WINDUP_CHECKING)//We are already in windup, continue
		return
	. = ..()
	if(!.)
		windup_checked = WEAPON_WINDUP_NOT_CHECKED

///Windup before firing
/obj/item/weapon/gun/minigun/proc/do_windup()
	windup_checked = WEAPON_WINDUP_CHECKING
	if(!do_after(gun_user, 0.4 SECONDS, TRUE, src, BUSY_ICON_DANGER, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
		windup_checked = WEAPON_WINDUP_NOT_CHECKED
		return
	windup_checked = WEAPON_WINDUP_CHECKED
	SEND_SIGNAL(src, COMSIG_GUN_FIRE)

/obj/item/weapon/gun/minigun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/minigun/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds

/obj/item/weapon/gun/minigun/cock(mob/living/carbon/user)
	var/obj/item/minigun_powerpack/power_pack = user.back
	if(!istype(power_pack))
		return FALSE
	return power_pack.attack_self(user)

/obj/item/weapon/gun/minigun/able_to_fire(mob/living/user)
	. = ..()
	if(.)
		if(!ishuman(user))
			return FALSE
		var/mob/living/carbon/human/H = user
		if(!istype(H.back,/obj/item/minigun_powerpack))
			click_empty(H)
			return FALSE

/obj/item/weapon/gun/minigun/load_into_chamber(mob/user)
	return ready_in_chamber()

/obj/item/weapon/gun/minigun/reload_into_chamber(mob/living/carbon/user)
	var/obj/item/minigun_powerpack/power_pack = user.back
	if(!istype(power_pack))
		return current_mag.current_rounds
	if(shells_fired_now >= shells_fired_max && power_pack.rounds_remaining > 0) // If shells fired exceeds shells needed to reload, and we have ammo.
		addtimer(CALLBACK(src, .proc/auto_reload, user, power_pack), 0.5 SECONDS)
	else
		shells_fired_now++

	return current_mag.current_rounds

/obj/item/weapon/gun/minigun/delete_bullet(obj/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return 1

/obj/item/weapon/gun/minigun/proc/auto_reload(mob/minigunner, obj/item/minigun_powerpack/power_pack)
	if(power_pack?.loc == minigunner)
		power_pack.attack_self(minigunner, TRUE)

/obj/item/weapon/gun/minigun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/minigun/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds




// PEPPERBALL GUN

//-------------------------------------------------------
//TLLL-12

/obj/item/weapon/gun/rifle/pepperball
	name = "\improper TLLL-12 pepperball gun"
	desc = "The TLLL-12 is ostensibly riot control device used by the TGMC in spiffy colors, working through a SAN ball that sends a short acting neutralizing chemical to knock out it's target, or weaken them. Guranteed to work on just about everything. Uses SAN Ball Holders as magazines."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "pepperball"
	item_state = "pepperball"
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	max_shells = 70 //codex
	caliber = CALIBER_PEPPERBALL
	current_mag = /obj/item/ammo_magazine/rifle/pepperball
	force = 30 // two shots weeds as it has no bayonet
	wield_delay = 0.5 SECONDS // Very fast to put up.
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list(
		/obj/item/attachable/buildasentry,
	) // One
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_AMMO_COUNTER

	fire_delay = 0.1 SECONDS
	burst_amount = 1
	accuracy_mult = 1.75
	recoil = 0
	accuracy_mult_unwielded = 0.75
	scatter = -5
	scatter_unwielded = 5

	placed_overlay_iconstate = "pepper"

//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket
	name = "\improper M-5 rocket launcher"
	desc = "The M-5 is the primary anti-armor used around the galaxy. Used to take out light-tanks and enemy structures, the M-5 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket
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
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100
	placed_overlay_iconstate = "sadar"
	///the smoke effect after firing
	var/datum/effect_system/smoke_spread/smoke

/obj/item/weapon/gun/launcher/rocket/Initialize(mapload, spawn_empty)
	. = ..()
	smoke = new(src, FALSE)

/obj/item/weapon/gun/launcher/rocket/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/weapon/gun/launcher/rocket/Fire()
	if((!CHECK_BITFIELD(flags_item, IS_DEPLOYED) && !able_to_fire(gun_user)) || gun_user?.do_actions)
		return

	if(gun_on_cooldown(gun_user))
		return

	if(windup_checked == WEAPON_WINDUP_NOT_CHECKED)
		INVOKE_ASYNC(src, .proc/do_windup)
		return TRUE
	else if (windup_checked == WEAPON_WINDUP_CHECKING)//We are already in windup, abort
		return TRUE

	. = ..()

	//loaded_rocket.current_rounds = max(loaded_rocket.current_rounds - 1, 0)

	if(current_mag && !current_mag.current_rounds)
		current_mag.loc = get_turf(src)
		current_mag.update_icon()
		current_mag = null
	log_combat(gun_user, gun_user, "fired the [src].")
	log_explosion("[gun_user] fired the [src] at [AREACOORD(loc)].")

///Windup before shooting
/obj/item/weapon/gun/launcher/rocket/proc/do_windup()
	windup_checked = WEAPON_WINDUP_CHECKING
	var/delay = 0.1 SECONDS
	if(has_attachment(/obj/item/attachable/scope/mini))
		delay += 0.2 SECONDS

	if(gun_user && gun_user.skills.getRating("firearms") < 0)
		delay += 0.6 SECONDS

	if(gun_user)
		if(!do_after(gun_user, delay, TRUE, src, BUSY_ICON_DANGER)) //slight wind up
			windup_checked = WEAPON_WINDUP_NOT_CHECKED
			return
		finish_windup()
		return

	addtimer(CALLBACK(src, .proc/finish_windup), delay)

///Proc that finishes the windup, this fires the gun.
/obj/item/weapon/gun/launcher/rocket/proc/finish_windup()
	windup_checked = WEAPON_WINDUP_CHECKED
	if(Fire())
		playsound(loc,'sound/weapons/guns/fire/launcher.ogg', 50, TRUE)
		return
	windup_checked = WEAPON_WINDUP_NOT_CHECKED


/obj/item/weapon/gun/launcher/rocket/examine_ammo_count(mob/user)
	if(current_mag?.current_rounds)
		to_chat(user, "It's ready to rocket.")
	else
		to_chat(user, "It's empty.")


/obj/item/weapon/gun/launcher/rocket/load_into_chamber(mob/user)
	return ready_in_chamber()


//No such thing
/obj/item/weapon/gun/launcher/rocket/reload_into_chamber(mob/user)
	return TRUE


/obj/item/weapon/gun/launcher/rocket/delete_bullet(obj/projectile/projectile_to_fire, refund = FALSE)
	qdel(projectile_to_fire)
	if(refund)
		current_mag.current_rounds++
	return TRUE


/obj/item/weapon/gun/launcher/rocket/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	user.transferItemToLoc(magazine, src) //Click!
	current_mag = magazine
	ammo = GLOB.ammo_list[current_mag.default_ammo]
	user.visible_message(span_notice("[user] loads [magazine] into [src]!"),
	span_notice("You load [magazine] into [src]!"), null, 3)
	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)
	update_icon()


/obj/item/weapon/gun/launcher/rocket/unload(mob/user)
	if(!user)
		return FALSE
	if(!current_mag || current_mag.loc != src)
		to_chat(user, span_warning("[src] is already empty!"))
		return TRUE
	to_chat(user, span_notice("You begin unloading [src]."))
	if(!do_after(user, current_mag.reload_delay * 0.5, TRUE, src, BUSY_ICON_GENERIC))
		to_chat(user, span_warning("Your unloading was interrupted!"))
		return TRUE
	if(!user) //If we want to drop it on the ground or there's no user.
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message(span_notice("[user] unloads [current_mag] from [src]."),
	span_notice("You unload [current_mag] from [src]."), null, 4)
	current_mag.update_icon()
	current_mag = null

	return TRUE


//Adding in the rocket backblast. The tile behind the specialist gets blasted hard enough to down and slightly wound anyone
/obj/item/weapon/gun/launcher/rocket/apply_gun_modifiers(obj/projectile/projectile_to_fire, atom/target)
	. = ..()
	var/turf/blast_source = get_turf(src)
	var/thrown_dir = REVERSE_DIR(get_dir(blast_source, target))
	var/turf/backblast_loc = get_step(blast_source, thrown_dir)
	smoke.set_up(0, backblast_loc)
	smoke.start()
	for(var/mob/living/carbon/victim in backblast_loc)
		if(victim.lying_angle || victim.stat == DEAD) //Have to be standing up to get the fun stuff
			continue
		victim.adjustBruteLoss(15) //The shockwave hurts, quite a bit. It can knock unarmored targets unconscious in real life
		victim.Paralyze(60) //For good measure
		victim.emote("pain")
		victim.throw_at(get_step(backblast_loc, thrown_dir), 1, 2)


/obj/item/weapon/gun/launcher/rocket/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/launcher/rocket/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds

//-------------------------------------------------------
//T-152 RPG

/obj/item/weapon/gun/launcher/rocket/sadar
	name = "\improper T-152 rocket launcher"
	desc = "The T-152 is the primary anti-armor weapon of the TGMC. Used to take out light-tanks and enemy structures, the T-152 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket/sadar
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
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

/obj/item/weapon/gun/launcher/rocket/sadar/Initialize(mapload, spawn_empty)
	. = ..()
	SSmonitor.stats.sadar_in_use += src

/obj/item/weapon/gun/launcher/rocket/sadar/Destroy()
	SSmonitor.stats.sadar_in_use -= src
	return ..()

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/weapon/gun/launcher/rocket/m57a4
	name = "\improper M57A4 quad thermobaric launcher"
	desc = "The M57A4 is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "m57a4"
	item_state = "m57a4"
	max_shells = 4 //codex
	caliber = CALIBER_ROCKETARRAY //codex
	load_method = MAGAZINE //codex
	current_mag = /obj/item/ammo_magazine/rocket/m57a4/ds
	aim_slowdown = 2.75
	attachable_allowed = list(
		/obj/item/attachable/buildasentry,
	)
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	general_codex_key = "explosive weapons"

	fire_delay = 0.6 SECONDS
	burst_delay = 0.4 SECONDS
	burst_amount = 4
	accuracy_mult = 0.8

	placed_overlay_iconstate = "thermo"

/obj/item/weapon/gun/launcher/rocket/m57a4/t57
	name = "\improper T-57 quad thermobaric launcher"
	desc = "The T-57 is posssibly the most awful man portable weapon. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles with nearly no force to the rocket. Enough said."
	icon_state = "t57"
	item_state = "t57"
	current_mag = /obj/item/ammo_magazine/rocket/m57a4



//-------------------------------------------------------
//T-160 Recoilless Rifle. Its effectively an RPG codewise.

/obj/item/weapon/gun/launcher/rocket/recoillessrifle
	name = "\improper T-160 recoilless rifle"
	desc = "The T-160 recoilless rifle is a long range explosive ordanance device used by the TGMC used to fire explosive shells at far distances. Uses a variety of 67mm shells designed for various purposes."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t160"
	item_state = "t160"
	max_shells = 1 //codex
	caliber = CALIBER_67MM //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 10000)
	current_mag = /obj/item/ammo_magazine/rocket/recoilless
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
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/buildasentry,
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

//-------------------------------------------------------
//Disposable RPG

/obj/item/weapon/gun/launcher/rocket/oneuse
	name = "\improper T-72 disposable rocket launcher"
	desc = "This is the premier disposable rocket launcher used throughout the galaxy, it cannot be reloaded or unloaded on the field. This one fires an 84mm explosive rocket."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t72"
	item_state = "t72"
	max_shells = 1 //codex
	caliber = CALIBER_84MM //codex
	load_method = SINGLE_CASING //codex
	current_mag = /obj/item/ammo_magazine/rocket/oneuse
	flags_equip_slot = ITEM_SLOT_BELT
	attachable_allowed = list(/obj/item/attachable/magnetic_harness)

	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

/obj/item/weapon/gun/launcher/rocket/oneuse/unload(mob/user) // Unsurprisngly you can't unload this.
	to_chat(user, span_warning("You can't unload this!"))
	return FALSE


/obj/item/weapon/gun/launcher/rocket/oneuse/examine_ammo_count(mob/user)
	if(current_mag?.current_rounds)
		to_chat(user, "It's loaded.")
	else
		to_chat(user, "It's empty.")

//-------------------------------------------------------
//TX-220 Railgun

/obj/item/weapon/gun/rifle/railgun
	name = "\improper TX-220 railgun"
	desc = "The TX-220 is a specialized heavy duty railgun made to shred through hard armor to allow for follow up attacks. Uses specialized canisters to reload."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "railgun"
	item_state = "railgun"
	max_shells = 1 //codex
	caliber = CALIBER_RAILGUN
	fire_sound = 'sound/weapons/guns/fire/railgun.ogg'
	fire_rattle = 'sound/weapons/guns/fire/railgun.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_reload.ogg'
	current_mag = /obj/item/ammo_magazine/railgun
	force = 40
	wield_delay = 1.75 SECONDS //You're not quick drawing this.
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER

	fire_delay = 1 SECONDS
	burst_amount = 1
	accuracy_mult = 2
	recoil = 0
