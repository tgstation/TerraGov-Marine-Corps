
## About

The point of this document is to outline the server's current and future intended design.

The current design section should be updated by contributors of pull requests which significantly affect balance or add new features. This will serve as a useful overview for new players and code contributors to understand the existing differences between the factions and a high-level overview of gameplay.

The future design section should be mainly updated by maintainers as a central location for their vision for the server. This gives direction for code contributors to build their PRs on and gives players insight into what to look forward to.

The main USP of TGMC is: “asymmetrical team deathmatch PvP gameplay with a high degree of QoL”.

# Current Design

## Visual

- Xenomorphs - arachnid/dinosaur mix.
- TG Marines - highly flamboyant armour design and accessorising similar to Destiny, or dressed in modern military attire if preferred. Ballistic, incendiary and explosive weaponry with a modern design, as well as futuristic laser weaponry.
- Sons of Mars - orange mirrored helmets, dark orange accent colour on black armoured suits. High-tech volkite weaponry.

## Gameplay

The two main factions Xenomorphs and TG Marines have assymetrical combat. This means whilst there may be a few distinct exceptions in their gameplay, they each have unique strengths, weaknesses and other differences.

### Xenomorphs

Xenos have 4 tiers of playable castes. Tier 1-3 have decreasing amounts of availability to players as they move up the tiers. The tiers more or less increase the combat prowess of the player with increasing tiers. They also serve to funnel some players into the weaker roles that they typically wouldn't play by having a player cap based off of total players on the team. Tier 4 allows only one playable per caste and typically comes with minimum player requirements.

Xenos gain maturity over time, progressing from Young to Mature to Elder to Ancient to Primordial. At each stage their stats improve, and for some castes their abilities improve as well e.g. Widows have a greater max amount of spiderlings.

The 4 main tiers are supplemented by a minion tier that consists of AI xenomorphs. This tier serves as cannon fodder to provide a low enough challenge to new and low skill marine players to learn the basics.

Xenos can persistently identify themselves through a simple phrase or word, e.g. `Mature Runner (Cucumber)`, as well as through selection of a female TTS voice.

### TG Marines

Marines have a variety of different roles, broadly categorised as infantry, engineers, medical staff, command and pilots. The vast majority of infantry are Marines, who are aided by Squad Leaders who are able to use useful AOE buffs.

## Faction Comparison

### Damage Types

| Aspect | Marines | Xenos |
| --- | --- | --- |
| Melee Damage | **Medium** (powerfist, vali, rocket sledge point-blank guns) | **Very Strong** (decent melee damage minimum for all castes, high amounts for specialists) |
| Short-Range Damage (on-screen) | **Very Strong** (most guns) | **Medium** (acid spit, Behemoth rocks, Warlock) |
| Long-Range Damage (off-screen) | **Very Strong** (snipers, TAT, mortar, CAS, OB) | **Weak** (just Boiler)
| Area of Effect Damage | **Very Strong** (CAS, OB, mortar, tank) | **Medium** (mainly T3s: Warlock, Defiler, Boiler, Praetorian, Behemoth, King)

### Combat Tactics

| Aspect | Marines | Xenos |
| --- | --- | --- |
| Flanking | **Weak** (slow movespeed) | **Very Strong** (x-ray and dark vision, high mobility) |
| Point Defence | **Very Strong** (cades, turrets, machine guns, SG, aim mode ungaballs, tank, mech) | **Medium** (quickly building walls, acid spray, crowd control abilities)
| Sieging | **Very Strong** (grenades, mortars, CAS, OB, flamethrowers, plasmacutters, machineguns) | **Medium** (acid spit, Boiler, Warlock, Crusher)
| Area Denial | **Very Strong** (grenades, turrets, tank, CAS, OB) | **Medium** (turrets, acid spray, gas, Warlock, Behemoth)
| Combat Initiation | **Medium** (grenades, rockets, tangle OB, squad leader orders) | **Very Strong** (multiple quick abilities that can be used for crowd control or cover to begin combat on favourable terms e.g. Queen's Screech, Defiler's Neurogas, etc)
| Backlining | **Weak** (low Mobility means difficult to retreat or get reinforcements) | **Very Strong** (several castes can reliabily win 1v1s, destroy structures, retreat if necessary, etc)
| Terrain Advantage | **Open Air** | **Caves** (this prevents Orbital Strikes, Close Air Support, Drop-pods, Tadpole and radio communication) | 
| Chokepoints | **Very Strong** (can focus heavy suppressive fire in one direction) | **Weak** (Warlock can reflect projectiles, but otherwise not much) |
| Open Areas | **Very Strong** (allows for many marines to do suppressive machine gun or sniper fire) | **Weak** (usually takes too damage whilst trying to engage, better off Flanking then slowly encroaching with weeds and walls) |
| Mazes (Twisting Paths) | **Weak** (blocks sightlines for most weaponry) | **Very Strong** (allows xenos to utilise their high mobility to gapclose and initiate combat, and quickly retreat out of combat)

### Misc

| Aspect | Marines | Xenos |
| --- | --- | --- |
| Mobility | **Weak** (slow movespeed, but there is Tadpole, Drop-pods and Move Orders which help) | **Very Strong** (fast movespeed especially on weeds, King Summon) | 
| Healing | **Medium** (can be done solo, but isn't infinite) | **Very Strong** (fast, plus weeds and pheros are usually prevalent) |
| Revival | **Possible** | **Impossible** |
| Respawning | **Slow** | **Fast** |
| Short-Term Resource Management | **Low** (quick reloads, on ammo, meds) | **High** (plasma pools are small and recharge slowly, requiring frequent periods of rest. Also healing needed more often due to ranged combat disparity) |
| Long-Term Resource Management | **High** (dependent on ammo, meds and materials resupplies) | **Medium** (Strategic and Tactical psypoints, weeds, pheromones) |
| Adaptability | **Very Strong** (can use any gun, and not having a skill merely slows you down) | **Strong** (caste swap possible but has a timer, you also lose your current evolution progress) |
| Population | **High** (no cap on marine population) | **Low** (cap on xeno population, and it's a fraction of marine pop) |
| Skill Floor |  **Low** (beginner loadouts, most marine guns work similarly) | **Medium** (T1s each have a few abilities to learn, knowing when to retreat and heal, several pieces of marine equipment to be know of)
| Skill Ceiling | **Very High** (accuracy, knowing the meta gear, when to change tactics, etc ) | **Very High** (accuracy, lots of ability combos, when to change tactics, etc) | 
| Teamwork Dependence | **Medium** (a few medics, engineers and a pilot are needed only) | **High** (at least half the team are required to be competent due to lower pop, and also requires certain roles filled: Queen, builders, frontliners and gas are basically essential)
| Kill Benefits | **Very High** (corpses become req points which can purchase game-changing equipment, also because of xeno's teamwork dependence you can easily disrupt their effectiveness by killing essential castes) | **Medium** (psypoints gained from marine corpses, but the purchases aren't as game-changing and stuff like Primordials can take a long while to come into effect)
| Game Mode: Nuclear War | **Advantaged** (marines losing control of their most important map area the FOB is not too impactful as the Alamo can be kept shipside to prevent a xeno Minor Victory) | **Disadvantaged** (xenos are massively impacted by loss of their resin silo to the point that marines can win games by ignoring nuke disks and just killing the silo. Their Point Defence is also weak which makes defending the silo and disk rooms difficult)

### Similarities

- Both have mechanics intended to reduce their individual effectiveness if they take heavy damage during sustained combat (sunder for xenos, fractures for marines).
- Both have snowball mechanics (they get stronger over the course of the round if they're winning). Psy points for xenos, req points for marines. Both also have structures. 
- Neither have catch-up mechanics (getting stronger if losing).

### Round flow

Both Xenos and marines should start on equal footing and have similar area control at the beginning of the round and additionally have lightly “biased” areas (Areas where there is an advantage for the defending side eg corridors for marines and caves for xenos) around the objective for both factions. This serves to preserve a challenge throughout the round while allowing both sides immediate strategic flexibility.

The round is divided into 2 phases: prep phase and combat phase. The swap of these is signified by the opening of shutters.

#### Xenomorphs

**Prep Phase**

Drone tree castes focus on construction, in particular mazing around disks (if the gamemode is Nuclear War), chokepoints, near Landing Zones and at their resin silo. Non-Drone tree castes focus on destroying obstacles that are beneficial to marines (e.g. windows) and ones which can hamper movement or mazing (e.g. window frames, boxes etc). Castes with the Corrosive Acid ability also melt walls to allow better hit-and-run attacks from multiple angles, and to prevent being cornered into a dead end.

**Combat Phase**

Everyone with the ability to emit pheromones does so, and the Queen selects leaders to emit their pheromones too. Most Drone tree castes keep the battlefield weeded and build wall cover as their first priorities, as well as keeping the team healed and plasma

#### TG Marines

**Prep Phase**

Marines obtain all the equipment they're going to keep on their body, whatever else they're going to bring with them, and anything else that they want to bring on the Alamo or Tadpole.

**Combat Phase**

TBA

### Respawning and progression

#### Xenomorphs

Respawning is handled by having a set amount of larva for marines (see crash). Upon death the larva will be temporarily disabled for 10 minutes. Prospective xeno players can play as a minion while waiting.

A currently pending respawn timer can be reduced by 1 minute by psy-draining a dead human, which also gives some psy points and gives them clone damage. Alternatively you may cocoon them for a much larger psy point generation over time that however extends their revival timer.

Xenos will progress through tiers by passively gaining evolution points. This will happen slowly over time (slower than now). Note: no maturity.

Xenos are able to switch between castes on a long cooldown (15 minutes). This is intended to prevent players from being locked into very situational castes without wanting to do so, for example playing ravager during a siege.

#### TG Marines

TBA

### Construction

#### Xenomorphs

Construction is the main form of progression for xenos. All purchasable improvements that provide benefit to the entire hive should have a physical representation. This aims to provide something to fight around/towards. See old school RTSes like C&C. (Long term consideration, add distance-based buffs for building closer to enemies)

Building will cost either tactical or strategic psy points. Strategic psy points are usable by all T4 xenos, and tactical by all xenos that can build. Strategic psy points include major impact purchases such as silos, primordial, etc, while tactical is lower impact such as turrets, special walls, etc.
Possible upgrades can include things like faster maturity, more slots, turrets, etc.

Builder roles can also build defensive structures such as walls and doors in order to provide a defensive line.

#### TG Marines

TBA

### Combat

#### Xenomorphs

Xenomorphs main attacking method is through melee, with the specialized exception of the sentinel line of castes, which trades tankiness for ranged ability.

Xenos should be able to both attack and defend from their current position at any given point in the round. Xenos primary engagement is skirmish-style where they will engage for a short period before retreating to recover plasma and health.

Sundering is a mechanic to ensure that xenos do not pressure marines 24/7 without consequences. To heal sunder, xenos can be healed by other xenos, or even faster, go to a structure that heals sunder.

**Abilities**

Xenomorph abilities are primarily very selfish, and aim to give the user more creative ways to synergise with the rest of their kit and provide situational benefits in combat. An exception are teamwork oriented castes such as drone. The use of these abilities is limited by plasma. Plasma should typically be enough for a brief engagement before they are forced to retreat again, and serves to stop the xeno from constantly attacking over and over with no reprieve.

Abilities are tied to progression using “Primordial” - these are abilities where after staying alive for a certain time unlocks a capstone ability.

Abilities should aim to be (in order):
1) Fun to use
2) Have a form of counterplay i.e. marines cannot be vulnerable at all times with no method of preventing it
3) Not aim to reduce marine player agency through e.g. stuns longer than short periods.
4) Synergise with either:
	- Other xenos (regardless of caste)
	- The rest of the users toolkit (see #1)
5) Be visually and auditorily appealing (see #1)

#### TG Marines

TBA

### Skill Level

#### Xenomorphs

Generally due to how players work they will progress through the tiers naturally as their skill increases e.g. a new player will die a lot as a Runner before surviving long enough to play a little as Hunter.
#### TG Marines

As there are a lot more players in this faction (around ~3x the amount of player xenos) and a vast majority of them being the Marine role the skill floor is very low. The numerous skilled players can carry less skilled players to average out the team capability. The skill ceiling remains high however.

## Future Design

### Gameplay

#### Xenomorphs

**Rework 1 ideas:**

- Allow low skill xenos as well?). There should always be an acceptable minimum of these AIs that scales with pop (ratio TBD)
- on TTS should hivemind play as well? and if yes can it be made so admins crack down on the ooc in ic
- Garrison (Tivi, pending map)
- Maturity removal, primo stay on maturity system
- Upping Minion spawn rate
- Xeno TTS (Tivi)
- Splitting psy points into tactical/strategic
- Make minions playable while in queue
- Adding a dedicated "become minion" button to make it easier for new players to become one
- Crash style respawn system (change psy drain and silos too)
- Sunder healing nerf, add sundering heal building (tac points)
- Skill levels should also also be reflected in the design of the castes, needing a high amount of skill (both floor and ceiling ideally) to play well as the tier increases.
- Low skill xenos playing as minions?
- There should always be an acceptable minimum of these AI minions that scales with pop (ratio TBD).

### Round flow

#### Xenomorphs

- During the combat phase all roles should directly or indirectly be able to fight in this phase.
- During the prep phase there needs to be some form of entertainment (Survs are excluded as a bad idea). Temp fix: xenos may swap castes on a long timer.

### Respawning and progression

#### Xenomorphs

- Respawning is handled by having a set amount of larva for marines (see crash). Upon death the larva will be temporarily disabled for 10 minutes. Prospective xeno players can play as a minion while waiting.
- A currently pending respawn timer can be reduced by 1 minute by psy-draining a dead human, which also gives some psy points and gives them clone damage. Alternatively you may cocoon them for a much larger psy point generation over time that however extends their revival timer.
- Xenos will progress through tiers by passively gaining evolution points. This will happen slowly over time (slower than now). Note: no maturity.
- Xenos are able to switch between castes on a long cooldown (15 minutes). This is intended to prevent players from being locked into very situational castes without wanting to do so, for example playing ravager during a siege.

### Construction

#### Xenomorphs

- Do we need more types of defensive structures? e.g. very expensive but durable wall
- what to do with miner/gen corruption, likely want miners to be capable for both. Discuss with grayson
