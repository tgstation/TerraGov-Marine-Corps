import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { Box, Modal, Tabs, Button, Stack, Section } from '../../components';
import { IndividualLoadouts } from './IndividualLoadouts';
import { IndividualPerks } from './IndividualPerks';

const TAB_LOADOUT = 'Loadout';
const TAB_PERKS = 'Perks';

const CampaignTabs = [TAB_LOADOUT, TAB_PERKS];

export type PerkData = {
  name: string;
  job: string;
  type: string;
  desc: string;
  cost: number;
  icon?: string;
  currently_active: number;
  is_debuff?: number;
};

export type IndividualData = {
  ui_theme: string;
  perks_data: PerkData[];
  currency: number;
  faction: string;
  jobs: string[];
  icons?: string[];
  mission_icons?: string[];
  equipped_loadouts_data: EquippedItemData[];
  available_loadouts_data: LoadoutItemData[];
  outfit_slots: string[];
};

export type EquippedItemData = {
  slot: string;
  item_type: LoadoutItemData;
};

export type LoadoutItemData = {
  name: string;
  job: string;
  slot: string;
  type: string;
  desc: string;
  purchase_cost: number;
  unlock_cost: number;
  valid_choice: number;
  icon?: string;
};

export const IndividualStats = (props) => {
  const { act, data } = useBackend<IndividualData>();
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    TAB_LOADOUT
  );
  const [selectedJob, setSelectedJob] = useLocalState(
    'selectedJob',
    data.jobs[0]
  );

  const [unlockedPerk, setPurchasedPerk] = useLocalState<PerkData | null>(
    'unlockedPerk',
    null
  );

  return (
    <Window
      theme={data.ui_theme}
      title={'Prep screen'}
      width={700}
      height={600}>
      <Window.Content>
        {unlockedPerk ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Purchase ' + unlockedPerk.name + '?'}>
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('unlock_perk', {
                        selected_perk: unlockedPerk.type,
                      });
                      setPurchasedPerk(null);
                    }}
                    icon={'check'}
                    color="green">
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setPurchasedPerk(null)}
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
          {data.jobs.map((jobname) => {
            return (
              <Tabs.Tab
                key={jobname}
                selected={jobname === selectedJob}
                fontSize="130%"
                textAlign="center"
                onClick={() => setSelectedJob(jobname)}>
                {jobname}
              </Tabs.Tab>
            );
          })}
        </Tabs>
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

const CampaignContent = (props) => {
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    TAB_LOADOUT
  );
  switch (selectedTab) {
    case TAB_LOADOUT:
      return <IndividualLoadouts />;
    case TAB_PERKS:
      return <IndividualPerks />;
    default:
      return null;
  }
};

/** Generates a small icon for buttons based on ICONMAP */
export const PerkIcon = (props: {
  icon: PerkData['icon'];
  icon_width?: string;
  icon_height?: string;
}) => {
  const { data } = useBackend<IndividualData>();
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
