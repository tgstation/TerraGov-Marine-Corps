import { range } from "common/collections";
import { resolveAsset } from "../../assets";
import { useBackend } from "../../backend";
import { Box, Button, Section, Stack, Flex } from "../../components";
import { LoadoutSlotData, GridSpotKey, SLOTS, getGridSpotKey } from './Types';

const ROWS = 4;
const COLUMNS = 3;

const BUTTON_DIMENSION_WIDTH = "70px";
const BUTTON_DIMENSION_HEIGHT = "70px";


export const SlotSelector = (props: LoadoutSlotData, context) => {
  const { act } = useBackend(context);

  const {
    items,
  } = props;

  const gridSpots = new Map<GridSpotKey, string>();

  for (const key of Object.keys(items)) {
    gridSpots.set(SLOTS[key].gridSpot, key);
  }

  return (
    <Section title="Slot Selector" textAlign="center">
      <Flex>
        <Flex.Item grow={1}><div> </div></Flex.Item>
        <Flex.Item align="center">
          <Stack fill vertical>
            {range(0, ROWS).map(row => (
              <Stack.Item key={row}>
                <Stack fill>
                  {range(0, COLUMNS).map(column => {
                    const key = getGridSpotKey([row, column]);
                    const keyAtSpot = gridSpots.get(key);
                    const item = items[keyAtSpot!];
                    const slot = SLOTS[keyAtSpot!];

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
                              {item.icons.map(iconinfo => (
                                <Box
                                  key={iconinfo.icon}
                                  as="img"
                                  src={`data:image/jpeg;base64,
                                      ${iconinfo.icon}`}
                                  height="100%"
                                  width="100%"
                                  color="transparent"
                                  style={{
                                    "position": "absolute",
                                    "vertical-align": "middle",
                                    transform:
                                      "translateX(" + iconinfo.translateX
                                      + ") translateY(" + iconinfo.translateY
                                      + ") scale(" + iconinfo.scale + ")",
                                  }}
                                />
                              ))}
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
        </Flex.Item>
        <Flex.Item grow={1}><div> </div></Flex.Item>
      </Flex>
    </Section>
  );
};
