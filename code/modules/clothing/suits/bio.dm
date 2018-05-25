//Biosuit complete with shoes (in the item sprite)
/obj/item/clothing/head/bio_hood
	name = "bio hood"
	icon_state = "bio"
	desc = "A hood that protects the head and face from biological comtaminants."
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEFACE|HIDEMASK|HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	siemens_coefficient = 0.9

/obj/item/clothing/suit/bio_suit
	name = "bio suit"
	desc = "A suit that protects against biological contamination."
	icon_state = "bio"
	item_state = "bio_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 1.0
	allowed = list(/obj/item/tank/emergency_oxygen,/obj/item/tool/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	siemens_coefficient = 0.9


//Standard biosuit, orange stripe
/obj/item/clothing/head/bio_hood/general
	icon_state = "bio_general"
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/suit/bio_suit/general
	icon_state = "bio_general"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL

//Virology biosuit, green stripe
/obj/item/clothing/head/bio_hood/virology
	icon_state = "bio_virology"

/obj/item/clothing/suit/bio_suit/virology
	icon_state = "bio_virology"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL

//Security biosuit, grey with red stripe across the chest
/obj/item/clothing/head/bio_hood/security
	icon_state = "bio_security"

/obj/item/clothing/suit/bio_suit/security
	icon_state = "bio_security"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL

//Janitor's biosuit, grey with purple arms
/obj/item/clothing/head/bio_hood/janitor
	icon_state = "bio_janitor"

/obj/item/clothing/suit/bio_suit/janitor
	icon_state = "bio_janitor"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL


//Scientist's biosuit, white with a pink-ish hue
/obj/item/clothing/head/bio_hood/scientist
	icon_state = "bio_scientist"

/obj/item/clothing/suit/bio_suit/scientist
	icon_state = "bio_scientist"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL

//CMO's biosuit, blue stripe
/obj/item/clothing/suit/bio_suit/cmo
	icon_state = "bio_cmo"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL

/obj/item/clothing/head/bio_hood/cmo
	icon_state = "bio_cmo"


//Plague Dr mask can be found in clothing/masks/gasmask.dm
/obj/item/clothing/suit/bio_suit/plaguedoctorsuit
	name = "Plague doctor suit"
	desc = "It protected doctors from the Black Death, back then. You bet your arse it's gonna help you against viruses."
	icon_state = "plaguedoctor"
	item_state = "bio_suit"
	flags_inv_hide = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL
