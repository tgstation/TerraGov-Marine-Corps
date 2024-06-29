import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

type Shuttle = {
  name: string;
  description: string;
  ref: string;
};

type ShuttlePickerData = {
  name: string;
  desc: string;
  assetpath: string;
  current_ref: string;
  shuttles: Shuttle[];
};

export const ShuttlePicker = (_props) => {
  const { act, data } = useBackend<ShuttlePickerData>();

  return (
    <Window width={500} height={500} title={'Shuttle Selection'}>
      <Window.Content>
        <Flex height={'100%'} direction={'row'}>
          <Flex.Item width={'45%'}>
            <ShuttleSelection />
          </Flex.Item>
          <Flex.Item width={'55%'}>
            <Box // Wrap the entire right column in a Box to keep the layout consistent
              style={{
                display: 'flex',
                flexDirection: 'column',
                height: '100%',
                position: 'relative',
              }}
            >
              <Box
                height={
                  '200%' // Keep the image at about 80% the length of the window
                }
                textAlign={'center'}
              >
                <img
                  src={resolveAsset(data.assetpath)}
                  style={{ height: '100%' }} // This is so the preview image stays within the layout
                />
              </Box>
              <Section
                // Align the description and button within this column and show the name of the ship
                title={data.name ? data.name : 'None'}
                fill
              >
                {/* This Box displays the description of the selected ship */}
                <Box>{data.desc !== null ? data.desc : 'Pick a ship!'}</Box>
                <Box
                  // This Box serves to position the button at the bottom while keeping it centered within the second column
                  style={{
                    position: 'absolute',
                    bottom: '5%',
                    width: '100%',
                    textAlign: 'center',
                  }}
                >
                  <Button
                    color={'bad'}
                    title={'Are you certain?'}
                    disabled={data.current_ref === null}
                    onClick={() => act('confirm')}
                  >
                    {'Confirm Selection'}
                  </Button>
                </Box>
              </Section>
            </Box>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

// This component displays each shuttle in a list on the left side of the window
const ShuttleSelection = (props) => {
  const { act, data } = useBackend<ShuttlePickerData>();

  return (
    <Section title="Available Models" fill>
      {data.shuttles.map((shuttle) => (
        <Button
          key={shuttle.ref}
          selected={shuttle.ref === data.current_ref}
          width={'100%'}
          onClick={() => act('pickship', { ref: shuttle.ref })}
        >
          {shuttle.name}
        </Button>
      ))}
    </Section>
  );
};
