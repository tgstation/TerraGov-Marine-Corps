/*
* Contains:
*		Security
*		Detective
*		Head of Security
*/

/*
* Security
*/
/obj/item/clothing/under/rank/warden
	name = "security suit"
	desc = "A formal security suit for officers complete with Nanotrasen belt buckle."
	icon_state = "wardenred"
	item_state = "r_suit"
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/warden/white
	name = "white security suit"
	desc = "A formal relic of years past before Nanotrasen decided it was cheaper to dye the suits red instead of washing out the blood."
	icon_state = "wardenwhite"
	item_state = "wardenwhite"

/obj/item/clothing/under/rank/security
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "securityred"
	item_state = "r_suit"
	siemens_coefficient = 0.9

/obj/item/clothing/under/rank/security/white
	name = "white security jumpsuit"
	desc = "A tactical relic of years past before Nanotrasen decided it was cheaper to dye the suits red instead of washing out the blood."
	icon_state = "securitywhite"
	item_state = "securitywhite"

/obj/item/clothing/under/rank/security/skirt
	name = "security jumpskirt"
	desc = "A \"tactical\" security jumpsuit with the legs replaced by a skirt."
	icon_state = "securityskirtred"
	item_state = "securityskirtred"
/obj/item/clothing/under/rank/dispatch
	name = "dispatcher's uniform"
	desc = "A dress shirt and khakis with a security patch sewn on."
	icon_state = "dispatch"
	flags_armor_protection = CHEST|GROIN|LEGS
	siemens_coefficient = 0.9
	adjustment_variants = list()

/obj/item/clothing/under/rank/security2
	name = "security officer's uniform"
	desc = "It's made of a slightly sturdier material, to allow for robust protection."
	icon_state = "redshirt2"
	item_state = "r_suit"
	siemens_coefficient = 0.9
	adjustment_variants = list()

/obj/item/clothing/under/rank/security/corp
	icon_state = "sec_corporate"
	adjustment_variants = list()

/obj/item/clothing/under/rank/warden/corp
	icon_state = "warden_corporate"
	adjustment_variants = list()

/obj/item/clothing/under/tactical
	name = "tactical jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "swatunder"
	siemens_coefficient = 0.9

/*
* Detective
*/
/obj/item/clothing/under/rank/det
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	siemens_coefficient = 0.9
	adjustment_variants = list()

/obj/item/clothing/under/rank/det/black
	icon_state = "detective2"
	adjustment_variants = list()

/obj/item/clothing/under/rank/det/slob
	icon_state = "polsuit"
	adjustment_variants = list(
		"Down" = "_d",
	)

/obj/item/clothing/under/rank/det/grey
	name = "noir suit"
	desc = "A hard-boiled private investigator's grey suit, complete with tie clip."
	icon_state = "greydet"
	item_state = "greydet"
	adjustment_variants = list()

/*
* Head of Security
*/
/obj/item/clothing/under/rank/head_of_security
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of \"Head of Security\". It has additional armor to protect the wearer."
	name = "head of security's jumpsuit"
	icon_state = "hosred"
	item_state = "r_suit"
	siemens_coefficient = 0.8

/obj/item/clothing/under/rank/head_of_security/white
	name = "head of security's white jumpsuit"
	desc = "There are old men, and there are bold men, but there are very few old, bold men."
	icon_state = "hoswhite"
	item_state = "hoswhite"

/obj/item/clothing/under/rank/head_of_security/alt
	name = "head of security's turtleneck"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with tactical pants."
	icon_state = "hosalt"
	item_state = "hosalt"

/obj/item/clothing/under/rank/head_of_security/corp
	icon_state = "hos_corporate"
	adjustment_variants = list()

//Jensen cosplay gear
/obj/item/clothing/under/rank/head_of_security/jensen
	desc = "You never asked for anything that stylish."
	name = "head of security's jumpsuit"
	icon_state = "jensen"
	item_state = "jensen"
	siemens_coefficient = 0.6
	adjustment_variants = list()

/*
*Blart Uniform
*/
/obj/item/clothing/under/rank/security/mallcop
	name = "NT mall cop uniform"
	desc = "The radio and badge are sewn on, what a crappy knock off. Secway not included."
	icon_state = "mallcop"
	item_state = "mallcop"

/*
* Navy uniforms
*/

/obj/item/clothing/under/rank/security/navyblue
	name = "security officer's uniform"
	desc = "The latest in fashionable security outfits."
	icon_state = "officerblueclothes"
	item_state = "officerblueclothes"

/obj/item/clothing/under/rank/head_of_security/navyblue
	desc = "The insignia on this uniform tells you that this uniform belongs to the Head of Security."
	name = "head of security's uniform"
	icon_state = "hosblueclothes"
	item_state = "hosblueclothes"

/obj/item/clothing/under/rank/warden/navyblue
	desc = "The insignia on this uniform tells you that this uniform belongs to the Warden."
	name = "warden's uniform"
	icon_state = "wardenblueclothes"
	item_state = "wardenblueclothes"
