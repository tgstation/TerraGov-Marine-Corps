import { range } from "common/collections";
import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Icon, Section, Stack } from "../components";
import { Window } from "../layouts";
import { createLogger } from '../logging';

const ROWS = 4;
const COLUMNS = 3;

const BUTTON_DIMENSION_WIDTH = "70px";
const BUTTON_DIMENSION_HEIGHT = "70px";

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
  slot_glasses: {
    displayName: "eyewear",
    gridSpot: getGridSpotKey([0, 0]),
    image: "inventory-glasses.png",
  },

  slot_head: {
    displayName: "headwear",
    gridSpot: getGridSpotKey([0, 1]),
    image: "inventory-head.png",
  },

  slot_wear_mask: {
    displayName: "mask",
    gridSpot: getGridSpotKey([0, 2]),
    image: "inventory-mask.png",
  },

  slot_w_uniform: {
    displayName: "uniform",
    gridSpot: getGridSpotKey([1, 0]),
    image: "inventory-uniform.png",
  },

  slot_suit: {
    displayName: "armor",
    gridSpot: getGridSpotKey([1, 1]),
    image: "inventory-suit.png",
  },

  slot_gloves: {
    displayName: "gloves",
    gridSpot: getGridSpotKey([1, 2]),
    image: "inventory-gloves.png",
  },

  slot_belt: {
    displayName: "belt",
    gridSpot: getGridSpotKey([2, 0]),
    image: "inventory-belt.png",
  },

  slot_shoes: {
    displayName: "shoes",
    gridSpot: getGridSpotKey([2, 1]),
    image: "inventory-shoes.png",
  },

  slot_s_store: {
    displayName: "armor storage item",
    gridSpot: getGridSpotKey([2, 2]),
    image: "inventory-suit_storage.png",
  },

  slot_back: {
    displayName: "back",
    gridSpot: getGridSpotKey([3, 0]),
    image: "inventory-back.png",
  },

  slot_l_store: {
    displayName: "left pocket",
    gridSpot: getGridSpotKey([3, 1]),
    image: "inventory-pocket.png",
  },

  slot_r_store: {
    displayName: "right pocket",
    gridSpot: getGridSpotKey([3, 2]),
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
};

const SlotSelector = (props, context) => {
  const { act, data } = useBackend<SlotData>(context);

  const {
    items,
  } = data;
  
  const logger = createLogger('LoadoutSelector');

  const gridSpots = new Map<GridSpotKey, string>();
  
  for (const key of Object.keys(items)) {
    logger.log('key', key);
    gridSpots.set(SLOTS[key].gridSpot, key);
  }
  return (
    <Section title="Slot Selector">
      <Stack fill vertical>
        {range(0, ROWS).map(row => (
          <Stack.Item key={row}>
            <Stack fill>
              {range(0, COLUMNS).map(column => {
                const key = getGridSpotKey([row, column]);
                const keyAtSpot = gridSpots.get(key);

                const item = data.items[keyAtSpot];
                const slot = SLOTS[keyAtSpot];

                let tooltip;

                if ("name" in item) {
                  tooltip = item.name;
                }
                else {
                  tooltip = slot.displayName;
                }

                return (
                  <Stack.Item
                    key={key}
                    style={{
                      width: BUTTON_DIMENSION_WIDTH,
                      height: BUTTON_DIMENSION_HEIGHT,
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
                              width: "65px",
                              height: "65px",
                              left: "50%",
                              top: "50%",
                              transform:
                                "translateX(-50%) translateY(-50%) scale(0.8)",
                            }}
                          />
                        )}
                        <Box style={{ 
                          position: "relative",
                          width: "60px",
                          height: "60px",
                        }}>
                          <Box
                            as="img"
                            src={`data:image/jpeg;base64,${item.icon}`}
                            height="100%"
                            width="100%"
                            style={{
                              "-ms-interpolation-mode": "nearest-neighbor",
                              "vertical-align": "middle",
                              position: "relative",
                            }}
                          />
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
    </Section>
  );
};

export const LoadoutSelector = (props, context) => {
  const { act, data } = useBackend<SlotData>(context);

  return (
    <Window 
      title="Slot selector"
      width={300} 
      height={300}>
      <Window.Content>
        <SlotSelector />
      </Window.Content>
    </Window>
  );
};