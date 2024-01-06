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
import { CampaignData, FactionReward } from './index';

export const CampaignAssets = (props) => {
  const { act, data } = useBackend<CampaignData>();
  const { faction_rewards_data } = data;
  const [selectedAsset, setSelectedAsset] = useLocalState<FactionReward | null>(
    'selectedAsset',
    null,
  );
  const [selectedReward, setSelectedReward] = useLocalState(
    'selectedReward',
    faction_rewards_data[0],
  );
  faction_rewards_data.sort((a, b) => {
    const used_asset_a = a.uses_remaining;
    const used_asset_b = b.uses_remaining;
    if (used_asset_a && used_asset_b) return 0;
    if (used_asset_a && !used_asset_b) return -1;
    if (!used_asset_a && used_asset_b) return 1;
    return 0;
  });

  return (
    <Stack>
      <Stack.Item>
        <Stack vertical>
          {faction_rewards_data.map((reward) => (
            <Stack.Item key={reward.name}>
              <Button
                width={'180px'}
                onClick={() => setSelectedReward(reward)}
                color={
                  selectedReward.name === reward.name
                    ? 'orange'
                    : reward.currently_active
                      ? 'yellow'
                      : reward.is_debuff
                        ? 'red'
                        : reward.uses_remaining > 0
                          ? 'blue'
                          : reward.uses_remaining < 0
                            ? 'red'
                            : 'grey'
                }
              >
                <Flex align="center">
                  <Flex.Item
                    mr={1.5}
                    className={classes([
                      'campaign_assets18x18',
                      selectedReward.name === reward.name
                        ? reward.icon + '_red'
                        : reward.currently_active
                          ? reward.icon + '_orange'
                          : reward.is_debuff
                            ? reward.icon + '_red'
                            : reward.uses_remaining > 0
                              ? reward.icon + '_blue'
                              : reward.uses_remaining < 0
                                ? reward.icon + '_red'
                                : reward.icon + '_grey',
                    ])}
                  />
                  {reward.name}
                </Flex>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={
            selectedReward ? (
              <Box>
                <Flex align="center">
                  <Flex.Item
                    mr={1.5}
                    className={classes([
                      'campaign_assets36x36',
                      selectedReward.icon + '_orange' + '_big',
                    ])}
                  />
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedReward.name}
                  </Flex.Item>
                  <Flex.Item alight="right" position="end">
                    <Button
                      onClick={() => setSelectedAsset(selectedReward)}
                      icon={'check'}
                    >
                      Select
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            ) : (
              'No asset selected'
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Name">
              {selectedReward?.name}
            </LabeledList.Item>
            <LabeledList.Item label="Summary">
              {selectedReward?.desc}
            </LabeledList.Item>
            <LabeledList.Item label="Remaining uses">
              {selectedReward?.uses_remaining} / {selectedReward?.uses_original}
            </LabeledList.Item>
            <LabeledList.Item label="Description">
              {selectedReward?.detailed_desc}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
