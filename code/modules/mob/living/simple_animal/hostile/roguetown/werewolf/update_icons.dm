/*/mob/living/simple_animal/hostile/rogue/werewolf/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	remove_overlay(HANDS_BEHIND_LAYER)

	var/list/hands = list()
	var/list/behindhands = list()

	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			if(I.bigboy)
				if(I.wielded)
					if(get_held_index_of_item(I) == 1)
						I.screen_loc = "WEST-4:16,SOUTH+7:-16"
					else
						I.screen_loc = "WEST-4:16,SOUTH+7:-16"
				else
					if(get_held_index_of_item(I) == 1)
						I.screen_loc = "WEST-4:0,SOUTH+7:-16"
					else
						I.screen_loc = "WEST-3:0,SOUTH+7:-16"
			else
				if(I.wielded)
					if(get_held_index_of_item(I) == 1)
						I.screen_loc = "WEST-3:0,SOUTH+7"
					else
						I.screen_loc = "WEST-3:0,SOUTH+7"
				else
					I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(observers && observers.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += I
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/mutable_appearance/inhand_overlay
		var/mutable_appearance/behindhand_overlay
		if(I.experimental_inhand)
			var/used_prop
			var/list/prop
			if(get_held_index_of_item(I) % 2 == 0) //righthand
				if(I.altgripped)
					used_prop = "altgripr"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				if(!prop && I.wielded)
					used_prop = "wieldedr"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				if(!prop && cmode)
					used_prop = "cmoder"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				if(!prop)
					used_prop = "genr"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				inhand_overlay = mutable_appearance(I.getmoboverlay(used_prop,prop), layer=-HANDS_LAYER)
				behindhand_overlay = mutable_appearance(I.getmoboverlay(used_prop,prop,behind=TRUE), layer=-HANDS_BEHIND_LAYER)
			else
				if(I.altgripped)
					used_prop = "altgripl"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				if(!prop && I.wielded)
					used_prop = "wieldedl"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				if(!prop && cmode)
					used_prop = "cmodel"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				if(!prop)
					used_prop = "genl"
					if(I.force_reupdate_inhand)
						prop = I.onprop[used_prop]
						if(!prop)
							prop = I.getonmobprop(used_prop)
							I.onprop[used_prop] = prop
					else
						prop = I.getonmobprop(used_prop)
				inhand_overlay = mutable_appearance(I.getmoboverlay(used_prop,prop), layer=-HANDS_LAYER)
				behindhand_overlay = mutable_appearance(I.getmoboverlay(used_prop,prop,behind=TRUE), layer=-HANDS_BEHIND_LAYER)

			inhand_overlay = center_image(inhand_overlay, I.inhand_x_dimension, I.inhand_y_dimension)
			behindhand_overlay = center_image(behindhand_overlay, I.inhand_x_dimension, I.inhand_y_dimension)

			if(gender == MALE)
				inhand_overlay.pixel_x += 0
				inhand_overlay.pixel_y += 0
				behindhand_overlay.pixel_x += 0
				behindhand_overlay.pixel_y += 0
			if(gender == FEMALE)
				inhand_overlay.pixel_x += 0
				inhand_overlay.pixel_y += 0
				behindhand_overlay.pixel_x += 0
				behindhand_overlay.pixel_y += 0

			hands += inhand_overlay
			behindhands += behindhand_overlay
		else
			var/icon_file = I.lefthand_file
			if(get_held_index_of_item(I) % 2 == 0)
				icon_file = I.righthand_file
			inhand_overlay = I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)
			inhand_overlay.pixel_x += 0
			inhand_overlay.pixel_y += 0
			hands += inhand_overlay

	update_inv_cloak() //cloak held items

	overlays_standing[HANDS_BEHIND_LAYER] = behindhands
	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_BEHIND_LAYER)
	apply_overlay(HANDS_LAYER)*/

/mob/living/simple_animal/hostile/rogue/werewolf/regenerate_icons()
	if(gender == MALE)
		icon_state = "wwolf_m"
	else
		icon_state = "wwolf_f"
	update_inv_hands()
	update_damage_overlays()

/mob/living/simple_animal/hostile/rogue/werewolf/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)
	testing("dambegin")
	var/list/hands = list()
	var/mutable_appearance/inhand_overlay = mutable_appearance("[icon_state]-dam", layer=-DAMAGE_LAYER)
	var/numba = 255 * (health / maxHealth)
	inhand_overlay.alpha = 255 - numba
	testing("damalpha [inhand_overlay.alpha]")
	hands += inhand_overlay

	overlays_standing[DAMAGE_LAYER] = hands
	apply_overlay(DAMAGE_LAYER)