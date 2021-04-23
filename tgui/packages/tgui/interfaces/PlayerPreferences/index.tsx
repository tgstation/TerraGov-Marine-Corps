import { useBackend, useLocalState } from '../../backend';
import { Button, Section, Flex, Tabs } from '../../components';
import { Window } from '../../layouts';
import { GearCustomization } from './GearCustomisation';
import { CharacterCustomization } from './CharacterCustomization';
import { JobPreferences } from './JobPreferences';
import { GameSettings } from './GameSettings';
import { KeybindSettings } from './KeybindSettings';
import { BackgroundInformation } from './BackgroundInformation';

export const PlayerPreferences = (props, context) => {
  const { act, data, config } = useBackend<PlayerPreferencesData>(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'selectedTabIndex', 1);

  const {
    save_slot_names,
    slot,
  } = data;

  let affectsSave = false;
  let CurrentTab = CharacterCustomization;
  switch (tabIndex) {
    case 1:
      CurrentTab = CharacterCustomization;
      affectsSave = true;
      break;
    case 2:
      CurrentTab = BackgroundInformation;
      affectsSave = true;
      break;
    case 3:
      CurrentTab = GearCustomization;
      affectsSave = true;
      break;
    case 4:
      CurrentTab = JobPreferences;
      affectsSave = true;
      break;
    case 5:
      CurrentTab = GameSettings;
      break;
    case 6:
      CurrentTab = KeybindSettings;
      break;
    default:
  }

  // I dont like this shit, but it doesn't matter in the end
  // i'd rather massage the data in js than byond.
  const slotNames = Object.values(save_slot_names).map(
    name => name.split(' ')[0]
  );

  const saveSlots = new Array(10).fill(1).map((_, idx) => (
    <Button
      key={idx + 1}
      selected={idx + 1 === slot}
      onClick={() => act('changeslot', { changeslot: idx + 1 })}>
      {slotNames[idx] || `Character ${idx + 1}`}
    </Button>
  ));

  return (
    <Window
      width={1140}
      height={650}>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item>
            <NavigationSelector tabIndex={tabIndex} onTabChange={setTabIndex} />
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            {affectsSave ? (
              <Section title="Save slot" buttons={saveSlots}>
                <CurrentTab />
              </Section>
            ) : (
              <CurrentTab />
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const NavigationSelector = (props, context) => {
  const { tabIndex, onTabChange } = props;
  return (
    <Tabs vertical>
      <Tabs.Tab selected={tabIndex === 1} onClick={() => onTabChange(1)}>
        Character Customization
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 2} onClick={() => onTabChange(2)}>
        Background Information
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 3} onClick={() => onTabChange(3)}>
        Gear Customization
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 4} onClick={() => onTabChange(4)}>
        Job Preferences
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 5} onClick={() => onTabChange(5)}>
        Game Settings
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 6} onClick={() => onTabChange(6)}>
        Keybindings
      </Tabs.Tab>
    </Tabs>
  );
};
