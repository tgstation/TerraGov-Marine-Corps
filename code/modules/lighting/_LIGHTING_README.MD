# The Lighting Systems
## Introduction

Hello reader, and welcome to the coders guide to lighting. TGMC uses three different lighting systems: Static Lighting, Movable Lighting and Hybrid Lighting
These all have their pros and cons, and are explained later in this file.
For now we will look at the frameworks we have pertaining to lighting.

```dm
vars
```
Additionally, we have SSlighting, the lighting subsystem which handles lighting updates for Static and Hybrid lighting.
//stuff about that goes here

## The Lighting systems
As mentioned previously,lighting is split into three seperate systems who's functionality, benefits and downsides will be discussed below

### Static Lighting
Static lighting is simple, in that it utilises lighting_objects found on every turf

### Movable lighting
Movable lighting is extremely simple and cheap as it requires no updates. This is done by replacing a large amount of updating objects with one single, large overlay, which we apply and manage through a component (link here). This means that it will move smoothly when the owner moves, but also means that rendering issues might occur, where the overlay will seemingly "pop in" to existence as it suddenly renders when someone walks around a corner or into the 2-tile render buffer around the edges of the viewport.

### Hybrid lighting
Hybrid lighting is, as the name implies, a hybrid of the two above systems. It still needs to update when the owner moves, or something in view changes like static lighting does, but uses overlays to hide areas using shadows. As a result, this has similar performance to Static lighting, but has a higher drain on player GPU and thus you should ideally avoid lagging players too much.
