#define isNecoArc(H) (is_species(H, /datum/species/NecoArc))

/datum/namepool/NecoArc/get_random_name()
	return "Neco Arc [rand(1,9)]X[ascii2text(rand(65, 87))]" //65 to 87 is (uppercase) A to W

/mob/living/carbon/human/species/NecoArc
	race = "Neco Arc"
	//gender = NEUTER

/datum/species/NecoArc
	name = "Neco Arc"
	//name_plural = "Neco Arc"
	icobase = 'ss220/icons/mob/human_races/r_NecoArc.dmi'
	default_language_holder = /datum/language_holder/sectoid
	eyes = "blank_eyes"
	speech_verb_override = "transmits"
	count_human = TRUE

	species_flags = HAS_NO_HAIR|NO_BREATHE|NO_POISON|NO_PAIN|USES_ALIEN_WEAPONS|NO_DAMAGE_OVERLAY

	paincries = list("neuter" = 'ss220/sound/necoarc/NecoVIBIVII!!.ogg')
	death_sound = 'ss220/sound/necoarc/Necojooooonoooooooo.ogg'
	blood_color = "#00FF00"
	flesh_color = "#C0C0C0"
	reagent_tag = IS_SECTOID
	namepool = /datum/namepool/NecoArc
	special_death_message = "You have perished."

/datum/emote/living/carbon/NecoArc
	mob_type_allowed_typecache = /mob/living/carbon/human/species/NecoArc

/datum/emote/living/carbon/NecoArc/mudamuda
	key = "muda"
	key_third_person = "muda muda"
	message = "Muda Muda"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco Muda muDa.ogg'

/datum/emote/living/carbon/NecoArc/bubu //then add to the grenade throw
	key = "bubu"
	key_third_person = "bu bu"
	message = "bu buuu"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco bu buuu.ogg'

/datum/emote/living/carbon/NecoArc/dori
	key = "dori"
	key_third_person = "dori dori dori"
	message = "dori dori dori"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco dori dori dori.ogg'

/datum/emote/living/carbon/NecoArc/sayesa
	key = "sa"
	key_third_person = "sa yesa"
	message = "Sa Yesa!"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco Sa Yesa 1.ogg'

/datum/emote/living/carbon/NecoArc/sayesa/two
	key = "sa2"
	key_third_person = "sa yesa2"
	sound = 'ss220/sound/necoarc/Neco Sa Yesa 2.ogg'

/datum/emote/living/carbon/NecoArc/yanyan
	key = "yanyan"
	key_third_person = "yanyan yaan"
	message = "yanyan yaan"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco yanyan yaan.ogg'

/datum/emote/living/carbon/NecoArc/nya
	key = "nya"
	//key_third_person = "nya"
	message = "nya"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco-Arc sound effect.ogg'

/datum/emote/living/carbon/NecoArc/isa
	key = "isa"
	//key_third_person = "nya"
	message = "iiiiisAAAAA!"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco iiiiisAAAAA.ogg'

/datum/emote/living/carbon/NecoArc/qahu
	key = "qahu"
	key_third_person = "quiajuuu"
	message = "qahuuuuu!"
	emote_type = EMOTE_AUDIBLE
	sound = 'ss220/sound/necoarc/Neco quiajuuubn.ogg'

/obj/item/clothing/head/helmet/NecoArc
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'ss220/icons/item/helmetnecoarc.dmi'
	icon_state = "shield-blue"
	item_icons = "helmetNA"
	flags_item = NODROP|DELONDROP
	soft_armor = list("melee" = 65, "bullet" = 60, "laser" = 30, "energy" = 20, "bomb" = 25, "bio" = 40, "rad" = 0, "fire" = 20, "acid" = 20)
	anti_hug = 5

//emergency call NecoArc
/datum/emergency_call/NecoArc
	name = "Neco Arc"
	base_probability = 0
	spawn_type = /mob/living/carbon/human/species/NecoArc
	shuttle_id = SHUTTLE_DISTRESS_UFO
	alignement_factor = 0

/datum/emergency_call/NecoArc/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>Ваши емоуты: *muda, *bubu, *dori, *sa, *sa2, *yanyan, *nya, *isa, *qahu.")
	to_chat(H, "<B>Ваша миссия проста: уничтожить всех людей и любую другую расу, представляющую угрозу.</b>")

/datum/job/NecoArc
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/sectoid
	faction = FACTION_SECTOIDS

/datum/outfit/job/NecoArc/leader
	name = "Neco Arc leader"
	jobtype = /datum/job/NecoArc/leader

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/marine/sectoid
	head = /obj/item/clothing/head/helmet/NecoArc
	ears = /obj/item/radio/headset/distress/sectoid
	w_uniform = /obj/item/clothing/under/sectoid
	glasses = /obj/item/clothing/glasses/night/sectoid
	shoes = /obj/item/clothing/shoes/sectoid
	wear_suit = /obj/item/clothing/suit/armor/sectoid/shield
	gloves = /obj/item/clothing/gloves/sectoid
	r_store = /obj/item/stack/medical/heal_pack/gauze/sectoid
	l_store = /obj/item/explosive/grenade/sectoid
	back = /obj/item/weapon/gun/rifle/sectoid_rifle

/datum/outfit/job/NecoArc/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BELT)

/datum/outfit/job/NecoArc/standard
	name = "Neco Arc standard"
	jobtype = /datum/job/NecoArc/standard

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/marine/sectoid
	head = /obj/item/clothing/head/helmet/NecoArc
	ears = /obj/item/radio/headset/distress/sectoid
	w_uniform = /obj/item/clothing/under/sectoid
	glasses = /obj/item/clothing/glasses/night/sectoid
	shoes = /obj/item/clothing/shoes/sectoid
	wear_suit = /obj/item/clothing/suit/armor/sectoid
	gloves = /obj/item/clothing/gloves/sectoid
	r_store = /obj/item/stack/medical/heal_pack/gauze/sectoid
	l_store = /obj/item/explosive/grenade/sectoid
	back = /obj/item/weapon/gun/rifle/sectoid_rifle

/datum/outfit/job/NecoArc/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/sectoid_rifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BELT)

/datum/job/NecoArc/leader
	job_category = JOB_CAT_COMMAND
	title = "Neco Arc Leader"
	outfit = /datum/outfit/job/NecoArc/leader

/datum/job/NecoArc/standard
	title = "Neco Arc"
	outfit = /datum/outfit/job/NecoArc/standard

/datum/emergency_call/NecoArc/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .
	H.name = GLOB.namepool[/datum/namepool/NecoArc].random_name(H)
	H.real_name = H.name

	M.transfer_to(H, TRUE)
	H.fully_replace_character_name(M.name, H.real_name)

	if(original)
		qdel(original)

	print_backstory(H)
	H.update_hair()

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/NecoArc/leader)
		H.apply_assigned_role_to_spawn(J)
		to_chat(H, "<p style='font-size:1.5em'>[span_notice("Yahoo")]</p>")
		return

	var/datum/job/J = SSjob.GetJobType(/datum/job/NecoArc/standard)
	H.apply_assigned_role_to_spawn(J)
	to_chat(H, "<p style='font-size:1.5em'>[span_notice("Yahoo")]</p>")

