import { Fragment, useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  Input,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { category_icon, useSupplyPacks } from './constants';
import { getSupplyRequestCostFromTypepathMap } from './helpers';
import { Pack } from './Pack';
import { CargoData } from './types';

type CategoryButtonProps = {
  icon: string;
  disabled?: boolean;
  id: string;
  mode: 'addone' | 'addall' | 'removeone' | 'removeall';
};

const CategoryButton = (props: CategoryButtonProps) => {
  const { act, data } = useBackend();
  const { icon, disabled, id, mode } = props;

  return (
    <Button
      icon={icon}
      disabled={disabled}
      onClick={() =>
        act('cart', {
          id: id,
          mode: mode,
        })
      }
    />
  );
};

type CategoryProps = {
  selectedPackCat: string[];
  should_filter?: BooleanLike;
  selectedMenu: string;
};

export const Category = (props: CategoryProps) => {
  const { act, data } = useBackend<CargoData>();

  const { shopping_list, currentpoints } = data;
  const shopping_list_cost = shopping_list
    ? getSupplyRequestCostFromTypepathMap(shopping_list)
    : 0;
  const spare_points = currentpoints - shopping_list_cost;
  const supplypacks = useSupplyPacks();
  if (!supplypacks) return;
  const { selectedPackCat, should_filter, selectedMenu } = props;

  const [filter, setFilter] = useState('');

  const filterSearch = (entry) =>
    should_filter && filter
      ? supplypacks[entry].name?.toLowerCase().includes(filter.toLowerCase())
      : true;

  return (
    <Section
      title={
        <>
          <Icon name={category_icon[selectedMenu]} mr="5px" />
          {selectedMenu}
        </>
      }
    >
      <Stack vertical>
        {should_filter && (
          <Stack.Item>
            <Input
              autoFocus
              placeholder="Search..."
              fluid
              onChange={setFilter}
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Table>
            {selectedPackCat.filter(filterSearch).map((entry) => {
              const shop_list = (shopping_list && shopping_list[entry]) || 0;
              const count = shop_list ? shop_list.amount : 0;
              const cost = supplypacks[entry].cost;
              return (
                <Table.Row key={entry}>
                  <Table.Cell width="130px">
                    <CategoryButton
                      icon="fast-backward"
                      disabled={!count}
                      id={entry}
                      mode="removeall"
                    />
                    <CategoryButton
                      icon="backward"
                      disabled={!count}
                      id={entry}
                      mode="removeone"
                    />
                    <Box width="25px" inline textAlign="center">
                      {!!count && <AnimatedNumber value={count} />}
                    </Box>
                    <CategoryButton icon="forward" id={entry} mode="addone" />
                    <CategoryButton
                      icon="fast-forward"
                      disabled={cost > spare_points}
                      id={entry}
                      mode="addall"
                    />
                  </Table.Cell>
                  <Table.Cell>
                    <Pack pack={entry} />
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
