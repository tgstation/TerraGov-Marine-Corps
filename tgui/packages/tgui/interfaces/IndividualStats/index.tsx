import {
  Button,
  LabeledList,
  Modal,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
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
  requirements?: string;
  cost: number;
  icon?: string;
  currently_active: number;
  is_debuff?: number;
};

export type IndividualData = {
  ui_theme: string;
  perks_data: PerkData[];
  currency: number;
  current_job?: string;
  faction: string;
  jobs: string[];
  perk_icons?: string[];
  equipped_loadouts_data: EquippedItemData[];
  available_loadouts_data: LoadoutItemData[];
  outfit_cost_data: OutfitCostData[];
};

export type OutfitCostData = {
  job: string;
  outfit_cost: number;
};

export type EquippedItemData = {
  slot: string;
  slot_text: string;
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
  quantity: number;
  requirements?: string;
  unlocked: number;
};

export const IndividualStats = (props) => {
  const { act, data } = useBackend<IndividualData>();
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    TAB_LOADOUT,
  );
  const [selectedJob, setSelectedJob] = useLocalState(
    'selectedJob',
    data.current_job ? data.current_job : data.jobs[0],
  );

  const [unlockedPerk, setPurchasedPerk] = useLocalState<PerkData | null>(
    'unlockedPerk',
    null,
  );

  const [equipOutfit, setEquippedOutfit] = useLocalState<OutfitCostData | null>(
    'equipOutfit',
    null,
  );

  const [unlockPotentialItem, setUnlockedItem] =
    useLocalState<LoadoutItemData | null>('unlockPotentialItem', null);

  return (
    <Window
      theme={data.ui_theme}
      title={'Prep screen'}
      width={980}
      height={790}
    >
      <Window.Content overflowY="auto">
        {unlockedPerk ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Purchase ' + unlockedPerk.name + '?'}
            >
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
                    color="green"
                  >
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setPurchasedPerk(null)}
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
        {equipOutfit ? (
          <Modal width="500px">
            <Section textAlign="center" title={'Equip loadout?'}>
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('equip_outfit', {
                        outfit_job: equipOutfit.job,
                      });
                      setEquippedOutfit(null);
                    }}
                    icon={'check'}
                    color="green"
                  >
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setEquippedOutfit(null)}
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
        {unlockPotentialItem ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={
                'Unlock ' +
                unlockPotentialItem.name +
                ' for ' +
                unlockPotentialItem.unlock_cost +
                ' credits?'
              }
            >
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('unlock_item', {
                        unlocked_item: unlockPotentialItem.type,
                        selected_job: unlockPotentialItem.job,
                      });
                      unlockPotentialItem.unlocked = 1;
                      setUnlockedItem(null);
                    }}
                    icon={'check'}
                    color="green"
                  >
                    Yes
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => setUnlockedItem(null)}
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
          {data.jobs.map((jobname) => {
            return (
              <Tabs.Tab
                key={jobname}
                selected={jobname === selectedJob}
                fontSize="130%"
                textAlign="center"
                onClick={() => {
                  act('set_selected_job', {
                    new_selected_job: jobname,
                  });
                  setSelectedJob(jobname);
                }}
              >
                {jobname}
              </Tabs.Tab>
            );
          })}
        </Tabs>
        <Stack fontSize="150%">
          <LabeledList>
            <LabeledList.Item label={'Credits'}>
              {data.currency}
            </LabeledList.Item>
          </LabeledList>
        </Stack>
        <Tabs fluid>
          {CampaignTabs.map((tabname) => {
            return (
              <Tabs.Tab
                key={tabname}
                selected={tabname === selectedTab}
                fontSize="130%"
                textAlign="center"
                onClick={() => {
                  act('set_selected_tab', {
                    new_selected_tab: tabname,
                  });
                  setSelectedTab(tabname);
                }}
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
    TAB_LOADOUT,
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
