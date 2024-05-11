/obj/item/explosive/grenade/training
	name = "M07 training grenade"
	desc = "A harmless reusable version of the M40 HEDP, used for training. Capable of being loaded in the any grenade launcher, or thrown by hand."
	icon_state = "training_grenade"
	worn_icon_state = "training_grenade"
	hud_state = "grenade_dummy"
	dangerous = FALSE
	icon_state_mini = "grenade_white"

/obj/item/explosive/grenade/training/prime()
	playsound(loc, 'sound/items/detector.ogg', 80, 0, 7)
	active = FALSE //so we can reuse it
	overlays.Cut()
	icon_state = initial(icon_state)
	det_time = initial(det_time) //these can be modified when fired by UGL
	throw_range = initial(throw_range)

/obj/item/explosive/grenade/training/fire_act(burn_level)
	return
