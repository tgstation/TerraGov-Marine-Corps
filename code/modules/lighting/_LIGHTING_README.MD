# The Lighting Systems
## Introduction

Hello reader, and welcome to the coders guide to lighting. TGMC uses three different lighting systems: Static Lighting, Movable Lighting and Hybrid Lighting
These all have their pros and cons, and are explained later in this file.
For now we will look at the frameworks we have pertaining to lighting.

```dm
//Our vars:
//The "intensity" of our light to determine how much it actually lights up
var/light_power
// The range of our light, aka how many turfs are actually lit up
var/light_range
//the color of our light
var/light_color
///whether the light is actually on or not, use /atom/proc/turn_on() to set this
var/light_on
```

Additionally, we have SSlighting, the lighting subsystem which handles lighting updates for Static and Hybrid lighting.
This subsystems takes enqueued lighting object, corner and source updates, as well as taking enqueued hybrid lighting updates.
You shouldnt really be touching this as it primarily just stops too many updates from happening at once.

## The Lighting systems
As mentioned previously,lighting is split into three seperate systems who's functionality, benefits and downsides will be discussed below

Seperate from these systems we also have a system to update the base lighting of an area, we do this using "Base lighting"

```dm
/area/proc/set_base_lighting(new_base_lighting_color = -1, new_alpha = -1)
```
Use this to set areas as required to luminosity. This is dnt through the application of an overlay to turfs and is cheap to use but not cheap to update.

### Static Lighting
Static lighting consists of a single, static_lighting_source light source which gets all turfs in view, then tells their /datum/static_lighting_objects to update themselves. These lighting objects manage to things: lighting corners, and an underlay. The lighting corners hold data for the diagonally located turfs to allow a smooth transition from dark to light, and the actual lighting is done using an underlay which is layered over the darkness layer in order to create light. Color is changed using a color matrix.
The advantage of this system, is that it is cheap, as long as it does not need to actively update opacity changes or a moving light target.
This system can also be used for as large lights as you want.
The disadvantage however is that updating this type of light, such as when it moves is relatively expensive, and colors are not always the prettiest. Additionally, lighting corners are known to be a large source of RAM usage and thus you should only load lighting objects in areas hat it is needed using /area/var/static_lighting.
Thus this should be your go to choice for large, immobile lights.

To update lights using this system use
```dm
/atom/proc/set_light(l_range, l_power, l_color, mask_type)
```
Note that the use of mask_type only is applicable to Hybrid lights.

### Movable lighting
Movable lighting is extremely simple and cheap as it requires no updates. This is done by replacing a large amount of updating objects with one single, large vis_contents overlay, which we apply and manage through a component (/datum/component/overlay_lighting). This means that it will move smoothly when the owner moves and requires no updating, but also means that rendering issues might occur, where the overlay will seemingly "pop in" to existence as it suddenly renders when someone walks around a corner or into the 1/2-tile render buffer around the edges of the viewport.
Thus this should be your go to ideal cheap light for small and mobile lights (NOT turfs or anchored objects!). This light also has more saturated colors than static lighting.

Note that this lighting type utilises special update procs from the other two lighting types, specifically
```dm
//update light variables
/atom/movable/proc/set_light_range_power_color(range, power, color)
	set_light_range(range)
	set_light_power(power)
	set_light_color(color)

//turn the light on and off without changing any variables
/atom/proc/set_light_on(new_value)
```

### Hybrid lighting
Hybrid lighting is, as the name implies, a hybrid of the two above systems. It still needs to update when the owner moves, or something in view changes like static lighting does, but uses overlays to hide areas using shadows. As a result, this has similar if not better performance to Static lighting, but has a higher drain on player GPU and thus you should ideally avoid lagging players that play on terrible computers too much. This means that you should use this lighting in decently sized lights that mostly stay immobile to avoid visible updates.
Notably the most primary cost of this method is the rendiering function "Group icons and set bounds" which calculates clientside matrix sizes and how they are displayed clientside.
It functions by fetching all nearby blockers, then calculating triangles behind these blocked areas which it then masks with overlays.
Note that overlays have a special handling here and are combined into one overlay as a client-side optimisation of render times.
This system also supports non-round lights, such as light cones, rotating lights, and shimmering lights through the use of
```dm
var/mask_type
```
Actual updates however are handled through the same procs as Static lighting, and the mask_type argument on set_light() allows you to change the mask type that is being used on the fly.
