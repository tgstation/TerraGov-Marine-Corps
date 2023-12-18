import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { Box, Modal, Tabs, Button, Stack, Section } from '../../components';
import { CampaignOverview } from './CampaignOverview';
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
  currently_active?: number;
  is_debuff?: number;
};

export type IndividualData = {
  ui_theme: string;
  perks_data: PerkData[];
  currency: number;
  faction: string;
  icons?: string[];
  mission_icons?: string[];
};

export const CampaignMenu = (props, context) => {
  const { act, data } = useBackend<IndividualData>(context);
  const [selectedTab, setSelectedTab] = useLocalState(
    context,
    'selectedTab',
    TAB_LOADOUT
  );

  const [purchasedPerk, setPurchasedPerk] = useLocalState<PerkData | null>(
    context,
    'purchasedPerk',
    null
  );

  return (
    <Window
      theme={data.ui_theme}
      title={'Prep screen'}
      width={700}
      height={600}>
      <Window.Content>
        {purchasedPerk ? (
          <Modal width="500px">
            <Section
              textAlign="center"
              title={'Purchase ' + purchasedPerk.name + '?'}>
              <Stack justify="space-around">
                <Stack.Item>
                  <Button
                    onClick={() => {
                      act('unlock_perk', {
                        selected_perk: purchasedPerk.type,
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
    TAB_LOADOUT
  );
  switch (selectedTab) {
    case TAB_LOADOUT:
      return <IndividualPerks />;
    case TAB_PERKS:
      return <IndividualPerks />;
    default:
      return null;
  }
};

/** Generates a small icon for buttons based on ICONMAP */
export const PerkIcon = (
  props: {
    icon: PerkData['icon'];
    icon_width?: string;
    icon_height?: string;
  },
  context
) => {
  const { data } = useBackend<IndividualData>(context);
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
