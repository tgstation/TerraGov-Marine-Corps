import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, LabeledList, ProgressBar, Modal, Divider, Tabs, Stack } from '../components';
import { Window } from '../layouts';


type VendingData = {
  vendor_name: string,
  displayed_records: VendingRecord[],
  hidden_records: VendingRecord[],
  coin_records: VendingRecord[],
  tabs: string[],
  stock: VendingStock,
  currently_vending: VendingRecord | null,
  extended: number,
  coin: string,
  ui_theme: string,
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
    extended,
    tabs,
    ui_theme,
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
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[0] : null);

  return (
    <Window
      title={vendor_name || "Vending Machine"}
      width={500}
      height={600}
      theme={ui_theme}>
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
            <Buying
              vending={currently_vending} />
          </Modal>
        )
      )}
      <Window.Content scrollable>
        <Section
          title="Select an item"
          buttons={
            <>
              <Button
                icon="power-off"
                selected={showEmpty}
                onClick={() => setShowEmpty(!showEmpty)}>
                Show sold-out items
              </Button>
              <Button
                icon="truck-loading"
                color="good"
                tooltip="Stock all loose items in the outlet back into the vending machine"
                onClick={() => act('vacuum')} />
            </>
          }>
          {(tabs.length > 0 && (
            <Section
              lineHeight={1.75}
              textAlign="center">
              <Tabs>
                <Stack
                  wrap="wrap">
                  {tabs.map(tabname => {
                    return (
                      <Stack.Item
                        m={0.5}
                        grow={tabname.length}
                        basis={"content"}
                        key={tabname}>
                        <Tabs.Tab
                          selected={tabname === selectedTab}
                          onClick={() => setSelectedTab(tabname)}>
                          {tabname}
                        </Tabs.Tab>
                      </Stack.Item>
                    );
                  })}
                </Stack>
              </Tabs>
              <Divider />
            </Section>
          ))}
          {!!(coin_records.length > 0) && (
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

type BuyingModalProps = {
  vending: VendingRecord,
};

const Buying = (props: BuyingModalProps, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    vending,
  } = props;

  return (
    <Section
      title={"You have selected "+vending.product_name}>
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
  ] = useLocalState<String|null>(context, 'showDesc', null);

  return (
    <LabeledList.Item
      labelColor="white"
      buttons={
        <>
          {stock >= 0 && (
            <Box inline>
              <ProgressBar
                value={stock}
                maxValue={stock}
                ranges={{
                  good: [10, Infinity],
                  average: [5, 10],
                  bad: [0, 5],
                }}>{stock} left
              </ProgressBar>
            </Box>)}
          <Box
            inline
            width="4px" />
          <Button
            selected={currently_vending && (
              currently_vending.product_name === product_name
            )}
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
      label={product_name}>
      {!!prod_desc && (
        <Button
          onClick={() => setShowDesc(prod_desc)}>?
        </Button>)}
    </LabeledList.Item>
  );
};


const Products = (props, context) => {
  const { data } = useBackend<VendingData>(context);

  const {
    displayed_records,
    stock,
    tabs,
  } = data;

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[0] : null);

  const [
    showEmpty,
    setShowEmpty,
  ] = useLocalState(context, 'showEmpty', false);

  return (
    <Section>
      <LabeledList>
        {displayed_records.length === 0 ? (
          <Box color="red">No product loaded!</Box>
        ) : (
          displayed_records
            .filter(record => !record.tab || record.tab === selectedTab)
            .map(display_record => {
              return (
                ((showEmpty || !!stock[display_record.product_name]) && (
                  <ProductEntry
                    stock={stock[display_record.product_name]}
                    key={display_record.product_name}
                    product_color={display_record.product_color}
                    product_name={display_record.product_name}
                    prod_desc={display_record.prod_desc}
                    prod_ref={display_record.ref} />
                ))
              );
            })
        )}
      </LabeledList>
    </Section>
  );
};

const Hacked = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    hidden_records,
    stock,
    tabs,
  } = data;

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[0] : null);

  return (
    <Section title="$*FD!!F">
      <LabeledList>
        {hidden_records
          .filter(record => !record.tab || record.tab === selectedTab)
          .map(hidden_record => {
            return (
              <ProductEntry
                stock={stock[hidden_record.product_name]}
                key={hidden_record.product_name}
                product_color={hidden_record.product_color}
                product_name={hidden_record.product_name}
                prod_desc={hidden_record.prod_desc}
                prod_ref={hidden_record.ref} />
            );
          })}
      </LabeledList>
    </Section>
  );
};


const Premium = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);

  const {
    coin_records,
    stock,
    coin,
    tabs,
  } = data;

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', tabs.length ? tabs[0] : null);

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
            {coin_records
              .filter(record => !record.tab || record.tab === selectedTab)
              .map(coin_record => {
                return (
                  <ProductEntry
                    stock={stock[coin_record.product_name]}
                    key={coin_record.product_name}
                    product_color={coin_record.product_color}
                    product_name={coin_record.product_name}
                    prod_desc={coin_record.prod_desc}
                    prod_ref={coin_record.ref} />
                );
              })}
          </LabeledList>
        )}
    </Section>
  );
};
