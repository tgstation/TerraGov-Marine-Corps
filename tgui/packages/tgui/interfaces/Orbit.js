import { createSearch } from 'common/string';
import { Box, Button, Input, Section } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

const PATTERN_DESCRIPTOR = / \[(?:ghost|dead)\]$/;
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
          content={thing.name.replace(PATTERN_DESCRIPTOR, "")}
          onClick={() => act("orbit", {
            name: thing.name,
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
        name: thing.name,
      })}>
      {thing.name}
      {thing.orbiters && (` (${thing.orbiters})`)}
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
        act("orbit", { name: member.name });
        break;
      }
    }
  };

  return (
    <Window>
      <Window.Content scrollable>
        <Section>
          <Input
            fluid
            value={searchText}
            onInput={(_, value) => setSearchText(value)}
            onEnter={(_, value) => orbitMostRelevant(value)} />
        </Section>

        <BasicSection
          title="Xenos"
          source={xenos}
          searchText={searchText}
        />

        <BasicSection
          title="Marines"
          source={marines}
          searchText={searchText}
        />

        <BasicSection
          title="Survivors"
          source={survivors}
          searchText={searchText}
        />

        <BasicSection
          title="Humans"
          source={humans}
          searchText={searchText}
        />

        <BasicSection
          title="Ghosts"
          source={ghosts}
          searchText={searchText}
        />

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
