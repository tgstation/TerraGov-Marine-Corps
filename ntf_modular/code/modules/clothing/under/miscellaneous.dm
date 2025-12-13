/obj/item/clothing/under/marine/sneaking
	name = "NTF Infiltration Uniform"
	desc = "An extremely expensive sneaking suit created by an Ninetails Corporation for high risk stealth missions, made with several layers of a nano-fiber that, while light, molds to the wearer's body shape and hardens protecting them. Only provided rarely to most successful Senior Operatives or higher. This uniform allows you to walk quietly and crawl through vents with ALT-CLICK. To change the variant of the suit, ALT-RIGHTCLICK on it."
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	icon_state = "sneak"
	armor_protection_flags = CHEST|GROIN|LEGS|ARMS|HANDS|FEET
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 15, FIRE = 15, ACID = 15)
	slowdown= -0.25
	var/variant = 1
	worn_icon_list = list(slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi')
	has_sensor = 2
	adjustment_variants = list()

/obj/item/clothing/under/marine/sneaking/equipped(mob/user, i_clothing)
	. = ..()
	ADD_TRAIT(user, TRAIT_CAN_VENTCRAWL, ARMOR_TRAIT)
	ADD_TRAIT(user, TRAIT_LIGHT_STEP, ARMOR_TRAIT)

/obj/item/clothing/under/marine/sneaking/unequipped(mob/unequipper, i_clothing)
	. = ..()
	REMOVE_TRAIT(unequipper, TRAIT_CAN_VENTCRAWL, ARMOR_TRAIT)
	REMOVE_TRAIT(unequipper, TRAIT_LIGHT_STEP, ARMOR_TRAIT)

/obj/item/clothing/under/marine/sneaking/AltRightClick(mob/user)
	. = ..()
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	worn_icon_list = list(slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi')
	variant ++
	shows_top_genital = FALSE
	shows_bottom_genital = FALSE
	if(variant == 7)
		variant = 1
	switch(variant)
		if(1)
			name = "NTF Infiltration Uniform"
			desc = "An extremely expensive sneaking suit created by an Ninetails Corporation for high risk stealth missions, made with several layers of a nano-fiber that, while light, molds to the wearer's body shape and hardens protecting them. Only provided rarely to most successful Senior Operatives or higher. This uniform allows you to walk quietly and crawl through vents with ALT-CLICK. To change the variant of the suit, ALT-CLICK on it."
			icon_state = "sneak"
		if(2)
			name = "NTC Spec-Ops Tactical T-Back Leotard"
			desc = "An extremely expensive sneaking leotard with extra skin-showing properties created by an Ninetails Corporation for high risk missions with high risk clothes, made with several layers of a nano-fiber that, while light, molds to the wearer's body shape and hardens protecting them. Only provided rarely to most successful Senior Operatives or higher. This leotard allows you to walk quietly and crawl through vents with ALT-CLICK"
			icon_state = "sneak_leotard"
			shows_bottom_genital = TRUE
		if(3)
			name = "NTC Spec-Ops Tactical String bikini"
			desc = "An extremely expensive sneaking... string bikini? with ultra-extra skin-showing properties created by an Ninetails Corporation for high risk missions with highest risk clothes, made with several layers of a nano-fiber that, while light-- It doesn't even matter, it practically doesn't exist, guess the sneakiest suit of all so far. This bikini allows you to walk quietly and crawl through vents with ALT-CLICK"
			icon_state = "sneak_kini"
			shows_bottom_genital = TRUE
		if(4)
			name = "executive suit"
			desc = "An extremely expensive looking formal uniform that seems to have toughened, kevlar or maybe another material fabric... Reminds you of john wick's suit but nowhere near as bulletproof."
			icon_state = "sneak_suit"
		if(5)
			name = "executive suit"
			desc = "An extremely expensive looking formal uniform with a short, side split skirt that seems to have toughened, kevlar or maybe another material fabric... Reminds you of john wick's suit but nowhere near as bulletproof."
			icon_state = "sneak_suitskirt"
		if(6)
			name = "sneaking harness"
			desc = "You are pretty much naked for maximum stealth, almost a NAKED SNAKE through the vents and all, good luck. This uniform allows you to walk quietly and crawl through vents with ALT-CLICK. To change the variant of the suit, ALT-CLICK on it."
			icon = 'ntf_modular/icons/obj/clothing/uniforms/lewdclothes.dmi'
			icon_state = "gear_harness"
			worn_icon_list = list(slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/lewdclothes.dmi')
			worn_icon_state = "gear_harness"
			shows_top_genital = TRUE
			shows_bottom_genital = TRUE
	update_icon()
	update_clothing_icon()

/obj/item/clothing/under/marine/sneaking/armoredsuit
	name = "executive suit"
	desc = "An extremely expensive looking formal uniform with a short, side split skirt that seems to have toughened, kevlar or maybe another material fabric... Reminds you of john wick's suit but nowhere near as bulletproof."
	soft_armor = list(MELEE = 10, BULLET = 20, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 15, FIRE = 15, ACID = 15)
	icon_state = "sneak_suitskirt"
