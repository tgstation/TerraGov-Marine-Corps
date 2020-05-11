import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, ProgressBar, LabeledList, Modal, Flex, Divider, Collapsible, AnimatedNumber } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { LabeledListItem } from '../components/LabeledList';
import { logger } from '../logging';
import { map } from 'common/collections';
import { FlexItem } from '../components/Flex';
import { Table, TableRow, TableCell } from '../components/Table';

export const Cargo = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    selectedMenu,
    setSelectedMenu,
  ] = useLocalState(context, 'selectedMenu', null);

  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'selectedCategory', 0);

  const {
    categories,
    supplypacks,
    currentpoints,
  } = data;

  const selectedPackCat = selectedCategory ? supplypacks[selectedMenu] : null;

  return (
    <Window resizable>
      <Flex>
        <Flex.Item width="150px">
          Points: <AnimatedNumber value={currentpoints} />
          <Divider/>
          <Button
            onClick={() => setSelectedMenu("pendingorder")}
            selected={selectedMenu==="pendingorder"}>Pending Order</Button>
          <Button
          onClick={() => setSelectedMenu("requests")}
          selected={selectedMenu==="requests"}>Requests</Button>
          <Divider/>
          { categories.map(category => (
            <Fragment>
              <Button key={category.id} selected={selectedMenu === category}
                onClick={() => {setSelectedMenu(category); setSelectedCategory(1)}}>
                {category}
              </Button>
              <br/>
            </Fragment>
          )) }
        </Flex.Item>
        <Flex.Item position="relative" grow={1}>
          <Window.Content scrollable>
            {!!selectedPackCat &&
              selectedPackCat.map(entry => (
              <Fragment>
                <Flex>
                  <FlexItem>
                    <Button>Buy</Button>
                  </FlexItem>
                  <FlexItem grow={1}>
                    <Collapsible
                      title={entry.name}
                      color="gray"
                    >
<Table>
  <TableRow>
    <TableCell>
    Container Type:
    </TableCell>
    <TableCell>
    {entry.container_name}
    </TableCell>
  </TableRow>
                      { map((contententry) => (

                          <TableRow>
                            <TableCell width="50%">
                            {contententry.name}
                            </TableCell>
                            <TableCell>
                            x {contententry.count}
                            </TableCell>
                          </TableRow>
                      ))(entry.contains) }
                      </Table>
                      <Divider/>
                    </Collapsible>
                  </FlexItem>
                  <FlexItem basis="30px" shrink={0} textAlign="right">
                    {entry.cost}
                  </FlexItem>
                </Flex>
              </Fragment>
            ))}
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};
