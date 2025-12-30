/mob/living/carbon/human/proc/handle_haul_resist()
	if(world.time <= next_haul_resist)
		return

	if(incapacitated())
		return

	var/mob/living/carbon/xenomorph/xeno = devouring_mob
	next_haul_resist = world.time + 1.4 SECONDS
	if(istype(get_active_held_item(), /obj/item))
		var/obj/item/item = get_active_held_item()
		if(item?.force)
			var/damage_of_item = rand(item.force, floor(item.force * 5))
			xeno.take_limb_damage(damage_of_item)
			visible_message(span_danger("<B>[src] attacks [xeno]'s carapace with the [item.name]!"))
			if(item.sharp)
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1)
			else
				var/hit_sound = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
				playsound(loc, hit_sound, 25, 1)
			if(prob(max(4*(100*xeno.getBruteLoss()/xeno.maxHealth - 75),0))) //4% at 24% health, 80% at 5% health
				xeno.gib()
		else
			visible_message(span_danger("You hear [src] struggling against [xeno]'s grip..."), vision_distance = 4)
	return

// Adding traits, etc after xeno restrains and hauls us
/mob/living/carbon/human/proc/handle_haul(mob/living/carbon/xenomorph/xeno)
	ADD_TRAIT(src, TRAIT_IMMOBILE, "t_s_xeno_haul")
	ADD_TRAIT(src, TRAIT_HAULED, "t_s_xeno_haul")

	devouring_mob = xeno
	layer = ABOVE_MOB_LAYER
	// add_filter("hauled_shadow", 1, color_matrix_filter(rgb(95, 95, 95)))
	pixel_y = 6
	next_haul_resist = 0

// Removing traits and other stuff after xeno releases us from haul
/mob/living/carbon/human/proc/handle_unhaul()
	var/location = get_turf(loc)
	remove_traits(list(TRAIT_HAULED, TRAIT_IMMOBILE), "t_s_xeno_haul")
	pixel_y = 0
	devouring_mob = null
	layer = MOB_LAYER
	//remove_filter("hauled_shadow")
	forceMove(location)
	next_haul_resist = 0

/mob/living/carbon/help_shake_act(mob/living/carbon/shaker)
	if(HAS_TRAIT(src, TRAIT_SURRENDERING))
		if(status_flags & GODMODE)
			status_flags &= ~GODMODE
			REMOVE_TRAIT(src, TRAIT_SURRENDERING, "surrender")
	. = ..()
