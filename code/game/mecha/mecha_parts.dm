/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "mecha part"
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "blank"
	w_class = WEIGHT_CLASS_GIGANTIC
	flags_1 = CONDUCT_1

/obj/item/mecha_parts/proc/try_attach_part(mob/user, obj/mecha/M) //For attaching parts to a finished mech
	if(!user.transferItemToLoc(src, M))
		to_chat(user, "<span class='warning'>\The [src] is stuck to your hand, you cannot put it in \the [M]!</span>")
		return FALSE
	user.visible_message("<span class='notice'>[user] attaches [src] to [M].</span>", "<span class='notice'>I attach [src] to [M].</span>")
	return TRUE

/obj/item/mecha_parts/part/try_attach_part(mob/user, obj/mecha/M)
	return

/obj/item/mecha_parts/chassis
	name = "Mecha Chassis"
	icon_state = "backbone"
	interaction_flags_item = NONE			//Don't pick us up!!
	var/construct_type

/obj/item/mecha_parts/chassis/Initialize()
	. = ..()
	if(construct_type)
		AddComponent(construct_type)

/////////// Ripley

/obj/item/mecha_parts/chassis/ripley
	name = "\improper Ripley chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/ripley

/obj/item/mecha_parts/part/ripley_torso
	name = "\improper Ripley torso"
	desc = ""
	icon_state = "ripley_harness"

/obj/item/mecha_parts/part/ripley_left_arm
	name = "\improper Ripley left arm"
	desc = ""
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/ripley_right_arm
	name = "\improper Ripley right arm"
	desc = ""
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/ripley_left_leg
	name = "\improper Ripley left leg"
	desc = ""
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/ripley_right_leg
	name = "\improper Ripley right leg"
	desc = ""
	icon_state = "ripley_r_leg"

///////// Odysseus

/obj/item/mecha_parts/chassis/odysseus
	name = "\improper Odysseus chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/odysseus

/obj/item/mecha_parts/part/odysseus_head
	name = "\improper Odysseus head"
	desc = ""
	icon_state = "odysseus_head"

/obj/item/mecha_parts/part/odysseus_torso
	name = "\improper Odysseus torso"
	desc="A torso part of Odysseus. Contains power unit, processing core and life support systems along with an attachment port for a mounted sleeper."
	icon_state = "odysseus_torso"

/obj/item/mecha_parts/part/odysseus_left_arm
	name = "\improper Odysseus left arm"
	desc = ""
	icon_state = "odysseus_l_arm"

/obj/item/mecha_parts/part/odysseus_right_arm
	name = "\improper Odysseus right arm"
	desc = ""
	icon_state = "odysseus_r_arm"

/obj/item/mecha_parts/part/odysseus_left_leg
	name = "\improper Odysseus left leg"
	desc = ""
	icon_state = "odysseus_l_leg"

/obj/item/mecha_parts/part/odysseus_right_leg
	name = "\improper Odysseus right leg"
	desc = ""
	icon_state = "odysseus_r_leg"

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "\improper Gygax chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/gygax

/obj/item/mecha_parts/part/gygax_torso
	name = "\improper Gygax torso"
	desc = ""
	icon_state = "gygax_harness"

/obj/item/mecha_parts/part/gygax_head
	name = "\improper Gygax head"
	desc = ""
	icon_state = "gygax_head"

/obj/item/mecha_parts/part/gygax_left_arm
	name = "\improper Gygax left arm"
	desc = ""
	icon_state = "gygax_l_arm"

/obj/item/mecha_parts/part/gygax_right_arm
	name = "\improper Gygax right arm"
	desc = ""
	icon_state = "gygax_r_arm"

/obj/item/mecha_parts/part/gygax_left_leg
	name = "\improper Gygax left leg"
	desc = ""
	icon_state = "gygax_l_leg"

/obj/item/mecha_parts/part/gygax_right_leg
	name = "\improper Gygax right leg"
	desc = ""
	icon_state = "gygax_r_leg"

/obj/item/mecha_parts/part/gygax_armor
	gender = PLURAL
	name = "\improper Gygax armor plates"
	desc = ""
	icon_state = "gygax_armor"


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "\improper Durand chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/durand

/obj/item/mecha_parts/part/durand_torso
	name = "\improper Durand torso"
	desc = ""
	icon_state = "durand_harness"

/obj/item/mecha_parts/part/durand_head
	name = "\improper Durand head"
	desc = ""
	icon_state = "durand_head"

/obj/item/mecha_parts/part/durand_left_arm
	name = "\improper Durand left arm"
	desc = ""
	icon_state = "durand_l_arm"

/obj/item/mecha_parts/part/durand_right_arm
	name = "\improper Durand right arm"
	desc = ""
	icon_state = "durand_r_arm"

/obj/item/mecha_parts/part/durand_left_leg
	name = "\improper Durand left leg"
	desc = ""
	icon_state = "durand_l_leg"

/obj/item/mecha_parts/part/durand_right_leg
	name = "\improper Durand right leg"
	desc = ""
	icon_state = "durand_r_leg"

/obj/item/mecha_parts/part/durand_armor
	gender = PLURAL
	name = "\improper Durand armor plates"
	desc = ""
	icon_state = "durand_armor"

////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "\improper Firefighter chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/firefighter


////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "\improper H.O.N.K chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/honker

/obj/item/mecha_parts/part/honker_torso
	name = "\improper H.O.N.K torso"
	desc = ""
	icon_state = "honker_harness"

/obj/item/mecha_parts/part/honker_head
	name = "\improper H.O.N.K head"
	desc = ""
	icon_state = "honker_head"

/obj/item/mecha_parts/part/honker_left_arm
	name = "\improper H.O.N.K left arm"
	desc = ""
	icon_state = "honker_l_arm"

/obj/item/mecha_parts/part/honker_right_arm
	name = "\improper H.O.N.K right arm"
	desc = ""
	icon_state = "honker_r_arm"

/obj/item/mecha_parts/part/honker_left_leg
	name = "\improper H.O.N.K left leg"
	desc = ""
	icon_state = "honker_l_leg"

/obj/item/mecha_parts/part/honker_right_leg
	name = "\improper H.O.N.K right leg"
	desc = ""
	icon_state = "honker_r_leg"


////////// Phazon

/obj/item/mecha_parts/chassis/phazon
	name = "\improper Phazon chassis"
	construct_type = /datum/component/construction/unordered/mecha_chassis/phazon

/obj/item/mecha_parts/part/phazon_torso
	name="\improper Phazon torso"
	desc="A Phazon torso part. The socket for the bluespace core that powers the exosuit's unique phase drives is located in the middle."
	icon_state = "phazon_harness"

/obj/item/mecha_parts/part/phazon_head
	name="\improper Phazon head"
	desc="A Phazon head. Its sensors are carefully calibrated to provide vision and data even when the exosuit is phasing."
	icon_state = "phazon_head"

/obj/item/mecha_parts/part/phazon_left_arm
	name="\improper Phazon left arm"
	desc="A Phazon left arm. Several microtool arrays are located under the armor plating, which can be adjusted to the situation at hand."
	icon_state = "phazon_l_arm"

/obj/item/mecha_parts/part/phazon_right_arm
	name="\improper Phazon right arm"
	desc="A Phazon right arm. Several microtool arrays are located under the armor plating, which can be adjusted to the situation at hand."
	icon_state = "phazon_r_arm"

/obj/item/mecha_parts/part/phazon_left_leg
	name="\improper Phazon left leg"
	desc="A Phazon left leg. It contains the unique phase drives that allow the exosuit to phase through solid matter when engaged."
	icon_state = "phazon_l_leg"

/obj/item/mecha_parts/part/phazon_right_leg
	name="\improper Phazon right leg"
	desc="A Phazon right leg. It contains the unique phase drives that allow the exosuit to phase through solid matter when engaged."
	icon_state = "phazon_r_leg"

/obj/item/mecha_parts/part/phazon_armor
	name="Phazon armor"
	desc="Phazon armor plates. They are layered with plasma to protect the pilot from the stress of phasing and have unusual properties."
	icon_state = "phazon_armor"


///////// Circuitboards

/obj/item/circuitboard/mecha
	name = "exosuit circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 1
	throw_range = 7

/obj/item/circuitboard/mecha/ripley/peripherals
	name = "Ripley Peripherals Control module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/ripley/main
	name = "Ripley Central Control module (Exosuit Board)"
	icon_state = "mainboard"


/obj/item/circuitboard/mecha/gygax/peripherals
	name = "Gygax Peripherals Control module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/gygax/targeting
	name = "Gygax Weapon Control and Targeting module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/gygax/main
	name = "Gygax Central Control module (Exosuit Board)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/durand/peripherals
	name = "Durand Peripherals Control module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/durand/targeting
	name = "Durand Weapon Control and Targeting module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/durand/main
	name = "Durand Central Control module (Exosuit Board)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/honker/peripherals
	name = "H.O.N.K Peripherals Control module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/targeting
	name = "H.O.N.K Weapon Control and Targeting module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/main
	name = "H.O.N.K Central Control module (Exosuit Board)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/odysseus/peripherals
	name = "Odysseus Peripherals Control module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/odysseus/main
	name = "Odysseus Central Control module (Exosuit Board)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/phazon/peripherals
	name = "Phazon Peripherals Control module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/targeting
	name = "Phazon Weapon Control and Targeting module (Exosuit Board)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/main
	name = "Phazon Central Control module (Exosuit Board)"
