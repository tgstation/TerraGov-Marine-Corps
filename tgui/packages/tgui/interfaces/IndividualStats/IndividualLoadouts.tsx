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
import { IndividualData, LoadoutItemData, OutfitCostData } from './index';

export const IndividualLoadouts = (props) => {
  const { act, data } = useBackend<IndividualData>();
  const { equipped_loadouts_data, available_loadouts_data, outfit_cost_data } =
    data;
  const [equipOutfit, setEquippedOutfit] = useLocalState<OutfitCostData | null>(
    'equipOutfit',
    null,
  );

  const [unlockPotentialItem, setUnlockedItem] =
    useLocalState<LoadoutItemData | null>('unlockPotentialItem', null);
  const [selectedJob, setSelectedJob] = useLocalState(
    'selectedJob',
    data.current_job ? data.current_job : data.jobs[0],
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
        <Section>
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
              onClick={() => setEquippedOutfit(selectedOutfitCostData)}
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
                    <Button
                      width={'260px'}
                      mt="5px"
                      mr="3px"
                      ml="3px"
                      onClick={() => {
                        setselectedLoadoutItem(equippeditem);
                        setselectedPossibleItem(equippeditem.item_type);
                      }}
                      color={
                        selectedLoadoutItem.item_type.name ===
                        equippeditem.item_type.name
                          ? 'orange'
                          : equippeditem.item_type.quantity === 0
                            ? 'grey'
                            : equippeditem.item_type.valid_choice === 0
                              ? 'red'
                              : 'blue'
                      }
                    >
                      <Flex align="center">
                        {!!equippeditem.item_type.icon && (
                          <Flex.Item
                            mr={1.5}
                            width={'18px'}
                            className={classes([
                              'campaign_loadout_items18x18',
                              selectedLoadoutItem.item_type.name ===
                              equippeditem.item_type.name
                                ? equippeditem.item_type.icon + '_orange'
                                : equippeditem.item_type.quantity === 0
                                  ? equippeditem.item_type.icon + '_grey'
                                  : equippeditem.item_type.valid_choice === 0
                                    ? equippeditem.item_type.icon + '_red'
                                    : equippeditem.item_type.icon + '_blue',
                            ])}
                          />
                        )}
                        <Flex.Item bold={1} width={'90px'}>
                          {equippeditem.slot_text + ':'}
                        </Flex.Item>
                        <Flex.Item>{equippeditem.item_type.name}</Flex.Item>
                      </Flex>
                    </Button>
                  </Stack.Item>
                ))}
            </LabeledList>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Stack
            fontSize="150%"
            bold={1}
            textAlign="center"
            mt={'12px'}
            mb={'28px'}
          >
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
                    onClick={() => {
                      setselectedPossibleItem(potentialitem);
                      potentialitem.unlocked &&
                        act('equip_item', {
                          selected_item: potentialitem.type,
                          selected_job: potentialitem.job,
                        });
                    }}
                    color={
                      selectedPossibleItem.name === potentialitem.name
                        ? 'orange'
                        : !potentialitem.unlocked ||
                            potentialitem.quantity === 0
                          ? 'grey'
                          : !potentialitem.valid_choice
                            ? 'red'
                            : 'blue'
                    }
                  >
                    <Flex align="center">
                      {!!potentialitem.icon && (
                        <Flex.Item
                          mr={1.5}
                          className={classes([
                            'campaign_loadout_items18x18',
                            selectedPossibleItem.name === potentialitem.name
                              ? potentialitem.icon + '_orange'
                              : !potentialitem.unlocked ||
                                  potentialitem.quantity === 0
                                ? potentialitem.icon + '_grey'
                                : !potentialitem.valid_choice
                                  ? potentialitem.icon + '_red'
                                  : potentialitem.icon + '_blue',
                          ])}
                        />
                      )}
                      {potentialitem.name}
                    </Flex>
                  </Button>
                </Stack.Item>
              ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          vertical
          title={selectedJob + ' loadout'}
          textColor={
            selectedOutfitCostData.outfit_cost <= data.currency
              ? 'white'
              : 'red'
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
                      'campaign_loadout_items36x36',
                      selectedPossibleItem.icon + '_orange' + '_big',
                    ])}
                  />
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedPossibleItem.name}
                  </Flex.Item>
                  {!selectedPossibleItem.unlocked && (
                    <Flex.Item alight="right" position="end">
                      <Button
                        onClick={() => setUnlockedItem(selectedPossibleItem)}
                        icon={'check'}
                      >
                        Unlock
                      </Button>
                    </Flex.Item>
                  )}
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
            {selectedPossibleItem.unlocked === 0 && (
              <LabeledList.Item label="Unlock cost">
                {selectedPossibleItem.unlock_cost}
              </LabeledList.Item>
            )}
            {selectedPossibleItem.quantity !== -1 && (
              <LabeledList.Item label="Quantity">
                {selectedPossibleItem.quantity === 0
                  ? 'None currently available'
                  : selectedPossibleItem.quantity}
              </LabeledList.Item>
            )}
            {selectedPossibleItem.requirements && (
              <LabeledList.Item label="Requirements">
                {selectedPossibleItem.requirements}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
