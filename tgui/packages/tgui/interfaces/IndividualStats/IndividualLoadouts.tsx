import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../../backend';
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
                        act('play_ding');
                        setselectedLoadoutItem(equippeditem);
                        setselectedPossibleItem(equippeditem.item_type);
                      }}
                      color={
                        selectedLoadoutItem.item_type.name ===
                        equippeditem.item_type.name
                          ? 'green'
                          : equippeditem.item_type.quantity === 0
                            ? 'grey'
                            : !equippeditem.item_type.valid_choice
                              ? 'red'
                              : equippeditem.item_type.purchase_cost > 0
                                ? 'orange'
                                : 'blue'
                      }
                    >
                      <Stack align="center">
                        {!!equippeditem.item_type.icon && (
                          <Stack.Item
                            mr={0.5}
                            width={'32px'}
                            className={classes([
                              'campaign_loadout_items32x32',
                              selectedLoadoutItem.item_type.name ===
                              equippeditem.item_type.name
                                ? equippeditem.item_type.icon + '_green'
                                : equippeditem.item_type.quantity === 0
                                  ? equippeditem.item_type.icon + '_grey'
                                  : !equippeditem.item_type.valid_choice
                                    ? equippeditem.item_type.icon + '_red'
                                    : equippeditem.item_type.purchase_cost > 0
                                      ? equippeditem.item_type.icon + '_orange'
                                      : equippeditem.item_type.icon + '_blue',
                            ])}
                          />
                        )}
                        <Stack.Item bold width={'90px'}>
                          {equippeditem.slot_text + ':'}
                        </Stack.Item>
                        <Stack.Item>{equippeditem.item_type.name}</Stack.Item>
                      </Stack>
                    </Button>
                  </Stack.Item>
                ))}
            </LabeledList>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill width={'240px'}>
          <Stack
            fontSize="150%"
            bold
            textAlign="center"
            mt={'10px'}
            mb={'14px'}
            ml={'10px'}
          >
            Equipment options
          </Stack>
          <Section fill scrollable width={'240px'} height={'555px'}>
            <Stack width={'240px'} wrap>
              {available_loadouts_data
                .filter((potentialitem) => potentialitem.job === selectedJob)
                .filter(
                  (potentialitem) =>
                    potentialitem.slot === selectedLoadoutItem.item_type.slot,
                )
                .map((potentialitem) => (
                  <Stack.Item ml={0.1} mr={1.5} mb={1} key={potentialitem.name}>
                    <Button
                      width={'100px'}
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
                          ? 'green'
                          : !potentialitem.unlocked ||
                              potentialitem.quantity === 0
                            ? 'grey'
                            : !potentialitem.valid_choice
                              ? 'red'
                              : potentialitem.purchase_cost > 0
                                ? 'orange'
                                : 'blue'
                      }
                    >
                      <Stack align="center" direction="column">
                        {!!potentialitem.icon && (
                          <Stack.Item
                            className={classes([
                              'campaign_loadout_items64x64',
                              selectedPossibleItem.name === potentialitem.name
                                ? potentialitem.icon + '_green' + '_big'
                                : !potentialitem.unlocked ||
                                    potentialitem.quantity === 0
                                  ? potentialitem.icon + '_grey' + '_big'
                                  : !potentialitem.valid_choice
                                    ? potentialitem.icon + '_red' + '_big'
                                    : potentialitem.purchase_cost > 0
                                      ? potentialitem.icon + '_orange' + '_big'
                                      : potentialitem.icon + '_blue' + '_big',
                            ])}
                          />
                        )}
                        {potentialitem.name}
                      </Stack>
                    </Button>
                  </Stack.Item>
                ))}
            </Stack>
          </Section>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
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
          title={
            selectedPossibleItem ? (
              <Box>
                <Stack align="center">
                  <Stack.Item
                    mr={1}
                    className={classes([
                      'campaign_loadout_items64x64',
                      selectedPossibleItem.icon + '_green' + '_big',
                    ])}
                  />
                  <Stack.Item fontSize="150%" grow={1}>
                    {selectedPossibleItem.name}
                  </Stack.Item>
                  {!selectedPossibleItem.unlocked && (
                    <Stack.Item align="right" position="end">
                      <Button
                        onClick={() => setUnlockedItem(selectedPossibleItem)}
                        icon={'check'}
                      >
                        Unlock
                      </Button>
                    </Stack.Item>
                  )}
                </Stack>
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
