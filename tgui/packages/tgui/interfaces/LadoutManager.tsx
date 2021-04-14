import { useBackend, useLocalState } from "../backend";
import { Stack, Button, Section, LabeledList, Divider, Tabs } from "../components";
import { Window } from "../layouts";

type Loadout =
  {
    name: string;
  }

type LoadoutListData = 
  {
    loadout_list: Loadout[];
  };

type TabData = 
  {
    tabIndex : string;
    setTabIndex : any;
  }

const LoadoutItem = (props : Loadout, context) => { 
  const { act } = useBackend(context);
  const {
    name
  } = props;

  return (
    <LabeledList.Item
      labelColor="white"
      label={name}>
      <Button
        onClick={() => act('SelectLoadout',{ loadout_name: name })}>
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
        {loadout_list.map(loadout => {
          return LoadoutItem(loadout, context);
        })}
      </Section>
    </Stack.Item>
  );
};

const JobTabs = (props : TabData, context) => {
  const { tabIndex, setTabIndex } = props;
  return(
    <Section>
      <Tabs>
        <Tabs.Tab selected={tabIndex === 'marine'} onClick={() => setTabIndex('marine')}>
          Marine
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 'engineer'} onClick={() => setTabIndex('engineer')}>
          Engineer
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 'medic'} onClick={() => setTabIndex('medic')}>
          Medic
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 'medic'} onClick={() => setTabIndex('medic')}>
          Squad Leader
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
}

export const LoadoutManager = (props, context) => {
  const { data } = useBackend<LoadoutListData>(context);
	const { loadout_list } = data;

  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tabIndex', 'marine');

  return ( 
    <Window 
      title="Loadout Manager"
      width={900} 
      height={600}>
      <Window.Content>
        <Stack fill vertical>
          <JobTabs tabIndex = {tabIndex} setTabIndex = {setTabIndex}/>
          <Divider></Divider>
          <LoadoutList loadout_list={loadout_list} /> 
        </Stack>
      </Window.Content>
    </Window>
  )

}

