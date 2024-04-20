#define MEAT (1<<0)
#define VEGETABLES (1<<1)
#define RAW (1<<2)
#define JUNKFOOD (1<<3)
#define GRAIN (1<<4)
#define FRUIT (1<<5)
#define DAIRY (1<<6)
#define FRIED (1<<7)
#define ALCOHOL (1<<8)
#define SUGAR (1<<9)
#define GROSS (1<<10)
#define TOXIC (1<<11)
#define PINEAPPLE (1<<12)
#define BREAKFAST (1<<13)
#define CLOTH (1<<14)
#define NUTS (1<<15)
#define SEAFOOD (1<<16)
#define ORANGES (1<<17)
#define BUGS (1<<18)
#define GORE (1<<19)
#define STONE (1<<20)

/// A list of food type names, in order of their flags
#define FOOD_FLAGS list( \
	"MEAT", \
	"VEGETABLES", \
	"RAW", \
	"JUNKFOOD", \
	"GRAIN", \
	"FRUIT", \
	"DAIRY", \
	"FRIED", \
	"ALCOHOL", \
	"SUGAR", \
	"GROSS", \
	"TOXIC", \
	"PINEAPPLE", \
	"BREAKFAST", \
	"CLOTH", \
	"NUTS", \
	"SEAFOOD", \
	"ORANGES", \
	"BUGS", \
	"GORE", \
	"STONE", \
)

/// IC meaning (more or less) for food flags
#define FOOD_FLAGS_IC list( \
	"Meat", \
	"Vegetables", \
	"Raw food", \
	"Junk food", \
	"Grain", \
	"Fruits", \
	"Dairy products", \
	"Fried food", \
	"Alcohol", \
	"Sugary food", \
	"Gross food", \
	"Toxic food", \
	"Pineapples", \
	"Breakfast food", \
	"Clothing", \
	"Nuts", \
	"Seafood", \
	"Oranges", \
	"Bugs", \
	"Gore", \
	"Rocks", \
)
