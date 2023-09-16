import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { CampaignOverview } from './CampaignOverview';
import { CampaignMissions } from './CampaignMissions';
import { CampaignAssets } from './CampaignAssets';

const TAB_OVERVIEW = 'Overview';
const TAB_MISSIONS = 'Missions';
const TAB_ASSETS = 'Assets';

const CampaignTabs = [TAB_OVERVIEW, TAB_MISSIONS, TAB_ASSETS];

type MissionData = {
  typepath: string;
  name: string;

  map_name: string;
  starting_faction: string;
  hostile_faction: string;
  winning_faction: string;
  outcome: string;

  objective_description: string;
  mission_brief: string;
  mission_rewards: string[];
};

type FactionReward = {
  name: string;
  desc: string;
  detailed_desc: string;
  uses_remaining: number;
  uses_original: number;
};

export type CampaignData = {
  ui_theme: string;

  current_mission: MissionData;
  potential_missions: MissionData[];
  finished_missions: MissionData[];

  faction_rewards_data: FactionReward[];
  active_attrition_points: number;
  total_attrition_points: number;
  faction_leader: string;
  victory_points: number;
  faction: string;
};

export const CampaignMenu = (props, context) => {
  const { data } = useBackend<CampaignData>(context);
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    TAB_OVERVIEW
  );
  return (
    <Window theme={data.ui_theme}>
      <Window.Content>
        <Tabs fluid>
          {CampaignTabs.map((tabname) => {
            return (
              <Tabs.Tab
                key={tabname}
                selected={tabname === selectedTab}
                fontSize="130%"
                onClick={() => setSelectedTab(tabname)}>
                {tabname}
              </Tabs.Tab>
            );
          })}
        </Tabs>
        <CampaignContent />
      </Window.Content>
    </Window>
  );
};

const CampaignContent = (props, context) => {
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    TAB_OVERVIEW
  );
  switch (selectedTab) {
    case TAB_OVERVIEW:
      return <CampaignOverview />;
    case TAB_MISSIONS:
      return <CampaignMissions />;
    case TAB_ASSETS:
      return <CampaignAssets />;
  }
};
