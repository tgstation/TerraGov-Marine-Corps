import { CampaignData, MissionIcon } from './index';
import { useBackend } from '../../backend';
import { LabeledList, Button, Section, Table, ProgressBar, Box, Flex } from '../../components';

export const CampaignOverview = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  const {
    current_mission,
    active_attrition_points,
    total_attrition_points,
    faction_leader,
    victory_points,
    max_victory_points,
    faction,
  } = data;
  const {
    name,
    map_name,
    objective_description,
    mission_brief,
    mission_parameters,
    vp_major_reward,
    ap_major_reward,
    vp_minor_reward,
    ap_minor_reward,
    mission_rewards,
    mission_icon,
  } = current_mission;
  return (
    <>
      <Section
        title={
          <Box>
            <Flex fontSize="150%" align="center">
              {
                <MissionIcon
                  icon={mission_icon + '_green'}
                  icon_width={'48px'}
                  icon_height={'48px'}
                />
              }
              Current Mission overview
            </Flex>
          </Box>
        }>
        <LabeledList>
          <LabeledList.Item label="Mission">{name}</LabeledList.Item>
          <LabeledList.Item label="Map name">{map_name}</LabeledList.Item>
          <LabeledList.Item label="Objectives">
            {objective_description}
          </LabeledList.Item>
          <LabeledList.Item label="Mission Brief">
            {mission_brief}
          </LabeledList.Item>
          <LabeledList.Item label="Mission Parameters">
            {mission_parameters}
          </LabeledList.Item>
          <LabeledList.Item label="Current Attrition">
            {active_attrition_points}
          </LabeledList.Item>
          <LabeledList.Item>
            <Button onClick={() => act('set_attrition_points')} icon={'check'}>
              Set Attrition points
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title={'Current Mission Rewards'}>
        <Table>
          <Table.Row>
            <Table.Cell />
            <Table.Cell color="label">Victory Points</Table.Cell>
            <Table.Cell color="label">Attrition Points</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell color="label">Major Victory</Table.Cell>
            <Table.Cell>{vp_major_reward}</Table.Cell>
            <Table.Cell>{ap_major_reward}</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell color="label">Minor Victory</Table.Cell>
            <Table.Cell>{vp_minor_reward}</Table.Cell>
            <Table.Cell>{ap_minor_reward}</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell color="label">Additional Rewards</Table.Cell>
            <Table.Cell colspan="2">{mission_rewards}</Table.Cell>
          </Table.Row>
        </Table>
      </Section>
      <Section title={'Faction Overview'}>
        <LabeledList>
          <LabeledList.Item label="Current leader">
            {faction_leader}
          </LabeledList.Item>
          <LabeledList.Item label="Victory Points">
            <ProgressBar
              color="green"
              value={victory_points / max_victory_points}>
              {victory_points} / {max_victory_points}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Total Attrition">
            {total_attrition_points}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
