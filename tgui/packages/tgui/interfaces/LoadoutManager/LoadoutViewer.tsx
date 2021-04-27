import { useBackend } from "../../backend";
import { Window } from "../../layouts";
import { Button, Section, Stack } from "../../components";
import { SlotSelector } from './Slots';
import { LoadoutViewerData } from './Types';

const LoadoutNavigator = (props: LoadoutViewerData, context) => {
  const { act } = useBackend(context);
  const {
    setLoadoutViewer,
    loadout,
  }= props;

  return (
    <Section title="Loadout Navigator">
      <Stack fill horizontal>
        <Button
          onClick={() => { 
            act('equipeLoadout', { loadout_name: loadout.name, loadout_job: loadout.job });
          }}>
          Equip Loadout
        </Button>
        <Button
          onClick={() => {
            act('deleteLoadout', { loadout_name: loadout.name, loadout_job: loadout.job });
          }}>
          Delete Loadout
        </Button>
        <Button
          onClick={() => {
            setLoadoutViewer(false); 
          }}>
          Close Loadout Viewer
        </Button>
      </Stack>
    </Section>
  );
};

export const LoadoutViewer = (context) => {
  const { act, data } = useBackend<LoadoutSlotData>(context);
  return (
    <Window 
      title="Loadout Maker"
      width={900} 
      height={600}>
      <Window.Content>
        <Stack fill vertical>
          <SlotSelector />
          <LoadoutNavigator
            loadout={loadout} 
          /> 
        </Stack>
      </Window.Content>
    </Window>
  );
};
