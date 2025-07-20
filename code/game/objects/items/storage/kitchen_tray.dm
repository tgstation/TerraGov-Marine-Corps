/obj/item/storage/kitchen_tray
	name = "tray"
	desc = "Use in hand to place items from tray to in front of yourself."
	icon = 'icons/obj/items/kitchen_tools.dmi'
	icon_state = "tray"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/kitchen_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/kitchen_right.dmi',
	)
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	atom_flags = CONDUCT
	hitsound = 'sound/items/trayhit1.ogg'
	storage_type = /datum/storage/kitchen_tray
	attack_verb = list("attacks", "slams", "slaps")
	/// Shield bash cooldown. based on world.time
	var/cooldown = 0

/obj/item/storage/kitchen_tray/Initialize(mapload, ...)
	. = ..()
	storage_datum.use_to_pickup = TRUE
	storage_datum.collection_mode = TRUE

/obj/item/storage/kitchen_tray/update_overlays()
	. = ..()
	if(!length(contents))
		return

	for(var/obj/item/thing in src)
		var/image/item_image = image("icon" = thing.icon, "icon_state" = thing.icon_state, "layer" = layer+0.01)
		item_image.pixel_x = rand(-10, 10)
		item_image.pixel_y = rand(-10, 8)
		. += item_image

/obj/item/storage/kitchen_tray/attack(mob/living/attacked, mob/living/user as mob)
	. = ..()
	if(length(contents))
		visible_message(span_warning("The force of the blow sends the contents of [src] flying!"))

	// Drop all the things. All of them.
	for(var/obj/item/dropped_item in src)
		storage_datum.remove_from_storage(dropped_item, get_turf(src))
		dropped_item.throw_at(get_step(user, pick(CARDINAL_ALL_DIRS)), 1, spin = TRUE)
	hitsound = pick('sound/items/trayhit1.ogg', 'sound/items/trayhit2.ogg')

	update_appearance(UPDATE_OVERLAYS)
	if(!ishuman(attacked))
		return

	var/mob/living/carbon/human/attacked_human = attacked
	if(!(user.zone_selected == ("eyes" || "head")))
		attacked_human.visible_message(span_danger("[user] slams [attacked_human] with the tray!"), span_warning("You get slammed with the tray!"))
		log_combat(user, attacked_human, "attacked", src)

		if(prob(15))
			attacked_human.Paralyze(6 SECONDS)
			attacked_human.take_limb_damage(3)
		else
			attacked_human.take_limb_damage(5)
		return

	if(attacked_human?.head.inventory_flags & COVEREYES || attacked_human?.wear_mask.inventory_flags & COVEREYES || attacked_human?.glasses.inventory_flags & COVEREYES)
		attacked_human.visible_message(span_danger("[user] slams [attacked_human] with the tray!"), span_warning("You get slammed in the face with the tray, against your mask!"))

		if(prob(10))
			attacked_human.Stun(rand(2 SECONDS, 6 SECONDS))
			attacked_human.take_limb_damage(3)
			return
		attacked_human.take_limb_damage(5)
		return

	//No eye or head protection, tough luck!

	attacked_human.visible_message(span_danger("[user] slams [attacked_human] in the face with the tray!"), span_warning("You get slammed in the face with the tray!"))

	if(prob(30))
		attacked_human.Stun(rand(4 SECONDS, 8 SECONDS))
		attacked_human.take_limb_damage(4)
		return

	attacked_human.take_limb_damage(8)
	if(prob(30))
		attacked_human.Paralyze(4 SECONDS)

/obj/item/storage/kitchen_tray/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/tool/kitchen/rollingpin))
		return

	if(cooldown < world.time - 25)
		user.visible_message(span_warning("[user] bashes [src] with [I]!"))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 25, 1)
		cooldown = world.time

/obj/item/storage/kitchen_tray/attack_self(mob/user)
	. = ..()
	for(var/obj/item/dropped_item in src)
		storage_datum.remove_from_storage(dropped_item, get_step(user, user.dir))
