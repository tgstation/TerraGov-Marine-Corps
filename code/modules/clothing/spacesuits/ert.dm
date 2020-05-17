/obj/item/clothing/head/helmet/space/rig/ert
	name = "emergency response team helmet"
	desc = "A helmet worn by members of the NanoTrasen Emergency Response Team. Armoured and space ready."
	icon_state = "rig0-ert_commander"
	item_state = "helm-command"
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 30, "bio" = 100, "rad" = 60, "fire" = 15, "acid" = 15)
	siemens_coefficient = 0.6


/obj/item/clothing/suit/space/rig/ert
	name = "emergency response team suit"
	desc = "A suit worn by members of the NanoTrasen Emergency Response Team. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/baton,/obj/item/weapon/energy/sword,/obj/item/restraints/handcuffs,/obj/item/tank/emergency_oxygen)
	slowdown = 1
	soft_armor = list("melee" = 60, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 30, "bio" = 100, "rad" = 100, "fire" = 15, "acid" = 15)
	allowed = list(/obj/item/flashlight, /obj/item/tank, /obj/item/t_scanner, /obj/item/rcd, /obj/item/tool/crowbar, \
	/obj/item/tool/screwdriver, /obj/item/tool/weldingtool, /obj/item/tool/wirecutters, /obj/item/tool/wrench, /obj/item/multitool, \
	/obj/item/radio, /obj/item/analyzer,/obj/item/weapon/gun)
	siemens_coefficient = 0.6

//Commander
/obj/item/clothing/head/helmet/space/rig/ert/commander
	name = "emergency response team commander helmet"
	desc = "A helmet worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights. Armoured and space ready."
	icon_state = "rig0-ert_commander"
	item_state = "helm-command"
	rig_color = "ert_commander"

/obj/item/clothing/suit/space/rig/ert/commander
	name = "emergency response team commander suit"
	desc = "A suit worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "suit-command"

//Security
/obj/item/clothing/head/helmet/space/rig/ert/security
	name = "emergency response team security helmet"
	desc = "A helmet worn by security members of a NanoTrasen Emergency Response Team. Has red highlights. Armoured and space ready."
	icon_state = "rig0-ert_security"
	item_state = "syndicate-helm-black-red"
	rig_color = "ert_security"

/obj/item/clothing/suit/space/rig/ert/security
	name = "emergency response team security suit"
	desc = "A suit worn by security members of a NanoTrasen Emergency Response Team. Has red highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_security"
	item_state = "syndicate-black-red"

//Engineer
/obj/item/clothing/head/helmet/space/rig/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "A helmet worn by engineering members of a NanoTrasen Emergency Response Team. Has orange highlights. Armoured and space ready."
	icon_state = "rig0-ert_engineer"
	rig_color = "ert_engineer"

/obj/item/clothing/suit/space/rig/ert/engineer
	name = "emergency response team engineer suit"
	desc = "A suit worn by the engineering of a NanoTrasen Emergency Response Team. Has orange highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_engineer"

//Medical
/obj/item/clothing/head/helmet/space/rig/ert/medical
	name = "emergency response team medical helmet"
	desc = "A helmet worn by medical members of a NanoTrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "rig0-ert_medical"
	rig_color = "ert_medical"

/obj/item/clothing/suit/space/rig/ert/medical
	name = "emergency response team medical suit"
	desc = "A suit worn by medical members of a NanoTrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "ert_medical"
