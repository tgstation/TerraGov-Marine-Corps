import { useBackend } from '../backend';
import { Box, Button, Section, NumberInput, Flex, Table, LabeledList } from '../components';
import { Window } from '../layouts';

export const Mortar = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    X,
    Y,
    D1,
    D2,
   
  } = data;
  var firstcoords = data.last_three_inputs[0] || [];
  return (
    <Window
      resizable>
      <Window.Content>
        <Flex direction = "column"  justify = "space-between">
          <Flex.Item>
            <Flex direction = "row" justify = "space-between">
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
            <Flex direction = "row" justify = "space-between">
              <Flex.Item>
                <NumberInput
                  value={X}
                  minValue={0}
                  maxValue={255}
                  width="43px"
                  onChange={(e, value) => act("change_target_x", {
                  target_x: value, 
                  })}>
                </NumberInput>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={Y}
                  minValue={0}
                  maxValue={255}
                  width="43px"
                  onChange={(e, value) => act("change_target_y", {
                  target_y: value,
                  })}>
                </NumberInput>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={D1}
                  minValue={0}
                  width="43px"
                  maxValue={10}
                  onChange={(e, value) =>  act("change_dial_x", {
                  dial_one: value,
                  })}>
                </NumberInput>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  value={D2}
                  minValue={0}
                  maxValue={10}
                  width="43px"
                  onChange={(e, value) =>  act("change_dial_y",{
                  dial_two: value,
                  })}>
                </NumberInput>
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item>
            <Table justify = "space-evenly">
              <Table.Row>
                <Table.Cell bold>
                  Button
                </Table.Cell>
                <Table.Cell> 
                </Table.Cell>
                <Table.Cell>
                  coordy
                </Table.Cell>
                <Table.Cell>
                  dialx
                </Table.Cell>
                <Table.Cell>
                  dialy
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>
                  Button
                </Table.Cell>
                <Table.Cell>
                  coordx
                </Table.Cell>
                <Table.Cell>
                  coordy
                </Table.Cell>
                <Table.Cell>
                  dialx
                </Table.Cell>
                <Table.Cell>
                  dialy
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell bold>
                  Button
                </Table.Cell>
                <Table.Cell>
                  coordx
                </Table.Cell>
                <Table.Cell>
                  coordy
                </Table.Cell>
                <Table.Cell>
                  dialx
                </Table.Cell>
                <Table.Cell>
                  dialy
                </Table.Cell>
              </Table.Row>
            </Table>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
