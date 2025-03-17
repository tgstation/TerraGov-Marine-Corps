//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "A hood that protects the head and face from biological comtaminants."
	permeability_coefficient = 0.01
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	inventory_flags = COVEREYES|COVERMOUTH
	inv_hide_flags = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES
	siemens_coefficient = 0.9

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	worn_icon_state = "bio_suit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	armor_protection_flags = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 1
	allowed = list(/obj/item/tank/emergency_oxygen,/obj/item/tool/pen,/obj/item/flashlight/pen)
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	inv_hide_flags = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0.9

//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	inv_hide_flags = HIDEGLOVES|HIDEJUMPSUIT

//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	icon_state = "bio_security"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	inv_hide_flags = HIDEGLOVES|HIDEJUMPSUIT

//Janitor's biosuit, grey with purple arms
/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	inv_hide_flags = HIDEGLOVES|HIDEJUMPSUIT


//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	inv_hide_flags = HIDEGLOVES|HIDEJUMPSUIT

//CMO's biosuit, blue stripe
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS
	inv_hide_flags = HIDEGLOVES|HIDEJUMPSUIT

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"


//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "Plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	worn_icon_state = "bio_suit"
	inv_hide_flags = HIDEGLOVES|HIDEJUMPSUIT
