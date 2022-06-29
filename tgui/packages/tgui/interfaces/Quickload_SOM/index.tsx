import { useBackend, useLocalState } from "../../backend";
import { Stack, Button, Section, Box, LabeledList, Modal, Tabs, Flex } from "../../components";
import { Window } from "../../layouts";
import { LoadoutListData, LoadoutTabData, LoadoutManagerData, LoadoutItemData } from './Types';

const LoadoutItem = (props : LoadoutItemData, context) => {
  const { act } = useBackend(context);
  const {
    loadout,
  } = props;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState<String|null>(context, 'showDesc', null);

  return (
    <LabeledList.Item
      labelColor="white"
      buttons={
        <Button
          onClick={() => {
            act('selectLoadout', { loadout_outfit: loadout.outfit });
          }}>
          Select Loadout
        </Button>
      }
      label={loadout.name}>
      {!!loadout.desc && (
        <Button
          onClick={() => setShowDesc(loadout.desc)}>?
        </Button>)}
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
            <Tabs.Tab selected={job === "SOM Standard"} onClick={() => setJob("SOM Standard")}>
              SOM Standard
            </Tabs.Tab>
            <Tabs.Tab selected={job === "SOM Engineer"} onClick={() => setJob("SOM Engineer")}>
              SOM Engineer
            </Tabs.Tab>
            <Tabs.Tab selected={job === "SOM Medic"} onClick={() => setJob("SOM Medic")}>
              SOM Medic
            </Tabs.Tab>
            <Tabs.Tab selected={job === "SOM Veteran"} onClick={() => setJob("SOM Veteran")}>
              SOM Veteran
            </Tabs.Tab>
            <Tabs.Tab selected={job === "SOM Leader"} onClick={() => setJob("SOM Leader")}>
              SOM Leader
            </Tabs.Tab>
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1}><div> </div></Flex.Item>
      </Flex>
    </Section>
  );
};

export const Quickload_SOM = (props, context) => {
  const { act, data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list } = data;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const [
    job,
    setJob,
  ] = useLocalState(context, 'job', "SOM Standard");

  return (
    <Window
      title="Quick Equip vendor"
      width={700}
      height={400}
      theme="som">
      {showDesc && (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button
            content="Dismiss"
            onClick={() => setShowDesc(null)} />
        </Modal>
      )}
      <Window.Content>
        <Stack vertical>
          <JobTabs job={job} setJob={setJob} />
          <LoadoutList
            loadout_list={loadout_list.filter(loadout => loadout.job === job)}
          />
        </Stack>
      </Window.Content>
    </Window>
  );
};
