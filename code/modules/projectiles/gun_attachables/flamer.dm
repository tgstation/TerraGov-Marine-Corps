/obj/item/attachable/flamer_nozzle
	name = "standard flamer nozzle"
	desc = "The standard flamer nozzle. This one fires a stream of fire for direct and accurate flames. Though not as area filling as its counterpart, this one excels at directed frontline combat."
	icon_state = "directional"
	icon = 'icons/obj/items/guns/attachments/flamer.dmi'
	slot = ATTACHMENT_SLOT_FLAMER_NOZZLE
	attach_delay = 2 SECONDS
	detach_delay = 2 SECONDS
	///This is pulled when the parent flamer fires, it determines how the parent flamers fire stream acts.
	var/stream_type = FLAMER_STREAM_STRAIGHT
	///Modifier for burn level of attached flamer. Percentage based.
	var/burn_level_mod = 1
	///Modifier for burn time of attached flamer. Percentage based.
	var/burn_time_mod = 1
	///Range modifier of attached flamer. Numerically based.
	var/range_modifier = 0
	///Damage multiplier for mobs caught in the initial stream of fire of the attached flamer.
	var/mob_flame_damage_mod = 1

/obj/item/attachable/flamer_nozzle/on_attach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	flamer.burn_level_mod *= burn_level_mod
	flamer.burn_time_mod *= burn_time_mod
	flamer.flame_max_range += range_modifier
	flamer.mob_flame_damage_mod *= mob_flame_damage_mod

/obj/item/attachable/flamer_nozzle/on_detach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	flamer.burn_level_mod /= burn_level_mod
	flamer.burn_time_mod /= burn_time_mod
	flamer.flame_max_range -= range_modifier
	flamer.mob_flame_damage_mod /= mob_flame_damage_mod

/obj/item/attachable/flamer_nozzle/unremovable
	attach_features_flags = NONE

/obj/item/attachable/flamer_nozzle/unremovable/invisible
	icon_state = "invisible"

/obj/item/attachable/flamer_nozzle/wide
	name = "spray flamer nozzle"
	desc = "This specialized nozzle sprays the flames of an attached flamer in a much more broad way than the standard nozzle. It serves for wide area denial as opposed to offensive directional flaming."
	icon_state = "wide"
	pixel_shift_y = 17
	stream_type = FLAMER_STREAM_CONE
	burn_time_mod = 0.3

///Funny red wide nozzle that can fill entire screens with flames. Admeme only.
/obj/item/attachable/flamer_nozzle/wide/red
	name = "red spray flamer nozzle"
	desc = "It is red, therefore its obviously more effective."
	icon_state = "wide_red"
	range_modifier = 3

///Flamer ammo is a normal ammo datum, which means we can shoot it if we want
/obj/item/attachable/flamer_nozzle/long
	name = "extended flamer nozzle"
	icon_state = "long"
	desc = "Rather than spreading the supplied fuel over an area, this nozzle launches a single fireball to ignite a target at range. Reduced volume per shot also means the next is ready quicker."
	stream_type = FLAMER_STREAM_RANGED
	delay_mod = -10

/obj/item/attachable/flamer_nozzle/long/on_attach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	//Since we're firing more like a normal gun, we do need to use up rounds after firing
	flamer.reciever_flags &= ~AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE

/obj/item/attachable/flamer_nozzle/long/on_detach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	if(initial(flamer.reciever_flags) & AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE)
		flamer.reciever_flags |= AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE
