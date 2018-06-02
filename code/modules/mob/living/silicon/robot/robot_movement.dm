/mob/living/silicon/robot/Process_Spaceslipping(var/prob_slip)
	if(module && (istype(module,/obj/item/circuitboard/robot_module/drone)))
		return 0
	..(prob_slip)

/mob/living/silicon/robot/Process_Spacemove()
	if(module)
		for(var/obj/item/tank/jetpack/J in module.modules)
			if(J && istype(J, /obj/item/tank/jetpack))
				if(J.allow_thrust(0.01))	return 1
	if(..())	return 1
	return 0

 //No longer needed, but I'll leave it here incase we plan to re-use it.
/mob/living/silicon/robot/movement_delay()
	. = ..()

	. += speed

	if(module_active && istype(module_active, /obj/item/robot/combat/mobility))
		. -= 3

	. += config.robot_delay
