import { range } from "common/collections";
import { resolveAsset } from "../../assets";
import { useBackend } from "../../backend";
import { Box, Button, Icon, Section, Stack } from "../../components";
import { createLogger } from '../../logging';
import { LoadoutManagerData, GridSpotKey, SLOTS, getGridSpotKey } from './Types';

const ROWS = 4;
const COLUMNS = 3;

const BUTTON_DIMENSION_WIDTH = "70px"; 
const BUTTON_DIMENSION_HEIGHT = "70px";


export const SlotSelector = (props, context) => {
  const { act, data } = useBackend<LoadoutManagerData>(context);

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
                          act("selectSlot", {
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
