import { useBackend, useLocalState } from "../backend";
import { Stack, Button, Section, LabeledList, Divider, Tabs, Box } from "../components";
import { Window } from "../layouts";
import { createLogger } from "../logging";

type Loadout =
  {
    name: string,
    job: string,
  }


type LoadoutListData = 
  {
    loadout_list: Loadout[],
    job: string,
  }

type LoadoutManagerData = 
  {
    loadout_list: Loadout[],
  };

type TabData = 
  {
    job: string,
    setJob: any,
  }

const LoadoutItem = (props : Loadout, context) => { 
  const { act } = useBackend(context);
  const {
    job,
    name,
  } = props;

  return (
    <LabeledList.Item
      labelColor="white"
      label={name}>
      <Box>

      </Box>
      <Button
        onClick={() => act('SelectLoadout', { loadout_name: name, loadout_job: job })}>
        Sadness
      </Button>
    </LabeledList.Item>
  );
};

const LoadoutList = (props : LoadoutListData, context) => {
  const { loadout_list, job } = props;
  return (
    <Stack.Item>
      <Section height={8} fill scrollable>
        <LabeledList>
          {loadout_list
            .map(loadout_visible => {
              return (
                <LoadoutItem 
                  key={loadout_visible.name}
                  name={loadout_visible.name}
                  job={loadout_visible.job} />
              );
            })}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const JobTabs = (props : TabData, context) => {
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
  const { data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list } = data;

  const [
    job,
    setJob,
  ] = useLocalState(context, 'job', "marine");

  return ( 
    <Window 
      title="Loadout Manager"
      width={900} 
      height={600}>
      <Window.Content>
        <Stack fill vertical>
          <JobTabs job={job} setJob={setJob} />
          <LoadoutList loadout_list={loadout_list} job={job} /> 
        </Stack>
      </Window.Content>
    </Window>
  );
};
