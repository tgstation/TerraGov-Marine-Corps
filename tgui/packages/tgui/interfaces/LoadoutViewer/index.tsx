import { Button, Flex, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Loadout } from '../LoadoutManager/Types';
import { SlotSelector } from './Slots';
import { LoadoutViewerData } from './Types';

const LoadoutNavigator = (props: Loadout) => {
  const { act } = useBackend();
  const { name, job } = props;

  return (
    <Section title="Loadout Navigator" textAlign="center">
      <Flex>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
        <Flex.Item>
          <Button
            onClick={() => {
              act('equipLoadout');
            }}
          >
            Equip Loadout
          </Button>
        </Flex.Item>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
        <Flex.Item>
          <Button.Confirm
            onClick={() => {
              act('overwriteLoadout');
            }}
          >
            Overwrite Loadout
          </Button.Confirm>
        </Flex.Item>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
        <Flex.Item>
          <Button.Confirm
            onClick={() => {
              act('deleteLoadout');
            }}
          >
            Delete Loadout
          </Button.Confirm>
        </Flex.Item>
        <Flex.Item grow={1}>
          <div> </div>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const LoadoutViewer = (props) => {
  const { data } = useBackend<LoadoutViewerData>();

  const { loadout, items } = data;

  return (
    <Window title="Loadout Viewer" width={400} height={460}>
      <Window.Content>
        <Stack fill vertical>
          <SlotSelector items={items} />
          <LoadoutNavigator name={loadout.name} job={loadout.job} />
        </Stack>
      </Window.Content>
    </Window>
  );
};
