import { CampaignData, FactionReward, AssetIcon } from './index';
import { useBackend, useLocalState } from '../../backend';
import { LabeledList, Button, Stack, Section, Flex, Box } from '../../components';

export const CampaignPurchase = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  const { purchasable_rewards_data } = data;
  const [purchasedAsset, setPurchasedAsset] =
    useLocalState<FactionReward | null>(context, 'purchasedAsset', null);
  const [selectedReward, setSelectedReward] = useLocalState(
    context,
    'selectedReward',
    purchasable_rewards_data[0]
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
                    ? 'orange'
                    : reward.uses_remaining > 0
                      ? 'blue'
                      : reward.uses_remaining < 0
                        ? 'red'
                        : 'grey'
                }>
                <Flex align="center">
                  {!!reward.icon && (
                    <AssetIcon
                      icon={
                        selectedReward.name === reward.name
                          ? reward.icon + '_red'
                          : reward.icon + '_blue'
                      }
                    />
                  )}
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
                  <Flex.Item>
                    {
                      <AssetIcon
                        icon={selectedReward.icon + '_orange'}
                        icon_width={'36px'}
                        icon_height={'36px'}
                      />
                    }
                  </Flex.Item>
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedReward.name}
                  </Flex.Item>
                  <Flex.Item alight="right" position="end">
                    <Button
                      onClick={() => setPurchasedAsset(selectedReward)}
                      icon={'check'}>
                      Select
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            ) : (
              'No asset selected'
            )
          }>
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
