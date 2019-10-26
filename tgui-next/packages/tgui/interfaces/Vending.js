import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';

export const Vending = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      {data.currently_vending_name ? (
        <NoticeBox>
          <Box>
            You have selected {data.currently_vending_name}.
          </Box>
          <Box>
            Please swipe your ID to pay for the article.
          </Box>
          <Button
            onClick={() => act(ref, 'cancel_buying')}
            content="Cancel" />
        </NoticeBox>
      ) : (
        (!!((data.premium_length > 0) || (data.isshared > 0)))
          && (
            <Box inline>Coin slot: </Box>)+(
            data.coin ? (
              <Button
                onClick={() => act(ref, 'remove_coin')}>
                Remove
              </Button>
            ) : ('No coin inserted'))
      )}
      <Section label="Select an item:">
        {data.displayed_records.length > 0 ? (
          data.displayed_records.map(display_record => (
            <Box key={display_record.id}>
              <Button
                onClick={() => act(ref, 'vend', {vend: display_record.prod_index, cat: display_record.prod_cat})}
                disabled={!display_record.amount}>
                <Box color={display_record.product_color} bold="1">
                  {display_record.product_name}
                </Box>
              </Button>
            </Box>
          ))
        ) : (
          <Box color="red">No product loaded!</Box>
        )}
      </Section>
    </Fragment>); };
