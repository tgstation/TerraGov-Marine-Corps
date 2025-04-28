import { useBackend } from '../backend';
import {
  Button,
  Dropdown,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { Window } from '../layouts';

interface InputData {
  cockState: string;
  assState: string;
  boobState: string;
  possibleCockStates: string[];
  possibleAssStates: string[];
  possibleBoobStates: string[];
}

export const GenitalMenu = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>();
  const {
    cockState,
    assState,
    boobState,
    possibleCockStates,
    possibleAssStates,
    possibleBoobStates,
  } = data;

  return (
    <Window title="Genital selection" width={260} height={190}>
      <Window.Content style={{ 'background-image': 'none' }} />
      <Section>
        <Stack fill vertical>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Genitalia">
                <Dropdown
                  options={possibleCockStates}
                  selected={cockState ? 'Visible (new sprites)' : 'Default'}
                  onSelected={(e: string) =>
                    act('changeCock', {
                      newState: e,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Butt">
                <Dropdown
                  options={possibleAssStates}
                  selected={assState ? assState : 'Default'}
                  onSelected={(e: string) =>
                    act('changeAss', {
                      newState: e,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Boobs">
                <Stack.Item title="Boobs">
                  <Dropdown
                    options={possibleBoobStates}
                    selected={boobState ? boobState : 'Default'}
                    onSelected={(e: string) =>
                      act('changeBoobs', {
                        newState: e,
                      })
                    }
                  />
                </Stack.Item>
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              bold
              color="bad"
              icon="ban"
              fontSize={1.25}
              textAlign="center"
              onClick={() => {
                act('reset');
              }}
            >
              Reset to default
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Window>
  );
};
