import { useBackend, useLocalState } from "../backend";
import { Stack, Button, Section, LabeledList, Divider, Tabs } from "../components";
import { Window } from "../layouts";
import { createLogger } from "../logging";

type Loadout =
  {
    name: string;
    job: string;
  }

type LoadoutManagerData = 
  {
    loadout_list: Loadout[];
    job_type: string;
  };

type LoadoutListData = 
  {
    loadout_list: Loadout[];
  };

type TabData = 
  {
    job_type: string;
  }

const LoadoutItem = (props : Loadout, context) => { 
  const { act } = useBackend(context);
  const {
    name,
    job,
  } = props;

  return (
    <LabeledList.Item
      labelColor="white"
      label={name}>
      <Button
        onClick={() => act('SelectLoadout', { loadout_name: name, loadout_job: job })}>
        Select Loadout
      </Button>
    </LabeledList.Item>
  );
};

const LoadoutList = (props : LoadoutListData, context) => {
  const { loadout_list } = props;
  
  return (
    <Stack.Item>
      <Section height={8} fill scrollable>
        <LabeledList>
          {loadout_list.map(loadout => {
            <LoadoutItem name={loadout.name} job={loadout.job} />;
          })}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const JobTabs = (props : TabData, context) => {
  const { job_type } = props;
  const { act } = useBackend(context);
  return (
    <Section>
      <Tabs>
        <Tabs.Tab selected={job_type === "marine"} onClick={() => act("SelectJobType", { job_type: "marine" })}>
          Marine
        </Tabs.Tab>
        <Tabs.Tab selected={job_type === "engie"} onClick={() => act("SelectJobType", { job_type: "engie" })}>
          Engineer
        </Tabs.Tab>
        <Tabs.Tab selected={job_type === "medic"} onClick={() => act("SelectJobType", { job_type: "medic" })}>
          Medic
        </Tabs.Tab>
        <Tabs.Tab selected={job_type === "smartgunner"} onClick={() => act("SelectJobType", { job_type: "smartgunner" })}>
          SmartGunner
        </Tabs.Tab>
        <Tabs.Tab selected={job_type === "leader"} onClick={() => act("SelectJobType", { job_type: "leader" })}>
          Squad Leader
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};

export const LoadoutManager = (props, context) => {
  const { data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list, job_type } = data;

  return ( 
    <Window 
      title="Loadout Manager"
      width={900} 
      height={600}>
      <Window.Content>
        <Stack fill vertical>
          <JobTabs job_type={job_type} />
          <LoadoutList loadout_list={loadout_list} /> 
        </Stack>
      </Window.Content>
    </Window>
  );
};
