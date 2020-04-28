import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, LabeledList, ProgressBar, Modal } from '../components';
import { decodeHtmlEntities } from 'common/string';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

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
        {data.currently_vending_name ? (
          <Buying />
        ) : (
          <Fragment>
            {(!!((data.premium_length > 0) || (data.isshared > 0))) && (
              <Premium />
            )}
            {data.hidden_records.length > 0 && !!data.extended && (
              <Hacked />
            )}
            <Products />
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};

const Buying = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section
      title={"You have selected "+data.currently_vending_name}
      buttons={
        <Button
          onClick={() => act('cancel_buying')}
          icon="times">
          Cancel
        </Button>
      }>
      <Box>
        Please swipe your ID to pay for the article.
        <Button
          onClick={() => act('swipe')}
          icon="id-card"
          ml={1}>
          Swipe
        </Button>
      </Box>
    </Section>
  );
};

const Premium = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const {
    coin_records,
    currently_vending_index,
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
      {!!coin && (
        <Section title="Select an item">
          {coin_records.map(coin_record => {
            const {
              id,
              prod_index,
              prod_cat,
              product_color,
              product_name,
            } = coin_record;
            return (
              <Box key={id}>
                <Button
                  selected={currently_vending_index
                    === prod_index}
                  onClick={() => act(
                    "vend",
                    { vend: prod_index,
                      cat: prod_cat })}
                  disabled={!coin_stock[prod_index]}>
                  <Box color={product_color} bold={1}>
                    { decodeHtmlEntities(product_name)}
                  </Box>
                </Button>
              </Box>
            );
          })}
        </Section>)}
    </Section>
  );
};

const Hacked = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const {
    currently_vending_index,
    hidden_records,
    hidden_stock,
  } = data;

  return (
    <Section title="$*FD!!F">
      {hidden_records.map(hidden_record => {
        const {
          id,
          prod_index,
          prod_cat,
          product_color,
          product_name,
        } = hidden_record;
        return (
          <Box key={id}>
            <Button
              selected={currently_vending_index === prod_index}
              onClick={() => act(
                'vend',
                { vend: prod_index, cat: prod_cat })}
              disabled={!hidden_stock[prod_index]}>
              <Box color={product_color} bold={1}>
                { decodeHtmlEntities(product_name)}
              </Box>
            </Button>
          </Box>
        );
      })}
    </Section>
  );
};

const Products = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', 0);

  const {
    displayed_records,
    currently_vending_index,
    displayed_stock,
  } = data;

  return (
    <Section
      title="Select an item"
      buttons={
        <Button
          icon="power-off"
          selected={showEmpty}
          onClick={() => setShowEmpty(!showEmpty)}>
          Show sold-out items
        </Button>
      }>
      <LabeledList>
        {displayed_records.length === 0 ? (
          <Box color="red">No product loaded!</Box>
        ) : (
          displayed_records.map(display_record => {
            const {
              id,
              prod_index,
              prod_cat,
              product_color,
              product_name,
              prod_desc,
            } = display_record;
            return (
              ((showEmpty || !!displayed_stock[prod_index]) && (
                <LabeledListItem key={id}
                  labelColor="white"
                  buttons={
                    <Fragment>
                      <ProgressBar
                        width="60px"
                        value={displayed_stock[prod_index]}
                        maxValue={displayed_stock[prod_index]}
                        ranges={{
                          good: [10, Infinity],
                          average: [5, 10],
                          bad: [-Infinity, 5],
                        }}>{displayed_stock[prod_index]} left
                      </ProgressBar>
                      <Box inline width="4px" />
                      <Button
                        selected={currently_vending_index
                          === prod_index}
                        onClick={() => act(
                          'vend',
                          { vend: prod_index,
                            cat: prod_cat })}
                        disabled={!displayed_stock[prod_index]}>
                        <Box color={product_color} bold={1}>
                          Vend
                        </Box>
                      </Button>
                    </Fragment>
                  }
                  label={decodeHtmlEntities(product_name)}>
                  {!!prod_desc && (
                    <Button
                      onClick={() => setShowDesc(prod_desc)}>?
                    </Button>)}
                </LabeledListItem>
              ))
            );
          })
        )}
      </LabeledList>
    </Section>
  );
};
