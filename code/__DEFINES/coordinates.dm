
////Tile coordinates (x, y) to absolute coordinates (in number of pixels). Center of a tile is generally assumed to be (16,16), but can be offset.
#define ABS_COOR(c) (((c - 1) * 32) + 16)
#define ABS_COOR_OFFSET(c, o) (((c - 1) * 32) + o)

//Absolute pixel coordinate to relative. If MODULUS is zero, then we want to return 32, as pixel coordinates range from 1 to 32 within a tile.
#define ABS_PIXEL_TO_REL(apc) (MODULUS(apc, 32) || 32)
