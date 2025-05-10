import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../../backend';
import { IndividualData, PerkData } from './index';

export const IndividualPerks = (props) => {
  const { act, data } = useBackend<IndividualData>();
  const { perks_data } = data;
  const [unlockedPerk, setPurchasedPerk] = useLocalState<PerkData | null>(
    'unlockedPerk',
    null,
  );
  const [selectedJob, setSelectedJob] = useLocalState(
    'selectedJob',
    data.current_job ? data.current_job : data.jobs[0],
  );
  const [selectedPerk, setSelectedPerk] = useLocalState(
    'selectedPerk',
    perks_data[0],
  );
  perks_data.sort((a, b) => {
    const used_asset_a = a.currently_active;
    const used_asset_b = b.currently_active;
    if (used_asset_a && used_asset_b) return 0;
    if (used_asset_a && !used_asset_b) return -1;
    if (!used_asset_a && used_asset_b) return 1;
    return 0;
  });

  return (
    <Stack>
      <Stack.Item>
        <Section>
          <Stack vertical>
            {perks_data
              .filter((perk) => perk.job === selectedJob)
              .map((perk) => (
                <Stack.Item key={perk.name}>
                  <Button
                    width={'220px'}
                    height={'22px'}
                    onClick={() => {
                      act('play_ding');
                      setSelectedPerk(perk);
                    }}
                    color={
                      selectedPerk.name === perk.name
                        ? 'green'
                        : perk.currently_active > 0
                          ? 'blue'
                          : perk.cost > data.currency
                            ? 'red'
                            : 'grey'
                    }
                  >
                    <Flex align="center" mt="1px">
                      <Flex.Item
                        mr={1.5}
                        className={classes([
                          'campaign_perks18x18',
                          selectedPerk.name === perk.name
                            ? perk.icon + '_green'
                            : perk.currently_active > 0
                              ? perk.icon + '_blue'
                              : perk.cost > data.currency
                                ? perk.icon + '_red'
                                : perk.icon + '_grey',
                        ])}
                      />
                      {perk.name}
                    </Flex>
                  </Button>
                </Stack.Item>
              ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          title={
            selectedPerk ? (
              <Box>
                <Flex align="center">
                  <Flex.Item
                    mr={1.5}
                    className={classes([
                      'campaign_perks36x36',
                      selectedPerk.icon + '_green' + '_big',
                    ])}
                  />
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedPerk.name}
                  </Flex.Item>
                  {!selectedPerk.currently_active && (
                    <Flex.Item alight="right" position="end">
                      <Button
                        onClick={() => setPurchasedPerk(selectedPerk)}
                        icon={'check'}
                      >
                        Unlock
                      </Button>
                    </Flex.Item>
                  )}
                </Flex>
              </Box>
            ) : (
              'No perk selected'
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Name">
              {selectedPerk?.name}
            </LabeledList.Item>
            <LabeledList.Item label="Summary">
              {selectedPerk?.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Cost">
              {selectedPerk?.cost}
            </LabeledList.Item>
            {selectedPerk.requirements && (
              <LabeledList.Item label="Requirements">
                {selectedPerk.requirements}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
