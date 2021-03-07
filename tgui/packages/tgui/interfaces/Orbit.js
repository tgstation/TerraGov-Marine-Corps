import { createSearch, multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { resolveAsset } from '../assets';
import { Box, Button, Divider, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = searchText => createSearch(searchText, thing => thing.name);

const compareString = (a, b) => a < b ? -1 : a > b;

const compareNumberedText = (a, b) => {
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

  return compareString(aName, bName);
};

const BasicSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  return source.length > 0 && (
    <Section title={`${title} - (${source.length})`}>
      {things.map(thing => (
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

const OrbitedButton = (props, context) => {
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

export const Orbit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    humans,
    marines,
    survivors,
    xenos,
    auto_observe,
    dead,
    ghosts,
    misc,
    npcs,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  const orbitMostRelevant = searchText => {
    for (const source of [
      humans,
      marines,
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
                onInput={(_, value) => setSearchText(value)}
                onEnter={(_, value) => orbitMostRelevant(value)} />
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
                tooltipPosition="bottom-left"
                selected={auto_observe}
                icon={auto_observe ? "toggle-on" : "toggle-off"}
                onClick={() => act("toggle_observe")} />
              <Button
                inline
                color="transparent"
                tooltip="Refresh"
                tooltipPosition="bottom-left"
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
          title="Misc"
          source={misc}
          searchText={searchText}
        />
      </Window.Content>
    </Window>
  );
};
