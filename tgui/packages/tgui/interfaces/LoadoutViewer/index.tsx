import { useBackend } from "../../backend";
import { Window } from "../../layouts";
import { Button, Section, Stack } from "../../components";
import { SlotSelector } from './Slots';
import { Loadout } from '../LoadoutManager/Types';
import { LoadoutViewerData } from "./Types";

const LoadoutNavigator = (props: Loadout, context) => {
  const { act } = useBackend(context);
  const {
    name,
    job,
  }= props;

  return (
    <Section title="Loadout Navigator">
      <Stack fill horizontal>
        <Button
          onClick={() => { 
            act('equipLoadout', { loadout_name: name, loadout_job: job });
          }}>
          Equip Loadout
        </Button>
        <Button
          onClick={() => {
            act('deleteLoadout', { loadout_name: name, loadout_job: job });
          }}>
          Delete Loadout
        </Button>
      </Stack>
    </Section>
  );
};

export const LoadoutViewer = (props, context) => {
  const { data } = useBackend<LoadoutViewerData>(context);
  
  const {
    loadout,
    items,
  }= data;

  return (
    <Window 
      title="Loadout Viewer"
      width={260} 
      height={460}>
      <Window.Content>
        <Stack fill vertical>
          <SlotSelector 
            items={items}
          />
          <LoadoutNavigator
            name={loadout.name}
            job={loadout.job} 
          /> 
        </Stack>
      </Window.Content>
    </Window>
  );
};
