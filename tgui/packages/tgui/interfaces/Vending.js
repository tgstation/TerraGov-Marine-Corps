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
      <Window.Content scrollable>
        {!!showDesc && (
          <Modal>
            <Box>{showDesc}</Box>
            <Button
              content="Dismiss"
              onClick={() => setShowDesc(null)} />
          </Modal>
        )}
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

  return (
    <Section
      title={"Coin slot: "+(data.coin ? data.coin : "No coin inserted")}
      buttons={data.coin && (
        <Button
          icon="donate"
          onClick={() => act("remove_coin")}>
          Remove
        </Button>)}>
      {!!data.coin && (
        <Section title="Select an item">
          {data.coin_records.map(coin_record => (
            <Box key={coin_record.id}>
              <Button
                selected={data.currently_vending_index
                  === coin_record.prod_index}
                onClick={() => act(
                  "vend",
                  { vend: coin_record.prod_index,
                    cat: coin_record.prod_cat })}
                disabled={!coin_record.amount}>
                <Box color={coin_record.product_color} bold={1}>
                  { decodeHtmlEntities(coin_record.product_name)}
                </Box>
              </Button>
            </Box>
          ))}
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

  return (
    <Section title="$*FD!!F">
      {data.hidden_records.map(hidden_record => (
        <Box key={hidden_record.id}>
          <Button
            selected={data.currently_vending_index
              === hidden_record.prod_index}
            onClick={() => act(
              'vend',
              { vend: hidden_record.prod_index,
                cat: hidden_record.prod_cat })}
            disabled={!hidden_record.amount}>
            <Box color={hidden_record.product_color} bold={1}>
              { decodeHtmlEntities(hidden_record.product_name)}
            </Box>
          </Button>
        </Box>
      ))}
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
        {data.displayed_records.length > 0 ? (
          data.displayed_records.map(display_record => {
            const {
              amount,
              id,
              prod_index,
              prod_cat,
              product_color,
              product_name,
              prod_desc,
            } = display_record;
            return (
              ((showEmpty || !!amount) && (
                <LabeledListItem key={id}
                  labelColor="white"
                  buttons={
                    <Fragment>
                      <ProgressBar
                        width="60px"
                        value={amount}
                        maxValue={amount}
                        ranges={{
                          good: [10, Infinity],
                          average: [5, 10],
                          bad: [-Infinity, 5],
                        }}>{amount} left
                      </ProgressBar>
                      <Box inline width="4px" />
                      <Button
                        selected={data.currently_vending_index
                          === prod_index}
                        onClick={() => act(
                          'vend',
                          { vend: prod_index,
                            cat: prod_cat })}
                        disabled={!amount}>
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
        ) : (
          <Box color="red">No product loaded!</Box>
        )}
      </LabeledList>
    </Section>
  );
};
