/obj/structure/fence
	name = "fence"
	desc = "A large metal mesh strewn between two poles. Intended as a cheap way to separate areas, while allowing one to see through it."
	icon = 'icons/obj/smooth_objects/fence.dmi'
	base_icon_state = "fence"
	icon_state = "fence-icon"
	density = TRUE
	anchored = TRUE //We can not be moved.
	layer = ABOVE_WINDOW_LAYER
	max_integrity = 150 //Its cheap but still viable to repair, cant be moved around, about 7 runner hits to take down
	resistance_flags = XENO_DAMAGEABLE
	minimap_color = MINIMAP_FENCE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_FENCE)
	canSmoothWith = list(SMOOTH_GROUP_FENCE)
	var/cut = FALSE //Cut fences can be passed through
	///Chance for the fence to break on /init
	var/chance_to_break = 80 //Defaults to 80%
	///icon set we switch to when destroyed
	var/destroyed_icon = 'icons/obj/smooth_objects/brokenfence.dmi'

/obj/structure/fence/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 125), BRUTE, BOMB)//Almost broken or half way
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 75), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(30, BRUTE, BOMB)

/obj/structure/fence/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/stack/rods) && obj_integrity < max_integrity)
		if(user.skills.getRating(SKILL_CONSTRUCTION) < SKILL_CONSTRUCTION_PLASTEEL)
			user.visible_message(span_notice("[user] fumbles around figuring out how to fix [src]'s wiring."),
			span_notice("You fumble around figuring out how to fix [src]'s wiring."))
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_CONSTRUCTION)
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		var/obj/item/stack/rods/R = I
		var/amount_needed = 4
		if(obj_integrity)
			amount_needed = 4

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		user.visible_message(span_notice("[user] starts repairing [src] with [R]."),
		"<span class='notice'>You start repairing [src] with [R]")
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)

		if(!do_after(user, 30, NONE, src, BUSY_ICON_FRIENDLY))
			return

		if(R.amount < amount_needed)
			to_chat(user, "<span class='warning'>You need more metal rods to repair [src].")
			return

		R.use(amount_needed)
		repair_damage(max_integrity, user)
		cut = 0
		density = TRUE
		icon = initial(icon)
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message(span_notice("[user] repairs [src] with [R]."),
		"<span class='notice'>You repair [src] with [R]")

	else if(cut) //Cut/brokn grilles can't be messed with further than this
		return

	if(!iswirecutter(I))
		return
	user.visible_message(span_notice("[user] starts cutting through [src] with [I]."),
	"<span class='notice'>You start cutting through [src] with [I]")
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
		return

	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	user.visible_message(span_notice("[user] cuts through [src] with [I]."),
	"<span class='notice'>You cut through [src] with [I]")
	deconstruct(TRUE)

/obj/structure/fence/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	if(!isliving(grab.grabbed_thing))
		return

	var/mob/living/grabbed_mob = grab.grabbed_thing
	var/state = user.grab_state
	user.drop_held_item()
	var/damage = (user.skills.getRating(SKILL_UNARMED) * UNARMED_SKILL_DAMAGE_MOD)
	switch(state)
		if(GRAB_PASSIVE)
			damage += BASE_OBJ_SLAM_DAMAGE
			grabbed_mob.visible_message(span_warning("[user] slams [grabbed_mob] against \the [src]!"))
			log_combat(user, grabbed_mob, "slammed", "", "against \the [src]")
		if(GRAB_AGGRESSIVE)
			damage += BASE_OBJ_SLAM_DAMAGE * 1.5
			grabbed_mob.visible_message(span_danger("[user] bashes [grabbed_mob] against \the [src]!"))
			log_combat(user, grabbed_mob, "bashed", "", "against \the [src]")
			if(prob(50))
				grabbed_mob.Paralyze(2 SECONDS)
		if(GRAB_NECK)
			damage += BASE_OBJ_SLAM_DAMAGE * 2
			grabbed_mob.visible_message(span_danger("<big>[user] crushes [grabbed_mob] against \the [src]!</big>"))
			log_combat(user, grabbed_mob, "crushed", "", "against \the [src]")
			grabbed_mob.Paralyze(2 SECONDS)
	grabbed_mob.apply_damage(damage, blocked = MELEE, updating_health = TRUE, attacker = user)
	take_damage(damage * 2, BRUTE, MELEE)
	return TRUE

/obj/structure/fence/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	SHOULD_CALL_PARENT(FALSE)
	if(disassembled)
		new /obj/item/stack/rods(loc)
	cut = TRUE
	density = FALSE
	icon = destroyed_icon

/obj/structure/fence/Initialize(mapload, start_dir)
	. = ..()

	if(prob(chance_to_break))
		obj_integrity = 0
		deconstruct(FALSE)

	if(start_dir)
		setDir(start_dir)

/obj/structure/fence/Destroy()
	density = FALSE
	icon = destroyed_icon
	return ..()

/obj/structure/fence/fire_act(burn_level)
	take_damage(burn_level, BURN, FIRE)

/obj/structure/fence/broken
	chance_to_break = 100

/obj/structure/fence/dark
	icon = 'icons/obj/smooth_objects/dark_fence.dmi'
	destroyed_icon = 'icons/obj/smooth_objects/brokenfence_dark.dmi'

/obj/structure/fence/dark/quality
	chance_to_break = 15
