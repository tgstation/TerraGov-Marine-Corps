import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, ProgressBar, LabeledList, Modal } from '../components';
import { map } from 'common/collections';
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
    displayed_records,
    current_m_points,
    total_marine_points,
    cats,
    vendor_name,
    show_points,
  } = data;

  return (
    <Window>
      {!!showDesc && (
        <Modal>
          <Box>{showDesc}</Box>
          <Button
            content="Dismiss"
            onClick={() => setShowDesc(null)} />
        </Modal>
      )}
      <Window.Content scrollable>
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

              <Button
                icon="power-off"
                selected={showEmpty}
                onClick={() => setShowEmpty(!showEmpty)}>
                Show Empty Categories
              </Button>
            </Fragment>
          }>

          {map((entry, category_name) => {
            const {
              remaining,
              total,
            } = cats[category_name];
            return (
              entry.length > 0
              && (showEmpty || (remaining > 0
                || (!total && !!current_m_points))) && (
                <ItemCategory
                  category_name={category_name}
                  entries={entry}
                  key={category_name} />
              ));
          })(displayed_records)}
        </Section>
      </Window.Content>
    </Window>
  );
};

const ItemCategory = (props, context) => {
  const { act, data } = useBackend(context);

  const { category_name, entries } = props;

  const {
    remaining,
    total,
  } = data.cats[category_name];

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const cant_buy = total && !remaining;

  return (
    <Section
      title={category_name}
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
          const {
            id,
            prod_cost,
            prod_index,
            prod_color,
            prod_name,
            prod_desc,
          } = display_record;
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
                    disabled={cant_buy || prod_cost > data.current_m_points}
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
          ); }
        )}
      </LabeledList>
    </Section>
  );
};
