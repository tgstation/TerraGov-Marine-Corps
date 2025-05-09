import { useBackend } from '../../backend';
import { Flex, Section, Tabs } from '../../components';
import { Window } from '../../layouts';
import { BackgroundInformation } from './BackgroundInformation';
import { CharacterCustomization } from './CharacterCustomization';
import { DrawOrder } from './DrawOrder';
import { SelectFieldPreference } from './FieldPreferences';
import { GameSettings } from './GameSettings';
import { GearCustomization } from './GearCustomisation';
import { JobPreferences } from './JobPreferences';
import { KeybindSettings } from './KeybindSettings';

export const PlayerPreferences = (props) => {
  const { act, data } = useBackend<PlayerPreferencesData>();

  const { slot, tabIndex } = data;

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
    case 7:
      CurrentTab = DrawOrder;
      break;
    default:
  }

  return (
    <Window width={1140} height={650}>
      <Window.Content scrollable>
        <Flex>
          <Flex.Item>
            <NavigationSelector tabIndex={tabIndex} />
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            {affectsSave ? (
              <Section>
                <SelectFieldPreference
                  label={'Save slot'}
                  value={'slot'}
                  action={'changeslot'}
                />
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

const NavigationSelector = (props) => {
  const { tabIndex } = props;
  const { act } = useBackend();
  return (
    <Tabs vertical>
      <Tabs.Tab
        selected={tabIndex === 1}
        onClick={() => act('tab_change', { tabIndex: 1 })}
      >
        Character Customization
      </Tabs.Tab>
      <Tabs.Tab
        selected={tabIndex === 2}
        onClick={() => act('tab_change', { tabIndex: 2 })}
      >
        Background Information
      </Tabs.Tab>
      <Tabs.Tab
        selected={tabIndex === 3}
        onClick={() => act('tab_change', { tabIndex: 3 })}
      >
        Gear Customization
      </Tabs.Tab>
      <Tabs.Tab
        selected={tabIndex === 4}
        onClick={() => act('tab_change', { tabIndex: 4 })}
      >
        Job Preferences
      </Tabs.Tab>
      <Tabs.Tab
        selected={tabIndex === 5}
        onClick={() => act('tab_change', { tabIndex: 5 })}
      >
        Game Settings
      </Tabs.Tab>
      <Tabs.Tab
        selected={tabIndex === 6}
        onClick={() => act('tab_change', { tabIndex: 6 })}
      >
        Keybindings
      </Tabs.Tab>
      <Tabs.Tab
        selected={tabIndex === 7}
        onClick={() => act('tab_change', { tabIndex: 7 })}
      >
        Draw Order
      </Tabs.Tab>
    </Tabs>
  );
};
