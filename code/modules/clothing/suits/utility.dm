/*
 * Contains:
 *		Fire protection
 *		Bomb protection
 *		Radiation protection
 */

/*
 * Fire protection
 */

/obj/item/clothing/suit/fire
	name = "firesuit"
	desc = "A suit that protects against fire and heat."
	icon_state = "fire"
	item_state = "fire_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/device/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/tool/extinguisher)
	slowdown = 1
	flags_inventory = STOPSPRESSUREDAMAGE|THICKMATERIAL
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	flags_heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRESUIT_max_heat_protection_temperature
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS


/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"


/obj/item/clothing/suit/fire/heavy
	name = "firesuit"
	desc = "An old, bulky thermal protection suit."
	//icon_state = "thermal"
	item_state = "ro_suit"
	w_class = 4//bulky item
	slowdown = 1.5

/*
 * Bomb protection
 */
/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	armor = list(melee = 20, bullet = 0, laser = 20,energy = 10, bomb = 100, bio = 0, rad = 0)
	flags_inventory = COVEREYES|COVERMOUTH|THICKMATERIAL
	flags_inv_hide = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES


/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_inventory = THICKMATERIAL
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor = list(melee = 20, bullet = 0, laser = 20,energy = 10, bomb = 100, bio = 0, rad = 0)
	flags_inv_hide = HIDEJUMPSUIT|HIDETAIL
	flags_heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_max_heat_protection_temperature


/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"

/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/baton,/obj/item/handcuffs)

/*
 * Radiation protection
 */
/obj/item/clothing/head/radiation
	name = "Radiation Hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	flags_inventory = COVEREYES|COVERMOUTH|THICKMATERIAL
	flags_inv_hide = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)


/obj/item/clothing/suit/radiation
	name = "Radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon_state = "rad"
	item_state = "rad_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	flags_inventory = THICKMATERIAL
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS|HANDS|FEET
	allowed = list(/obj/item/device/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/clothing/head/radiation,/obj/item/clothing/mask/gas)
	slowdown = 1.5
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 60, rad = 100)
	flags_inv_hide = HIDEJUMPSUIT|HIDETAIL
