/obj/item/attachable/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/attachable/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/item/attachable/get_mechanics_info()
	. = ..()
	var/list/attach_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		attach_strings += general_entry.mechanics_text

	if(slot == "muzzle")
		attach_strings += "This attaches to the muzzle slot on most weapons.<br>"
	if(slot == "rail")
		attach_strings += "This attaches to the rail slot on most weapons.<br>"
	if(slot == "stock")
		attach_strings += "This attaches to the stock slot on most weapons.<br>"
	if(slot == "under")
		attach_strings += "This attaches to the underbarrel slot on most weapons.<br>"

	if(flags_attach_features & ATTACH_REMOVABLE)
		attach_strings += "This can be field stripped off the weapon if needed."

	if(flags_attach_features & ATTACH_ACTIVATION)
		attach_strings += "This needs to be activated to be used."

	if(flags_attach_features & ATTACH_RELOADABLE)
		attach_strings += "This can be reloaded with the appropriate ammunition."

	attach_strings += "<br><U>Always on modifications</U>:<br>"

	if(max_range)
		attach_strings += "This attachment has a max range of [max_range] tiles."
	if(damage_mod)
		attach_strings += "Damage: [damage_mod * 100]%"
	if(damage_falloff_mod)
		attach_strings += "Damage falloff: [damage_falloff_mod * 100]%"
	if(burst_scatter_mod)
		attach_strings += "Scatter chance: [burst_scatter_mod * 100]%"
	if(silence_mod)
		attach_strings += "This can silence the weapon if it is attached."
	if(light_mod)
		attach_strings += "Light increase: [light_mod] if turned on."
	if(delay_mod)
		attach_strings += "Delay between shots: [delay_mod / 10]"
	if(burst_mod)
		attach_strings += "Burst change: [burst_mod] shots."
	if(size_mod)
		attach_strings += "This will make your weapon [size_mod] weight bigger. Potentially making it no longer suitable for holsters."
	if(melee_mod)
		attach_strings += "Melee damage: [melee_mod]."
	if(wield_delay_mod)
		attach_strings += "Wield delay: [wield_delay_mod / 10] seconds."
	if(attach_shell_speed_mod)
		attach_strings += "Bullet speed: [attach_shell_speed_mod * 100]%"
	if(movement_acc_penalty_mod)
		attach_strings += "Running accuracy penalty: [movement_acc_penalty_mod * 100]%"
	if(max_rounds)
		attach_strings += "This attachment can hold [max_rounds] of its ammunition."
	if(scope_zoom_mod)
		attach_strings += "This has optical glass allowing for magnification and viewing long distances."
	if(aim_speed_mod)
		switch(aim_speed_mod)
			if(-INFINITY to 0.35)
				attach_strings += "<br>It will slow the user down more by a small amount if wielded."
			if((0.36) to 0.75)
				attach_strings += "<br>It will slow the user down more by a modest amount if wielded."
			if((0.76) to 1)
				attach_strings += "<br>It will slow the user down more by a large amount if wielded."
			if((1.01) to INFINITY)
				attach_strings += "<br>It will slow the user down more by a massive amount if wielded."
	if(!aim_speed_mod)
		attach_strings += "<br>It will not slow the user down more if this is attached and wielded."
	if(ammo_mod)
		attach_strings += "This will allow you to overcharge your weapon."
	if(charge_mod)
		attach_strings += "Charge cost: [charge_mod]."
	if(length(gun_firemode_list_mod) > 0)
		attach_strings += "This will allow for additional firemodes."


	attach_strings += "<br><U>Wielded modifications</U>:<br>"

	if(accuracy_mod)
		attach_strings += "Accuracy wielded: [accuracy_mod * 100]%"
	if(scatter_mod)
		attach_strings += "Scatter wielded: [scatter_mod]%"
	if(recoil_mod)
		attach_strings += "Recoil wielded: [recoil_mod]"

	attach_strings += "<br><U>un-wielded modifications</U>:<br>"

	if(accuracy_unwielded_mod)
		attach_strings += "Accuracy un-wielded: [accuracy_unwielded_mod * 100]%"
	if(scatter_unwielded_mod)
		attach_strings += "Scatter un-wielded: [scatter_unwielded_mod]%"
	if(recoil_unwielded_mod)
		attach_strings += "Recoil un-wielded: [recoil_unwielded_mod]"

	. += jointext(attach_strings, "<br>")


/datum/codex_entry/baton
	associated_paths = list(/obj/item/weapon/baton)
	mechanics_text = "The baton needs to be turned on to apply the stunning effect. Use it in your hand to toggle it on or off. If your intent is \
	set to 'harm', you will inflict damage when using it, regardless if it is on or not. Each stun reduces the baton's charge, which can be replenished by \
	putting it inside a weapon recharger."

/datum/codex_entry/mines
	associated_paths = list(/obj/item/explosive/mine)
	mechanics_text = "Claymores are best used in tandem with sentry guns that can shoot enemies which trip them, and ambushing marines concealed by tarps or cloaking devices."

/datum/codex_entry/sniper_rifle
	associated_paths = list(/obj/item/weapon/gun/rifle/sniper/M42A)
	lore_text = "A rather strange gun in the TGMC's arsenal. The M42A \"Express\" originally was born out of it's younger brother the M42. Made by the same \
	company who eventually went on to design the M56 smartgun system. Which the M42As specialized scope eventually adopted a modified IFF system similar to it's cousin the smartgun. <br><br>\
	It was at first marketed to PMCs and civilians as an expensive accurate long range rifle but it failed due to the lack of need for such a thing for PMCs and the wide variety of options \
	already available for civilians in a more affordable package. The company after the failure went onto design the M56 smartgun and succeeded there however. Which kept them afloat after the failure of the M42.<br><br>\
	Later however an announcement by the Marine Corps who decided to replace the aging supply of the current adopted Sniper Rifle after complaints that the frames were starting to wear out due to long-term use and thus trials would be announced to replace them.<br><br>\
	Eventually, the board of directors decided to give that reviving the M42 design was a worthwhile possibility. And thus the design was decided to be modernized and equipped with an IFF-capable scope, after that it was named as the M42A and submitted to go the trials.<br><br>\
	Though high unit cost didn't allow it to be more widely adopted it was eventually decided that it would meet limited adoption for Marksmen and be designated the T-26."

/datum/codex_entry/battle_rifle
	associated_paths = list(/obj/item/weapon/gun/rifle/m4ra)
	lore_text = "The M45A was born from a commission order from the TGMC to the company which made the M42A and M56 smartgun systems. <br><br>\
	The reason for this commission order resulted from complaints from light infantry and scout units about the poor accuracy of the new T-26 \
	carbine at longer ranges and the large size of the T-29 making close combat uncomfortable eventually reached the higher ups, who kept getting \
	the same complaints over and over. So they eventually reached out to a trusted company to do it.<br><br>\
	The commission order requested a versatile rifle that can do combat at all ranges but can be compact. <br><br>\
	Eventually, the designers decided to use the same 10x28 round the M42A used with different pressure specifications \
	the ammo used for the M45A was pretty much purpose-built to use.<br><br>\
	It was also decided to use a bullpup configuration to keep the size compact and to allow for a longer barrel \
	while keeping the size small. This resulted in a gun created for specialized troops to use at longer than usual \
	ranges and at close range quite effectively.<br><br>\
	After tests by the troops it was meant to be supplied to (light infantry and scout troops) it was rather well-liked \
	and was met with limited adoption for light infantry and scout troops.<br><br>\
	The TGMC gave it the designation of T-45 after adoption."

/datum/codex_entry/rocket_launcher
	associated_paths = list(/obj/item/weapon/gun/launcher/rocket)
	lore_text = "Nicknamed the \"SADAR\", which refers to the previous rocket launcher the SU-185 eventually replaced. <br><br>\
	The SU-185 was designed with low weight to be easy to carry on one's back and still be able to carry rockets on the person who \
	is carrying the weapon without making them weighed down too far. It's also created with short range application of rockets rather than long ranged.<br><br>\
	It was designed after a possible announcement for the replacement to the heavy and aging T-151 SADAR (Non-TGMC name PF-1.), \
	after the actual announcement of the trial participants to show their designs to the Corps where eventually the SU-185 won out \
	the trials after a close last part on the trials with its competitors in the final round, winning out due to showing lower weight and better short-range accuracy than its peers. <br><br>\
	After field-testing good reports from troops eventually, leading to its full adoption with the naming of \"T-152\". <br><br>\
	It's a rather rare sight due to the current doctrine adopted by the TGMC not using heavy explosives often, so it's a rather \
	rare sight outside of specialized users. and the rising prevalence of shipside combat making it dangerous to fire inside those \
	spaces makes it even used less. Not that it makes it any less dangerous on an open field."

/datum/codex_entry/smartgun
	associated_paths = list(/obj/item/weapon/gun/smartgun)
	lore_text = "The T-90A's design is the one used by most forces under the world who use the M56 4-kit smartgun system, \
	it has several different other names depending on the user but the one used by the TGMC is defined as T-90A. <br><br>\
	The M56 4-piece system was adopted when the technology eventually developed a practical point as older systems required \
	a much heavier powerpack or assistant to carry ammunition due to the lack of an autoloading system. After these problems \
	were solved with the powerpacks autoloading system and eventual size reductions to allow for more practical use of the gun \
	inside combat, the M56 system was offered to the TGMC and was eventually met with adoption after combat tests showed good results."

/datum/codex_entry/standard_shotgun
	associated_paths = list(/obj/item/weapon/gun/shotgun/pump/t35)
	lore_text = "The K23 itself was designed at first for military use as 12 gauge pump-action shotguns were starting to pick up steam \
	again due to advancements in ammunition made them much more effective at breaking doors and simple masterkey shotguns were starting \
	to fall out of favor due to the preference of grenade launchers or other grips started to phase them out. <br><br>\
	Eventually trials were made for a new shotgun and the K23 eventually won them out and was adopted as the T-35. It was \
	officially adopted as a door breaching tool but was incredibly effective at close quarters and shipside combat because \
	advancements in  ammunition allowed shotguns to punch through common ballistic armor, making it a popular option for close quarters situations."

/datum/codex_entry/standard_revolver
	associated_paths = list(/obj/item/weapon/gun/revolver/standard_revolver)
	lore_text = "The original RN-44 used to be the only standard issue sidearm of the TGMC. Though it was once going to \
	be fully replaced by the T-27 once that was adopted, it was eventually decided to be kept due to complaints from \
	troops of the power and accuracy of the new 9mm pistol to the old .44 so it was decided to keep both handguns and \
	allow a choice between both. Then soon after a modernization came to the old RN-44 design. Eventually being updated to the TP-44.<br><br>\
	The original RN-44 design that was adopted quite some time ago by the Marine Corps as part of a new program asking for \
	a new sidearm that could be reliable on long voyages without much maintenance and the RN-44 eventually won out it's peers \
	due to its good accuracy and ability to stay in good condition for long periods of time. Eventually ending up as the original TP-44."

/datum/codex_entry/standard_pistol
	associated_paths = list(/obj/item/weapon/gun/pistol/standard_pistol)
	lore_text = "The RL-9's design was created to require as little maintenance for a Pistol in a long period of time in-order \
	to compete during the new trials to be put up by the Marine Corps once they decided the TP-44 Revolver was too cumbersome for normal use. <br><br>\
	Eventually the RL-9 won the trials due to showing good use after passing the 300 round test in the final rounds of the trial with only a \
	single misfire during the entire 1000 round firing.<br><br>\
	After the trials the gun was slated to fully replace the TP-44 as the TP-19 Pistol.<br><br>\
	But certain troops complained that the T-27 couldn't be as accurate out to further ranges and the power of the .44 round was more worthwhile \
	to them than the 9mm round. Eventually it was decided that the TP019 would be adopted as the second sidearm of the TGMC instead of fully \
	replacing the TP-44 which would later eventually be modernized."

/datum/codex_entry/standard_assaultrifle
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_assaultrifle)
	lore_text = "The RM-51 used to be the Marine Corps standard issue Rifle. It was known for it's rather heavy and large \
	size but good accuracy at range. But it was eventually replaced by the T-18 because of it's relatively poor performance at close range situations.<br><br>\
	The RM-51 (Corps designation T-12) is still widely used by the Corps because of the sheer amount in surplus and because it's still a rather reliable weapon in the field.<br><br>\
	The original RM-51 was designed once news of a trial for the adoption of a caseless assault rifle to replace the current aging \
	rifle were made public to all gun manufacturers, and eventually the RM-51s design won out its competitors due to its ability to stay reliable in harsh conditions."

/datum/codex_entry/standard_carbine
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_carbine)
	lore_text = "The reason for the adoption of the ALF-4 carbine surfaced after repeated complaints of the unwieldiness of the T-12 \
	Rifle surfaced inside tight spaces, this then prompted the higher command of the TGMC to decide to adopt a new rifle within new barrel \
	length designations due to the rising prevalence of fighting in close quarters situations inside spaceships and some colonies.<br><br>\
	Eventually a selection process was made and the ALF-4 eventually won the trials and field testing soon ensured. Which eventually lead \
	to great feedback from the troops supplied with it. This soon lead to it replacing the T-12 Rifle as the standard issue firearm. \
	With the designation T-18. Though the T-12 itself is still used widely due to availability."

/datum/codex_entry/standard_lmg
	associated_paths = list(/obj/item/weapon/gun/rifle/standard_lmg)
	lore_text = "The ALF-8 LMG is pretty much an upsized version of the ALF-4 Carbine, the ALF-8 was created to put down heavy suppressive \
	fire in a light and compact package. It was created when the ALF-8 package was seen to be unable to perform suppressive fire roles very \
	effectively due to it’s small stature and lighter than usual barrel. So eventually the ALF-8 was created to do that role when the T-12 \
	Rifle (non-marine designation RM-51) also began to suffer under prolonged combat due to overheating and low ammo count.<br><br>\
	The ALF-8 itself is based off the ALF-4’s design. The only major differences are a heavier and longer barrel created to have a \
	large amount of rounds go threw it in short periods of time and different mag wells to accept bigger magazines than it’s little brother. \
	It was eventually adopted and designated the T-42.<br><br>\
	However these days it's been mostly replaced by the M56 smartgun system due to the M56s ability to use IFF and also self-load due to it’s \
	autoloading systems. Removing the need of an assistant to carry the bulky ammo.<br><br>\
	However, the T-42 is still used since it's much easier to use than the special training required for the smartgun system. These days it's \
	usually used when IFF isn't needed such as high visibility environments and defensive positions."

/datum/codex_entry/standard_smg
	associated_paths = list(/obj/item/weapon/gun/smg/standard_smg)
	lore_text = "The MD-65 is a rather compact gun, designed for use by specialized troops who don't have the space to carry a bigger \
	firearm and don't want to be stuck with a handgun. <br><br>\
	It's generally used inside it's belt holster or slung on your back as a secondary firearm for use in situations where you have a \
	larger gun and would prefer a more CQC able weapon. It also has a rather large magazine capacity due to the small caliber size and caseless ammunition. <br><br>\
	The MD-65 was adopted as a program to allow specialized units like medics and engineers to carry a smaller firearm to maximize \
	weight and storage capacity. However it slowly spread in popularity to light infantry and scout units. It was named T-19 upon adoption."
