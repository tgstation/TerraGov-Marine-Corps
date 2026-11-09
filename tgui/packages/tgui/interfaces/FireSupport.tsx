import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type MunitionData = {
  munition_type: string;
  munition_name: string;
  munition_uses: number;
  munition_cost: number;
  munition_desc: string;
  munition_icon: string;
};

type FireSupportData = {
  points: number;
  munition_list: MunitionData[];
};

export const FireSupport = (props) => {
  const { act, data } = useBackend<FireSupportData>();
  const munitionList = data.munition_list ?? [];

  const [selectedMunitionType, setSelectedMunitionType] = useLocalState<
    string | null
  >('selectedMunitionType', munitionList[0]?.munition_type ?? null);

  const currentMunition =
    munitionList.find(
      (munition) => munition.munition_type === selectedMunitionType,
    ) ??
    munitionList[0] ??
    null;

  return (
    <Window title="Fire Support Requisition" width={760} height={540}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Dropship Points">
              <Stack align="center" justify="space-between">
                <Stack.Item fontSize="150%">
                  {data.points ?? 0} points available
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Section title="Available Support" width="270px">
                  <Stack vertical>
                    {munitionList.length > 0 ? (
                      munitionList.map((munition) => (
                        <Stack.Item key={munition.munition_name}>
                          <Button
                            fluid
                            align="left"
                            color={
                              currentMunition?.munition_type ===
                              munition.munition_type
                                ? 'green'
                                : 'transparent'
                            }
                            onClick={() =>
                              setSelectedMunitionType(munition.munition_type)
                            }
                          >
                            <Stack align="center" justify="space-between">
                              <Stack.Item grow>
                                <Stack align="center">
                                  <Stack.Item
                                    mr={1.5}
                                    className={classes([
                                      'munition_types32x32',
                                      munition.munition_icon,
                                    ])}
                                  />
                                  {munition.munition_name}
                                </Stack>
                              </Stack.Item>
                              <Stack.Item
                                color={
                                  currentMunition?.munition_type ===
                                  munition.munition_type
                                    ? 'white'
                                    : 'grey'
                                }
                              >
                                {munition.munition_cost}pt
                              </Stack.Item>
                            </Stack>
                          </Button>
                        </Stack.Item>
                      ))
                    ) : (
                      <Stack.Item>No munition packages available.</Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                {currentMunition ? (
                  <Section
                    title={
                      <Stack align="center">
                        <Stack.Item
                          mr={1.5}
                          className={classes([
                            'munition_types64x64',
                            currentMunition.munition_icon + '_big',
                          ])}
                        />
                        <Stack.Item fontSize="150%" grow={1}>
                          {currentMunition.munition_name}
                        </Stack.Item>
                        <Stack.Item fontSize="150%" grow={1}>
                          {
                      <Button
                        icon="check"
                        color="green"
                        disabled={
                          (data.points ?? 0) < currentMunition.munition_cost
                        }
                        onClick={() => {
                          act('purchase', {
                            munition_type: currentMunition.munition_type,
                            munition_cost: currentMunition.munition_cost,
                          });
                        }}
                      >
                        Purchase
                      </Button>
                    }
                        </Stack.Item>
                      </Stack>
                    }
                  >
                    <LabeledList>
                      <LabeledList.Item label="Cost">
                        {currentMunition.munition_cost} points
                      </LabeledList.Item>
                      <LabeledList.Item label="Uses available">
                        {currentMunition.munition_uses}
                      </LabeledList.Item>
                      <LabeledList.Item label="Description">
                        {currentMunition.munition_desc}
                      </LabeledList.Item>
                    </LabeledList>

                    {(data.points ?? 0) < currentMunition.munition_cost ? (
                      <Button mt={1} color="red" fluid disabled>
                        Insufficient dropship points
                      </Button>
                    ) : null}
                  </Section>
                ) : (
                  <Section title="No support selected">
                    No fire support packages are currently available.
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
