import { Box, Button, Flex, Image, Section } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type DropshipEntry = {
  name: string;
  description: string;
  ref: string;
};

type DropshipPickerData = {
  name: string;
  desc: string;
  assetpath: string;
  current_ref: string;
  dropship_selected: boolean;
  shuttles: DropshipEntry[];
};

export const DropshipPicker = (_props) => {
  const { act, data } = useBackend<DropshipPickerData>();

  return (
    <Window width={510} height={500} title={'Dropship Selector'}>
      <Window.Content>
        <Flex height={'95%'} direction={'row'}>
          <Flex.Item width={'45%'}>
            <ShuttleSelection />
          </Flex.Item>
          <Flex.Item width={'55%'} height={'35%'}>
            <Image
              src={data.assetpath ? resolveAsset(data.assetpath) : ''}
              height={'284px'}
            />
            <Section
              title={'Description - ' + (data.name ? data.name : 'None')}
              fill
            >
              <Box>{data.desc !== null ? data.desc : 'Pick a ship!'}</Box>
            </Section>
          </Flex.Item>
        </Flex>
        <Button
          color={'bad'}
          width={'100%'}
          disabled={data.current_ref === null}
          onClick={() => act('confirm')}
        >
          {'CONFIRM SELECTION'}
        </Button>
      </Window.Content>
    </Window>
  );
};

const ShuttleSelection = (props) => {
  const { act, data } = useBackend<DropshipPickerData>();

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
