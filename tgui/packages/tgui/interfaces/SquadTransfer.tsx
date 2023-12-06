import { Stack, Button, Section } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

type SquadSelectorData = {
  active_squads?: SquadEntry[];
  active_requests?: string[];
};

type SquadEntry = {
  name: string;
  id: string;
  color: string;
  members?: string[];
};

export const SquadTransfer = (props, context) => {
  const { act, data } = useBackend<SquadSelectorData>(context);
  const { active_squads } = data;
  const [selectedSquad, setSelectedSquad] = useLocalState<string>(
    context,
    'selectedSquad',
    ''
  );

  const [selectedMember, setSelectedMember] = useLocalState<string>(
    context,
    'selectedMember',
    ''
  );

  const selectedSquadEntry = active_squads?.find(
    (i) => i.name === selectedSquad
  );

  return (
    <Window width={380} height={360}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Section title={'Transfer from'} width={'120px'}>
              <Stack vertical>
                {active_squads?.map((squad) => (
                  <Stack.Item key={squad.name}>
                    <Button
                      width={'110px'}
                      onClick={() => setSelectedSquad(squad.name)}
                      backgroundColor={
                        selectedSquad === squad.name ? null : squad.color
                      }
                      selected={selectedSquad === squad.name}>
                      {squad.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={'Transfered'} width={'120px'}>
              <Stack vertical>
                {selectedSquadEntry?.members
                  ? Object.keys(selectedSquadEntry.members).map((name) => (
                    <Stack.Item key={name}>
                      <Button
                        width={'110px'}
                        onClick={() => setSelectedMember(name)}
                        selected={selectedMember === name}>
                        {name}
                      </Button>
                    </Stack.Item>
                  ))
                  : null}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={'Transfer to'} width={'120px'}>
              <Stack vertical>
                {active_squads?.map((squad) => (
                  <Stack.Item key={squad.name}>
                    <Button
                      width={'110px'}
                      onClick={() =>
                        act('transfer', {
                          transfer_target:
                            selectedSquadEntry?.members?.[selectedMember],
                          squad_id: squad?.id,
                        })
                      }
                      backgroundColor={
                        selectedSquad === squad.name ? null : squad.color
                      }
                      disabled={selectedSquad === squad.name}>
                      {squad.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
