/obj/item/clothing/gloves/healthanalyzer
	name = "\improper HF2 analyzer gloves"
	desc = "Advanced medical gauntlets with a built-in health analyzer for quickly scanning patients via a simple touch or wave."
	icon_state = "medscan_gloves"
	worn_icon_state = "medscan_gloves"
	soft_armor = list(MELEE = 25, BULLET = 15, LASER = 10, ENERGY = 15, BOMB = 15, BIO = 5, FIRE = 15, ACID = 15)
	cold_protection_flags = HANDS
	heat_protection_flags = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	/// Our internal health analyzer
	var/datum/health_scan/internal_scanner

/obj/item/clothing/gloves/healthanalyzer/Initialize(mapload)
	. = ..()
	internal_scanner = new(src)

/obj/item/clothing/gloves/healthanalyzer/Destroy()
	QDEL_NULL(internal_scanner)
	return ..()

/obj/item/clothing/gloves/healthanalyzer/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(user.gloves == src)
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
		RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK_ALTERNATE, PROC_REF(on_unarmed_attack_alternate))
	else
		UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
		UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK_ALTERNATE)

/obj/item/clothing/gloves/healthanalyzer/unequipped(mob/living/carbon/human/user, slot)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK) // We were delimbed or something
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK_ALTERNATE)

/// Signal handler: calls the analyze_vitals proc if we're good to analyze the carbon human target
/obj/item/clothing/gloves/healthanalyzer/proc/on_unarmed_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		INVOKE_ASYNC(internal_scanner, TYPE_PROC_REF(/datum/health_scan, analyze_vitals), target, user, FALSE)

/// Signal handler: calls the analyze_vitals proc if we're good to analyze the carbon human target.
/// Since we're right clicking we also try to show the scan to the `target`
/obj/item/clothing/gloves/healthanalyzer/proc/on_unarmed_attack_alternate(mob/living/carbon/human/user, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	if(user.a_intent != INTENT_HELP)
		return
	if(istype(user) && istype(target))
		INVOKE_ASYNC(internal_scanner, TYPE_PROC_REF(/datum/health_scan, analyze_vitals), target, user, TRUE)
