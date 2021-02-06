//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

//Because this parent type did not exist
//Note that this means that snipers will have a slowdown of 3, due to the scope
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
	caliber = "10x28mm"
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
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	starting_attachment_types = list(/obj/item/attachable/scope/antimaterial, /obj/item/attachable/sniperbarrel)

	fire_delay = 2.5 SECONDS
	burst_amount = 1
	accuracy_mult = 1.50
	recoil = 2


/obj/item/weapon/gun/rifle/sniper/antimaterial/Initialize()
	. = ..()
	LT = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-LASER_LAYER)
	integrated_laze = new(src)

/obj/item/weapon/gun/rifle/sniper/antimaterial/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(targetmarker_primed)
		if(!iscarbon(target))
			return
		if(laser_target)
			deactivate_laser_target()
		if(target.apply_laser())
			activate_laser_target(target, user)
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

/mob/living/carbon/monkey/apply_laser()
	overlays_standing[M_LASER_LAYER] = image("icon" = 'icons/obj/items/projectiles.dmi',"icon_state" = "sniper_laser", "layer" =-M_LASER_LAYER)
	apply_overlay(M_LASER_LAYER)
	return TRUE

/mob/living/carbon/proc/remove_laser()
	return FALSE

/mob/living/carbon/human/remove_laser()
	remove_overlay(LASER_LAYER)
	return TRUE

/mob/living/carbon/xenomorph/remove_laser()
	remove_overlay(X_LASER_LAYER)
	return TRUE

/mob/living/carbon/monkey/remove_laser()
	remove_overlay(M_LASER_LAYER)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/antimaterial/unique_action(mob/user)
	if(!targetmarker_primed && !targetmarker_on)
		return laser_on(user)
	else
		return laser_off(user)


/obj/item/weapon/gun/rifle/sniper/antimaterial/Destroy()
	laser_off()
	QDEL_NULL(integrated_laze)
	. = ..()

/obj/item/weapon/gun/rifle/sniper/antimaterial/dropped()
	laser_off()
	. = ..()

/obj/item/weapon/gun/rifle/sniper/antimaterial/process()
	if(!rail.zoom)
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
		to_chat(user, "<span class='danger'>You lose sight of your target!</span>")
		playsound(user,'sound/machines/click.ogg', 25, 1)

/obj/item/weapon/gun/rifle/sniper/antimaterial/zoom(mob/living/user, tileoffset = 11, viewsize = 12) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	. = ..()
	if(!rail.zoom && (targetmarker_on || targetmarker_primed) )
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
	to_chat(user, "<span class='danger'>You focus your target marker on [target]!</span>")
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
	if(!rail.zoom) //Can only use and prime the laser targeter when zoomed.
		to_chat(user, "<span class='warning'>You must be zoomed in to use your target marker!</span>")
		return TRUE
	targetmarker_primed = TRUE //We prime the target laser
	if(user?.client)
		user.client.click_intercept = src
		to_chat(user, "<span class='notice'><b>You activate your target marker and take careful aim.</b></span>")
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
		to_chat(user, "<span class='notice'><b>You deactivate your target marker.</b></span>")
		playsound(user,'sound/machines/click.ogg', 25, 1)
	return TRUE


/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C anti-tank sniper rifle"
	desc = "A high end mag-rail heavy sniper rifle from Nanotrasen chambered in the heaviest ammo available, 10x99mm Caseless."
	icon_state = "m42c"
	item_state = "m42c"
	max_shells = 6 //codex
	caliber = "10x99mm"
	fire_sound = 'sound/weapons/guns/fire/sniper_heavy.ogg'
	dry_fire_sound = 'sound/weapons/guns/fire/sniper_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/sniper_heavy_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/sniper_heavy_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/sniper_heavy_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/elite
	force = 17
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)
	flags_item_map_variant = NONE
	starting_attachment_types = list(/obj/item/attachable/scope/pmc, /obj/item/attachable/sniperbarrel)
	gun_iff_signal = list(ACCESS_IFF_PMC)

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
			PMC_sniper.visible_message("<span class='warning'>[PMC_sniper] is blown backwards from the recoil of the [src]!</span>","<span class='highdanger'>You are knocked prone by the blowback!</span>")
			step(PMC_sniper,turn(PMC_sniper.dir,180))
			PMC_sniper.Paralyze(10 SECONDS)

//SVD //Based on the Dragunov sniper rifle.

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper SVD Dragunov-033 sniper rifle"
	desc = "A sniper variant of the AK-47 service rifle, with a new stock, barrel, and scope. It doesn't have the punch of modern sniper rifles, but it's finely crafted in 2133 by someone probably illiterate. Fires 7.62x54mmR rounds."
	icon_state = "svd"
	item_state = "svd"
	max_shells = 10 //codex
	caliber = "7.62x54mm Rimmed" //codex
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
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 24, "under_y" = 13, "stock_x" = 20, "stock_y" = 14)
	starting_attachment_types = list(/obj/item/attachable/scope/slavic, /obj/item/attachable/slavicbarrel, /obj/item/attachable/stock/slavic)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 2

	fire_delay = 1.2 SECONDS
	burst_amount = 1
	accuracy_mult = 0.85
	scatter = 15
	recoil = 2



//M4RA marksman rifle

/obj/item/weapon/gun/rifle/m4ra
	name = "\improper T-45 battle rifle"
	desc ="The T-45 is a light specialized battle rifle, mostly used by light infantry and scouts. It's designed to be useable at all ranges due to the compact size it is also very adaptable to different situations due to the ability to use specialized ammo. An experimental, requisitions-only design, takes specialized 'A19' 10x28mm rounds."
	icon_state = "m4ra"
	item_state = "m4ra"
	max_shells = 20 //codex
	muzzleflash_iconstate = "muzzle_flash_medium"
	caliber = "10x28mm caseless" //codex
	fire_sound = 'sound/weapons/guns/fire/t64.ogg'
	unload_sound = 'sound/weapons/guns/interact/m4ra_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/m4ra_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m4ra_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/rifle/m4ra
	force = 16
	aim_slowdown = 0.35
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/bipod,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/grenade,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_iff_signal = list(ACCESS_IFF_MARINE)
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_AUTOMATIC)
	gun_skill_category = GUN_SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	starting_attachment_types = list(/obj/item/attachable/scope/mini/m4ra, /obj/item/attachable/stock/rifle/marksman)
	actions_types = list(/datum/action/item_action/aim_mode)
	aim_fire_delay = 0.2 SECONDS
	aim_speed_modifier = 2

	fire_delay = 0.45 SECONDS
	burst_amount = 1
	accuracy_mult = 1.75
	scatter = -15
	recoil = 2

//-------------------------------------------------------
//SMARTGUN

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper T-90A smartgun"
	desc = "The actual firearm in the 4-piece M56B Smartgun System. This one has TGMC markings, thus designating it a T-90A. It is essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a powerpack. Click the powerpack icon in the top left or use special action to reload."
	icon_state = "m56"
	item_state = "m56"
	max_shells = 100 //codex
	caliber = "10x28mm Caseless" //codex
	fire_sound = "gun_smartgun"
	load_method = POWERPACK //codex
	current_mag = /obj/item/ammo_magazine/internal/smartgun
	flags_equip_slot = NONE
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	wield_delay = 1.6 SECONDS
	aim_slowdown = 1.5
	var/datum/ammo/ammo_secondary = /datum/ammo/bullet/smartgun/lethal//Toggled ammo type
	var/shells_fired_max = 50 //Smartgun only; once you fire # of shells, it will attempt to reload automatically. If you start the reload, the counter resets.
	var/shells_fired_now = 0 //The actual counter used. shells_fired_max is what it is compared to.
	var/restriction_toggled = TRUE //Begin with the safety on.
	gun_skill_category = GUN_SKILL_SMARTGUN
	attachable_allowed = list(
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
	)

	flags_gun_features = GUN_INTERNAL_MAG|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	starting_attachment_types = list(/obj/item/attachable/flashlight)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 16,"rail_x" = 11, "rail_y" = 18, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 14)
	gun_iff_signal = list(ACCESS_IFF_MARINE)

	fire_delay = 0.3 SECONDS
	burst_amount = 4
	accuracy_mult = 1.15
	damage_falloff_mult = 0.5


/obj/item/weapon/gun/smartgun/Initialize()
	. = ..()
	ammo_secondary = GLOB.ammo_list[ammo_secondary]


/obj/item/weapon/gun/smartgun/examine_ammo_count(mob/user)
	to_chat(user, "[current_mag?.current_rounds ? "Ammo counter shows [current_mag.current_rounds] round\s remaining." : "It's dry."]")
	to_chat(user, "The restriction system is [restriction_toggled ? "<B>on</b>" : "<B>off</b>"].")

/obj/item/weapon/gun/smartgun/unique_action(mob/living/carbon/user)
	var/obj/item/smartgun_powerpack/power_pack = user.back
	if(!istype(power_pack))
		return FALSE
	return power_pack.attack_self(user)

/obj/item/weapon/gun/smartgun/able_to_fire(mob/living/user)
	. = ..()
	if(.)
		if(!ishuman(user))
			return FALSE
		var/mob/living/carbon/human/H = user
		if(!istype(H.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner) || !istype(H.back,/obj/item/smartgun_powerpack))
			click_empty(H)
			return FALSE

/obj/item/weapon/gun/smartgun/load_into_chamber(mob/user)
	return ready_in_chamber()

/obj/item/weapon/gun/smartgun/reload_into_chamber(mob/living/carbon/user)
	var/obj/item/smartgun_powerpack/power_pack = user.back
	if(!istype(power_pack))
		return current_mag.current_rounds
	if(shells_fired_now >= shells_fired_max && power_pack.rounds_remaining > 0) // If shells fired exceeds shells needed to reload, and we have ammo.
		addtimer(CALLBACK(src, .proc/auto_reload, user, power_pack), 0.5 SECONDS)
	else
		shells_fired_now++

	return current_mag.current_rounds

/obj/item/weapon/gun/smartgun/delete_bullet(obj/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return 1

/obj/item/weapon/gun/smartgun/toggle_gun_safety()
	var/obj/item/weapon/gun/smartgun/G = get_active_firearm(usr)
	if(!istype(G))
		return //Right kind of gun is not in hands, abort.
	src = G
	to_chat(usr, "[icon2html(src, usr)] You [restriction_toggled? "<B>disable</b>" : "<B>enable</b>"] the [src]'s fire restriction. You will [restriction_toggled ? "harm anyone in your way" : "target through IFF"].")
	playsound(loc,'sound/machines/click.ogg', 25, 1)
	var/A = ammo
	ammo = ammo_secondary
	ammo_secondary = A
	restriction_toggled = !restriction_toggled

/obj/item/weapon/gun/smartgun/proc/auto_reload(mob/smart_gunner, obj/item/smartgun_powerpack/power_pack)
	if(power_pack?.loc == smart_gunner)
		power_pack.attack_self(smart_gunner, TRUE)

/obj/item/weapon/gun/smartgun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/smartgun/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds


/obj/item/weapon/gun/smartgun/dirty
	name = "\improper M56D 'dirty' smartgun"
	desc = "The actual firearm in the 4-piece M56D Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way."
	current_mag = /obj/item/ammo_magazine/internal/smartgun/dirty
	ammo_secondary = /datum/ammo/bullet/smartgun/dirty/lethal
	attachable_allowed = list() //Cannot be upgraded.
	flags_gun_features = GUN_INTERNAL_MAG|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER

	fire_delay = 0.3 SECONDS
	accuracy_mult = 1.1


//-------------------------------------------------------
//GRENADE LAUNCHER

/obj/item/weapon/gun/launcher/m92
	name = "\improper T-26 grenade launcher"
	desc = "A heavy, 6-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m92"
	item_state = "m92"
	max_shells = 6 //codex
	caliber = "40mm grenades" //codex
	load_method = SINGLE_CASING //codex
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = 0.6 SECONDS
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	var/list/grenades = list()
	var/max_grenades = 6
	aim_slowdown = 1
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
	)

	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	var/datum/effect_system/smoke_spread/smoke
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1.8 SECONDS


/obj/item/weapon/gun/launcher/m92/Initialize()
	. = ..()
	for(var/i in 1 to 6)
		grenades += new /obj/item/explosive/grenade/frag(src)


/obj/item/weapon/gun/launcher/m92/examine_ammo_count(mob/user)
	if(!length(grenades) || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, "<span class='notice'> It is loaded with <b>[length(grenades)] / [max_grenades]</b> grenades.</span>")


/obj/item/weapon/gun/launcher/m92/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/explosive/grenade))
		if(length(grenades) >= max_grenades)
			to_chat(user, "<span class='warning'>The grenade launcher cannot hold more grenades!</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return

		grenades += I
		playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 25, 1)
		to_chat(user, "<span class='notice'>You put [I] in the grenade launcher.</span>")
		to_chat(user, "<span class='info'>Now storing: [grenades.len] / [max_grenades] grenades.</span>")

	else if(istype(I, /obj/item/attachable) && check_inactive_hand(user))
		attach_to_gun(user, I)


/obj/item/weapon/gun/launcher/m92/afterattack(atom/target, mob/user, flag)
	if(user.action_busy)
		return
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(user.skills.getRating("firearms") < 0 && !do_after(user, 0.8 SECONDS, TRUE, src))
		return
	if(get_dist(target,user) <= 2)
		to_chat(user, "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>")
		return
	if(!length(grenades))
		to_chat(user, "<span class='warning'>The grenade launcher is empty.</span>")
		return
	fire_grenade(target,user)
	var/obj/screen/ammo/A = user.hud_used.ammo
	A.update_hud(user)


//Doesn't use most of any of these. Listed for reference.
/obj/item/weapon/gun/launcher/m92/load_into_chamber()
	return


/obj/item/weapon/gun/launcher/m92/reload_into_chamber()
	return


/obj/item/weapon/gun/launcher/m92/unload(mob/user)
	if(length(grenades))
		var/obj/item/explosive/grenade/nade = grenades[length(grenades)] //Grab the last one.
		if(user)
			user.put_in_hands(nade)
			playsound(user, unload_sound, 25, 1)
		else
			nade.loc = get_turf(src)
		grenades -= nade
	else
		to_chat(user, "<span class='warning'>It's empty!</span>")
	return TRUE


/obj/item/weapon/gun/launcher/m92/proc/fire_grenade(atom/target, mob/user)
	playsound(user.loc, cocked_sound, 25, 1)
	last_fired = world.time
	visible_message("<span class='danger'>[user] fired a grenade!</span>")
	to_chat(user, "<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/explosive/grenade/F = grenades[1]
	grenades -= F
	F.loc = user.loc
	F.throw_range = 20
	if(F?.loc) //Apparently it can get deleted before the next thing takes place, so it runtimes.
		log_explosion("[key_name(user)] fired a grenade [F] from [src] at [AREACOORD(user.loc)].")
		log_combat(user, src, "fired a grenade [F] from [src]")
		F.det_time = min(10, F.det_time)
		F.launched = TRUE
		F.activate()
		F.throwforce += F.launchforce //Throws with signifcantly more force than a standard marine can.
		F.throw_at(target, 20, 3, user)
		playsound(F.loc, fire_sound, 50, 1)
		if(fire_animation)
			flick("[fire_animation]", src)

/obj/item/weapon/gun/launcher/m92/get_ammo_type()
	if(length(grenades) == 0)
		return list("empty", "empty")
	else
		var/obj/item/explosive/grenade/F = grenades[1]
		return list(F.hud_state, F.hud_state_empty)

/obj/item/weapon/gun/launcher/m92/get_ammo_count()
	return length(grenades)

//-------------------------------------------------------
//T-70 Grenade Launcher.

/obj/item/weapon/gun/launcher/m92/standardmarine
	name = "\improper T-70 grenade launcher"
	desc = "The T-70 is the standard grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t70"
	item_state = "t70"
	fire_animation = "t70_fire"
	max_shells = 6 //codex
	caliber = "40mm grenades" //codex
	load_method = SINGLE_CASING //codex
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = 1 SECONDS
	fire_sound = 'sound/weapons/guns/fire/underbarrel_grenadelauncher.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	aim_slowdown = 1.2
	general_codex_key = "explosive weapons"
	attachable_allowed = list(
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
	)

	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	starting_attachment_types = list(/obj/item/attachable/stock/t70stock)
	gun_skill_category = GUN_SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 11, "stock_y" = 12)

	fire_delay = 1.2 SECONDS

/obj/item/weapon/gun/launcher/m92/standardmarine/Initialize()
	. = ..()
	grenades.Cut(1,0)

/obj/item/weapon/gun/launcher/m81
	name = "\improper T-81 grenade launcher"
	desc = "A lightweight, single-shot grenade launcher used by the TerraGov Marine Corps for area denial and big explosions."
	icon_state = "m81"
	item_state = "m81"
	max_shells = 1 //codex
	caliber = "40mm grenades" //codex
	load_method = SINGLE_CASING //codex
	materials = list(/datum/material/metal = 7000)
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = 0.2 SECONDS
	fire_sound = 'sound/weapons/guns/fire/grenadelauncher.ogg'
	cocked_sound = 'sound/weapons/guns/interact/m92_cocked.ogg'
	aim_slowdown = 1
	gun_skill_category = GUN_SKILL_FIREARMS
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER
	attachable_allowed = list()
	var/grenade
	var/grenade_type_allowed = /obj/item/explosive/grenade
	var/riot_version
	general_codex_key = "explosive weapons"
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1.05 SECONDS


/obj/item/weapon/gun/launcher/m81/Initialize(mapload, spawn_empty)
	. = ..()
	if(!spawn_empty)
		if(riot_version)
			grenade = new /obj/item/explosive/grenade/chem_grenade/teargas(src)
		else
			grenade = new /obj/item/explosive/grenade/frag(src)


/obj/item/weapon/gun/launcher/m81/examine_ammo_count(mob/user)
	if(!grenade || (get_dist(user, src) > 2 && user != loc))
		return
	to_chat(user, "<span class='notice'> It is loaded with a grenade.</span>")


/obj/item/weapon/gun/launcher/m81/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/explosive/grenade))
		if(!istype(I, grenade_type_allowed))
			to_chat(user, "<span class='warning'>[src] can't use this type of grenade!</span>")
			return

		if(grenade)
			to_chat(user, "<span class='warning'>The grenade launcher cannot hold more grenades!</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return

		grenade = I
		to_chat(user, "<span class='notice'>You put [I] in the grenade launcher.</span>")

	else if(istype(I, /obj/item/attachable) && check_inactive_hand(user))
		attach_to_gun(user, I)


/obj/item/weapon/gun/launcher/m81/afterattack(atom/target, mob/user, flag)
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(get_dist(target,user) <= 2)
		to_chat(user, "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>")
		return
	if(!grenade)
		to_chat(user, "<span class='warning'>The grenade launcher is empty.</span>")
		return
	fire_grenade(target,user)
	playsound(user.loc, cocked_sound, 25, 1)


//Doesn't use most of any of these. Listed for reference.
/obj/item/weapon/gun/launcher/m81/load_into_chamber()
	return


/obj/item/weapon/gun/launcher/m81/reload_into_chamber()
	return


/obj/item/weapon/gun/launcher/m81/unload(mob/user)
	if(grenade)
		var/obj/item/explosive/grenade/nade = grenade
		if(user)
			user.put_in_hands(nade)
			playsound(user, unload_sound, 25, 1)
		else
			nade.loc = get_turf(src)
		grenade = null
	else
		to_chat(user, "<span class='warning'>It's empty!</span>")
	return TRUE


/obj/item/weapon/gun/launcher/m81/proc/fire_grenade(atom/target, mob/user)
	set waitfor = 0
	last_fired = world.time
	user.visible_message("<span class='danger'>[user] fired a grenade!</span>", \
						"<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/explosive/grenade/F = grenade
	grenade = null
	F.loc = user.loc
	F.throw_range = 20
	F.throw_at(target, 20, 2, user)
	if(F?.loc) //Apparently it can get deleted before the next thing takes place, so it runtimes.
		log_explosion("[key_name(user)] fired a grenade [F] from \a [src] at [AREACOORD(user.loc)].")
		message_admins("[ADMIN_TPMONTY(user)] fired a grenade [F] from \a [src].")
		F.icon_state = initial(F.icon_state) + "_active"
		F.activate()
		F.updateicon()
		playsound(F.loc, fire_sound, 50, 1)
		addtimer(CALLBACK(F, /obj/item/explosive/grenade.proc/prime), 1 SECONDS)

/obj/item/weapon/gun/launcher/m81/riot
	name = "\improper M81 riot grenade launcher"
	desc = "A lightweight, single-shot grenade launcher to launch tear gas grenades. Used by Nanotrasen security during riots."
	grenade_type_allowed = /obj/item/explosive/grenade/chem_grenade
	riot_version = TRUE
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_POLICE|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	req_access = list(ACCESS_MARINE_BRIG)


//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket
	name = "\improper M-5 rocket launcher"
	desc = "The M-5 is the primary anti-armor used around the galaxy. Used to take out light-tanks and enemy structures, the M-5 rocket launcher is a dangerous weapon with a variety of combat uses. Uses a variety of 84mm rockets."
	icon_state = "m5"
	item_state = "m5"
	max_shells = 1 //codex
	caliber = "84mm rockets" //codex
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
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	dry_fire_sound = 'sound/weapons/guns/fire/launcher_empty.ogg'
	reload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	unload_sound = 'sound/weapons/guns/interact/launcher_reload.ogg'
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	var/datum/effect_system/smoke_spread/smoke

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100


/obj/item/weapon/gun/launcher/rocket/Initialize(mapload, spawn_empty)
	. = ..()
	smoke = new(src, FALSE)

/obj/item/weapon/gun/launcher/rocket/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/weapon/gun/launcher/rocket/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	if(!able_to_fire(user) || user.action_busy)
		return

	if(gun_on_cooldown(user))
		return

	var/delay = 0.1 SECONDS
	if(has_attachment(/obj/item/attachable/scope/mini))
		delay += 0.2 SECONDS

	if(user.skills.getRating("firearms") < 0)
		delay += 0.6 SECONDS

	if(!do_after(user, delay, TRUE, src, BUSY_ICON_DANGER)) //slight wind up
		return

	playsound(loc,'sound/weapons/guns/fire/launcher.ogg', 50, TRUE)
	. = ..()


	//loaded_rocket.current_rounds = max(loaded_rocket.current_rounds - 1, 0)

	if(current_mag && !current_mag.current_rounds)
		current_mag.loc = get_turf(src)
		current_mag.update_icon()
		current_mag = null

	log_combat(usr, usr, "fired the [src].")
	log_explosion("[usr] fired the [src] at [AREACOORD(loc)].")


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
	user.visible_message("<span class='notice'>[user] loads [magazine] into [src]!</span>",
	"<span class='notice'>You load [magazine] into [src]!</span>", null, 3)
	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)
	update_icon()


/obj/item/weapon/gun/launcher/rocket/unload(mob/user)
	if(!user)
		return FALSE
	if(!current_mag || current_mag.loc != src)
		to_chat(user, "<span class='warning'>[src] is already empty!</span>")
		return TRUE
	to_chat(user, "<span class='notice'>You begin unloading [src].</span>")
	if(!do_after(user, current_mag.reload_delay * 0.5, TRUE, src, BUSY_ICON_GENERIC))
		to_chat(user, "<span class='warning'>Your unloading was interrupted!</span>")
		return TRUE
	if(!user) //If we want to drop it on the ground or there's no user.
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>", null, 4)
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
	caliber = "84mm rockets" //codex
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
	. = ..()
	SSmonitor.stats.sadar_in_use -= src

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/weapon/gun/launcher/rocket/m57a4
	name = "\improper M57A4 quad thermobaric launcher"
	desc = "The M57A4 is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "m57a4"
	item_state = "m57a4"
	max_shells = 4 //codex
	caliber = "84mm rockets" //codex
	load_method = MAGAZINE //codex
	current_mag = /obj/item/ammo_magazine/rocket/m57a4
	aim_slowdown = 2.75
	attachable_allowed = list()
	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	general_codex_key = "explosive weapons"

	fire_delay = 0.6 SECONDS
	burst_delay = 0.4 SECONDS
	burst_amount = 4
	accuracy_mult = 0.8


//-------------------------------------------------------
//T-160 Recoilless Rifle. Its effectively an RPG codewise.

/obj/item/weapon/gun/launcher/rocket/recoillessrifle
	name = "\improper T-160 recoilless rifle"
	desc = "The T-160 recoilless rifle is a long range explosive ordanance device used by the TGMC used to fire explosive shells at far distances. Uses a variety of 67mm shells designed for various purposes."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "t160"
	item_state = "t160"
	max_shells = 1 //codex
	caliber = "67mm shells" //codex
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
	)

	flags_gun_features = GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_FIREARMS
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)

	fire_delay = 1 SECONDS
	recoil = 3
	scatter = -100

//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket/oneuse
	name = "\improper T-72 rocket launcher"
	desc = "This is the premier disposable rocket launcher used throughout the galaxy, it cannot be reloaded or unloaded on the field. This one fires a 68mm explosive rocket."
	icon_state = "t72"
	item_state = "t72"
	max_shells = 1 //codex
	caliber = "84mm rockets" //codex
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
	to_chat(user, "<span class='warning'>You can't unload this!</span>")
	return FALSE


/obj/item/weapon/gun/launcher/rocket/oneuse/examine_ammo_count(mob/user)
	if(current_mag?.current_rounds)
		to_chat(user, "It's loaded.")
	else
		to_chat(user, "It's empty.")

//-------------------------------------------------------
//This gun is very powerful, but also has a kick.

/obj/item/weapon/gun/minigun
	name = "\improper T-100 Minigun"
	desc = "A six barreled rotary machine gun, The ultimate in man-portable firepower, capable of laying down high velocity armor piercing rounds this thing will no doubt pack a punch."
	icon_state = "minigun"
	item_state = "minigun"
	max_shells = 500 //codex
	caliber = "7.62x51mm" //codex
	load_method = MAGAZINE //codex
	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'
	unload_sound = 'sound/weapons/guns/interact/minigun_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/minigun_reload.ogg'
	cocked_sound = 'sound/weapons/guns/interact/minigun_cocked.ogg'
	current_mag = /obj/item/ammo_magazine/minigun
	type_of_casings = "cartridge"
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	wield_delay = 12
	gun_skill_category = GUN_SKILL_FIREARMS
	aim_slowdown = 0.8
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WIELDED_FIRING_ONLY|GUN_LOAD_INTO_CHAMBER|GUN_AMMO_COUNTER
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_allowed = list(/obj/item/attachable/flashlight)
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 24, "under_y" = 14, "stock_x" = 24, "stock_y" = 12)

	fire_delay = 0.175 SECONDS
	scatter = 10
	recoil = 2
	recoil_unwielded = 4
	damage_falloff_mult = 0.5

/obj/item/weapon/gun/minigun/Initialize(mapload, spawn_empty)
	. = ..()
	SSmonitor.stats.miniguns_in_use += src

/obj/item/weapon/gun/minigun/Destroy()
	. = ..()
	SSmonitor.stats.miniguns_in_use -= src

//This is a minigun not a chaingun.
obj/item/weapon/gun/minigun/Fire(atom/target, mob/living/user, params, reflex = FALSE, dual_wield)
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_minigun_start.ogg', 30)
	if(!do_after(user, 0.15 SECONDS, TRUE, src, BUSY_ICON_DANGER, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
		return
	return ..()


/obj/item/weapon/gun/minigun/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/minigun/get_ammo_count()
	if(!current_mag)
		return in_chamber ? 1 : 0
	else
		return in_chamber ? (current_mag.current_rounds + 1) : current_mag.current_rounds
