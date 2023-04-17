import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, ProgressBar, LabeledList, Modal } from '../components';
import { Window } from '../layouts';

export const MarineSelector = (props, context) => {
  const { act, data } = useBackend(context);

  const [showEmpty, setShowEmpty] = useLocalState(context, 'showEmpty', 0);

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', null);

  const categories = Object.keys(data.displayed_records)
    .map((key) => ({
      ...data.cats[key],
      name: key,
      entries: data.displayed_records[key],
    }))
    .filter(
      (category) =>
        category.entries.length > 0 &&
        (showEmpty || category.remaining > 0 || category.remaining_points > 0)
    );

  return (
    <Window width={600} height={700}>
      {!!showDesc && (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button content="Dismiss" onClick={() => setShowDesc(null)} />
        </Modal>
      )}
      <Window.Content scrollable>
        <Section
          title="Choose your equipment"
          buttons={
            <>
              <Box inline width="4px" />
              <Button
                icon="power-off"
                selected={showEmpty}
                onClick={() => setShowEmpty(!showEmpty)}>
                Show Empty Categories
              </Button>
            </>
          }>
          Make selections in each of the categories below to get equipped.
          Surplus of some of the equipment found in this machine may be found in
          surplus vendors nearby.
        </Section>
        {categories.map((category) => (
          <ItemCategory category={category} key={category.id} />
        ))}
      </Window.Content>
    </Window>
  );
};

const ItemCategory = (props, context) => {
  const {
    category: {
      entries,
      name,
      choice,
      remaining,
      total,
      remaining_points,
      total_points,
    },
  } = props;

  const cant_buy =
    (choice === 'choice' && !remaining) ||
    (choice === 'points' && !remaining_points);

  return (
    <Section
      title={name}
      buttons={
        (choice === 'choice' && (
          <ProgressBar
            value={remaining / total}
            ranges={{
              good: [1, Infinity],
              average: [0.1, 1],
              bad: [-Infinity, 0.1],
            }}>
            {remaining + '/' + total + ' Choices'}
          </ProgressBar>
        )) ||
        (choice === 'points' && (
          <ProgressBar
            value={remaining_points / total_points}
            ranges={{
              good: [0.67, Infinity],
              average: [0.33, 0.67],
              bad: [-Infinity, 0.33],
            }}>
            {remaining_points + '/' + total_points + ' Points'}
          </ProgressBar>
        ))
      }>
      <LabeledList>
        {entries.map((display_record) => {
          return (
            <ItemLine
              display_record={display_record}
              key={display_record.id}
              cant_buy={cant_buy}
              remaining_points={remaining_points}
            />
          );
        })}
      </LabeledList>
    </Section>
  );
};

const ItemLine = (props, context) => {
  const { act, data } = useBackend(context);

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', null);

  const {
    display_record: {
      id,
      prod_cost,
      prod_index,
      prod_color,
      prod_name,
      prod_desc,
    },
    cant_buy,
    remaining_points,
  } = props;

  return (
    <LabeledList.Item
      key={id}
      buttons={
        <>
          {prod_color === 'white' && (
            <Box inline mr="6px" ml="6px">
              Essential!
            </Box>
          )}
          {prod_color === 'orange' && (
            <Box inline mr="6px" ml="6px" color="orange">
              Recommended
            </Box>
          )}
          {prod_color === 'synth-cosmetic' && (
            <Box inline mr="6px" ml="6px" color="blue">
              Cosmetic
            </Box>
          )}
          {prod_color === 'synth-armor' && (
            <Box inline mr="6px" ml="6px" color="red">
              Provides Armor
            </Box>
          )}
          {prod_color === 'synth-rcmarmor' && (
            <Box inline mr="6px" ml="6px" color="orange">
              Recommended - Provides Armor
            </Box>
          )}
          {prod_color === 'synth-rcmarmstorage' && (
            <Box inline mr="6px" ml="6px" color="green">
              Recommended - Provides Armor and Storage
            </Box>
          )}
          {prod_color === 'synth-attachable' && (
            <Box inline mr="6px" ml="6px" color="green">
              Recommended - Can be attached to flak jacket
            </Box>
          )}
          {prod_cost > 0 && (
            <Box inline width="75px" mr="6px" ml="6px">
              {prod_cost} points
            </Box>
          )}
          <Button
            disabled={cant_buy || prod_cost > remaining_points}
            onClick={() => act('vend', { vend: prod_index })}
            selected={prod_color === 'white'}>
            Vend
          </Button>
        </>
      }
      label={prod_name}
      labelColor="white">
      {!!prod_desc && <Button onClick={() => setShowDesc(prod_desc)}>?</Button>}
    </LabeledList.Item>
  );
};
