/obj/item/mecha_equipment/melee_core
	name = "melee core"
	desc = "A bluespace orion-sperkov converter. Through science you can't be bothered to understand, makes mechs faster and their weapons able to draw more power, making them more dangerous. However this comes at the cost of not being able to use projectile and laser weaponry."
	icon_state = "melee_core"
	equipment_slot = MECHA_UTILITY
	used_for_greyscale_mech = TRUE
	///speed amount we modify the mech by
	var/speed_mod

/obj/item/mecha_equipment/melee_core/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	ADD_TRAIT(M, TRAIT_MELEE_CORE, REF(src))
	speed_mod = min(chassis.move_delay-1, round(chassis.move_delay * 0.5))
	M.move_delay -= speed_mod

/obj/item/mecha_equipment/melee_core/detach(atom/moveto)
	REMOVE_TRAIT(chassis, TRAIT_MELEE_CORE, REF(src))
	chassis.move_delay += speed_mod
	return ..()

/obj/item/mecha_equipment/ability/dash
	name = "actuator safety override"
	desc = "A haphazard collection of electronics that allows the user to override standard safety inputs to increase speed, at the cost of extremely high power usage."
	icon_state = "booster"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_overload_mode
	used_for_greyscale_mech = TRUE
	///sound to loop when the dash is activated
	var/datum/looping_sound/mech_overload/sound_loop

/obj/item/mecha_equipment/ability/dash/Initialize(mapload)
	. = ..()
	sound_loop = new

/obj/item/mecha_equipment/ability/zoom
	name = "enhanced zoom"
	desc = "A magnifying module that allows the pilot to see much further than with the standard optics. Night vision not included."
	icon_state = "zoom"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_zoom
	used_for_greyscale_mech = TRUE

/obj/item/mecha_equipment/ability/smoke
	name = "generic smoke module"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	///smoke type to spawn when this ability is activated
	var/smoke_type
	///size of smoke cloud that spawns
	var/size = 6
	///duration of smoke cloud that spawns
	var/duration = 8

/obj/item/mecha_equipment/ability/smoke/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new smoke_type
	smoke.set_up(size, M, duration)
	smoke.attach(M)
	M.smoke_system = smoke
	M.smoke_charges = initial(M.smoke_charges)

/obj/item/mecha_equipment/ability/smoke/detach(atom/moveto)
	var/datum/effect_system/smoke_spread/bad/oldsmoke = new
	oldsmoke.set_up(3, chassis)
	oldsmoke.attach(chassis)
	chassis.smoke_system = oldsmoke
	return ..()

/obj/item/mecha_equipment/ability/smoke/tanglefoot
	name = "tanglefoot generator"
	desc = "A tanglefoot smoke generator capable of dispensing large amounts of non-lethal gas that saps the energy from any xenoform creatures it touches."
	icon_state = "tfoot_gas"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /datum/effect_system/smoke_spread/plasmaloss
	used_for_greyscale_mech = TRUE

/obj/item/mecha_equipment/ability/smoke/cloak_smoke
	name = "smoke generator"
	desc = "A multiple launch module that generates a large amount of cloaking smoke to disguise nearby friendlies. Sadly, huge robots are too difficult to hide with it."
	icon_state = "smoke_gas"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /datum/effect_system/smoke_spread/tactical
	used_for_greyscale_mech = TRUE
