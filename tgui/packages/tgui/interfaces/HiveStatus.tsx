import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Collapsible, Icon, Table, Box, ProgressBar } from '../components';
import { classes } from 'common/react';

type HiveData = {
  hive_name: string,
}

export const HiveStatus = (props, context) => {
  const { data } = useBackend<HiveData>(context);
  const { hive_name } = data;

  return (
    <Window
      title={hive_name + " Hive Status"}
      resizable
      width={700}
      height={800}
    >
      <Window.Content scrollable>
        <Collapsible title = "Caste Population Pyramid" open>
          <CasteCounts />
        </Collapsible>
        <Divider />
      </Window.Content>
    </Window>
  );
};
