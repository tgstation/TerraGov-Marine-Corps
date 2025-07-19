

/obj/item/clothing/head/centhat
	name = "\improper CentCom. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	worn_icon_state = "centhat"
	siemens_coefficient = 0.9
	armor_protection_flags = NONE

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	worn_icon_state = "hairflower"
	armor_protection_flags = NONE
	w_class = WEIGHT_CLASS_TINY

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	worn_icon_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	worn_icon_state = "that"
	siemens_coefficient = 0.9
	armor_protection_flags = NONE

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	armor_protection_flags = NONE

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	armor_protection_flags = NONE

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	inventory_flags = COVEREYES
	inv_hide_flags = HIDEEARS|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	siemens_coefficient = 0.9
	armor_protection_flags = NONE

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	icon_state = "syndicate"
	worn_icon_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	inventory_flags = COVEREYES|COVERMOUTH
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	siemens_coefficient = 2
	armor_protection_flags = HEAD|FACE|EYES
	anti_hug = 1

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	worn_icon_state="cueball"
	inventory_flags = NONE
	armor_protection_flags = HEAD|FACE|EYES

/obj/item/clothing/head/greenbandanna
	name = "green bandanna"
	desc = "It's a green bandanna with some fine nanotech lining."
	icon_state = "greenbandanna"
	worn_icon_state = "greenbandanna"
	inventory_flags = NONE
	inv_hide_flags = NONE
	armor_protection_flags = NONE

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	worn_icon_state = "cardborg_h"
	inventory_flags = COVERMOUTH|COVEREYES
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	worn_icon_state = "justicered"
	inventory_flags = COVERMOUTH|COVEREYES
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	worn_icon_state = "detective"
	siemens_coefficient = 0.9

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	worn_icon_state = "pirate"
	armor_protection_flags = NONE

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	worn_icon_state = "hgpiratecap"
	armor_protection_flags = NONE
	item_flags = SYNTH_RESTRICTED
	soft_armor = list(MELEE = 50, BULLET = 80, LASER = 50, ENERGY = 10, BOMB = 50, BIO = 0, FIRE = 10, ACID = 10)

/obj/item/clothing/head/bandanna/brown
	name = "brown bandanna"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandanna serves as a lightweight and comfortable hat."
	icon_state = "bandanna_brown"
	worn_icon_state = "bandanna_brown"

/obj/item/clothing/head/bandanna/grey
	name = "grey bandanna"
	desc = "Show off the bleak side of your soul."
	icon_state = "bandanna_grey"
	worn_icon_state = "bandanna_grey"

/obj/item/clothing/head/bandanna/red
	name = "red bandanna"
	desc = "For when it comes crashing down and it hurts inside."
	icon_state = "bandanna_red"
	worn_icon_state = "bandanna_red"

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	worn_icon_state = "bowler"
	armor_protection_flags = NONE

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	worn_icon_state = "bowler_hat"
	desc = "For the gentleman of distinction."
	armor_protection_flags = NONE

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	worn_icon_state = "beaver_hat"
	desc = "Soft felt makes this hat both comfortable and elegant."

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	worn_icon_state = "boater_hat"
	desc = "The ultimate in summer fashion."

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	worn_icon_state = "fedora"
	desc = "A sharp, stylish hat."

/obj/item/clothing/head/feathertrilby
	name = "\improper feather trilby"
	icon_state = "feather_trilby"
	worn_icon_state = "feather_trilby"
	desc = "A sharp, stylish hat with a feather."

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	worn_icon_state = "fez"
	desc = "You should wear a fez. Fezzes are cool."

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	worn_icon_state = "witch"
	inventory_flags = NONE
	inv_hide_flags = HIDEALLHAIR
	siemens_coefficient = 2

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	worn_icon_state = "chickensuit"
	inventory_flags = NONE
	inv_hide_flags = HIDEALLHAIR
	siemens_coefficient = 2
	armor_protection_flags = HEAD|FACE|EYES

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	worn_icon_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	inventory_flags = COVERMOUTH|COVEREYES|BLOCKSHARPOBJ
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	siemens_coefficient = 2
	armor_protection_flags = HEAD|FACE|EYES
	anti_hug = 10 //Lel

/obj/item/clothing/head/white_dress
	name = "Dress White Cap"
	desc = "The dress white cap for your dress uniform."
	icon_state = "white_dress" //with thanks to Baystation12
	worn_icon_state = "white_dress" //with thanks to Baystation12

/obj/item/clothing/head/garrisoncap
	name = "Garrison Cap"
	desc = "The garrison cap for your service uniform. It reminds you of a shur for the external female genitalia."
	icon_state = "garrisoncap" //with thanks to Fitz 'Pancake' Sholl
	worn_icon_state = "garrisoncap" //with thanks to Fitz 'Pancake' Sholl

/obj/item/clothing/head/servicecap
	name = "Service Cap"
	desc = "The service cap for your service uniform. Technically, this is for officers, but the BX is full of these cap, so why not grab one?"
	icon_state = "servicecap" //with thanks to Fitz 'Pancake' Sholl
	worn_icon_state = "servicecap" //with thanks to Fitz 'Pancake' Sholl

/obj/item/clothing/head/serviceberet
	name = "Service Beret"
	desc = "The beret for your service uniform. This feels like something someone much higher speed than you would wear."
	icon_state = "beret_service"
	worn_icon_state = "beret_service"

/obj/item/clothing/head/servicecampaignhat
	name = "Service Campaign Hat"
	desc = "The campaign hat for your service uniform. You can feel the menacing aura coming off it by just looking at it."
	icon_state = "campaignhat_service"
	worn_icon_state = "campaignhat_service"

/obj/item/clothing/head/serviceushanka
	name = "Service Ushanka"
	desc = "The ushanka for your service uniform. For when you need to perform parade in subzero temperature."
	icon_state = "ushanaka_service"
	worn_icon_state = "ushanaka_service"

/obj/item/clothing/head/techpriest
	name = "Techpriest hood"
	desc = "Praise the Omnissiah!"
	icon_state = "tp_hood"
	worn_icon_state = "tp_hood"
	inv_hide_flags = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	armor_protection_flags = HEAD|FACE|EYES
