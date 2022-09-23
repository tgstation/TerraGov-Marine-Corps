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
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, "rad" = 0, FIRE = 90, ACID = 0)
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	flags_item = IMPEDE_JETPACK
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/tool/extinguisher)
	slowdown = 1.0
	flags_inventory = NOPRESSUREDMAGE
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags_heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS


/obj/item/clothing/suit/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"


/obj/item/clothing/suit/fire/heavy
	name = "firesuit"
	desc = "A suit that protects against extreme fire and heat."
	//icon_state = "thermal"
	item_state = "ro_suit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	slowdown = 1.5

/*
* Bomb protection
*/
/obj/item/clothing/head/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 100, BIO = 0, "rad" = 0, FIRE = 0, ACID = 0)
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	siemens_coefficient = 0


/obj/item/clothing/suit/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	slowdown = 2
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 100, BIO = 0, "rad" = 0, FIRE = 0, ACID = 0)
	flags_inv_hide = HIDEJUMPSUIT
	flags_heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0


/obj/item/clothing/head/bomb_hood/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	flags_armor_protection = HEAD

/obj/item/clothing/suit/bomb_suit/security
	icon_state = "bombsuitsec"
	item_state = "bombsuitsec"
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/baton,/obj/item/restraints/handcuffs)
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

/*
* Radiation protection
*/
/obj/item/clothing/head/radiation
	name = "Radiation Hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. Label: Made with lead, do not eat insulation"
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, "rad" = 100, FIRE = 0, ACID = 0)


/obj/item/clothing/suit/radiation
	name = "Radiation suit"
	desc = "A suit that protects against radiation. Label: Made with lead, do not eat insulation."
	icon_state = "rad"
	item_state = "rad_suit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS|HANDS|FEET
	allowed = list(/obj/item/flashlight,/obj/item/tank/emergency_oxygen,/obj/item/clothing/head/radiation,/obj/item/clothing/mask/gas)
	slowdown = 1.5
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 60, "rad" = 100, FIRE = 0, ACID = 0)
	flags_inv_hide = HIDEJUMPSUIT
