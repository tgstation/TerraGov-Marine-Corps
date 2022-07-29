import { BooleanLike } from 'common/react';
import { createSearch, multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { resolveAsset } from '../assets';
import { Box, Button, Divider, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = (searchText: string) => {
  return createSearch(searchText, (thing: { name: string}) => thing.name);
};

const compareNumberedText = (
  a: { name: string },
  b: { name: string },
) => {
  const aName = a.name;
  const bName = b.name;

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const aNumberMatch = aName.match(PATTERN_NUMBER);
  const bNumberMatch = bName.match(PATTERN_NUMBER);

  if (aNumberMatch
    && bNumberMatch
    && aName.replace(PATTERN_NUMBER, "") === bName.replace(PATTERN_NUMBER, "")
  ) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return aName.localeCompare(bName);
};

type OrbitList = {
  name: string,
  ref: string,
  orbiters: number,
}

type OrbitData = {
  humans: OrbitList[],
  marines: OrbitList[],
  som: OrbitList[],
  survivors: OrbitList[],
  xenos: OrbitList[],
  dead: OrbitList[],
  ghosts: OrbitList[],
  misc: OrbitList[],
  npcs: OrbitList[],
  auto_observe: BooleanLike,
}

type BasicSectionProps = {
  searchText: string,
  source: OrbitList[],
  title: string,
}

type OrbitedButtonProps = {
  color: string,
  thing: OrbitList,
}

const BasicSection = (props: BasicSectionProps, context: any) => {
  const { act } = useBackend(context);
  const { searchText, source, title } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  if (source.length <= 0) {
    return null;
  }
  return (
    <Section title={`${title} - (${source.length})`}>
      {things.map((thing: OrbitList) => (
        <Button
          key={thing.name}
          content={thing.name}
          onClick={() => act("orbit", {
            ref: thing.ref,
          })} />
      ))}
    </Section>
  );
};

const OrbitedButton = (props: OrbitedButtonProps, context: any) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("orbit", {
        ref: thing.ref,
      })}>
      {thing.name}
      {thing.orbiters && (
        <Box inline ml={1}>
          {"("}{thing.orbiters}{" "}
          <Box
            as="img"
            src={resolveAsset('ghost.png')}
            opacity={0.7}
          />
          {")"}
        </Box>
      )}
    </Button>
  );
};

export const Orbit = (props: any, context: any) => {
  const { act, data } = useBackend<OrbitData>(context);
  const {
    humans,
    marines,
    som,
    survivors,
    xenos,
    dead,
    ghosts,
    misc,
    npcs,
    auto_observe,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  const orbitMostRelevant = (searchText: string) => {
    for (const source of [
      humans,
      marines,
      som,
      survivors,
      xenos,
    ]) {
      const member = source
        .filter(searchFor(searchText))
        .sort(compareNumberedText)[0];
      if (member !== undefined) {
        act("orbit", { ref: member.ref });
        break;
      }
    }
  };

  return (
    <Window
      title="Orbit"
      width={350}
      height={700}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Icon
                name="search"
                mr={1} />
            </Flex.Item>
            <Flex.Item grow={1}>
              <Input
                placeholder="Search..."
                autoFocus
                fluid
                value={searchText}
                onInput={(_: any, value: string) => setSearchText(value)}
                onEnter={(_: any, value: string) => orbitMostRelevant(value)} />
            </Flex.Item>
            <Flex.Item>
              <Divider vertical />
            </Flex.Item>
            <Flex.Item>
              <Button
                inline
                color="transparent"
                tooltip={multiline`Toggle Auto-Observe. When active, you'll
                see the UI / full inventory of whoever you're orbiting, Neat!`}
                tooltipPosition="bottom-start"
                selected={auto_observe}
                icon={auto_observe ? "toggle-on" : "toggle-off"}
                onClick={() => act("toggle_observe")} />
              <Button
                inline
                color="transparent"
                tooltip="Refresh"
                tooltipPosition="bottom-start"
                icon="sync-alt"
                onClick={() => act("refresh")} />
            </Flex.Item>
          </Flex>
        </Section>

        <Section title={`Xenos - (${xenos.length})`}>
          {xenos
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <Section title={`Marines - (${marines.length})`}>
          {marines
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <Section title={`SOM - (${som.length})`}>
          {som
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <Section title={`Survivors - (${survivors.length})`}>
          {survivors
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <Section title={`Humans - (${humans.length})`}>
          {humans
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
        </Section>

        <Section title={`Ghosts - (${ghosts.length})`}>
          {ghosts
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="grey"
                thing={thing} />
            ))}
        </Section>

        <BasicSection
          title="NPCs"
          source={npcs}
          searchText={searchText}
        />

        <BasicSection
          title="Dead"
          source={dead}
          searchText={searchText}
        />

        <BasicSection
          title="Misc"
          source={misc}
          searchText={searchText}
        />
      </Window.Content>
    </Window>
  );
};
