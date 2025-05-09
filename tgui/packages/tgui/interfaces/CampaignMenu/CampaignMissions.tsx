import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../../backend';
import { CampaignData, MissionData } from './index';

export const CampaignMissions = (props) => {
  const { act, data } = useBackend<CampaignData>();
  const { available_missions } = data;
  const [selectedNewMission, setSelectedNewMission] =
    useLocalState<MissionData | null>('selectedNewMission', null);
  const [selectedMission, setSelectedMission] = useLocalState(
    'selectedMission',
    available_missions[0],
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
                    ? 'green'
                    : mission.mission_critical
                      ? 'red'
                      : 'blue'
                }
              >
                <Flex align="center">
                  <Flex.Item
                    mt={'3px'}
                    mr={1.5}
                    className={classes([
                      'campaign_missions24x24',
                      selectedMission.name === mission.name
                        ? mission.mission_icon + '_green'
                        : mission.mission_critical
                          ? mission.mission_icon + '_red'
                          : mission.mission_icon + '_blue',
                    ])}
                  />
                  <Flex.Item>{mission.name}</Flex.Item>
                </Flex>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          title={
            selectedMission ? (
              <Box>
                <Flex align="center">
                  <Flex.Item
                    mr={1.5}
                    className={classes([
                      'campaign_missions48x48',
                      selectedMission.mission_icon + '_yellow' + '_big',
                    ])}
                  />
                  <Flex.Item fontSize="150%" grow={1}>
                    {selectedMission.name}
                  </Flex.Item>
                  <Flex.Item alight="right" position="end">
                    <Button
                      onClick={() => setSelectedNewMission(selectedMission)}
                      icon={'check'}
                    >
                      Select
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            ) : (
              'No Mission selected'
            )
          }
        >
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
              <Table.Cell colSpan={2}>
                {selectedMission?.mission_rewards}
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
