import { range } from "common/collections";
import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Icon, Stack } from "../components";
import { Window } from "../layouts";

const ROWS = 5;
const COLUMNS = 6;

const BUTTON_DIMENSIONS = "50px";

type GridSpotKey = string;

const getGridSpotKey = (spot: [number, number]): GridSpotKey => {
  return `${spot[0]}/${spot[1]}`;
};

const SLOTS: Record<
  string,
  {
    displayName: string;
    gridSpot: GridSpotKey;
    image?: string;
  }
> = {
  eyes: {
    displayName: "eyewear",
    gridSpot: getGridSpotKey([0, 1]),
    image: "inventory-glasses.png",
  },

  head: {
    displayName: "headwear",
    gridSpot: getGridSpotKey([0, 2]),
    image: "inventory-head.png",
  },

  mask: {
    displayName: "mask",
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-mask.png",
  },

  jumpsuit: {
    displayName: "uniform",
    gridSpot: getGridSpotKey([2, 1]),
    image: "inventory-uniform.png",
  },

  armor: {
    displayName: "armor",
    gridSpot: getGridSpotKey([2, 2]),
    image: "inventory-suit.png",
  },

  gloves: {
    displayName: "gloves",
    gridSpot: getGridSpotKey([2, 3]),
    image: "inventory-gloves.png",
  },

  shoes: {
    displayName: "shoes",
    gridSpot: getGridSpotKey([3, 2]),
    image: "inventory-shoes.png",
  },

  suit_storage: {
    displayName: "suit storage item",
    gridSpot: getGridSpotKey([4, 0]),
    image: "inventory-suit_storage.png",
  },

  belt: {
    displayName: "belt",
    gridSpot: getGridSpotKey([4, 2]),
    image: "inventory-belt.png",
  },

  back: {
    displayName: "backpack",
    gridSpot: getGridSpotKey([4, 3]),
    image: "inventory-back.png",
  },

  left_pocket: {
    displayName: "left pocket",
    gridSpot: getGridSpotKey([4, 4]),
    image: "inventory-pocket.png",
  },

  right_pocket: {
    displayName: "right pocket",
    gridSpot: getGridSpotKey([4, 5]),
    image: "inventory-pocket.png",
  },
};

type SlotItem =
  {
    icon: string;
    name: string;
  }

type SlotData = {
  items: Record<keyof typeof SLOTS, SlotItem>;
  name: string;
};

export const LoadoutSelector = (props : any, context : any) => {
  const { act, data } = useBackend<SlotData>(context);

  const gridSpots = new Map<GridSpotKey, string>();

  return (
    <Window 
      title="Slot selector"
      width={400} 
      height={400}>
      <Window.Content>
        <Stack fill vertical>
          {range(0, ROWS).map(row => (
            <Stack.Item key={row}>
              <Stack fill>
                {range(0, COLUMNS).map(column => {
                  const key = getGridSpotKey([row, column]);
                  const keyAtSpot = gridSpots.get(key);
                  if (!keyAtSpot) {
                    return (
                      <Stack.Item
                        key={key}
                        style={{
                          width: BUTTON_DIMENSIONS,
                          height: BUTTON_DIMENSIONS,
                        }}
                      />
                    );
                  }

                  const item = data.items[keyAtSpot];
                  const slot = SLOTS[keyAtSpot];

                  let content;
                  let tooltip;

                  if (item === null) {
                    tooltip = slot.displayName;
                  } else if ("name" in item) {

                    content = (
                      <Box
                        as="img"
                        src={`data:image/jpeg;base64,${item.icon}`}
                        height="100%"
                        width="100%"
                        style={{
                          "-ms-interpolation-mode": "nearest-neighbor",
                          "vertical-align": "middle",
                        }}
                      />
                    );

                    tooltip = item.name;
                  }

                  return (
                    <Stack.Item
                      key={key}
                      style={{
                        width: BUTTON_DIMENSIONS,
                        height: BUTTON_DIMENSIONS,
                      }}
                    >
                      <Box
                        style={{
                          position: "relative",
                          width: "100%",
                          height: "100%",
                        }}
                      >
                        <Button
                          onClick={() => {
                            act("chose", {
                              key: keyAtSpot,
                            });
                          }}
                          tooltip={tooltip}
                        >
                          {slot.image && (
                            <Box
                              as="img"
                              src={resolveAsset(slot.image)}
                              opacity={0.7}
                              style={{
                                position: "absolute",
                                width: "32px",
                                height: "32px",
                                left: "50%",
                                top: "50%",
                                transform:
                                  "translateX(-50%) translateY(-50%) scale(0.8)",
                              }}
                            />
                          )}
                          <Box style={{ position: "relative" }}>
                            {content}
                          </Box>
                        </Button>
                      </Box>
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};