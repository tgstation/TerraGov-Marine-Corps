import { classes } from 'common/react';

import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
} from '../../components';
import { IndividualData, LoadoutItemData } from './index';

export const IndividualLoadouts = (props) => {
  const { act, data } = useBackend<IndividualData>();
  const { equipped_loadouts_data, available_loadouts_data, outfit_cost_data } =
    data;
  const [equipPotentialItem, setEquippedItem] =
    useLocalState<LoadoutItemData | null>('equipPotentialItem', null);
  const [selectedJob, setSelectedJob] = useLocalState(
    'selectedJob',
    data.jobs[0],
  );
  const [selectedLoadoutItem, setselectedLoadoutItem] = useLocalState(
    'selectedLoadoutItem',
    equipped_loadouts_data[0],
  );
  const [selectedPossibleItem, setselectedPossibleItem] = useLocalState(
    'selectedPossibleItem',
    available_loadouts_data[0],
  );
  const selectedOutfitCostData =
    outfit_cost_data.find(
      (OutfitCostData) => OutfitCostData.job === selectedJob,
    ) || outfit_cost_data[0];

  return (
    <Stack>
      <Stack.Item>
        <Stack>
          <Button
            color={'green'}
            width={'180px'}
            height={'35px'}
            fontSize="150%"
            textAlign="center"
            mt={'10px'}
            mb={'18px'}
            tooltip={
              selectedOutfitCostData.outfit_cost > data.currency
                ? 'Insufficient credits'
                : 'Equip Loadout'
            }
            disabled={selectedOutfitCostData.outfit_cost > data.currency}
            onClick={() =>
              act('equip_outfit', {
                outfit_job: selectedJob,
              })
            }
          >
            Equip outfit
          </Button>
        </Stack>
        <Stack vertical>
          <LabeledList>
            {equipped_loadouts_data
              .filter(
                (equippeditem) => equippeditem.item_type.job === selectedJob,
              )
              .map((equippeditem) => (
                <Stack.Item
                  key={
                    equippeditem.item_type
                      ? equippeditem.item_type.name
                      : 'null'
                  }
                >
                  <Flex mt="3px" ml="3px" Align="center">
                    {equippeditem.slot_text}
                  </Flex>
                  <Button
                    width={'180px'}
                    onClick={() => {
                      setselectedLoadoutItem(equippeditem);
                      setselectedPossibleItem(equippeditem.item_type);
                    }}
                    color={
                      selectedLoadoutItem.item_type.name ===
                      equippeditem.item_type.name
                        ? 'orange'
                        : equippeditem.item_type.valid_choice === 0
                          ? 'red'
                          : equippeditem.item_type.quantity === 0
                            ? 'red'
                            : 'blue'
                    }
                  >
                    <Flex align="center">
                      {!!equippeditem.item_type.icon && (
                        <Flex.Item
                          mr={1.5}
                          className={classes([
                            'campaign_perks18x18',
                            selectedLoadoutItem.item_type.name ===
                            equippeditem.item_type.name
                              ? equippeditem.item_type.icon + '_orange'
                              : equippeditem.item_type.valid_choice === 0
                                ? equippeditem.item_type.icon + '_red'
                                : equippeditem.item_type.quantity === 0
                                  ? equippeditem.item_type.icon + '_red'
                                  : equippeditem.item_type.icon + '_blue',
                          ])}
                        />
                      )}
                      {equippeditem.item_type.name}
                    </Flex>
                  </Button>
                </Stack.Item>
              ))}
          </LabeledList>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          vertical
          title={selectedJob + ' loadout'}
          textColor={
            selectedOutfitCostData.outfit_cost < data.currency ? 'white' : 'red'
          }
        >
          Equip cost: {selectedOutfitCostData.outfit_cost}
        </Section>
        <Section
          vertical
          title={
            selectedPossibleItem ? (
              <Box>
                <Flex align="center">
                  <Flex.Item
                    mr={1.5}
                    className={classes([
                      'campaign_perks36x36',
                      selectedPossibleItem.icon + '_orange' + '_big',
                    ])}
                  />
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedPossibleItem.name}
                  </Flex.Item>
                  {selectedPossibleItem.valid_choice ? (
                    <Flex.Item alight="right" position="end">
                      <Button
                        onClick={() => setEquippedItem(selectedPossibleItem)}
                        icon={'check'}
                      >
                        Equip
                      </Button>
                    </Flex.Item>
                  ) : null}
                </Flex>
              </Box>
            ) : (
              'No item selected'
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Name">
              {selectedPossibleItem?.name}
            </LabeledList.Item>
            <LabeledList.Item label="Summary">
              {selectedPossibleItem?.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Equip cost">
              {selectedPossibleItem?.purchase_cost}
            </LabeledList.Item>
            {selectedPossibleItem.quantity === -1 ? null : (
              <LabeledList.Item label="Quantity remaining">
                {selectedPossibleItem.quantity}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Stack fontSize="150%" textAlign="center" mt={'12px'} mb={'28px'}>
          Equipment options
        </Stack>
        <Stack vertical>
          {available_loadouts_data
            .filter((potentialitem) => potentialitem.job === selectedJob)
            .filter(
              (potentialitem) =>
                potentialitem.slot === selectedLoadoutItem.item_type.slot,
            )
            .map((potentialitem) => (
              <Stack.Item key={potentialitem.name}>
                <Button
                  width={'180px'}
                  onClick={() => setselectedPossibleItem(potentialitem)}
                  color={
                    selectedPossibleItem.name === potentialitem.name
                      ? 'orange'
                      : potentialitem.valid_choice === 0
                        ? 'red'
                        : potentialitem.quantity === 0
                          ? 'red'
                          : 'blue'
                  }
                >
                  <Flex align="center">
                    {!!potentialitem.icon && (
                      <Flex.Item
                        mr={1.5}
                        className={classes([
                          'campaign_perks18x18',
                          selectedPossibleItem.name === potentialitem.name
                            ? potentialitem + '_orange'
                            : potentialitem.valid_choice === 0
                              ? potentialitem + '_red'
                              : potentialitem.quantity === 0
                                ? potentialitem + '_red'
                                : potentialitem + '_blue',
                        ])}
                      />
                    )}
                    {potentialitem.name}
                  </Flex>
                </Button>
              </Stack.Item>
            ))}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
