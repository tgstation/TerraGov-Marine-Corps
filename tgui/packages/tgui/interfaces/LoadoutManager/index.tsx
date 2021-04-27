import { useBackend, useLocalState } from "../../backend";
import { Stack, Button, Section, LabeledList, Divider, Tabs, Box } from "../../components";
import { Window } from "../../layouts";
import { Loadout, LoadoutViewerData, LoadoutListData, LoadoutTabData, LoadoutManagerData } from './Types';
import { NameInputModal } from './NameInputModal';
import { LoadoutViewer } from './LoadoutViewer';

const LoadoutItem = (props : LoadoutViewerData, context) => { 
  const { act } = useBackend(context);
  const {
    loadout,
    setLoadoutViewer,
  } = props;

  return (
    <LabeledList.Item
      labelColor="white"
      label={loadout.name}>
      <Button
        onClick={() => {
          act('selectLoadout', { loadout_name: loadout.name, loadout_job: loadout.job });
          setLoadoutViewer(true);
        }}>
        Select Loadout
      </Button>
    </LabeledList.Item>
  );
};

const LoadoutList = (props : LoadoutListData, context) => {
  const { loadout_list, setLoadoutViewer } = props;
  return (
    <Stack.Item>
      <Section height={16} fill scrollable>
        <LabeledList>
          {loadout_list
            .map(loadout_visible => {
              return (
                <LoadoutItem 
                  key={loadout_visible.name}
                  loadout={loadout_visible} 
                  setLoadoutViewer={setLoadoutViewer} />
              );
            })}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const JobTabs = (props : LoadoutTabData, context) => {
  const { job, setJob } = props;
  return (
    <Section>
      <Tabs>
        <Tabs.Tab selected={job === "marine"} onClick={() => setJob("marine")}>
          Marine
        </Tabs.Tab>
        <Tabs.Tab selected={job === "engineer"} onClick={() => setJob("engineer")}>
          Engineer
        </Tabs.Tab>
        <Tabs.Tab selected={job === "medic"} onClick={() => setJob("medic")}>
          Medic
        </Tabs.Tab>
        <Tabs.Tab selected={job === "smartgunner"} onClick={() => setJob("smartgunner")}>
          SmartGunner
        </Tabs.Tab>
        <Tabs.Tab selected={job === "leader"} onClick={() => setJob("leader")}>
          Squad Leader
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};

export const LoadoutManager = (props, context) => {
  const { act, data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list, current_loadout } = data;

  const [
    job,
    setJob,
  ] = useLocalState(context, 'job', "marine");
  const [
    saveNewLoadout,
    setSaveNewLoadout,
  ] = useLocalState(context, 'newLoadout', false);
  const [
    loadoutViewerOpened,
    setLoadoutViewerOpened,
  ] = useLocalState(context, 'loadoutViewer', false);

  return ( 
    <Window 
      title="Loadout Manager"
      width={600} 
      height={400}>
      <Window.Content>
        <Stack vertical>
          <JobTabs job={job} setJob={setJob} />
          <LoadoutList 
            loadout_list={loadout_list} 
            job={job} 
            setLoadoutViewer={setLoadoutViewerOpened}
          />
          <Button
            onClick={() => setSaveNewLoadout(true)}>
            Save your equiped loadout
          </Button>
          {
            saveNewLoadout
            && <NameInputModal
              label="Name of the new Loadout"
              button_text="Save"
              onBack={() => setSaveNewLoadout(false)}
              onSubmit={name => {
                act("saveLoadout", {
                  loadout_job: job,
                  loadout_name: name,
                });
                setSaveNewLoadout(false);
              }}
            />
          }
          {
            loadoutViewerOpened
            && <LoadoutViewer 
              loadout={current_loadout} 
              setLoadoutViewer={setLoadoutViewerOpened}
            />
          }
        </Stack>
      </Window.Content>
    </Window>
  );
};
