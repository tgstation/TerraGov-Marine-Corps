import {
  Box,
  Button,
  Collapsible,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Vote = (props) => {
  const { data } = useBackend();
  const { mode, question, lower_admin } = data;

  // Adds the voting type to title if there is an ongoing vote
  let windowTitle = 'Vote';
  if (mode) {
    windowTitle +=
      ': ' + (question || mode).replace(/^\w/, (c) => c.toUpperCase());
  }

  return (
    <Window title={windowTitle} width={400} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {!!lower_admin && (
            <Section title="Admin Options">
              <VoteOptions />
              <VotersList />
            </Section>
          )}
          <Section title="Start Voting">
            <StartVoteOptions />
          </Section>
          <ChoicesPanel />
          <TimePanel />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StartVoteOptions = (props) => {
  const { act, data } = useBackend();
  const {
    allow_vote_mode,
    allow_vote_restart,
    allow_vote_groundmap,
    allow_vote_shipmap,
    vote_happening,
  } = data;
  return (
    <Stack.Item>
      <Collapsible title="Start a vote">
        <Stack justify="space-between">
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                <Button
                  disabled={vote_happening || !allow_vote_groundmap}
                  onClick={() => act('groundmap')}
                >
                  Ground Map
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={vote_happening || !allow_vote_shipmap}
                  onClick={() => act('shipmap')}
                >
                  Ship Map
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={vote_happening || !allow_vote_restart}
                  onClick={() => act('restart')}
                >
                  Restart
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={vote_happening || !allow_vote_mode}
                  onClick={() => act('gamemode')}
                >
                  Gamemode
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Collapsible>
    </Stack.Item>
  );
};

// Gives access to starting votes
const VoteOptions = (props) => {
  const { act, data } = useBackend();
  const {
    allow_vote_mode,
    allow_vote_restart,
    allow_vote_groundmap,
    allow_vote_shipmap,
    upper_admin,
  } = data;

  return (
    <Stack.Item>
      <Collapsible title="Allow Votes">
        <Stack justify="space-between">
          <Stack.Item>
            <Stack vertical>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_groundmap ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_groundmap}
                    onClick={() => act('toggle_groundmap')}
                  >
                    Groundmap vote{' '}
                    {allow_vote_groundmap ? 'Enabled' : 'Disabled'}
                  </Button.Checkbox>
                )}
              </Stack.Item>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_shipmap ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_shipmap}
                    onClick={() => act('toggle_shipmap')}
                  >
                    Shipmap vote {allow_vote_shipmap ? 'Enabled' : 'Disabled'}
                  </Button.Checkbox>
                )}
              </Stack.Item>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_restart ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_restart}
                    onClick={() => act('toggle_restart')}
                  >
                    Restart vote {allow_vote_restart ? 'Enabled' : 'Disabled'}
                  </Button.Checkbox>
                )}
              </Stack.Item>
              <Stack.Item>
                {!!upper_admin && (
                  <Button.Checkbox
                    mr={!allow_vote_mode ? 1 : 1.6}
                    color="red"
                    checked={!!allow_vote_mode}
                    onClick={() => act('toggle_gamemode')}
                  >
                    Gamemode vote {allow_vote_mode ? 'Enabled' : 'Disabled'}
                  </Button.Checkbox>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button disabled={!upper_admin} onClick={() => act('custom')}>
              Create Custom Vote
            </Button>
          </Stack.Item>
        </Stack>
      </Collapsible>
    </Stack.Item>
  );
};

// Table to view voters by ckey
const VotersList = (props) => {
  const { data } = useBackend();
  const { voting } = data;

  return (
    <Stack.Item>
      <Collapsible title={`View Voters: ${voting.length}`}>
        <Section height={8} fill scrollable>
          {voting.map((voter) => {
            return <Box key={voter}>{voter}</Box>;
          })}
        </Section>
      </Collapsible>
    </Stack.Item>
  );
};

// Display choices
const ChoicesPanel = (props) => {
  const { act, data } = useBackend();
  const { choices, selected_choice, vote_counts } = data;

  return (
    <Stack.Item grow>
      <Section fill scrollable title="Choices">
        {choices.length !== 0 ? (
          <LabeledList>
            {choices.map((choice, i) => (
              <Box key={choice.num_index}>
                <LabeledList.Item
                  label={choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                  textAlign="right"
                  buttons={
                    <Button
                      color={
                        selected_choice.includes(choice.num_index)
                          ? 'green'
                          : 'orange'
                      }
                      onClick={() => {
                        act('vote', { index: choice.num_index });
                      }}
                    >
                      Vote
                    </Button>
                  }
                >
                  {selected_choice.includes(choice.num_index) && (
                    <Icon
                      alignSelf="right"
                      mr={2}
                      color="green"
                      name="vote-yea"
                    />
                  )}
                  {vote_counts[choice.num_index - 1]} Votes
                </LabeledList.Item>
                <LabeledList.Divider />
              </Box>
            ))}
          </LabeledList>
        ) : (
          <NoticeBox>No choices available!</NoticeBox>
        )}
      </Section>
    </Stack.Item>
  );
};

// Countdown timer at the bottom. Includes a cancel vote option for admins
const TimePanel = (props) => {
  const { act, data } = useBackend();
  const { upper_admin, time_remaining } = data;

  return (
    <Stack.Item mt={1}>
      <Section>
        <Stack justify="space-between">
          <Box fontSize={1.5}>Time Remaining: {time_remaining || 0}s</Box>
          {!!upper_admin && (
            <Button color="red" onClick={() => act('cancel')}>
              Cancel Vote
            </Button>
          )}
        </Stack>
      </Section>
    </Stack.Item>
  );
};
