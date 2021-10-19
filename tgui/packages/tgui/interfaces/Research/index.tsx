import { useBackend } from '../../backend';
import { Button, Divider, LabeledList, Section } from '../../components';
import { Window } from '../../layouts';
import { ResearchData, ResearchResource, RewardTier } from './Types';
import { hexToRGB, objectToArray } from './Utility';

export const Research = (props, context) => {
  const { act, data } = useBackend<ResearchData>(context);
  const {
    init_resource,
  } = data;

  return (
    <Window
      resizable
      width={600}
      height={600}>
      <Window.Content
        scrollable
        align="stretch"
        backgroundColor={init_resource ? hexToRGB(init_resource.colour, 0.5) : ""}>
        <Section title="Base resource">
          {
            init_resource
              ? constructResourceInfo(init_resource, act)
              : "No resource inserted"
          }
        </Section>
        {
          init_resource ? init_resource.rewards.length > 0
            ? <RarityInfo {... init_resource.rewards} />
            : "" : ""
        }

      </Window.Content>
    </Window>
  );
};

const constructResourceInfo = (resource: ResearchResource, act: Function) => {
  const {
    name,
    colour,
  } = resource;

  return (
    <LabeledList>
      <LabeledList.Item label="Name">
        {name}
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          content="Research item"
          onClick={() => act('start_research')} />
      </LabeledList.Item>
    </LabeledList>
  );
};

const RarityInfo = (rewards_list: RewardTier[]) => {
  // THANKS IE!!!!
  rewards_list = objectToArray(rewards_list);

  return (
    <Section title="Reward tiers info and possible rewards" p="5px">
      {rewards_list.map(tier => (constructTierInfo(tier)))}
    </Section>
  );
};

const constructTierInfo = (tier: RewardTier) => {
  const {
    type,
    probability,
    rewards_list,
  } = tier;

  return (
    <>
      {constructRarityText(type, probability)}
      <Divider />
      <LabeledList>
        {rewards_list.map(item => (
          <LabeledList.Item>
            {item}
          </LabeledList.Item>))}
      </LabeledList>
      <Divider />
    </>
  );
};

const constructRarityText = (rarityText: string, rarityVal: number) => {
  return `${rarityText.toUpperCase()} ${rarityVal}%`;
};
