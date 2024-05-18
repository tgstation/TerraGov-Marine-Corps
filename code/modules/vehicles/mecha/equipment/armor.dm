/obj/item/mecha_equipment/armor
	equipment_slot = MECHA_ARMOR
	///short protection name to display in the UI
	var/protect_name = "you're mome"
	///icon in armor.dmi that shows in the UI
	var/iconstate_name
	///how much the armor of the mech is modified by
	var/list/armor_mod = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/mecha_equipment/armor/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	chassis.soft_armor = chassis.soft_armor.modifyRating(arglist(armor_mod))

/obj/item/mecha_equipment/armor/detach(atom/moveto)
	var/list/removed_armor = armor_mod.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type]
	chassis.soft_armor = chassis.soft_armor.modifyRating(arglist(removed_armor))
	return ..()
