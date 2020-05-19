

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "centhat"
	siemens_coefficient = 0.9
	flags_armor_protection = 0

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	item_state = "hairflower"
	flags_armor_protection = 0

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	siemens_coefficient = 0.9
	flags_armor_protection = 0

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	flags_armor_protection = 0

/obj/item/clothing/head/mailman
	name = "station cap"
	icon_state = "mailman"
	desc = "<i>Choo-choo</i>!"
	flags_armor_protection = 0

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	flags_armor_protection = 0

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags_inventory = COVEREYES
	flags_inv_hide = HIDEEARS|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	siemens_coefficient = 0.9
	flags_armor_protection = 0

/obj/item/clothing/head/syndicatefake
	name = "red space-helmet replica"
	icon_state = "syndicate"
	item_state = "syndicate"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD|FACE|EYES
	anti_hug = 1

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	item_state="cueball"
	flags_inventory = 0
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/head/greenbandanna
	name = "green bandanna"
	desc = "It's a green bandanna with some fine nanotech lining."
	icon_state = "greenbandanna"
	item_state = "greenbandanna"
	flags_inventory = NONE
	flags_inv_hide = NONE
	flags_armor_protection = 0

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags_inventory = COVERMOUTH|COVEREYES
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags_inventory = COVERMOUTH|COVEREYES
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"
	flags_armor_protection = 0

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"
	siemens_coefficient = 0.9

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	flags_armor_protection = 0

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"
	flags_armor_protection = 0
	soft_armor = list("melee" = 50, "bullet" = 80, "laser" = 50, "energy" = 10, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)

/obj/item/clothing/head/bandanna
	name = "pirate bandanna"
	desc = "Yarr."
	icon_state = "bandanna"
	item_state = "bandanna"

/obj/item/clothing/head/bandanna/red
	name = "red bandanna"
	desc = "For when it comes crashing down and it hurts inside."
	icon_state = "bandanna_red"

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	item_state = "bowler"
	flags_armor_protection = 0

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For the gentleman of distinction."
	flags_armor_protection = 0

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Soft felt makes this hat both comfortable and elegant."

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "The ultimate in summer fashion."

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A sharp, stylish hat."

/obj/item/clothing/head/feathertrilby
	name = "\improper feather trilby"
	icon_state = "feather_trilby"
	item_state = "feather_trilby"
	desc = "A sharp, stylish hat with a feather."

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "You should wear a fez. Fezzes are cool."

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags_inventory = NONE
	flags_inv_hide = HIDEALLHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags_inventory = NONE
	flags_inv_hide = HIDEALLHAIR
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD|FACE|EYES

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags_inventory = COVERMOUTH|COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	siemens_coefficient = 2.0
	flags_armor_protection = HEAD|FACE|EYES
	anti_hug = 10 //Lel

/obj/item/clothing/head/white_dress
	name = "White Dress Hat"
	desc = "The white dress hat for your dress uniform."
	icon_state = "white_dress" //with thanks to Baystation12
	item_state = "white_dress" //with thanks to Baystation12
