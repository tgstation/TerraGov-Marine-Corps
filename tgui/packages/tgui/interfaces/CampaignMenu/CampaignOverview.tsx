import { CampaignData } from './index';
import { useBackend } from '../../backend';
import { Section } from '../../components';

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
  return <Section title={faction + ' Campaign Overview'}></Section>;
};
