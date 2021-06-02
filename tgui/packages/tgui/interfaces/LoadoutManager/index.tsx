import { useBackend, useLocalState } from "../../backend";
import { Stack, Button, Section, LabeledList, Tabs, Box, Flex } from "../../components";
import { Window } from "../../layouts";
import { LoadoutListData, LoadoutTabData, LoadoutManagerData, LoadoutItemData } from './Types';
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
            act('selectLoadout', { loadout_name: loadout.name, loadout_job: loadout.job });
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
  const { loadout_list } = props;
  return (
    <Stack.Item>
      <Section height={23} fill scrollable>
        <LabeledList>
          {loadout_list
            .map(loadout_visible => {
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

const JobTabs = (props: LoadoutTabData) => {
  const { job, setJob } = props;
  return (
    <Section>
      <Flex>
        <Flex.Item grow={1}><div> </div></Flex.Item>
        <Flex.Item>
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
        </Flex.Item>
        <Flex.Item grow={1}><div> </div></Flex.Item>
      </Flex>
    </Section>
  );
};

export const LoadoutManager = (props, context) => {
  const { act, data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list } = data;

  const [
    job,
    setJob,
  ] = useLocalState(context, 'job', "marine");
  const [
    saveNewLoadout,
    setSaveNewLoadout,
  ] = useLocalState(context, 'newLoadout', false);

  return ( 
    <Window 
      title="Loadout Manager"
      width={400} 
      height={400}>
      <Window.Content>
        <Stack vertical>
          <JobTabs job={job} setJob={setJob} />
          <LoadoutList 
            loadout_list={loadout_list.filter(loadout => loadout.job === job)} 
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
                  loadout_job: job,
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
