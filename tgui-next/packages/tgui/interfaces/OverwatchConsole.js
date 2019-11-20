import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, NoticeBox, Section, Flex, Box, LabeledList, Table, Tabs } from '../components';


const LoginRequired = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section title={"Unauthorized Access"}>
        <NoticeBox>
          Authentication required
        </NoticeBox>

        <em style={{ margin: '15px', display: 'block' }}>
          In order to use this console you must authenticate yourself.
        </em>
        <Flex justify={'center'} align={'center'}>
          <Flex.Item>
            <Button onClick={() => act(ref, 'change_operator', {})}>
              Authenticate
            </Button>
          </Flex.Item>
        </Flex>
      </Section>
    </Fragment>
  );
}

const Main = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    current_squad,
    squad_leader = null,
    primary_objective = null,
    secondary_objective = null
  } = data;

  const squad = current_squad ? `Overwatch: ${current_squad}` : "No Squad selected";

  return (
    <Fragment>

      <Section title={"Squad details"}>
        <Flex justify={"space-between"}>
          <Flex.Item>
            <strong>Overwatch:</strong> {current_squad || "No Squad"}
          </Flex.Item>
          <Flex.Item>
            <Button onClick={() => act(ref, 'pick_squad', {})}>
            Select Squad
            </Button>
          </Flex.Item>
        </Flex>

        <Flex justify={"space-between"}>
          <Flex.Item>
            <strong>Squad Lead:</strong> {squad_leader || "No squad lead"}
          </Flex.Item>
          <Flex.Item>
            <Button onClick={() => act(ref, 'change_lead', {})}>
              Change Lead
            </Button>
          </Flex.Item>
        </Flex>
      </Section>

      <Section>
        <Flex>
          <Button onClick={() => act(ref, 'message', {})}>
            Message Squad
          </Button>
          <Button disabled={(squad_leader == null)} onClick={() => act(ref, 'sl_message', {})}>
            Message Leader
          </Button>

          <Button onClick={() => act(ref, 'insubordination', {})}>
            Mark Insubordination
          </Button>
          <Button onClick={() => act(ref, 'squad_transfer', {})}>
            Transfer Marine
          </Button>
        </Flex>
      </Section>

      <Section title={"Primary Objective"}>
        <Section level={3}>
          {primary_objective || "No primary objective set"}
        </Section>
        <Button onClick={() => act(ref, 'set_primary', {})}>
          Update Objective
        </Button>
      </Section>
      <Section title={"Secondary Objective"}>
        <Section level={3}>
          {secondary_objective || "No secondary objective set"}
        </Section>
        <Button onClick={() => act(ref, 'set_secondary', {})}>
          Update Objective
        </Button>
      </Section>
    </Fragment>
  );
}

const Monitor = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const { monitor_members } = data;


  const renderMember = (member) => (
    <tr>
      <td>
        <Button onClick={() => act(ref, 'use_cam', {"cam_target": member.ref})}>
          {member.name}
        </Button>
      </td>
      <td>{member.role}</td>
      <td>{member.fire_team || 'unassigned'}</td>
      <td>{member.area_name}</td>
      <td>{member.mob_state}</td>
      <td>{member.dist} ({member.direction})</td>
    </tr>
  );

  return (
    <Fragment>
      <Section title={"Squad Members"}>
        <table style={{ width: '100%' }}>
          <thead>
            <tr>
              <strong>
                <td>Name</td>
                <td>Rank</td>
                <td>Fire Team</td>
                <td>Area</td>
                <td>State</td>
                <td>Distance</td>
              </strong>
            </tr>
          </thead>
          <tbody>
            {monitor_members.map(m => renderMember(m))}
          </tbody>
        </table>
      </Section>
      <Section>
        Actions:
      </Section>
    </Fragment>

  );
}

const Supply = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const { supply_can_launch, supply_time_left, supply_valid_beacon, supply_x_offset, supply_y_offset } = data;

  const time_left = Math.max(Math.round(supply_time_left * 0.1, 0), 0);
  return (
  <Fragment>
    <Section title={"Supply"}>

    <LabeledList>

      <LabeledList.Item label="Can Launch">
        {supply_can_launch ? 'True':'False'}
      </LabeledList.Item>

      <LabeledList.Item label="Squad Beacon">
        {supply_valid_beacon ? <font color='green'>Transmitting!</font> : 'Not Transmitting'}
      </LabeledList.Item>

      <br />

      <LabeledList.Item label="Time left">
        {time_left} seconds
      </LabeledList.Item>

      <br />

      <LabeledList.Item label="X Offset">
        {supply_x_offset} <Button onClick={() => act(ref, 'supply_x', {})}>Update</Button>
      </LabeledList.Item>

      <LabeledList.Item label="Y Offset">
        {supply_y_offset} <Button onClick={() => act(ref, 'supply_y', {})}>Update</Button>
      </LabeledList.Item>
    </LabeledList>

    <br />

    <Section>
      <Button disabled={!supply_can_launch} onClick={() => act(ref, 'dropsupply', {})}>Launch</Button>
    </Section>

    </Section>
  </Fragment>
  );
}


export const OverwatchConsole = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const { logged_in, current_page, operator_name } = data;

  if(!logged_in) {
    return (<LoginRequired {...props} />);
  }

  return (
    <Fragment>
      <Section title={"Overwatch"}>
        <Flex justify={"space-between"}>
          <Flex.Item>
          </Flex.Item>
          <Flex.Item>
          <span style={{ margin: '0 5px' }}> Welcome, <strong>{operator_name}</strong></span>
          <Button onClick={() => act(ref, 'logout', {})}>
            Logout
          </Button>
          </Flex.Item>
        </Flex>
      </Section>

      <Tabs>
        <Tabs.Tab
          label="Main"
          content={<Main {...props} />}
        />
        <Tabs.Tab
          label="Monitor"
          content={<Monitor {...props} />}
        />
        <Tabs.Tab
          label="Supply"
          content={<Supply {...props} />}
        />
      </Tabs>
    </Fragment>
  );
};
