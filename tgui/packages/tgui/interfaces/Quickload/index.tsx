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

const JobTabs = (props: LoadoutTabData, context) => {
  const { job, setJob } = props;
  const { data } = useBackend<any>(context);
  const categories_to_use = data.vendor_categories;
  return (
    <Section>
      <Flex>
        <Flex.Item grow={1}><div> </div></Flex.Item>
        <Flex.Item>
          <Tabs>
            {categories_to_use.map((role, i) => (
              <Tabs.Tab key={i}
                selected={job === role.jobs}
                onClick={() => setJob(role)}>
                {role}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1}><div> </div></Flex.Item>
      </Flex>
    </Section>
  );
};

export const Quickload = (props, context) => {
  const { act, data } = useBackend<LoadoutManagerData>(context);
  const { loadout_list } = data;
  const ui_theme_to_use = data.ui_theme;
  const default_job_tab = data.vendor_categories[0];

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const [
    job,
    setJob,
  ] = useLocalState(context, 'job', default_job_tab);

  return (
    <Window
      title="Quick Equip vendor"
      width={700}
      height={400}
      theme={ui_theme_to_use}>
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
