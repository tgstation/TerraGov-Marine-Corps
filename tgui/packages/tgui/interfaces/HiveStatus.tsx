import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Flex, Divider, Collapsible, Icon, Table, Box, ProgressBar } from '../components';
import { classes } from 'common/react';

type HiveData = {
  name: string,
}

type StatusData = {
  hive_info: HiveData
}

export const HiveStatus = (props, context) => {
  const { data } = useBackend<StatusData>(context);
  const { hive_info } = data;

  return (
    <Window
      title={hive_info.name + " Hive Status"}
      resizable
      width={700}
      height={800}
    >
      <Window.Content scrollable>
        <Collapsible title = "Caste Population Pyramid" open>
        </Collapsible>
        <Divider />
      </Window.Content>
    </Window>
  );
};
