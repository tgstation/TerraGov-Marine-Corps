//DIONA ORGANS.
/datum/organ/internal/diona
	removed_type = /obj/item/organ/diona

/datum/organ/internal/diona/process()
	return

/datum/organ/internal/diona/strata
	name = "neural strata"
	parent_organ = "chest"

/datum/organ/internal/diona/bladder
	name = "gas bladder"
	parent_organ = "head"

/datum/organ/internal/diona/polyp
	name = "polyp segment"
	parent_organ = "groin"

/datum/organ/internal/diona/ligament
	name = "anchoring ligament"
	parent_organ = "groin"

/datum/organ/internal/diona/node
	name = "receptor node"
	parent_organ = "head"
	removed_type = /obj/item/organ/diona/node

/datum/organ/internal/diona/nutrients
	name = "nutrient vessel"
	parent_organ = "chest"
	removed_type = /obj/item/organ/diona/nutrients

/obj/item/organ/diona
	name = "diona nymph"
	icon = 'icons/obj/objects.dmi'
	icon_state = "nymph"
	organ_tag = "special" // Turns into a nymph instantly, no transplanting possible.

/obj/item/organ/diona/removed(var/mob/living/target,var/mob/living/user)

	var/mob/living/carbon/human/H = target
	if(!istype(target))
		cdel(src)

	if(!H.internal_organs.len)
		H.death()

	//This is a terrible hack and I should be ashamed.
	var/datum/seed/diona = seed_types["diona"]
	if(!diona)
		cdel(src)

//	var/mob/living/carbon/alien/diona/D = new(get_turf(src))
//	diona.request_player(D)

	cdel(src)

// These are different to the standard diona organs as they have a purpose in other
// species (absorbing radiation and light respectively)
/obj/item/organ/diona/nutrients
	name = "nutrient vessel"
	organ_tag = "nutrient vessel"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	organ_type = /datum/organ/internal/diona/nutrients

/obj/item/organ/diona/nutrients/removed()
	return

/obj/item/organ/diona/node
	name = "receptor node"
	organ_tag = "receptor node"
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	organ_type = /datum/organ/internal/diona/node


/obj/item/organ/diona/node/removed()
	return



//XENOMORPH ORGANS
/datum/organ/internal/xenos/eggsac
	name = "egg sac"
	parent_organ = "groin"
	removed_type = /obj/item/organ/xenos/eggsac

/datum/organ/internal/xenos/plasmavessel
	name = "plasma vessel"
	parent_organ = "chest"
	removed_type = /obj/item/organ/xenos/plasmavessel
	var/stored_plasma = 0
	var/max_plasma = 500

/datum/organ/internal/xenos/plasmavessel/queen
	name = "bloated plasma vessel"
	stored_plasma = 200
	max_plasma = 500

/datum/organ/internal/xenos/plasmavessel/sentinel
	stored_plasma = 100
	max_plasma = 250

/datum/organ/internal/xenos/plasmavessel/hunter
	name = "tiny plasma vessel"
	stored_plasma = 100
	max_plasma = 150

/datum/organ/internal/xenos/acidgland
	name = "acid gland"
	parent_organ = "head"
	removed_type = /obj/item/organ/xenos/acidgland

/datum/organ/internal/xenos/hivenode
	name = "hive node"
	parent_organ = "chest"
	removed_type = /obj/item/organ/xenos/hivenode

/datum/organ/internal/xenos/resinspinner
	name = "resin spinner"
	parent_organ = "head"
	removed_type = /obj/item/organ/xenos/resinspinner

/obj/item/organ/xenos
	name = "xeno organ"
	icon = 'icons/effects/blood.dmi'
	desc = "It smells like an accident in a chemical factory."

/obj/item/organ/xenos/eggsac
	name = "egg sac"
	icon_state = "xgibmid1"
	organ_tag = "egg sac"
	organ_type = /datum/organ/internal/xenos/eggsac

/obj/item/organ/xenos/plasmavessel
	name = "plasma vessel"
	icon_state = "xgibdown1"
	organ_tag = "plasma vessel"
	organ_type = /datum/organ/internal/xenos/plasmavessel

/obj/item/organ/xenos/acidgland
	name = "acid gland"
	icon_state = "xgibtorso"
	organ_tag = "acid gland"
	organ_type = /datum/organ/internal/xenos/acidgland

/obj/item/organ/xenos/hivenode
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "hive node"
	organ_type = /datum/organ/internal/xenos/hivenode

/obj/item/organ/xenos/resinspinner
	name = "hive node"
	icon_state = "xgibmid2"
	organ_tag = "resin spinner"
	organ_type = /datum/organ/internal/xenos/resinspinner

//VOX ORGANS.
/datum/organ/internal/stack
	name = "cortical stack"
	removed_type = /obj/item/organ/stack
	parent_organ = "head"
	robotic = 2
	vital = 1
	var/backup_time = 0
	var/datum/mind/backup

/datum/organ/internal/stack/process()
	if(owner && owner.stat != 2 && !is_broken())
		backup_time = world.time
		if(owner.mind) backup = owner.mind

/datum/organ/internal/stack/vox
	removed_type = /obj/item/organ/stack/vox

/datum/organ/internal/stack/vox/stack

/obj/item/organ/stack
	name = "cortical stack"
	icon_state = "brain-prosthetic"
	organ_tag = "stack"
	robotic = 2
	organ_type = /datum/organ/internal/stack

/obj/item/organ/stack/vox
	name = "vox cortical stack"
	organ_type = /datum/organ/internal/stack/vox