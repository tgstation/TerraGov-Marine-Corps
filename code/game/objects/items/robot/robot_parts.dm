/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/items/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	matter = list("metal" = 500, "glass" = 0)
	var/construction_time = 100
	var/list/construction_cost = list("metal"=20000,"glass"=5000)
	var/list/part = null

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	construction_time = 200
	construction_cost = list("metal"=18000)
	part = list("l_arm","l_hand")

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	construction_time = 200
	construction_cost = list("metal"=18000)
	part = list("r_arm","r_hand")

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	construction_time = 200
	construction_cost = list("metal"=15000)
	part = list("l_leg","l_foot")

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	construction_time = 200
	construction_cost = list("metal"=15000)
	part = list("r_leg","r_foot")

/obj/item/robot_parts/chest
	name = "robot torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	construction_time = 350
	construction_cost = list("metal"=40000)

/obj/item/robot_parts/head
	name = "robot head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	construction_time = 350
	construction_cost = list("metal"=25000)

/obj/item/robot_parts/robot_suit
	name = "robot endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	construction_time = 500
	construction_cost = list("metal"=50000)