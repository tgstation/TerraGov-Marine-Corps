import { SetStateAction, useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Section,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Category } from './Category';
import { StaticMenus } from './constants';
import {
  getSupplyRequestCost,
  getSupplyRequestCostFromTypepathMap,
} from './helpers';
import { Pack } from './Pack';
import { CargoData, SupplyRequest } from './types';

export const Exports = (props) => {
  const { act, data } = useBackend<CargoData>();

  const { export_history } = data;

  return (
    <Section title="Exports">
      <Table>
        {export_history?.map((exp) => (
          <Table.Row key={exp.id}>
            <Table.Cell>{exp.name}</Table.Cell>
            <Table.Cell>
              {exp.amount} x {exp.points} points ({exp.total})
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

type OrderListProps = {
  type?: SupplyRequest[]; // Replace `any` with the specific type of the `type` array if known
  buttons?: React.ReactNode;
  readOnly?: BooleanLike;
  selectedMenu: string;
};

export const OrderList = (props: OrderListProps) => {
  const { act, data } = useBackend<CargoData>();
  const { currentpoints } = data;
  const { type, buttons, readOnly, selectedMenu } = props;
  if (!type) return;

  return (
    <Section title={selectedMenu} buttons={buttons}>
      {type.map((request) => {
        const { id, orderer_rank, orderer, authed_by, reason, packs } = request;
        const cost = getSupplyRequestCost(request);
        const rank = orderer_rank || '';

        return (
          <Section
            key={id}
            title={'Order #' + id}
            buttons={
              !readOnly && (
                <>
                  {(!authed_by || selectedMenu === 'Denied Requests') && (
                    <Button
                      onClick={() => act('approve', { id: id })}
                      icon="check"
                      color={currentpoints > cost ? 'green' : 'red'}
                    >
                      Approve
                    </Button>
                  )}
                  {!authed_by && (
                    <Button
                      onClick={() => act('deny', { id: id })}
                      icon="times"
                    >
                      Deny
                    </Button>
                  )}
                </>
              )
            }
          >
            <LabeledList>
              <LabeledList.Item label="Requested by">
                {rank + ' ' + orderer}
              </LabeledList.Item>
              <LabeledList.Item label="Reason">{reason}</LabeledList.Item>
              <LabeledList.Item label="Total Cost">
                {cost} points
              </LabeledList.Item>
              <LabeledList.Item label="Contents">
                {Object.keys(packs).map((pack) => (
                  <Pack key={pack} pack={pack} amount={packs[pack].amount} />
                ))}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </Section>
  );
};

type RequestsProps = {
  readOnly?: BooleanLike;
  selectedMenu: string;
};

export const Requests = (props: RequestsProps) => {
  const { act, data } = useBackend<CargoData>();
  const { readOnly, selectedMenu } = props;
  const { currentpoints, requests } = data;
  const totalrequestscosts = getSupplyRequestCost(requests);

  return (
    <OrderList
      type={requests}
      readOnly={readOnly}
      selectedMenu={selectedMenu}
      buttons={
        !readOnly && (
          <>
            <Button
              icon="check-double"
              color={currentpoints > totalrequestscosts ? 'good' : 'bad'}
              onClick={() => act('approveall')}
            >
              Approve All
            </Button>
            <Button icon="times-circle" onClick={() => act('denyall')}>
              Deny All
            </Button>
          </>
        )
      }
    />
  );
};

type ShoppingCartProps = {
  readOnly?: BooleanLike;
  selectedMenu: string;
  setSelectedMenu: React.Dispatch<SetStateAction<string | null>>;
};

export const ShoppingCart = (props: ShoppingCartProps) => {
  const { act, data } = useBackend<CargoData>();

  const { shopping_list, currentpoints } = data;
  const { readOnly, selectedMenu, setSelectedMenu } = props;
  const shopping_list_array = Object.keys(shopping_list || {});
  const [reason, setReason] = useState('');
  const shopping_list_cost = shopping_list
    ? getSupplyRequestCostFromTypepathMap(shopping_list)
    : 0;

  return (
    <Section>
      <Box textAlign="center">
        <Button
          p="5px"
          icon="dollar-sign"
          color={shopping_list_cost > currentpoints ? 'bad' : 'good'}
          disabled={(readOnly && !reason) || !shopping_list}
          onClick={() => {
            act(readOnly ? 'submitrequest' : 'buycart', {
              reason: reason,
            });
            setSelectedMenu(StaticMenus.AwaitingDelivery);
          }}
        >
          {readOnly ? 'Submit Request' : 'Purchase Cart'}
        </Button>
        <Button
          p="5px"
          disabled={!shopping_list}
          icon="snowplow"
          onClick={() => {
            act('clearcart');
            setSelectedMenu('');
          }}
        >
          Clear Cart
        </Button>
      </Box>
      {readOnly && (
        <>
          <Box width="10%" inline>
            Reason:{' '}
          </Box>
          <Input
            autoFocus
            placeholder="Reason"
            width="89%"
            inline
            expensive
            value={reason}
            onChange={setReason}
          />
        </>
      )}
      <Category
        selectedPackCat={shopping_list_array}
        selectedMenu={selectedMenu}
      />
    </Section>
  );
};
