//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "A hood that protects the head and face from biological comtaminants."
	permeability_coefficient = 0.01
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	siemens_coefficient = 0.9

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	item_state = "bio_suit"
	w_class = WEIGHT_CLASS_BULKY//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_armor_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 1.0
	allowed = list(/obj/item/tank/emergency_oxygen,/obj/item/tool/pen,/obj/item/flashlight/pen)
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0.9


//Standard biosuit, orange stripe
/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT

//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT

//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	icon_state = "bio_security"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT

//Janitor's biosuit, grey with purple arms
/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT


//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT

//CMO's biosuit, blue stripe
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"
	flags_armor_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"


//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "Plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT
