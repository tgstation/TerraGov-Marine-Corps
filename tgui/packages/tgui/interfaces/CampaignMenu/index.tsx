import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { Box, Modal, Tabs, Button, Stack, Section } from '../../components';
import { CampaignOverview } from './CampaignOverview';
import { CampaignMissions } from './CampaignMissions';
import { CampaignAssets } from './CampaignAssets';
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
  name: string;

  map_name: string;
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
  icons?: string[];
  mission_icons?: string[];
};

export const CampaignMenu = (props, context) => {
  const { act, data } = useBackend<CampaignData>(context);
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    TAB_OVERVIEW
  );

  const [selectedAsset, setSelectedAsset] = useLocalState<FactionReward | null>(
    context,
    'selectedAsset',
    null
  );
  const [purchasedAsset, setPurchasedAsset] =
    useLocalState<FactionReward | null>(context, 'purchasedAsset', null);
  const [selectedNewMission, setSelectedNewMission] =
    useLocalState<MissionData | null>(context, 'selectedNewMission', null);

  return (
    <Window
      theme={data.ui_theme}
      title={data.faction + ' Mission Control'}
      width={700}
      height={600}>
      <Window.Content>
        {selectedAsset ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Activate ' + selectedAsset.name + '?'}>
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
                    color="green">
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setSelectedAsset(null)}
                    icon={'times'}
                    color="red">
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
              title={'Purchase ' + purchasedAsset.name + '?'}>
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
                    color="green">
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setPurchasedAsset(null)}
                    icon={'times'}
                    color="red">
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
              title={'Select ' + selectedNewMission.name + '?'}>
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
                    color="green">
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setSelectedNewMission(null)}
                    icon={'times'}
                    color="red">
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
    case TAB_PURCHASABLE_ASSETS:
      return <CampaignPurchase />;
    default:
      return null;
  }
};

/** Generates a small icon for buttons based on ICONMAP */
export const AssetIcon = (
  props: {
    icon: FactionReward['icon'];
    icon_width?: string;
    icon_height?: string;
  },
  context
) => {
  const { data } = useBackend<CampaignData>(context);
  const { icons = [] } = data;
  const { icon, icon_width, icon_height } = props;
  if (!icon || !icons[icon]) {
    return null;
  }

  return (
    <Box
      width={icon_width ? icon_width : '18px'}
      height={icon_height ? icon_height : '18px'}
      as="img"
      mr={1.5}
      src={`data:image/jpeg;base64,${icons[icon]}`}
      style={{
        transform: 'scale(1)',
        '-ms-interpolation-mode': 'nearest-neighbor',
      }}
    />
  );
};

/** Generates a small icon for buttons based on ICONMAP for missions */
export const MissionIcon = (
  props: {
    icon: MissionData['mission_icon'];
    icon_width?: string;
    icon_height?: string;
  },
  context
) => {
  const { data } = useBackend<CampaignData>(context);
  const { mission_icons = [] } = data;
  const { icon, icon_width, icon_height } = props;
  if (!icon || !mission_icons[icon]) {
    return null;
  }

  return (
    <Box
      width={icon_width ? icon_width : '24px'}
      height={icon_height ? icon_height : '24px'}
      as="img"
      mr={1.5}
      src={`data:image/jpeg;base64,${mission_icons[icon]}`}
      style={{
        transform: 'scale(1)',
        '-ms-interpolation-mode': 'nearest-neighbor',
      }}
    />
  );
};
