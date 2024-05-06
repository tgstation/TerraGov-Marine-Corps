/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/items/robot_parts.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	worn_icon_state = "buildpipe"
	icon_state = "blank"
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BELT
	var/list/part

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)

/obj/item/robot_parts/chest
	name = "robot torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"

/obj/item/robot_parts/head
	name = "robot head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"

/obj/item/robot_parts/robot_suit
	name = "robot endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"

/obj/item/robot_parts/biotic
	name = "biotic limbs"
	icon = 'icons/mob/human_races/r_human.dmi'
	atom_flags = NONE

/obj/item/robot_parts/biotic/l_arm
	name = "biotic left arm"
	desc = "A biotic limb."
	icon_state = "l_arm"
	part = list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)

/obj/item/robot_parts/biotic/r_arm
	name = "biotic right arm"
	desc = "A biotic limb."
	icon_state = "r_arm"
	part = list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)

/obj/item/robot_parts/biotic/l_leg
	name = "biotic left leg"
	desc = "A biotic limb."
	icon_state = "l_leg"
	part = list(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)

/obj/item/robot_parts/biotic/r_leg
	name = "biotic right leg"
	desc = "A biotic limb."
	icon_state = "r_leg"
	part = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
