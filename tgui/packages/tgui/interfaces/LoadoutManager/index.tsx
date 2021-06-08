import { useBackend, useLocalState } from "../../backend";
import { Stack, Button, Section, LabeledList } from "../../components";
import { Window } from "../../layouts";
import { LoadoutListData, LoadoutManagerData, LoadoutItemData } from './Types';
import { NameInputModal } from './NameInputModal';

const LoadoutItem = (props : LoadoutItemData, context) => { 
  const { act } = useBackend(context);
  const {
    loadout,
  } = props;

  return (
    <LabeledList.Item
      labelColor="white"
      buttons={
        <Button
          onClick={() => {
            act('selectLoadout', { loadout_name: loadout.name });
          }}>
          Select Loadout
        </Button>
      }
      label={loadout.name}>
      <div> </div>
    </LabeledList.Item>
  );
};

const LoadoutList = (props: LoadoutListData) => {
  const { 
    loadout_list,
    job,
    } = props;
  return (
    <Stack.Item>
      <Section height={23} fill scrollable>
        <LabeledList>
          {loadout_list
            .filter(loadout => loadout.job == job).map(loadout_visible => {
              return (
                <LoadoutItem 
                  key={loadout_visible.name}
                  loadout={loadout_visible} />
              );
            })}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

export const LoadoutManager = (props, context) => {
  const { act, data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list, job } = data;

  const [
    saveNewLoadout,
    setSaveNewLoadout,
  ] = useLocalState(context, 'newLoadout', false);

  return ( 
    <Window 
      title="Loadout Manager"
      width={500} 
      height={340}>
      <Window.Content>
        <Stack vertical>
          <LoadoutList 
            loadout_list={loadout_list} 
            job={job}
          />
          <Button
            onClick={() => setSaveNewLoadout(true)}>
            Save your equipped loadout
          </Button>
          {
            saveNewLoadout
            && <NameInputModal
              label="Name of the new Loadout"
              button_text="Save"
              onBack={() => setSaveNewLoadout(false)}
              onSubmit={name => {
                act("saveLoadout", {
                  loadout_name: name,
                });
                setSaveNewLoadout(false);
              }}
            />
          }
        </Stack>
      </Window.Content>
    </Window>
  );
};
