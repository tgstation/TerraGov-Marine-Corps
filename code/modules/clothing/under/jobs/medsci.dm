/*
* Science
*/
/obj/item/clothing/under/rank/research_director
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	name = "research director's jumpsuit"
	icon_state = "director"
	worn_icon_state = "g_suit"

/obj/item/clothing/under/rank/research_director/rdalt
	desc = "A simple blue utilitarian jumpsuit that serves as the standard issue service uniform of support synthetics onboard TGMC facilities."
	name = "synthetic service uniform"
	icon_state = "rdalt"

/obj/item/clothing/under/rank/research_director/dress_rd
	name = "research director dress uniform"
	desc = "Feminine fashion for the style concious RD. Its fabric provides minor protection from biological contaminants."
	icon_state = "dress_rd"
	armor_protection_flags = CHEST|GROIN|ARMS

/obj/item/clothing/under/rank/scientist
	desc = "It's made of a special fiber that provides minor protection against small explosions. It has markings that denote the wearer as a scientist."
	name = "scientist's jumpsuit"
	icon_state = "science"
	worn_icon_state = "w_suit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/chemist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a chemist rank stripe on it."
	name = "chemist's jumpsuit"
	icon_state = "chemistry"
	worn_icon_state = "w_suit"
	permeability_coefficient = 0.50

/*
* Medical
*/
/obj/item/clothing/under/rank/chief_medical_officer
	desc = "It's a jumpsuit worn by those with the experience to be \"Chief Medical Officer\". It provides minor biological protection."
	name = "chief medical officer's jumpsuit"
	icon_state = "cmo"
	worn_icon_state = "w_suit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/geneticist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a genetics rank stripe on it."
	name = "geneticist's jumpsuit"
	icon_state = "genetics"
	worn_icon_state = "w_suit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/virologist
	desc = "It's made of a special fiber that gives special protection against biohazards. It has a virologist rank stripe on it."
	name = "virologist's jumpsuit"
	icon_state = "virology"
	worn_icon_state = "w_suit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/nursesuit
	desc = "It's a jumpsuit commonly worn by nursing staff in the medical department."
	name = "nurse's suit"
	icon_state = "nursesuit"
	permeability_coefficient = 0.50
	armor_protection_flags = CHEST|GROIN

/obj/item/clothing/under/rank/nurse
	desc = "A dress commonly worn by the nursing staff in the medical department."
	name = "nurse's dress"
	icon_state = "nurse"
	permeability_coefficient = 0.50
	armor_protection_flags = CHEST|GROIN
	adjustment_variants = list()

/obj/item/clothing/under/rank/orderly
	desc = "A white suit to be worn by orderly people who love orderly things."
	name = "orderly's uniform"
	icon_state = "orderly"
	permeability_coefficient = 0.50
	adjustment_variants = list()

/obj/item/clothing/under/rank/medical
	desc = "It's made of a special fiber that provides minor protection against biohazards. It has a cross on the chest denoting that the wearer is trained medical personnel."
	name = "medical doctor's jumpsuit"
	icon_state = "medical"
	worn_icon_state = "w_suit"
	permeability_coefficient = 0.50

/obj/item/clothing/under/rank/medical/blue
	name = "blue medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in baby blue."
	icon_state = "scrubsblue"
	adjustment_variants = list(
		"Half" = "_h",
	)

/obj/item/clothing/under/rank/medical/green
	name = "green medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in dark green."
	icon_state = "scrubsgreen"
	adjustment_variants = list(
		"Half" = "_h",
	)

/obj/item/clothing/under/rank/medical/purple
	name = "purple medical scrubs"
	desc = "It's made of a special fiber that provides minor protection against biohazards. This one is in deep purple."
	icon_state = "scrubspurple"
	adjustment_variants = list(
		"Half" = "_h",
	)

/obj/item/clothing/under/rank/psych
	desc = "A basic white jumpsuit. It has turqouise markings that denote the wearer as a psychiatrist."
	name = "psychiatrist's jumpsuit"
	icon_state = "psych"
	worn_icon_state = "w_suit"
	adjustment_variants = list()


/obj/item/clothing/under/rank/psych/turtleneck
	desc = "A turqouise turtleneck and a pair of dark blue slacks, belonging to a psychologist."
	name = "psychologist's turtleneck"
	icon_state = "psychturtle"
	worn_icon_state = "b_suit"
	adjustment_variants = list()
