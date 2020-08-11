import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, LabeledList, ProgressBar, Modal, Divider } from '../components';
import { decodeHtmlEntities } from 'common/string';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', 0);

  return (
    <Window title={data.vendor_name} width={500} height={550}>
      {showDesc ? (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button
            content="Dismiss"
            onClick={() => setShowDesc(null)} />
        </Modal>
      ) : (
        data.currently_vending_name && (
          <Modal width="400px">
            <Buying />
          </Modal>
        )
      )}
      <div>
        <div
          className="VendingWindow__header">
          <Section
            title="Select an item"
            buttons={
              <Button
                icon="power-off"
                selected={showEmpty}
                onClick={() => setShowEmpty(!showEmpty)}>
                Show sold-out items
              </Button>
            } />
        </div>
        <div className="VendingWindow__content">
          <Window.Content scrollable>
            <Fragment>
              {(!!((data.premium_length > 0) || (data.isshared > 0))) && (
                <Premium />
              )}
              {data.hidden_records.length > 0 && !!data.extended && (
                <Hacked />
              )}
              <Products />
            </Fragment>
          </Window.Content>
        </div>
      </div>
    </Window>
  );
};

const Buying = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section
      title={"You have selected "+data.currently_vending_name}>
      <Box>
        Please swipe your ID to pay for the article.
        <Divider />
        <Button
          onClick={() => act('swipe')}
          icon="id-card"
          ml={1}>
          Swipe
        </Button>
        <Button
          onClick={() => act('cancel_buying')}
          icon="times">
          Cancel
        </Button>
      </Box>
    </Section>
  );
};

const Premium = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    coin_records,
    coin_stock,
    coin,
  } = data;

  return (
    <Section
      title={"Coin slot: "+(coin ? coin : "No coin inserted")}
      buttons={coin && (
        <Button
          icon="donate"
          onClick={() => act("remove_coin")}>
          Remove
        </Button>)}>
      {!!coin
        && (
          <LabeledList>
            {coin_records.map(coin_record => {
              const {
                id,
                index,
              } = coin_record;
              return (
                <ProductEntry
                  stock={coin_stock[index]}
                  key={id}
                  {...display_record} />
              );
            })}
          </LabeledList>
        )}
    </Section>
  );
};

const ProductEntry = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    currently_vending_index,
  } = data;

  const {
    stock,
    index,
    category,
    color,
    name,
    desc,
    path,
  } = props;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  return (
    <LabeledListItem
      labelColor="white"
      buttons={
        <Fragment>
          <ProgressBar
            width="60px"
            value={stock}
            maxValue={stock}
            ranges={{
              good: [10, Infinity],
              average: [5, 10],
              bad: [-Infinity, 5],
            }}>{stock} left
          </ProgressBar>
          <Box inline width="4px" />
          <Button
            selected={currently_vending_index
              === index}
            onClick={() => act(
              'vend',
              { vend: index,
                cat: category })}
            disabled={!stock}>
            <Box color={color} bold={1}>
              Vend
            </Box>
          </Button>
        </Fragment>
      }
      label={decodeHtmlEntities(name)}>
      {!!desc && (
        <Button
          onClick={() => setShowDesc(desc)}>?
        </Button>)}
      <span
        className={classes(['vending32x32', path])}
        style={{
          'horizontal-align': 'middle',
          'vertical-align': 'middle',
        }} />
    </LabeledListItem>
  );
};

const Hacked = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    hidden_records,
    hidden_stock,
  } = data;

  return (
    <Section title="$*FD!!F">
      <LabeledList>
        {hidden_records.map(hidden_record => {
          const {
            id,
            index,
            cat,
            color,
            name,
            desc,
          } = hidden_record;
          return (
            <ProductEntry
              stock={hidden_stock[index]}
              key={id}
              {...display_record} />
          );
        })}
      </LabeledList>
    </Section>
  );
};

const Products = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', 0);

  const {
    displayed_records,
    displayed_stock,
  } = data;

  return (
    <Section>
      <LabeledList>
        {displayed_records.length === 0 ? (
          <Box color="red">No product loaded!</Box>
        ) : (
          displayed_records.map(display_record => {
            const {
              id,
              index,
            } = display_record;
            return (
              ((showEmpty || !!displayed_stock[index]) && (
                <ProductEntry
                  stock={displayed_stock[index]}
                  key={id}
                  {...display_record} />
              ))
            );
          })
        )}
      </LabeledList>
    </Section>
  );
};
