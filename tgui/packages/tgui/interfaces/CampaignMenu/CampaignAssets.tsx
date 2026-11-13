import { Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../../backend';
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
                    ? 'green'
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
                <Stack align="center">
                  <Stack.Item
                    mr={1.5}
                    className={classes([
                      'campaign_assets18x18',
                      selectedReward.name === reward.name
                        ? reward.icon + '_green'
                        : reward.currently_active
                          ? reward.icon + '_yellow'
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
                </Stack>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          title={
            selectedReward ? (
              <Stack align="center">
                <Stack.Item
                  mr={1.5}
                  className={classes([
                    'campaign_assets36x36',
                    selectedReward.icon + '_orange' + '_big',
                  ])}
                />
                <Stack.Item fontSize="150%" grow={1}>
                  {selectedReward.name}
                </Stack.Item>
                <Stack.Item position="end">
                  <Button
                    onClick={() => setSelectedAsset(selectedReward)}
                    icon={'check'}
                  >
                    Select
                  </Button>
                </Stack.Item>
              </Stack>
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
