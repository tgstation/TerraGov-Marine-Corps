import { CampaignData, MissionData, MissionIcon } from './index';
import { useBackend, useLocalState } from '../../backend';
import { LabeledList, Button, Stack, Section, Table, Box, Flex } from '../../components';

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
                height={'30px'}
                width={'180px'}
                onClick={() => setSelectedMission(mission)}
                color={
                  selectedMission.name === mission.name
                    ? 'orange'
                    : mission.mission_critical
                      ? 'red'
                      : 'blue'
                }>
                <Flex align="center">
                  <Flex.Item pt={'3px'}>
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
                  </Flex.Item>
                  <Flex.Item>{mission.name}</Flex.Item>
                </Flex>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Section
          title={
            selectedMission ? (
              <Box>
                <Flex align="center">
                  <Flex.Item>
                    {
                      <MissionIcon
                        icon={selectedMission.mission_icon + '_yellow'}
                        icon_width={'48px'}
                        icon_height={'48px'}
                      />
                    }
                  </Flex.Item>
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedMission.name}
                  </Flex.Item>
                  <Flex.Item alight="right" position="end">
                    <Button
                      onClick={() => setSelectedNewMission(selectedMission)}
                      icon={'check'}>
                      Select
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            ) : (
              'No Mission selected'
            )
          }>
          <LabeledList>
            <LabeledList.Item label="Map name">
              {selectedMission?.map_name}
            </LabeledList.Item>
            <LabeledList.Item label="Objectives">
              {selectedMission?.objective_description}
            </LabeledList.Item>
            <LabeledList.Item label="Mission Brief">
              {selectedMission?.mission_brief}
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
              <Table.Cell>{selectedMission?.vp_major_reward}</Table.Cell>
              <Table.Cell>{selectedMission?.ap_major_reward}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell color="label">Minor Victory</Table.Cell>
              <Table.Cell>{selectedMission?.vp_minor_reward}</Table.Cell>
              <Table.Cell>{selectedMission?.ap_minor_reward}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell color="label">Additional Rewards</Table.Cell>
              <Table.Cell colspan="2">
                {selectedMission?.mission_rewards}
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
