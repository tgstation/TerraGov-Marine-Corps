//XENOMORPH ORGANS
/datum/internal_organ/xenos/eggsac
	name = "egg sac"
	parent_limb = "groin"
	removed_type = /obj/item/organ/xenos/eggsac

/datum/internal_organ/xenos/plasmavessel
	name = "plasma vessel"
	parent_limb = "chest"
	removed_type = /obj/item/organ/xenos/plasmavessel
	var/stored_plasma = 0
	var/max_plasma = 500

/datum/internal_organ/xenos/plasmavessel/queen
	name = "bloated plasma vessel"
	stored_plasma = 200
	max_plasma = 500

/datum/internal_organ/xenos/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/datum/internal_organ/xenos/plasmavessel/hunter
	name = "tiny plasma vessel"
	stored_plasma = 100
	max_plasma = 150

/datum/internal_organ/xenos/acidgland
	name = "acid gland"
	parent_limb = "head"
	removed_type = /obj/item/organ/xenos/acidgland

/datum/internal_organ/xenos/hivenode
	name = "hive node"
	parent_limb = "chest"
	removed_type = /obj/item/organ/xenos/hivenode

/datum/internal_organ/xenos/resinspinner
	name = "resin spinner"
	parent_limb = "head"
	removed_type = /obj/item/organ/xenos/resinspinner

/obj/item/organ/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."

/obj/item/organ/xenos/eggsac
	name = "egg sac"
	icon_state = "xgibmid1"
	organ_tag = "egg sac"
	organ_type = /datum/internal_organ/xenos/eggsac

/obj/item/organ/xenos/plasmavessel
	name = "plasma vessel"
	icon_state = "xgibdown1"
	organ_tag = "plasma vessel"
	organ_type = /datum/internal_organ/xenos/plasmavessel

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	icon_state = "xgibtorso"
	organ_tag = "acid gland"
	organ_type = /datum/internal_organ/xenos/acidgland

/obj/item/organ/xenos/hivenode
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "hive node"
	organ_type = /datum/internal_organ/xenos/hivenode

/obj/item/organ/xenos/resinspinner
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "resin spinner"
	organ_type = /datum/internal_organ/xenos/resinspinner
