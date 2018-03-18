/mob/living/silicon/robot/dust()
	//Delete the MMI first so that it won't go popping out.
	if(mmi)
		cdel(mmi)
		mmi = null
	..()

/mob/living/silicon/robot/death(gibbed)
	if(camera)
		camera.status = 0
	if(module)
		var/obj/item/device/gripper/G = locate(/obj/item/device/gripper) in module
		if(G) G.drop_item()
	remove_robot_verbs()
	sql_report_cyborg_death(src)
	..(gibbed,"is destroyed!")
	playsound(src.loc, 'sound/effects/metal_crash.ogg', 100)
	robogibs(src)
	cdel(src)
