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

export const CampaignPurchase = (props) => {
  const { act, data } = useBackend<CampaignData>();
  const { purchasable_rewards_data } = data;
  const [purchasedAsset, setPurchasedAsset] =
    useLocalState<FactionReward | null>('purchasedAsset', null);
  const [selectedReward, setSelectedReward] = useLocalState(
    'selectedReward',
    purchasable_rewards_data[0],
  );
  purchasable_rewards_data.sort((a, b) => {
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
          {purchasable_rewards_data.map((reward) => (
            <Stack.Item key={reward.name}>
              <Button
                width={'180px'}
                onClick={() => setSelectedReward(reward)}
                color={
                  selectedReward.name === reward.name
                    ? 'green'
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
                        ? reward.icon + '_green'
                        : reward.icon + '_blue',
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
                      onClick={() => setPurchasedAsset(selectedReward)}
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
            <LabeledList.Item label="Cost">
              {selectedReward?.cost}
            </LabeledList.Item>
            <LabeledList.Item label="Uses">
              {selectedReward?.uses_original}
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
