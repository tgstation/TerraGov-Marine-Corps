import { CampaignData, FactionReward } from './index';
import { useBackend, useLocalState } from '../../backend';
import { LabeledList, Button, Stack, Section } from '../../components';

export const CampaignAssets = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  const { faction_rewards_data } = data;
  const [selectedAsset, setSelectedAsset] = useLocalState<FactionReward | null>(
    context,
    'selectedAsset',
    null
  );
  const [selectedReward, setSelectedReward] = useLocalState(
    context,
    'selectedReward',
    faction_rewards_data[0]
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
                width={'150px'}
                onClick={() => setSelectedReward(reward)}
                color={
                  selectedReward.name === reward.name
                    ? 'orange'
                    : reward.uses_remaining > 0
                      ? 'green'
                      : reward.uses_remaining < 0
                        ? 'red'
                        : 'grey'
                }>
                {reward.name}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={selectedReward ? selectedReward.name : 'No reward selected'}
          buttons={
            <Button
              onClick={() => setSelectedAsset(selectedReward)}
              icon={'check'}>
              Activate
            </Button>
          }>
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
