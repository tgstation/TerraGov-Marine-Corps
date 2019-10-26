import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, Box } from '../components';
import { decodeHtmlEntities } from 'common/string';

export const Vending = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      {data.currently_vending_name ? (
        <Section
          title={"You have selected "+data.currently_vending_name}
          buttons={
            <Button
              onClick={() => act(ref, 'cancel_buying')}
              icon="times">
              Cancel
            </Button>
          }>
          <Box>
            Please swipe your ID to pay for the article.
            <Button
              onClick={() => act(ref, 'swipe')}
              icon="id-card"
              ml={1}>
              Swipe
            </Button>
          </Box>
        </Section>
      ) : (
        (!!((data.premium_length > 0) || (data.isshared > 0))) && (
          <Section
            title={"Coin slot: "+(data.coin ? data.coin : "No coin inserted")}
            buttons={data.coin && (
              <Button
                icon="donate"
                onClick={() => act(ref, "remove_coin")}>
                Remove
              </Button>)}>
            {!!data.coin && (
              <Section title="Select an item">
                {data.coin_records.map(coin_record => (
                  <Box key={coin_record.id}>
                    <Button
                      selected={data.currently_vending_index === coin_record.prod_index}
                      onClick={() => act(ref, "vend", {vend: coin_record.prod_index, cat: coin_record.prod_cat})}
                      disabled={!coin_record.amount}>
                      <Box color={coin_record.product_color} bold={1}>
                        { decodeHtmlEntities(coin_record.product_name)}
                      </Box>
                    </Button>
                  </Box>
                ))}
              </Section>)}
          </Section>
        ))}
      {data.hidden_records.length > 0 && (
        <Section title="$*FD!!F">
          {data.hidden_records.map(hidden_record => (
            <Box key={hidden_record.id}>
              <Button
                selected={data.currently_vending_index === hidden_record.prod_index}
                onClick={() => act(ref, 'vend', {vend: hidden_record.prod_index, cat: hidden_record.prod_cat})}
                disabled={!hidden_record.amount}>
                <Box color={hidden_record.product_color} bold={1}>
                  { decodeHtmlEntities(hidden_record.product_name)}
                </Box>
              </Button>
            </Box>
          ))}
        </Section>
      )}
      <Section title="Select an item">
        {data.displayed_records.length > 0 ? (
          data.displayed_records.map(display_record => (
            <Box key={display_record.id}>
              <Button
                selected={data.currently_vending_index === display_record.prod_index}
                onClick={() => act(ref, 'vend', {vend: display_record.prod_index, cat: display_record.prod_cat})}
                disabled={!display_record.amount}>
                <Box color={display_record.product_color} bold={1}>
                  { decodeHtmlEntities(display_record.product_name)}
                </Box>
              </Button>
            </Box>
          ))
        ) : (
          <Box color="red">No product loaded!</Box>
        )}
      </Section>
    </Fragment>); };
