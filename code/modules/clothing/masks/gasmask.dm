

/obj/item/clothing/mask/gas
	name = "Transparent gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon_state = "gas_alt"
	item_state = "gas_alt"
	flags_inventory = COVERMOUTH | COVEREYES | BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEFACE|HIDELOWHAIR
	flags_cold_protection = HEAD
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	voice_filter = "lowpass=f=750,volume=2"
	var/gas_filter_strength = 1			//For gas mask filters
	var/list/filtered_gases = list(/datum/reagent/toxin/phoron, "sleeping_agent", "carbon_dioxide")
	///Does this particular mask have breath noises
	var/breathy = TRUE
	///This covers most of the screen
	var/hearing_range = 5

/obj/item/clothing/mask/gas/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!breathy)
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_GAS_BREATH))
		return
	if(slot != SLOT_WEAR_MASK)
		return
	for(var/M in get_hearers_in_view(hearing_range, src))
		if(ismob(M))
			var/mob/HM = M
			if(HM?.client?.prefs?.toggles_sound & SOUND_GAS_MASK)
				continue
			HM.playsound_local(user, "gasbreath", 20, 1)
			TIMER_COOLDOWN_START(src, COOLDOWN_GAS_BREATH, 10 SECONDS)

/obj/item/clothing/mask/gas/tactical
	name = "Tactical gas mask"
	icon_state = "gas_alt_tactical"

/obj/item/clothing/mask/gas/tactical/coif
	name = "Tactical coifed gas mask"
	desc = "A face-covering coifed mask that can be connected to an air supply. Filters harmful gases from the air."
	icon_state = "gascoif"
	flags_inv_hide = HIDEEARS|HIDEFACE|HIDEALLHAIR

/obj/item/clothing/mask/gas/pmc
	name = "\improper M8 pattern armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter."
	icon_state = "pmc_mask"
	item_state = "helmet"
	anti_hug = 3
	flags_inventory = COVERMOUTH|BLOCKGASEFFECT
	flags_inv_hide = HIDEEARS|HIDEFACE|HIDEALLHAIR
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/pmc/damaged
	name = "damaged M8 pattern armored balaclava"
	anti_hug = 0

/obj/item/clothing/mask/gas/pmc/upp
	name = "\improper UPP armored commando balaclava"
	icon_state = "upp_mask"

/obj/item/clothing/mask/gas/pmc/leader
	name = "\improper M8 pattern armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_mask"

/obj/item/clothing/mask/gas/wolves
	name = "tactical balaclava"
	desc = "A superior balaclava worn by the Steel Wolves."
	icon_state = "wolf_mask"
	anti_hug = 2
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/icc
	name = "\improper Modelle/60 gas mask"
	desc = "A gasmask worn by ICC personnel."
	icon_state = "icc"

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out phoron but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 2, ENERGY = 2, BOMB = 0, BIO = 75, FIRE = 2, ACID = 2)
	flags_armor_protection = HEAD|FACE

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	anti_hug = 1
	siemens_coefficient = 0.7
	flags_armor_protection = FACE|EYES

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	siemens_coefficient = 0.7

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	//desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/mode = 0// 0==Scouter|1==Night Vision|2==Thermal|3==Meson
	var/vchange = 0//This didn't do anything before. It now checks if the mask has special functions/N


/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	flags_armor_protection = HEAD|FACE|EYES
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"
	breathy = FALSE
	voice_filter = null

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
