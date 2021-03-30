import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, LabeledList, ProgressBar, Modal, Divider, Tabs } from '../components';
import { decodeHtmlEntities } from 'common/string';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { type } from 'node:os';


type VendingData = {
  vendor_name: string,
  displayed_records: VendingRecord[],
  hidden_records: VendingRecord[],
  coin_records: VendingRecord[],
  tabs: string[],
  stock: VendingStock,
  currently_vending: VendingRecord,
  extended: BooleanLike,
  isshared: BooleanLike,
  coin: string,
};

type VendingStock = {
  [ key: string ]: number
};

type VendingRecord = {
  product_name: string,
  product_color: string,
  prod_price: number,
  prod_desc: string,
  ref: string,
  tab: string,
}

export const Vending = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    vendor_name,
    currently_vending,
    hidden_records,
    coin_records,
    isshared,
    extended,
    tabs,
  } = data;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', false);

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[1] : null);

  return (
    <Window
      title={vendor_name || "Vending Machine"}
      width={500}
      height={600}>
      {showDesc ? (
        <Modal width="400px">
          <Box>{showDesc}</Box>
          <Button
            content="Dismiss"
            onClick={() => setShowDesc(null)} />
        </Modal>
      ) : (
        currently_vending && (
          <Modal width="400px">
            <Buying />
          </Modal>
        )
      )}
      <Window.Content scrollable>
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
          {(tabs.length > 0 && (
            <Section>
              <Tabs>
                {tabs.map(tabname => {
                  return (
                    <Tabs.Tab
                      key={tabname}
                      selected={tabname === selectedTab}
                      onClick={() => setSelectedTab(tabname)}>
                      {tabname}
                    </Tabs.Tab>
                  );
                })}
              </Tabs>
            </Section>
          ))}
          {(!!((coin_records.length > 0) || (isshared > 0))) && (
            <Premium />
          )}
          {hidden_records.length > 0 && !!extended && (
            <Hacked />
          )}
          <Products />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Buying = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    currently_vending,
  } = data;

  return (
    <Section
      title={"You have selected "+currently_vending.product_name}>
      <Box>
        Please swipe your ID to pay for the article.
        <Divider />
        <Button
          onClick={() => act('swipe')}
          icon="id-card"
          ml="6px">
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
  const { act, data } = useBackend<VendingData>(context);

  const {
    coin_records,
    stock,
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
                product_color,
                product_name,
                prod_desc,
                ref,
              } = coin_record;
              return (
                <ProductEntry
                  stock={stock[product_name]}
                  key={product_name}
                  product_color={product_color}
                  product_name={product_name}
                  prod_desc={prod_desc}
                  prod_ref={ref} />
              );
            })}
          </LabeledList>
        )}
    </Section>
  );
};


type VendingProductEntryProps = {
  stock: number,
  product_color: string,
  product_name: string,
  prod_desc: string,
  prod_ref: string,
}

const ProductEntry = (props: VendingProductEntryProps, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    currently_vending,
  } = data;

  const {
    stock,
    product_color,
    product_name,
    prod_desc,
    prod_ref,
  } = props;

  const [
    showDesc,
    setShowDesc,
  ] = useLocalState(context, 'showDesc', null);

  return (
    <LabeledList.Item
      labelColor="white"
      buttons={
        <>
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
            selected={currently_vending.product_name === product_name}
            onClick={() => act(
              'vend',
              { vend: prod_ref })}
            disabled={!stock}>
            <Box color={product_color} bold={1}>
              Vend
            </Box>
          </Button>
        </>
      }
      label={decodeHtmlEntities(product_name)}>
      {!!prod_desc && (
        <Button
          onClick={() => setShowDesc(prod_desc)}>?
        </Button>)}
    </LabeledList.Item>
  );
};

const Hacked = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    hidden_records,
    stock,
  } = data;

  return (
    <Section title="$*FD!!F">
      <LabeledList>
        {hidden_records.map(hidden_record => {
          const {
            product_color,
            product_name,
            prod_desc,
            ref,
          } = hidden_record;
          return (
            <ProductEntry
              stock={stock[product_name]}
              key={product_name}
              product_color={product_color}
              product_name={product_name}
              prod_desc={prod_desc}
              prod_ref={ref} />
          );
        })}
      </LabeledList>
    </Section>
  );
};

const Products = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', false);

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', null);

  const {
    displayed_records,
    stock,
  } = data;

  return (
    <Section>
      <LabeledList>
        {displayed_records.length === 0 ? (
          <Box color="red">No product loaded!</Box>
        ) : (
          displayed_records
            .filter(record => !record.tab || record.tab === selectedTab)
            .map(display_record => {
              const {
                product_color,
                product_name,
                prod_desc,
                ref,
              } = display_record;
              return (
                ((showEmpty || !!stock[product_name]) && (
                  <ProductEntry
                    stock={stock[product_name]}
                    key={product_name}
                    product_color={product_color}
                    product_name={product_name}
                    prod_desc={prod_desc}
                    prod_ref={ref} />
                ))
              );
            })
        )}
      </LabeledList>
    </Section>
  );
};
