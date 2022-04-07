import { useBackend } from '../backend';
import { Button, NumberInput, Flex, Table, Input } from '../components';
import { Window } from '../layouts';

export const Mortar = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    X,
    Y,
    DX,
    DY,
    last_three_inputs,
  } = data;
  return (
    <Window
      width={450}
      height={180}>
      <Window.Content>
        <Flex direction="column" justify="space-between">
          <Flex.Item>
            <Flex direction="row" justify="space-between">
              <Flex.Item>
                LONGITUDE
              </Flex.Item>
              <Flex.Item>
                LATITUDE
              </Flex.Item>
              <Flex.Item>
                LONGITUDE OFFSET
              </Flex.Item>
              <Flex.Item>
                LATITUDE OFFSET
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item>
            <Flex direction="row" justify="space-between">
              <Flex.Item>
                <NumberInput
                  value={X}
                  minValue={0}
                  maxValue={255}
                  width="43px"
                  onChange={(e, value) => act("change_target_x", {
                    target_x: value,
                  })} />
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={Y}
                  minValue={0}
                  maxValue={255}
                  width="43px"
                  onChange={(e, value) => act("change_target_y", {
                    target_y: value,
                  })} />
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={DX}
                  minValue={-10}
                  width="43px"
                  maxValue={10}
                  onChange={(e, value) => act("change_dial_x", {
                    dial_one: value,
                  })} />
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={DY}
                  minValue={-10}
                  maxValue={10}
                  width="43px"
                  onChange={(e, value) => act("change_dial_y", {
                    dial_two: value,
                  })} />
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item>
            <Flex direction="row">
              <Button
                content="Save 1:"
                inline
                onClick={() => act("change_saved_coord_one", {
                  name: last_three_inputs["coords_one"]["name"],
                })} />
              <Button
                content="Save 2:"
                inline
                onClick={() => act("change_saved_coord_two", {
                  name: last_three_inputs["coords_two"]["name"],
                })} />
              <Button
                content="Save 3:"
                inline
                onClick={() => act("change_saved_coord_three", {
                  name: last_three_inputs["coords_three"]["name"],
                })} />
            </Flex>
          </Flex.Item>
          <Flex.Item>
            <Table justify="space-evenly">
              <Table.Row>
                <Table.Cell>
                  <Button
                    content="Select:"
                    onClick={() => act("set_saved_coord_one")} />
                </Table.Cell>
                <Table.Cell>
                  <Input
                    value={last_three_inputs["coords_one"]["name"]}
                    width="100px"
                    onChange={(e, value) => act("change_saved_one_name", {
                      name: value,
                    })} />
                </Table.Cell>
                {Object.values(last_three_inputs["coords_one"]).map(
                  (coordsinput, i) => (
                    <Table.Cell key={"coords_one_" + i}>
                      {coordsinput}
                    </Table.Cell>
                  ))}
              </Table.Row>
              <Table.Row>
                <Table.Cell>
                  <Button
                    content="Select:"
                    onClick={() => act("set_saved_coord_two")} />
                </Table.Cell>
                <Table.Cell>
                  <Input
                    value={last_three_inputs["coords_two"]["name"]}
                    width="100px"
                    onChange={(e, value) => act("change_saved_two_name", {
                      name: value,
                    })} />
                </Table.Cell>
                {Object.values(last_three_inputs["coords_two"]).map(
                  (coordsinput, i) => (
                    <Table.Cell key={"coords_two_" + i}>
                      {coordsinput}
                    </Table.Cell>
                  ))}
              </Table.Row>
              <Table.Row>
                <Table.Cell>
                  <Button
                    content="Select:"
                    onClick={() => act("set_saved_coord_three")} />
                </Table.Cell>
                <Table.Cell>
                  <Input
                    value={last_three_inputs["coords_three"]["name"]}
                    width="100px"
                    onChange={(e, value) => act("change_saved_three_name", {
                      name: value,
                    })} />
                </Table.Cell>
                {Object.values(last_three_inputs["coords_three"]).map(
                  (coordsinput, i) => (
                    <Table.Cell key={"coords_three_" + i}>
                      {coordsinput}
                    </Table.Cell>
                  ))}
              </Table.Row>
            </Table>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
