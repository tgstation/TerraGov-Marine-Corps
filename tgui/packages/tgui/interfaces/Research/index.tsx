import {
  AnimatedNumber,
  Box,
  Button,
  Divider,
  Flex,
  Image,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ResearchData, ResearchResource, RewardTier } from './Types';
import { hexToRGB, objectToArray } from './Utility';

export const Research = (props) => {
  const { act, data } = useBackend<ResearchData>();
  const { acquired_points, anchored, researching, init_resource } = data;

  return (
    <Window width={400} height={600}>
      <Window.Content
        scrollable
        align="stretch"
        backgroundColor={
          init_resource ? hexToRGB(init_resource.colour, 0.5) : ''
        }
      >
        <Button
          style={{
            margin: '0.2em',
          }}
          content={anchored ? 'Release' : 'Lock'}
          disabled={researching}
          icon={anchored ? 'lock' : 'lock-open'}
          onClick={() => act('switch_anchored')}
        />
        <Divider />
        Total acquired credits: <AnimatedNumber value={acquired_points} />
        <Divider />
        {init_resource ? (
          constructResourceInfo(init_resource, act, researching)
        ) : (
          <Section title="Base resource">{'No resource inserted'}</Section>
        )}
        {init_resource ? (
          init_resource.rewards.length > 0 ? (
            <RarityInfo {...init_resource.rewards} />
          ) : (
            ''
          )
        ) : (
          ''
        )}
      </Window.Content>
    </Window>
  );
};

const constructResourceInfo = (
  resource: ResearchResource,
  act: Function,
  researching: boolean,
) => {
  const { name, colour, icon } = resource;

  return (
    <Section title={name}>
      <Flex direction="row">
        <Flex.Item basis="auto">
          <Button
            content="Research item"
            disabled={researching}
            icon="prescription-bottle"
            onClick={() => act('start_research')}
          />
        </Flex.Item>
        <Flex.Item
          basis="auto"
          overflow="hidden"
          position="relative"
          style={{
            display: 'flex',
            justifyContent: 'center',
          }}
        >
          <Image
            src={`data:image/jpeg;base64,
                ${icon}`}
            color="transparent"
            style={{
              verticalAlign: 'middle',
              width: '190px',
              transform: 'scale(2) translate(0, -10%)',
            }}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const RarityInfo = (rewards_list: RewardTier[]) => {
  // THANKS IE!!!!
  rewards_list = objectToArray(rewards_list);

  return (
    <Section title="Reward tiers info and possible rewards" p="5px">
      {rewards_list.map((tier) => constructTierInfo(tier))}
    </Section>
  );
};

const constructTierInfo = (tier: RewardTier) => {
  const { type, probability, rewards_list } = tier;

  return (
    <Box mb="0.6em">
      <Box bold>{constructRarityText(type, probability)}</Box>
      <Table>
        {rewards_list.map((item, i) => (
          <Table.Row key={i}>{`> ${item}`}</Table.Row>
        ))}
      </Table>
    </Box>
  );
};

const constructRarityText = (rarityText: string, rarityVal: number) => {
  return `${rarityText.toUpperCase()} ${rarityVal}%`;
};
