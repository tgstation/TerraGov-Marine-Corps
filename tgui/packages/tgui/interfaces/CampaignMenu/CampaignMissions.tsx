import { CampaignData, MissionData, MissionIcon } from './index';
import { useBackend, useLocalState } from '../../backend';
import { LabeledList, Button, Stack, Section, Table } from '../../components';

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
                width={'180px'}
                onClick={() => setSelectedMission(mission)}
                color={
                  selectedMission.name === mission.name
                    ? 'orange'
                    : mission.mission_critical
                      ? 'red'
                      : 'blue'
                }>
                {!!mission.mission_icon && (
                  <MissionIcon
                    icon={
                      selectedMission.name === mission.name
                        ? mission.mission_icon + '_yellow'
                        : mission.mission_critical
                          ? mission.mission_icon + '_red'
                          : mission.mission_icon + '_blue'
                    }
                  />
                )}
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
        <Section title={'Rewards'}>
          <Table>
            <Table.Row>
              <Table.Cell />
              <Table.Cell color="label">Victory Points</Table.Cell>
              <Table.Cell color="label">Attrition Points</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell color="label">Major Victory</Table.Cell>
              <Table.Cell>{selectedMission.vp_major_reward}</Table.Cell>
              <Table.Cell>{selectedMission.ap_major_reward}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell color="label">Minor Victory</Table.Cell>
              <Table.Cell>{selectedMission.vp_minor_reward}</Table.Cell>
              <Table.Cell>{selectedMission.ap_minor_reward}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell color="label">Additional Rewards</Table.Cell>
              <Table.Cell colspan="2">
                {selectedMission.mission_rewards}
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
