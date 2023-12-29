

/obj/item/clothing/head/centhat
	name = "\improper CentCom. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "centhat"
	siemens_coefficient = 0.9
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	item_state = "hairflower"
	flags_armor_protection = HEAD
	w_class = WEIGHT_CLASS_TINY
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	siemens_coefficient = 0.9
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags_inventory = COVEREYES
	flags_inv_hide = HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	siemens_coefficient = 0.9
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	siemens_coefficient = 2
	flags_armor_protection = HEAD
	anti_hug = 1
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	item_state="cueball"
	flags_inventory = NONE
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/greenbandanna
	name = "green bandanna"
	desc = "It's a green bandanna with some fine nanotech lining."
	icon_state = "greenbandanna"
	item_state = "greenbandanna"
	flags_inventory = NONE
	flags_inv_hide = NONE
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inventory = COVERMOUTH|COVEREYES
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags_inventory = COVERMOUTH|COVEREYES
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"
	siemens_coefficient = 0.9
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"
	flags_item = SYNTH_RESTRICTED
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 80, LASER = 50, ENERGY = 10, BOMB = 50, BIO = 0, FIRE = 10, ACID = 10)

/obj/item/clothing/head/bandanna/brown
	name = "brown bandanna"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandanna serves as a lightweight and comfortable hat."
	icon_state = "bandanna_brown"
	item_state = "bandanna_brown"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/bandanna/grey
	name = "grey bandanna"
	desc = "Show off the bleak side of your soul."
	icon_state = "bandanna_grey"
	item_state = "bandanna_grey"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/bandanna/red
	name = "red bandanna"
	desc = "For when it comes crashing down and it hurts inside."
	icon_state = "bandanna_red"
	item_state = "bandanna_red"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	item_state = "bowler"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For the gentleman of distinction."
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Soft felt makes this hat both comfortable and elegant."
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "The ultimate in summer fashion."
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A sharp, stylish hat."
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/feathertrilby
	name = "\improper feather trilby"
	icon_state = "feather_trilby"
	item_state = "feather_trilby"
	desc = "A sharp, stylish hat with a feather."
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "You should wear a fez. Fezzes are cool."
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags_inventory = NONE
	flags_inv_hide = HIDEALLHAIR
	siemens_coefficient = 2
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags_inventory = NONE
	flags_inv_hide = HIDEALLHAIR
	siemens_coefficient = 2
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags_inventory = COVERMOUTH|COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	siemens_coefficient = 2
	flags_armor_protection = HEAD|FACE|EYES
	anti_hug = 10 //Lel
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/white_dress
	name = "Dress White Cap"
	desc = "The dress white cap for your dress uniform."
	icon_state = "white_dress" //with thanks to Baystation12
	item_state = "white_dress" //with thanks to Baystation12
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/garrisoncap
	name = "Garrison Cap"
	desc = "The garrison cap for your service uniform. It reminds you of a shur for the external female genitalia."
	icon_state = "garrisoncap" //with thanks to Fitz 'Pancake' Sholl
	item_state = "garrisoncap" //with thanks to Fitz 'Pancake' Sholl
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/servicecap
	name = "Service Cap"
	desc = "The service cap for your service uniform. Technically, this is for officers, but the BX is full of these cap, so why not grab one?"
	icon_state = "servicecap" //with thanks to Fitz 'Pancake' Sholl
	item_state = "servicecap" //with thanks to Fitz 'Pancake' Sholl
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/serviceberet
	name = "Service Beret"
	desc = "The beret for your service uniform. This feels like something someone much higher speed than you would wear."
	icon_state = "beret_service"
	item_state = "beret_service"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/servicecampaignhat
	name = "Service Campaign Hat"
	desc = "The campaign hat for your service uniform. You can feel the menacing aura coming off it by just looking at it."
	icon_state = "campaignhat_service"
	item_state = "campaignhat_service"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/serviceushanka
	name = "Service Ushanka"
	desc = "The ushanka for your service uniform. For when you need to perform parade in subzero temperature."
	icon_state = "ushanaka_service"
	item_state = "ushanaka_service"
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP

/obj/item/clothing/head/techpriest
	name = "Techpriest hood"
	desc = "Praise the Omnissiah!"
	icon_state = "tp_hood"
	item_state = "tp_hood"
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_armor_protection = HEAD
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	flags_armor_features = ARMOR_NO_DECAP
