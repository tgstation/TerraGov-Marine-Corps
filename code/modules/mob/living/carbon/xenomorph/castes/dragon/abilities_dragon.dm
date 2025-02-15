/* Backhand, aka hurtful Oppressor's Tail Lash:
	IF NO GRAB:
		Just port the current unarmed attack and make it it's own ability.
	IF GRAB:
		Big chat message in place of telegraph.area
		After 3s, deal 150 brute damage (vs. melee defense) across 5 limbs.
		Restore 250 plasma after successful cast.
		End grab.
*/

/* Fly, aka odd Hivemind's Manifest:
	TBD
*/

/* Tailswipe, aka expanded Oppressor's Tail Lash:
	- Telegraphed
	- Bigger AoE (assuming 5x3)
	- Apparently casted from "behind"; just rotate 180 degrees after cast.
	- To marines:
		- 55 brute damage (vs. melee defense)
		- Knockdown (2s)
	- To vehicles (multitile):
		- Prevent movement for 1.5s
		- Knockdown everyone inside for 1.5s
	- Restore 75 plasma after successful cast.
*/

/* Dragon Breath, aka highly modified Acid Spit:
	IF NO GRAB:
		- Takes 3s to even start (basically telegraphed).
		- Primo doesn't modify damage.
		- do_after after start of 10s. Will keep track of how long the ability went on.
		- Slowdown during the entire do_after.
		- Press 'resist' to end shooting? Not really intitive.
		- Fires at 0.2s, 15 spread.
		- Proj on contact does 2 xeno fire stack + 40 burn damage (vs. fire defense). Leaves xeno fire on turf.
		- Timer (after start) that happens every 1s that gives 30 plasma; removed on end.
	IF GRAB:
		Big chat message in place of telegraph.
		After 3s, deal 200 burn damage (vs. fire defense) across 6 limbs (aka all).
		Knockback 5 tiles
		Restore 250 plasma after successful cast.
		End grab.
*/

/* Windcurrent, aka utility Oppressor's Tail Lash:
	- Telegraphed.
	- Deletes gas in front in 5x5.
	- To marines:
		- Knockback (4 tiles)
		- 50 burn damage (vs. fire defense)
	- Restore 200 plasma after successful cast.
*/

/* Grab, aka Gorger's Grab on Crack:
	- Telegraphed.
	- 1x3 line in front.
	- Picks the first marine in list and passively grabs them.
	- Slows down dragon (automatic, comes with the passive grab).
	- If grabbing & take 300 damage (post-armor), end ability.
	- To marines:
		- Can't move on their own (aka TRAIT_IMMOBILE)
		- Can still take out stuff, shoot, powerfist, whatever they do.
	- Restore 250 plasma after successful grab.
*/

/* Psychic Channel:
	TBA
*/
