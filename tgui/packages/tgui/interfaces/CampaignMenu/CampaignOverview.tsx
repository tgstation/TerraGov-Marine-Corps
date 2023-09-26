import { CampaignData } from './index';
import { useBackend } from '../../backend';
import { LabeledList, Button, Section } from '../../components';

export const CampaignOverview = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  const {
    current_mission,
    active_attrition_points,
    total_attrition_points,
    faction_leader,
    victory_points,
    faction,
  } = data;
  const { map_name, objective_description, mission_brief } = current_mission;
  return (
    <>
      <Section title={'Mission Overview'}>
        <LabeledList>
          <LabeledList.Item label="Map name">{map_name}</LabeledList.Item>
          <LabeledList.Item label="Objectives">
            {objective_description}
          </LabeledList.Item>
          <LabeledList.Item label="Mission Brief">
            {mission_brief}
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
      <Section title={'Faction Overview'}>
        <LabeledList>
          <LabeledList.Item label="Current leader">
            {faction_leader}
          </LabeledList.Item>
          <LabeledList.Item label="Victory Points">
            {victory_points}
          </LabeledList.Item>
          <LabeledList.Item label="Total Attrition">
            {total_attrition_points}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
