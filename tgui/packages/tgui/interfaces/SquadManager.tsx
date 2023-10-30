import { Stack, Box, Button, TextArea, Dropdown } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

type SquadManagerData = {
  active_squads?: SquadData[];
  valid_colors: string[];
};

type SquadData = {
  name: string;
  leader: string;
  color: string;
};

export const SquadManager = (props, context) => {
  const { act, data } = useBackend<SquadManagerData>(context);
  const { active_squads, valid_colors } = data;
  const [squadName, setSquadName] = useLocalState<string>(
    context,
    'squadName',
    'New Squad'
  );
  const [squadColor, setSquadColor] = useLocalState<string>(
    context,
    'squadColor',
    valid_colors[0]
  );

  const [squadDesc, setSquadDesc] = useLocalState<string>(
    context,
    'squadDesc',
    'No description set.'
  );

  return (
    <Window width={350} height={320}>
      <Window.Content>
        <Stack>
          <Stack.Item>
            <Stack vertical>
              {active_squads?.map((squad) => (
                <Stack.Item key={squad.name}>
                  <Box
                    backgroundColor={squad.color}
                    height={'120%'}
                    pt={0.5}
                    pl={1}
                    width={'90px'}>
                    {squad.name}
                    <Box contents={squad.leader} />
                  </Box>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <TextArea
                      autoFocus
                      content={squadName}
                      placeholder={'New name'}
                      onChange={(e, value) => setSquadName(value)}
                      width="180px"
                      height="20px"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() =>
                        act('create_squad', {
                          name: squadName,
                          color: squadColor,
                          desc: squadDesc,
                        })
                      }>
                      Create
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <Dropdown
                      width={'180px'}
                      selected={squadColor}
                      options={Object.keys(valid_colors)}
                      onSelected={(e) => setSquadColor(e)}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Box
                      backgroundColor={squadColor}
                      width="50px"
                      height="20px"
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <TextArea
                  fluid
                  content={squadDesc}
                  placeholder="Set Description for squad"
                  onChange={(e, value) => setSquadDesc(value)}
                  width="180px"
                  height="200px"
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
