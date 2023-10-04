import { CampaignData, MissionData } from './index';
import { useBackend, useLocalState } from '../../backend';
import { LabeledList, Button, Stack, Section } from '../../components';

export const CampaignMissions = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  const { available_missions } = data;
  const [selectedNewMission, setSelectedNewMission] =
    useLocalState<MissionData | null>(context, 'selectedNewMission', null);
  const [selectedMission, setSelectedMission] = useLocalState(
    context,
    'selectedMission',
    available_missions[0]
  );

  return (
    <Stack>
      <Stack.Item>
        <Stack vertical>
          {available_missions.map((mission) => (
            <Stack.Item key={mission.name}>
              <Button
                width={'120px'}
                onClick={() => setSelectedMission(mission)}
                selected={selectedMission.name === mission.name}>
                {mission.name}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={selectedMission ? selectedMission.name : 'No Mission selected'}
          buttons={
            <Button
              onClick={() => setSelectedNewMission(selectedMission)}
              icon={'check'}>
              Select
            </Button>
          }>
          <LabeledList>
            <LabeledList.Item label="Map name">
              {selectedMission?.map_name}
            </LabeledList.Item>
            <LabeledList.Item label="Objectives">
              {selectedMission?.objective_description}
            </LabeledList.Item>
            <LabeledList.Item label="Mission Brief">
              {selectedMission.mission_brief}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Rewards">{selectedMission.mission_rewards}</Section>
      </Stack.Item>
    </Stack>
  );
};
