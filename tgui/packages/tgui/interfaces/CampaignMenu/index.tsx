import { useBackend, useLocalState } from '../../backend';
import { Button, Modal, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { CampaignAssets } from './CampaignAssets';
import { CampaignMissions } from './CampaignMissions';
import { CampaignOverview } from './CampaignOverview';
import { CampaignPurchase } from './CampaignPurchase';

const TAB_OVERVIEW = 'Overview';
const TAB_MISSIONS = 'Missions';
const TAB_ASSETS = 'Assets';
const TAB_PURCHASABLE_ASSETS = 'Purchase Assets';

const CampaignTabs = [
  TAB_OVERVIEW,
  TAB_MISSIONS,
  TAB_ASSETS,
  TAB_PURCHASABLE_ASSETS,
];

export type MissionData = {
  faction_rewards_data;
  typepath?: string;
  name?: string;

  map_name?: string;
  starting_faction?: string;
  hostile_faction?: string;
  winning_faction?: string;
  outcome?: string;

  objective_description: string;
  mission_brief: string;
  mission_parameters: string;
  mission_rewards: string;
  vp_major_reward: number;
  vp_minor_reward: number;
  ap_major_reward: number;
  ap_minor_reward: number;
  mission_icon?: string;
  mission_critical?: number;
};

export type FactionReward = {
  name: string;
  type: string;
  desc: string;
  detailed_desc: string;
  uses_remaining: number;
  uses_original: number;
  cost: number;
  icon?: string;
  currently_active?: number;
  is_debuff?: number;
};

export type CampaignData = {
  ui_theme: string;

  current_mission: MissionData;
  available_missions: MissionData[];
  finished_missions: MissionData[];

  faction_rewards_data: FactionReward[];
  purchasable_rewards_data: FactionReward[];
  active_attrition_points: number;
  total_attrition_points: number;
  faction_leader?: string;
  victory_points: number;
  max_victory_points: number;
  faction: string;
};

export const CampaignMenu = (props) => {
  const { act, data } = useBackend<CampaignData>();
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    TAB_OVERVIEW,
  );

  const [selectedAsset, setSelectedAsset] = useLocalState<FactionReward | null>(
    'selectedAsset',
    null,
  );
  const [purchasedAsset, setPurchasedAsset] =
    useLocalState<FactionReward | null>('purchasedAsset', null);
  const [selectedNewMission, setSelectedNewMission] =
    useLocalState<MissionData | null>('selectedNewMission', null);

  return (
    <Window
      theme={data.ui_theme}
      title={data.faction + ' Mission Control'}
      width={700}
      height={600}
    >
      <Window.Content>
        {selectedAsset ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Activate ' + selectedAsset.name + '?'}
            >
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('activate_reward', {
                        selected_reward: selectedAsset.type,
                      });
                      setSelectedAsset(null);
                    }}
                    icon={'check'}
                    color="green"
                  >
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setSelectedAsset(null)}
                    icon={'times'}
                    color="red"
                  >
                    No
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        ) : null}
        {purchasedAsset ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Purchase ' + purchasedAsset.name + '?'}
            >
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('purchase_reward', {
                        selected_reward: purchasedAsset.type,
                      });
                      setPurchasedAsset(null);
                    }}
                    icon={'check'}
                    color="green"
                  >
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setPurchasedAsset(null)}
                    icon={'times'}
                    color="red"
                  >
                    No
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        ) : null}
        {selectedNewMission ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Select ' + selectedNewMission.name + '?'}
            >
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('set_next_mission', {
                        new_mission: selectedNewMission.typepath,
                      });
                      setSelectedNewMission(null);
                    }}
                    icon={'check'}
                    color="green"
                  >
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setSelectedNewMission(null)}
                    icon={'times'}
                    color="red"
                  >
                    No
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        ) : null}
        <Tabs fluid>
          {CampaignTabs.map((tabname) => {
            return (
              <Tabs.Tab
                key={tabname}
                selected={tabname === selectedTab}
                fontSize="130%"
                textAlign="center"
                onClick={() => setSelectedTab(tabname)}
              >
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

const CampaignContent = (props) => {
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    TAB_OVERVIEW,
  );
  switch (selectedTab) {
    case TAB_OVERVIEW:
      return <CampaignOverview />;
    case TAB_MISSIONS:
      return <CampaignMissions />;
    case TAB_ASSETS:
      return <CampaignAssets />;
    case TAB_PURCHASABLE_ASSETS:
      return <CampaignPurchase />;
    default:
      return null;
  }
};
