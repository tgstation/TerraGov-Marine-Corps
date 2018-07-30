//-------------------------------------------------------
//SNIPER RIFLES
//Keyword rifles. They are subtype of rifles, but still contained here as a specialist weapon.

//Because this parent type did not exist
//Note that this means that snipers will have a slowdown of 3, due to the scope
/obj/item/weapon/gun/rifle/sniper
	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	gun_skill_category = GUN_SKILL_SPEC
	wield_delay = WIELD_DELAY_SLOW

	able_to_fire(mob/living/user)
		. = ..()
		if(. && istype(user)) //Let's check all that other stuff first.
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && user.mind.cm_skills.spec_weapons != SKILL_SPEC_SNIPER)
				user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
				return 0

//Pow! Headshot.
/obj/item/weapon/gun/rifle/sniper/M42A
	name = "\improper M42A scoped rifle"
	desc = "A heavy sniper rifle manufactured by Armat Systems. It has a scope system and fires armor penetrating rounds out of a 15-round magazine.\n'Peace Through Superior Firepower'"
	icon_state = "m42a"
	item_state = "m42a"
	origin_tech = "combat=6;materials=5"
	fire_sound = 'sound/weapons/gun_sniper.ogg'
	current_mag = /obj/item/ammo_magazine/sniper
	force = 12
	wield_delay = 12 //Ends up being 1.6 seconds due to scope
	zoomdevicename = "scope"
	attachable_allowed = list(/obj/item/attachable/bipod)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY

	New()
		select_gamemode_skin(type, list(MAP_ICE_COLONY = "s_m42a") )
		..()
		attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 20, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
		var/obj/item/attachable/scope/S = new(src)
		S.attach_icon = "" //Let's make it invisible. The sprite already has one.
		S.icon_state = ""
		S.flags_attach_features &= ~ATTACH_REMOVABLE
		S.Attach(src)
		var/obj/item/attachable/sniperbarrel/Q = new(src)
		Q.Attach(src)
		update_attachables()
		S.icon_state = initial(S.icon_state)


/obj/item/weapon/gun/rifle/sniper/M42A/set_gun_config_values()
	fire_delay = config.high_fire_delay*4
	burst_amount = config.min_burst_value
	accuracy_mult = config.base_hit_accuracy_mult
	scatter = config.low_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.min_recoil_value


/obj/item/weapon/gun/rifle/sniper/M42A/jungle //These really should just be skins.
	name = "\improper M42A marksman rifle"
	icon_state = "m_m42a" //NO BACK STATE
	item_state = "m_m42a"

/obj/item/weapon/gun/rifle/sniper/elite
	name = "\improper M42C anti-tank sniper rifle"
	desc = "A high end mag-rail heavy sniper rifle from Weyland-Armat chambered in the heaviest ammo available, 10x99mm Caseless."
	icon_state = "m42c"
	item_state = "m42c" //NEEDS A TWOHANDED STATE
	origin_tech = "combat=7;materials=5"
	fire_sound = 'sound/weapons/sniper_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/elite
	force = 17
	zoomdevicename = "scope"
	attachable_allowed = list()
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_WY_RESTRICTED|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY

/obj/item/weapon/gun/rifle/sniper/elite/New()
	..()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 15, "rail_y" = 19, "under_x" = 20, "under_y" = 15, "stock_x" = 20, "stock_y" = 15)
	var/obj/item/attachable/scope/S = new(src)
	S.icon_state = "pmcscope"
	S.attach_icon = "pmcscope"
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	var/obj/item/attachable/sniperbarrel/Q = new(src)
	Q.Attach(src)
	update_attachables()

/obj/item/weapon/gun/rifle/sniper/elite/set_gun_config_values()
	fire_delay = config.high_fire_delay*5
	burst_amount = config.min_burst_value
	accuracy_mult = config.base_hit_accuracy_mult + config.max_hit_accuracy_mult
	scatter = config.low_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.max_recoil_value

/obj/item/weapon/gun/rifle/sniper/elite/simulate_recoil(total_recoil = 0, mob/user, atom/target)
	. = ..()
	if(.)
		var/mob/living/carbon/human/PMC_sniper = user
		if(PMC_sniper.lying == 0 && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC) && !istype(PMC_sniper.wear_suit,/obj/item/clothing/suit/storage/marine/veteran))
			PMC_sniper.visible_message("<span class='warning'>[PMC_sniper] is blown backwards from the recoil of the [src]!</span>","<span class='highdanger'>You are knocked prone by the blowback!</span>")
			step(PMC_sniper,turn(PMC_sniper.dir,180))
			PMC_sniper.KnockDown(5)

//SVD //Based on the actual Dragunov sniper rifle.

/obj/item/weapon/gun/rifle/sniper/svd
	name = "\improper SVD Dragunov-033 sniper rifle"
	desc = "A sniper variant of the MAR-40 rifle, with a new stock, barrel, and scope. It doesn't have the punch of modern sniper rifles, but it's finely crafted in 2133 by someone probably illiterate. Fires 7.62x54mmR rounds."
	icon_state = "svd003"
	item_state = "svd003" //NEEDS A ONE HANDED STATE
	origin_tech = "combat=5;materials=3;syndicate=5"
	fire_sound = 'sound/weapons/gun_kt42.ogg'
	current_mag = /obj/item/ammo_magazine/sniper/svd
	type_of_casings = "cartridge"
	attachable_allowed = list(
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope/slavic)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY

/obj/item/weapon/gun/rifle/sniper/svd/New()
	..()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 17,"rail_x" = 13, "rail_y" = 19, "under_x" = 24, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	var/obj/item/attachable/S = new /obj/item/attachable/scope/slavic(src)
	S.Attach(src)
	S = new /obj/item/attachable/slavicbarrel(src)
	S.Attach(src)
	S = new /obj/item/attachable/stock/slavic(src)
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachables()

/obj/item/weapon/gun/rifle/sniper/svd/set_gun_config_values()
	fire_delay = config.mhigh_fire_delay*2
	burst_amount = config.low_burst_value
	accuracy_mult = config.base_hit_accuracy_mult - config.low_hit_accuracy_mult
	scatter = config.low_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.min_recoil_value



//M4RA marksman rifle

/obj/item/weapon/gun/rifle/m4ra
	name = "\improper M4RA battle rifle"
	desc = "The M4RA battle rifle is a designated marksman rifle in service with the USCM. Only fielded in small numbers, and sporting a bullpup configuration, the M4RA battle rifle is perfect for reconnaissance and fire support teams.\nIt is equipped with rail scope and takes 10x24mm A19 high velocity magazines."
	icon_state = "m41b"
	item_state = "m4ra" //PLACEHOLDER
	origin_tech = "combat=5;materials=4"
	fire_sound = list('sound/weapons/gun_m4ra.ogg')
	current_mag = /obj/item/ammo_magazine/rifle/m4ra
	force = 16
	attachable_allowed = list(
						/obj/item/attachable/suppressor,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/bipod,
						/obj/item/attachable/compensator)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY
	gun_skill_category = GUN_SKILL_SPEC

/obj/item/weapon/gun/rifle/m4ra/New()
	..()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 13, "stock_x" = 24, "stock_y" = 13)
	var/obj/item/attachable/scope/S = new(src)
	S.icon_state = null // the gun's sprite already shows a scope
	S.attach_icon = null
	S.flags_attach_features &= ~ATTACH_REMOVABLE //Don't want it coming off.
	S.Attach(src)
	var/obj/item/attachable/stock/rifle/marksman/Q = new(src) //Already cannot be removed.
	Q.Attach(src)
	update_attachables()


/obj/item/weapon/gun/rifle/m4ra/set_gun_config_values()
	fire_delay = config.high_fire_delay
	burst_amount = config.med_burst_value
	burst_delay = config.mlow_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult
	scatter = config.low_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.min_recoil_value

/obj/item/weapon/gun/rifle/m4ra/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && user.mind.cm_skills.spec_weapons != SKILL_SPEC_SCOUT)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return 0



//-------------------------------------------------------
//SMARTGUN

//Come get some.
/obj/item/weapon/gun/smartgun
	name = "\improper M56B smartgun"
	desc = "The actual firearm in the 4-piece M56B Smartgun System. Essentially a heavy, mobile machinegun.\nReloading is a cumbersome process requiring a powerpack. Click the powerpack icon in the top left to reload.\nYou may toggle firing restrictions by using a special action."
	icon_state = "m56"
	item_state = "m56"
	origin_tech = "combat=6;materials=5"
	fire_sound = "gun_smartgun"
	current_mag = /obj/item/ammo_magazine/internal/smartgun
	flags_equip_slot = NOFLAGS
	w_class = 5
	force = 20
	wield_delay = 16
	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	var/datum/ammo/ammo_secondary = /datum/ammo/bullet/smartgun/lethal//Toggled ammo type
	var/shells_fired_max = 20 //Smartgun only; once you fire # of shells, it will attempt to reload automatically. If you start the reload, the counter resets.
	var/shells_fired_now = 0 //The actual counter used. shells_fired_max is what it is compared to.
	var/restriction_toggled = 1 //Begin with the safety on.
	gun_skill_category = GUN_SKILL_SMARTGUN
	attachable_allowed = list(
						/obj/item/attachable/heavy_barrel,
						/obj/item/attachable/burstfire_assembly)

	flags_gun_features = GUN_INTERNAL_MAG|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY


/obj/item/weapon/gun/smartgun/New()
	..()
	ammo_secondary = ammo_list[ammo_secondary]
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 16,"rail_x" = 17, "rail_y" = 19, "under_x" = 22, "under_y" = 14, "stock_x" = 22, "stock_y" = 14)


/obj/item/weapon/gun/smartgun/set_gun_config_values()
	fire_delay = config.low_fire_delay
	burst_amount = config.med_burst_value
	burst_delay = config.min_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult
	scatter = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult

/obj/item/weapon/gun/smartgun/examine(mob/user)
	..()
	user << "[current_mag.current_rounds ? "Ammo counter shows [current_mag.current_rounds] round\s remaining." : "It's dry."]"
	user << "The restriction system is [restriction_toggled ? "<B>on</b>" : "<B>off</b>"]."

/obj/item/weapon/gun/smartgun/unique_action(mob/user)
	toggle_restriction(user)

/obj/item/weapon/gun/smartgun/able_to_fire(mob/living/user)
	. = ..()
	if(.)
		if(!ishuman(user)) return 0
		var/mob/living/carbon/human/H = user
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.smartgun < SKILL_SMART_USE)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return 0
		if ( !istype(H.wear_suit,/obj/item/clothing/suit/storage/marine/smartgunner) || !istype(H.back,/obj/item/smartgun_powerpack))
			click_empty(H)
			return 0


/obj/item/weapon/gun/smartgun/load_into_chamber(mob/user)
//	if(active_attachable) active_attachable = null
	return ready_in_chamber()

/obj/item/weapon/gun/smartgun/reload_into_chamber(mob/user)
	var/mob/living/carbon/human/smart_gunner = user
	var/obj/item/smartgun_powerpack/power_pack = smart_gunner.back
	if(istype(power_pack)) //I don't know how it would break, but it is possible.
		if(shells_fired_now >= shells_fired_max && power_pack.rounds_remaining > 0) // If shells fired exceeds shells needed to reload, and we have ammo.
			auto_reload(smart_gunner, power_pack)
		else shells_fired_now++

	return current_mag.current_rounds

/obj/item/weapon/gun/smartgun/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return 1

/obj/item/weapon/gun/smartgun/proc/toggle_restriction(mob/user)
	user << "\icon[src] You [restriction_toggled? "<B>disable</b>" : "<B>enable</b>"] the [src]'s fire restriction. You will [restriction_toggled ? "harm anyone in your way" : "target through IFF"]."
	playsound(loc,'sound/machines/click.ogg', 25, 1)
	var/A = ammo
	ammo = ammo_secondary
	ammo_secondary = A
	restriction_toggled = !restriction_toggled

/obj/item/weapon/gun/smartgun/proc/auto_reload(mob/smart_gunner, obj/item/smartgun_powerpack/power_pack)
	set waitfor = 0
	sleep(5)
	if(power_pack && power_pack.loc)
		power_pack.attack_self(smart_gunner)

/obj/item/weapon/gun/smartgun/dirty
	name = "\improper M56D 'dirty' smartgun"
	desc = "The actual firearm in the 4-piece M56D Smartgun System. If you have this, you're about to bring some serious pain to anyone in your way.\nYou may toggle firing restrictions by using a special action."
	origin_tech = "combat=7;materials=5"
	current_mag = /obj/item/ammo_magazine/internal/smartgun/dirty
	ammo_secondary = /datum/ammo/bullet/smartgun/lethal
	attachable_allowed = list() //Cannot be upgraded.
	flags_gun_features = GUN_INTERNAL_MAG|GUN_WY_RESTRICTED|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY

/obj/item/weapon/gun/smartgun/dirty/set_gun_config_values()
	fire_delay = config.low_fire_delay
	burst_amount = config.med_burst_value
	burst_delay = config.min_fire_delay
	accuracy_mult = config.base_hit_accuracy_mult + config.min_hit_accuracy_mult + config.min_hit_accuracy_mult
	scatter = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult


//-------------------------------------------------------
//GRENADE LAUNCHER

/obj/item/weapon/gun/launcher/m92
	name = "\improper M92 grenade launcher"
	desc = "A heavy, 6-shot grenade launcher used by the Colonial Marines for area denial and big explosions."
	icon_state = "m92"
	item_state = "m92" //NEED TWO HANDED SPRITE
	origin_tech = "combat=5;materials=5"
	matter = list("metal" = 6000)
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = 8
	fire_sound = 'sound/weapons/armbomb.ogg'
	cocked_sound = 'sound/weapons/gun_m92_cocked.ogg'
	var/list/grenades = new/list()
	var/max_grenades = 6
	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	attachable_allowed = list(/obj/item/attachable/magnetic_harness)

	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY
	gun_skill_category = GUN_SKILL_SPEC

/obj/item/weapon/gun/launcher/m92/New()
	set waitfor = 0
	..()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	sleep(1)
	grenades += new /obj/item/explosive/grenade/frag(src)
	grenades += new /obj/item/explosive/grenade/frag(src)
	grenades += new /obj/item/explosive/grenade/incendiary(src)
	grenades += new /obj/item/explosive/grenade/frag(src)
	grenades += new /obj/item/explosive/grenade/frag(src)

/obj/item/weapon/gun/launcher/m92/set_gun_config_values()
	fire_delay = config.max_fire_delay*3
	accuracy_mult = config.base_hit_accuracy_mult
	accuracy_mult_unwielded = config.base_hit_accuracy_mult
	scatter = config.med_scatter_value
	scatter_unwielded = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult


/obj/item/weapon/gun/launcher/m92/examine(mob/user)
	..()
	if(grenades.len)
		if (get_dist(user, src) > 2 && user != loc) return
		user << "\blue It is loaded with <b>[grenades.len] / [max_grenades]</b> grenades."

/obj/item/weapon/gun/launcher/m92/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/explosive/grenade)))
		if(grenades.len < max_grenades)
			if(user.drop_inv_item_to_loc(I, src))
				grenades += I
				user << "<span class='notice'>You put [I] in the grenade launcher.</span>"
				user << "<span class='info'>Now storing: [grenades.len] / [max_grenades] grenades.</span>"
		else
			user << "<span class='warning'>The grenade launcher cannot hold more grenades!</span>"

	else if(istype(I,/obj/item/attachable))
		if(check_inactive_hand(user)) attach_to_gun(user,I)

/obj/item/weapon/gun/launcher/m92/afterattack(atom/target, mob/user, flag)
	if(able_to_fire(user))
		if(get_dist(target,user) <= 2)
			user << "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>"
			return
		if(grenades.len)
			fire_grenade(target,user)
			playsound(user.loc, cocked_sound, 25, 1)
		else user << "<span class='warning'>The grenade launcher is empty.</span>"

//Doesn't use most of any of these. Listed for reference.
/obj/item/weapon/gun/launcher/m92/load_into_chamber()
	return

/obj/item/weapon/gun/launcher/m92/reload_into_chamber()
	return

/obj/item/weapon/gun/launcher/m92/unload(mob/user)
	if(grenades.len)
		var/obj/item/explosive/grenade/nade = grenades[grenades.len] //Grab the last one.
		if(user)
			user.put_in_hands(nade)
			playsound(user, unload_sound, 25, 1)
		else nade.loc = get_turf(src)
		grenades -= nade
	else user << "<span class='warning'>It's empty!</span>"

/obj/item/weapon/gun/launcher/m92/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && user.mind.cm_skills.spec_weapons != SKILL_SPEC_GRENADIER)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return 0

/obj/item/weapon/gun/launcher/m92/proc/fire_grenade(atom/target, mob/user)
	set waitfor = 0
	last_fired = world.time
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("<span class='danger'>[] fired a grenade!</span>", user), 1)
	user << "<span class='warning'>You fire the grenade launcher!</span>"
	var/obj/item/explosive/grenade/F = grenades[1]
	grenades -= F
	F.loc = user.loc
	F.throw_range = 20
	F.throw_at(target, 20, 2, user)
	if(F && F.loc) //Apparently it can get deleted before the next thing takes place, so it runtimes.
		message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from \a ([name]).")
		log_game("[key_name_admin(user)] used a grenade ([name]).")
		F.icon_state = initial(F.icon_state) + "_active"
		F.active = 1
		F.updateicon()
		playsound(F.loc, fire_sound, 50, 1)
		sleep(10)
		if(F && F.loc) F.prime()

/obj/item/weapon/gun/launcher/m81
	name = "\improper M81 grenade launcher"
	desc = "A lightweight, single-shot grenade launcher used by the Colonial Marines for area denial and big explosions."
	icon_state = "m81"
	item_state = "m81"
	origin_tech = "combat=5;materials=5"
	matter = list("metal" = 7000)
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	wield_delay = WIELD_DELAY_VERY_FAST
	fire_sound = 'sound/weapons/armbomb.ogg'
	cocked_sound = 'sound/weapons/gun_m92_cocked.ogg'
	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY
	gun_skill_category = GUN_SKILL_SPEC
	attachable_allowed = list()
	var/grenade
	var/grenade_type_allowed = /obj/item/explosive/grenade
	var/riot_version

/obj/item/weapon/gun/launcher/m81/New(loc, spawn_empty)
	set waitfor = 0
	..()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 14, "rail_y" = 22, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	if(!spawn_empty)
		if(riot_version)
			grenade = new /obj/item/explosive/grenade/chem_grenade/teargas(src)
		else
			grenade = new /obj/item/explosive/grenade/frag(src)

/obj/item/weapon/gun/launcher/m81/set_gun_config_values()
	fire_delay = config.max_fire_delay * 1.5
	accuracy_mult = config.base_hit_accuracy_mult
	scatter = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult


/obj/item/weapon/gun/launcher/m81/examine(mob/user)
	..()
	if(grenade)
		if (get_dist(user, src) > 2 && user != loc) return
		user << "\blue It is loaded with a grenade."

/obj/item/weapon/gun/launcher/m81/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/explosive/grenade)))
		if((istype(I, grenade_type_allowed)))
			if(!grenade)
				if(user.drop_inv_item_to_loc(I, src))
					grenade = I
					user << "<span class='notice'>You put [I] in the grenade launcher.</span>"
			else
				user << "<span class='warning'>The grenade launcher cannot hold more grenades!</span>"
		else
			user << "<span class='warning'>[src] can't use this type of grenade!</span>"

	else if(istype(I,/obj/item/attachable))
		if(check_inactive_hand(user)) attach_to_gun(user,I)

/obj/item/weapon/gun/launcher/m81/afterattack(atom/target, mob/user, flag)
	if(able_to_fire(user))
		if(get_dist(target,user) <= 2)
			user << "<span class='warning'>The grenade launcher beeps a warning noise. You are too close!</span>"
			return
		if(grenade)
			fire_grenade(target,user)
			playsound(user.loc, cocked_sound, 25, 1)
		else user << "<span class='warning'>The grenade launcher is empty.</span>"

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
		else nade.loc = get_turf(src)
		grenade = null
	else user << "<span class='warning'>It's empty!</span>"

/obj/item/weapon/gun/launcher/m81/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		if(user.mind && user.mind.cm_skills)
			if(riot_version)
				if(user.mind.cm_skills.police < SKILL_POLICE_MP)
					user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
					return 0
			else if(user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && user.mind.cm_skills.spec_weapons != SKILL_SPEC_GRENADIER)
				user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
				return 0


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
	if(F && F.loc) //Apparently it can get deleted before the next thing takes place, so it runtimes.
		message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from \a ([name]).")
		log_game("[key_name_admin(user)] used a grenade ([name]).")
		F.icon_state = initial(F.icon_state) + "_active"
		F.active = 1
		F.updateicon()
		playsound(F.loc, fire_sound, 50, 1)
		sleep(10)
		if(F && F.loc) F.prime()


/obj/item/weapon/gun/launcher/m81/riot
	name = "\improper M81 riot grenade launcher"
	desc = "A lightweight, single-shot grenade launcher to launch tear gas grenades. Used by the Colonial Marines Military Police during riots."
	grenade_type_allowed = /obj/item/explosive/grenade/chem_grenade
	riot_version = TRUE




//-------------------------------------------------------
//M5 RPG

/obj/item/weapon/gun/launcher/rocket
	name = "\improper M5 RPG"
	desc = "The M5 RPG is the primary anti-armor weapon of the USCM. Used to take out light-tanks and enemy structures, the M5 RPG is a dangerous weapon with a variety of combat uses."
	icon_state = "m5"
	item_state = "m5"
	origin_tech = "combat=6;materials=5"
	matter = list("metal" = 10000)
	current_mag = /obj/item/ammo_magazine/internal/launcher/rocket
	flags_equip_slot = NOFLAGS
	w_class = 5
	force = 15
	wield_delay = 12
	aim_slowdown = SLOWDOWN_ADS_SPECIALIST
	attachable_allowed = list(
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_INTERNAL_MAG|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY
	gun_skill_category = GUN_SKILL_SPEC
	var/datum/effect_system/smoke_spread/smoke

/obj/item/weapon/gun/launcher/rocket/New()
	..()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 6, "rail_y" = 19, "under_x" = 19, "under_y" = 14, "stock_x" = 19, "stock_y" = 14)
	smoke = new()
	smoke.attach(src)

/obj/item/weapon/gun/launcher/rocket/set_gun_config_values()
	fire_delay = config.high_fire_delay*2
	accuracy_mult = config.base_hit_accuracy_mult
	scatter = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.med_recoil_value


/obj/item/weapon/gun/launcher/rocket/examine(mob/user)
	..()
	if(current_mag.current_rounds)  user << "It's ready to rocket."
	else 							user << "It's empty."


/obj/item/weapon/gun/launcher/rocket/able_to_fire(mob/living/user)
	. = ..()
	if (. && istype(user)) //Let's check all that other stuff first.
		/*var/turf/current_turf = get_turf(user)
		if (current_turf.z == 3 || current_turf.z == 4) //Can't fire on the Almayer, bub.
			click_empty(user)
			user << "<span class='warning'>You can't fire that here!</span>"
			return 0*/
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && user.mind.cm_skills.spec_weapons != SKILL_SPEC_ROCKET)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return 0

/obj/item/weapon/gun/launcher/rocket/load_into_chamber(mob/user)
//	if(active_attachable) active_attachable = null
	return ready_in_chamber()

//No such thing
/obj/item/weapon/gun/launcher/rocket/reload_into_chamber(mob/user)
	return 1

/obj/item/weapon/gun/launcher/rocket/delete_bullet(obj/item/projectile/projectile_to_fire, refund = 0)
	cdel(projectile_to_fire)
	if(refund) current_mag.current_rounds++
	return 1

/obj/item/weapon/gun/launcher/rocket/reload(mob/user, obj/item/ammo_magazine/rocket)
	if(flags_gun_features & GUN_BURST_FIRING) return

	if(!rocket || !istype(rocket) || rocket.caliber != current_mag.caliber)
		user << "<span class='warning'>That's not going to fit!</span>"
		return

	if(current_mag.current_rounds > 0)
		user << "<span class='warning'>[src] is already loaded!</span>"
		return

	if(rocket.current_rounds <= 0)
		user << "<span class='warning'>That frame is empty!</span>"
		return

	if(user)
		user << "<span class='notice'>You begin reloading [src]. Hold still...</span>"
		if(do_after(user,current_mag.reload_delay, TRUE, 5, BUSY_ICON_FRIENDLY))
			user.drop_inv_item_on_ground(rocket)
			replace_ammo(user,rocket)
			current_mag.current_rounds = current_mag.max_rounds
			rocket.current_rounds = 0
			user << "<span class='notice'>You load [rocket] into [src].</span>"
			if(reload_sound) playsound(user, reload_sound, 25, 1)
			else playsound(user,'sound/machines/click.ogg', 25, 1)
		else
			user << "<span class='warning'>Your reload was interrupted!</span>"
			return
	else
		rocket.loc = get_turf(src)
		replace_ammo(,rocket)
		current_mag.current_rounds = current_mag.max_rounds
		rocket.current_rounds = 0
	rocket.update_icon()
	return 1

/obj/item/weapon/gun/launcher/rocket/unload(mob/user)
	if(user)
		if(!current_mag.current_rounds) user << "<span class='warning'>[src] is already empty!</span>"
		else 							user << "<span class='warning'>It would be too much trouble to unload [src] now. Should have thought ahead!</span>"

//Adding in the rocket backblast. The tile behind the specialist gets blasted hard enough to down and slightly wound anyone
/obj/item/weapon/gun/launcher/rocket/apply_bullet_effects(obj/item/projectile/projectile_to_fire, mob/user, i = 1, reflex = 0)

	var/backblast_loc = get_turf(get_step(user.loc, turn(user.dir, 180)))
	smoke.set_up(1, 0, backblast_loc, turn(user.dir, 180))
	smoke.start()
	for(var/mob/living/carbon/C in backblast_loc)
		if(!C.lying) //Have to be standing up to get the fun stuff
			C.adjustBruteLoss(15) //The shockwave hurts, quite a bit. It can knock unarmored targets unconscious in real life
			C.Stun(4) //For good measure
			C.emote("pain")

		..()

//-------------------------------------------------------
//M5 RPG'S MEAN FUCKING COUSIN

/obj/item/weapon/gun/launcher/rocket/m57a4
	name = "\improper M57-A4 'Lightning Bolt' quad thermobaric launcher"
	desc = "The M57-A4 'Lightning Bolt' is posssibly the most destructive man-portable weapon ever made. It is a 4-barreled missile launcher capable of burst-firing 4 thermobaric missiles. Enough said."
	icon_state = "m57a4"
	item_state = "m57a4"
	origin_tech = "combat=7;materials=5"
	current_mag = /obj/item/ammo_magazine/internal/launcher/rocket/m57a4
	aim_slowdown = SLOWDOWN_ADS_SUPERWEAPON
	attachable_allowed = list()
	flags_gun_features = GUN_INTERNAL_MAG|GUN_WY_RESTRICTED|GUN_SPECIALIST|GUN_WIELDED_FIRING_ONLY

/obj/item/weapon/gun/launcher/rocket/m57a4/set_gun_config_values()
	fire_delay = config.mhigh_fire_delay
	burst_delay = config.med_fire_delay
	burst_amount = config.high_burst_value
	accuracy_mult = config.base_hit_accuracy_mult - config.med_hit_accuracy_mult
	scatter = config.med_scatter_value
	damage_mult = config.base_hit_damage_mult
	recoil = config.med_recoil_value