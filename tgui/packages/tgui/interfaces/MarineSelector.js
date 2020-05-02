import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, ProgressBar, LabeledList, Modal } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { LabeledListItem } from '../components/LabeledList';

export const MarineSelector = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', 0);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const {
    current_m_points,
    total_marine_points,
    show_points,
  } = data;

  const categories = Object
    .keys(data.displayed_records)
    .map(key => ({
      ...data.cats[key],
      name: key,
      entries: data.displayed_records[key],
    }))
    .filter(category => (
      category.entries.length > 0
      && (showEmpty
      || category.remaining > 0
      || !category.total && !!current_m_points)
    ));

  return (
    <Window>
      {!!showDesc && (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button
            content="Dismiss"
            onClick={() => setShowDesc(null)} />
        </Modal>
      )}
      <div>
        <div
          className="VendingWindow__header">
          <Section
            title="Choose your equipment"
            buttons={
              <Fragment>
                {!!show_points && (
                  <ProgressBar
                    width="100px"
                    value={current_m_points / total_marine_points}
                    ranges={{
                      good: [0.67, Infinity],
                      average: [0.33, 0.67],
                      bad: [-Infinity, 0.33],
                    }} >
                    {current_m_points +"/"+ total_marine_points + " Points"}
                  </ProgressBar>
                )}
                <Box inline width="4px" />
                <Button
                  icon="power-off"
                  selected={showEmpty}
                  onClick={() => setShowEmpty(!showEmpty)}>
                  Show Empty Categories
                </Button>
              </Fragment>
            } />
        </div>
        <div className="VendingWindow__content">
          <Window.Content scrollable>
            <Section>
              {categories.map(category => (
                <ItemCategory
                  category={category}
                  key={category.id} />
              ))}
            </Section>
          </Window.Content>
        </div>
      </div>
    </Window>
  );
};

const ItemCategory = (props, context) => {
  const {
    category: {
      entries,
      name,
      remaining,
      total,
    },
  } = props;

  const cant_buy = total && !remaining;

  return (
    <Section
      title={name}
      buttons={!!total && (
        <ProgressBar
          value={remaining
            / total}
          ranges={{
            good: [1, Infinity],
            average: [0.1, 1],
            bad: [-Infinity, 0.1],
          }} >
          {remaining +"/"+ total + " Choices"}
        </ProgressBar>)}>
      <LabeledList>
        {entries.map(display_record => {
          return (
            <ItemLine
              display_record={display_record}
              key={display_record.id}
              cant_buy={cant_buy} />
          ); }
        )}
      </LabeledList>
    </Section>
  );
};

const ItemLine = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const {
    current_m_points,
  } = data;

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
  } = props;

  return (
    <LabeledListItem
      key={id}
      buttons={
        <Fragment>
          {prod_color === "white"
          && (<Box inline mr={1} ml={1}>Essential!</Box>)}
          {prod_color === "orange"
          && (
            <Box inline mr={1} ml={1} color="orange">
              Recommended
            </Box>
          )}
          {prod_cost > 0
          && (
            <Box inline width="75px" mr={1} ml={1}>
              {prod_cost} points
            </Box>
          )}
          <Button
            disabled={cant_buy || prod_cost > current_m_points}
            onClick={() => act(
              'vend',
              { vend: prod_index })}
            selected={prod_color === "white"}>
            Vend
          </Button>
        </Fragment>
      }
      label={prod_name}
      labelColor="white">
      {!!prod_desc && (
        <Button onClick={() => setShowDesc(prod_desc)}>
          ?
        </Button>)}
    </LabeledListItem>
  );
};
