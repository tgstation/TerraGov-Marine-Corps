#define FLAMER_WATER 200

//FLAMETHROWER

/obj/item/weapon/gun/flamer
	name = "flamer"
	desc = "flame go froosh"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	fire_sound = "gun_flamethrower"
	dry_fire_sound = 'sound/weapons/guns/fire/flamethrower_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/flamethrower_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/flamethrower_reload.ogg'
	muzzle_flash = null
	aim_slowdown = 0.85
	general_codex_key = "flame weapons"
	attachable_allowed = list( //give it some flexibility.
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/shoulder_mount,
		)
	attachments_by_slot = list(
		ATTACHMENT_SLOT_MUZZLE,
		ATTACHMENT_SLOT_RAIL,
		ATTACHMENT_SLOT_STOCK,
		ATTACHMENT_SLOT_UNDER,
		ATTACHMENT_SLOT_MAGAZINE,
	)
	flags_gun_features = GUN_AMMO_COUNTER|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	attachable_offset = list("rail_x" = 12, "rail_y" = 23)
	fire_delay = 0.1 SECONDS
	scatter = 10

	placed_overlay_iconstate = "flamer"

	ammo_datum_type = /datum/ammo/flamethrower
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/large
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/backtank,
	)
	///Flamethrower modes
	var/list/datum/flamer_mode/mode_list = list(
		"Standard" = /datum/flamer_mode/standard,
		"Over" = /datum/flamer_mode/over,
		"Blast" = /datum/flamer_mode/blast,
	)
	windup_delay = 0.4 SECONDS
	windup_sound = 'sound/weapons/guns/interact/flamethrower_on.ogg'
	///Damage multiplier for mobs caught in the initial stream of fire.
	var/mob_flame_damage_mod = 2

/obj/item/weapon/gun/flamer/get_magazine_default_ammo(obj/item/mag)
	return null

/obj/item/weapon/gun/flamer/unique_action(mob/user)
	if(!user)
		CRASH("switch_modes called with no user.")

	var/list/available_modes = list()
	for(var/mode in mode_list)
		available_modes += list("[mode]" = image(icon = initial(mode_list[mode].radial_icon), icon_state = initial(mode_list[mode].radial_icon_state)))

	var/datum/flamer_mode/choice = mode_list[show_radial_menu(user, user, available_modes, null, 64, tooltips = TRUE)]
	if(!choice)
		return
	playsound(user, 'sound/weapons/guns/interact/flamethrower_on.ogg', 5, FALSE, 2)

	gun_firemode = initial(choice.fire_mode)
	ammo_datum_type = initial(choice.ammo_datum_type)
	fire_delay = initial(choice.fire_delay)
	burst_amount = initial(choice.burst_amount)
	fire_sound = initial(choice.fire_sound)
	rounds_per_shot = initial(choice.rounds_per_shot)
	scatter = initial(choice.scatter)
	SEND_SIGNAL(src, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)
	SEND_SIGNAL(src, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, fire_delay)
	SEND_SIGNAL(src, COMSIG_GUN_FIRE_MODE_TOGGLE, initial(choice.fire_mode), user.client)
	update_icon()
	to_chat(user, initial(choice.message_to_user))
	user?.hud_used.update_ammo_hud(src, get_ammo_list(), get_display_ammo_count())

	if(!in_chamber || !length(chamber_items))
		return
	QDEL_NULL(in_chamber)

	in_chamber = get_ammo_object(chamber_items[current_chamber_position])

/datum/flamer_mode
	///how much fuel the gun uses on this mode when shot.
	var/rounds_per_shot = 1
	///the ammo datum this mode is.
	var/datum/ammo/ammo_datum_type = null
	///how long it takes between each shot of that mode, same as gun fire delay.
	var/fire_delay = 0
	///Gives guns a burst amount, editable.
	var/burst_amount = 0
	///The gun firing sound of this mode
	var/fire_sound = "gun_flamethrower"
	var/scatter = 0
	///What message it sends to the user when you switch to this mode.
	var/message_to_user = ""
	///Used to change the gun firemode, like automatic, semi-automatic and burst.
	var/fire_mode = GUN_FIREMODE_SEMIAUTO
	///Which icon file the radial menu will use.
	var/radial_icon = 'icons/mob/radial.dmi'
	///The icon state the radial menu will use.
	var/radial_icon_state = "flamer"

/datum/flamer_mode/standard
	ammo_datum_type = /datum/ammo/flamethrower
	message_to_user = "You set the flamethrowers mode to standard fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	radial_icon_state = "flamer"
	fire_delay = 0.1 SECONDS
	scatter = 10

/datum/flamer_mode/over
	ammo_datum_type = /datum/ammo/flamethrower/over
	message_to_user = "You set the laser rifle's charge mode to over fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	radial_icon_state = "flamer_over"
	fire_delay = 0.1 SECONDS
	scatter = 10

/datum/flamer_mode/blast
	ammo_datum_type = /datum/ammo/flamethrower/blast
	message_to_user = "You set the laser rifle's charge mode to blast fire."
	fire_mode = GUN_FIREMODE_AUTOMATIC
	radial_icon_state = "flamer_blast"
	fire_delay = 2 SECONDS
	rounds_per_shot = 10

/obj/item/weapon/gun/flamer/big_flamer
	name = "\improper FL-240 incinerator unit"
	desc = "The FL-240 has proven to be one of the most effective weapons at clearing out soft-targets. This is a weapon to be feared and respected as it is quite deadly."
	icon_state = "m240"
	item_state = "m240"

/obj/item/weapon/gun/flamer/som
	name = "\improper V-62 incinerator"
	desc = "The V-62 is a deadly weapon employed in close quarter combat, favoured as much for the terror it inspires as the actual damage it inflicts. It has good range for a flamer, but lacks the integrated extinguisher of its TGMC equivalent."
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "v62"
	item_state = "v62"
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_SHOWS_LOADED
	inhand_x_dimension = 64
	inhand_y_dimension = 32
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_64.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_64.dmi',
	)
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/large/som
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/flamer_tank/large/som,
		/obj/item/ammo_magazine/flamer_tank/backtank,
	)

/obj/item/weapon/gun/flamer/som/mag_harness
	starting_attachment_types = list(/obj/item/attachable/magnetic_harness)

/obj/item/weapon/gun/flamer/mini_flamer
	name = "mini flamethrower"
	desc = "A weapon-mounted refillable flamethrower attachment.\nIt is designed for short bursts."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "flamethrower"

	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY
	w_class = WEIGHT_CLASS_BULKY
	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'

	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/mini
	allowed_ammo_types = list(
		/obj/item/ammo_magazine/flamer_tank/mini,
		/obj/item/ammo_magazine/flamer_tank/backtank,
	)
	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	pixel_shift_x = 15
	pixel_shift_y = 18
	damage_mult = 0.75

	wield_delay_mod = 0.2 SECONDS
	windup_delay = 0 SECONDS
	mode_list = null

/obj/item/weapon/gun/flamer/mini_flamer/unremovable
	flags_attach_features = NONE


/obj/item/weapon/gun/flamer/big_flamer/marinestandard
	name = "\improper FL-84 flamethrower"
	desc = "The FL-84 flamethrower is the current standard issue flamethrower of the TGMC, and is used for area control and urban combat. Use unique action to use hydro cannon"
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/large
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "tl84"
	item_state = "tl84"
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_SHOWS_LOADED
	attachable_offset = list("rail_x" = 10, "rail_y" = 23, "stock_x" = 16, "stock_y" = 13, "under_x" = 31, "under_y" = 15)
	attachable_allowed = list(
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/motiondetector,
		/obj/item/attachable/buildasentry,
		/obj/item/attachable/stock/t84stock,
		/obj/item/weapon/gun/flamer/hydro_cannon,
	)
	starting_attachment_types = list(/obj/item/attachable/stock/t84stock, /obj/item/weapon/gun/flamer/hydro_cannon)

/obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide
	starting_attachment_types = list(
		/obj/item/attachable/stock/t84stock,
		/obj/item/weapon/gun/flamer/hydro_cannon,
		/obj/item/attachable/magnetic_harness,
	)

/obj/item/weapon/gun/flamer/big_flamer/flx
	name = "\improper FL-X-150 flamethrower"
	desc = "The FL-X-150 flamethrower is an advanced flamethrower that outputs more powerful and longer lasting flames, it is much more effective at area control and urban combat."
	flags_gun_features = GUN_AMMO_COUNTER|GUN_WIELDED_FIRING_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_SHOWS_LOADED
	icon = 'icons/Marine/gun64.dmi'
	icon_state = "flx150"
	item_state = "flx150"
	ammo_datum_type = /datum/ammo/flamethrower/blue
	mode_list = list(
		"Standard" = /datum/flamer_mode/standard/blue,
		"Over" = /datum/flamer_mode/over/blue,
		"Blast" = /datum/flamer_mode/blast/blue,
	)

/datum/flamer_mode/standard/blue
	ammo_datum_type = /datum/ammo/flamethrower/blue

/datum/flamer_mode/over/blue
	ammo_datum_type = /datum/ammo/flamethrower/over/blue

/datum/flamer_mode/blast/blue
	ammo_datum_type = /datum/ammo/flamethrower/blast/blue

/turf/proc/ignite(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	//extinguish any flame present
	var/obj/flamer_fire/old_fire = locate(/obj/flamer_fire) in src
	if(old_fire)
		var/new_fire_level = min(fire_lvl + old_fire.firelevel, fire_lvl * 2)
		var/new_burn_level = min(burn_lvl + old_fire.burnlevel, burn_lvl * 1.5)
		old_fire.set_fire(new_fire_level, new_burn_level, f_color, fire_stacks, fire_damage)
		return

	new /obj/flamer_fire(src, fire_lvl, burn_lvl, f_color, fire_stacks, fire_damage)
	for(var/obj/structure/jungle/vines/vines in src)
		QDEL_NULL(vines)

/turf/open/floor/plating/ground/snow/ignite(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	if(slayer > 0)
		slayer -= 1
		update_icon(1, 0)
	return ..()




GLOBAL_LIST_EMPTY(flamer_particles)
/particles/flamer_fire
	icon = 'icons/effects/particles/fire.dmi'
	icon_state = "bonfire"
	width = 100
	height = 100
	count = 1000
	spawning = 8
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_BOX, list(-16, -16), list(16, 16), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)

/particles/flamer_fire/New(set_color)
	..()
	if(set_color != "red") // we're already red colored by default
		color = set_color

/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	layer = BELOW_OBJ_LAYER
	light_system = MOVABLE_LIGHT
	light_mask_type = /atom/movable/lighting_mask/flicker
	light_on = TRUE
	light_range = 3
	light_power = 3
	light_color = LIGHT_COLOR_LAVA
	///Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/firelevel = 12
	///Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature
	var/burnlevel = 10
	///The color the flames and associated particles appear
	var/flame_color = "red"

/obj/flamer_fire/Initialize(mapload, fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	. = ..()
	set_fire(fire_lvl, burn_lvl, f_color, fire_stacks, fire_damage)

	START_PROCESSING(SSobj, src)

	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)


/obj/flamer_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

///Effects applied to a mob that crosses a burning turf
/obj/flamer_fire/proc/on_cross(datum/source, mob/living/M, oldloc, oldlocs)
	if(istype(M))
		M.flamer_fire_act(burnlevel)

/obj/flamer_fire/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!CHECK_BITFIELD(S.smoke_traits, SMOKE_EXTINGUISH)) //Fire suppressing smoke
		return

	firelevel -= 20 //Water level extinguish
	updateicon()
	if(firelevel < 1) //Extinguish if our firelevel is less than 1
		playsound(S, 'sound/effects/smoke_extinguish.ogg', 20)
		qdel(src)

///Sets the fire object to the correct colour and fire values, and applies the initial effects to any mob on the turf
/obj/flamer_fire/proc/set_fire(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	if(f_color && (flame_color != f_color))
		flame_color = f_color

	if(!GLOB.flamer_particles[flame_color])
		GLOB.flamer_particles[flame_color] = new /particles/flamer_fire(flame_color)

	particles = GLOB.flamer_particles[flame_color]
	icon_state = "[flame_color]_2"

	if(fire_lvl)
		firelevel = fire_lvl
	if(burn_lvl)
		burnlevel = burn_lvl

	if(!fire_stacks && !fire_damage)
		return

	for(var/mob/living/C in get_turf(src))
		C.flamer_fire_act(fire_stacks)
		C.take_overall_damage(fire_damage, BURN, FIRE, updating_health = TRUE)

/obj/flamer_fire/proc/updateicon()
	var/light_color = "LIGHT_COLOR_LAVA"
	var/light_intensity = 3
	switch(flame_color)
		if("red")
			light_color = LIGHT_COLOR_LAVA
		if("blue")
			light_color = LIGHT_COLOR_CYAN
		if("green")
			light_color = LIGHT_COLOR_GREEN
	switch(firelevel)
		if(1 to 9)
			icon_state = "[flame_color]_1"
			light_intensity = 2
		if(10 to 25)
			icon_state = "[flame_color]_2"
			light_intensity = 4
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			icon_state = "[flame_color]_3"
			light_intensity = 6
	set_light_range_power_color(light_intensity, light_power, light_color)

/obj/flamer_fire/process()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf?
		qdel(src)
		return

	updateicon()

	if(!firelevel)
		qdel(src)
		return

	T.flamer_fire_act(burnlevel)

	var/j = 0
	for(var/i in T)
		if(++j >= 11)
			break
		var/atom/A = i
		if(QDELETED(A)) //The destruction by fire of one atom may destroy others in the same turf.
			continue
		A.flamer_fire_act(burnlevel)

	firelevel -= 2 //reduce the intensity by 2 per tick

/obj/item/weapon/gun/flamer/hydro_cannon
	name = "underslung hydrocannon"
	desc = "For the quenching of unfortunate mistakes."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "hydrocannon"

	fire_delay = 0.15 SECONDS
	fire_sound = 'sound/effects/extinguish.ogg'

	ammo_datum_type = /datum/ammo/water
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/water
	allowed_ammo_types = list( /obj/item/ammo_magazine/flamer_tank/water)

	slot = ATTACHMENT_SLOT_UNDER
	attach_delay = 3 SECONDS
	detach_delay = 3 SECONDS
	flags_gun_features = GUN_AMMO_COUNTER|GUN_IS_ATTACHMENT|GUN_ATTACHMENT_FIRE_ONLY|GUN_WIELDED_STABLE_FIRING_ONLY|GUN_WIELDED_FIRING_ONLY
	mode_list = null
	windup_delay = 0
	scatter = 0

#undef FLAMER_WATER
