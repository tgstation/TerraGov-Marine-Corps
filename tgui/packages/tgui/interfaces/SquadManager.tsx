import { useState } from 'react';
import { Box, Button, Dropdown, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SquadManagerData = {
  active_squads?: SquadData[];
  valid_colors: string[];
};

type SquadData = {
  name: string;
  leader: string;
  color: string;
};

export const SquadManager = (props) => {
  const { act, data } = useBackend<SquadManagerData>();
  const { active_squads, valid_colors } = data;
  const [squadName, setSquadName] = useState('New Squad');
  const [squadColor, setSquadColor] = useState(valid_colors[0]);
  const [squadDesc, setSquadDesc] = useState('No description set.');

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
                    width={'90px'}
                  >
                    {squad.name}
                    <Box>{squad.leader}</Box>
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
                      expensive
                      placeholder={'New name'}
                      onChange={setSquadName}
                      width="180px"
                      height="20px"
                    >
                      {squadName}
                    </TextArea>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() =>
                        act('create_squad', {
                          name: squadName,
                          color: squadColor,
                          desc: squadDesc,
                        })
                      }
                    >
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
                  expensive
                  placeholder="Set Description for squad"
                  onChange={setSquadDesc}
                  width="180px"
                  height="200px"
                >
                  {squadDesc}
                </TextArea>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
