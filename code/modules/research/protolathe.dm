/obj/machinery/rnd/protolathe
	name = "Protolathe"
	icon_state = "protolathe"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER

//Available designs

/datum/design/research
	build_type = PROTOLATHE
	construction_time = 100

/datum/design/research/armor_targeting
	name="Shoulder mount weapon module"
	desc="Interfaces a weapon with the wearer's mind to allow one to multitask while shooting"
	build_path=/obj/item/attachable/shoulder_mount
	materials = list(/datum/material/psi = 20)
	
/datum/design/research/blood_implant
	name="Blood regen implant"
	build_path=/obj/item/implanter/chem/blood
	materials = list(/datum/material/virilyth = 40)

/datum/design/research/cloak_implant
	name="Clock implant"
	build_path=/obj/item/implanter/cloak
	materials = list(/datum/material/psi = 40, /datum/material/virilyth = 20)

/datum/design/research/blade_implant
	name="Blade implant"
	build_path=/obj/item/implanter/blade
	materials = list(/datum/material/psi = 5, /datum/material/virilyth = 80)
