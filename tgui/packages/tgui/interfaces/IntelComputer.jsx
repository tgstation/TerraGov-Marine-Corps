import { Component, Fragment } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export class FakeTerminal extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      currentIndex: 0,
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (state.currentIndex <= props.allMessages.length) {
      this.setState((prevState) => {
        return {
          currentIndex: prevState.currentIndex + 1,
        };
      });
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages[state.currentIndex]);
    } else {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const { linesPerSecond = 2.5 } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map((value) => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}

const DownloadProgress = (props) => (
  <Section title={`Running search.bat - ${props.current}%`} height="100%">
    <ProgressBar
      ranges={{
        good: [0.75, Infinity],
        average: [-Infinity, 0.75],
      }}
      value={props.current / 100}
    />
  </Section>
);

const Uploadprogress = (props) => (
  <Section title={`Running transmit.bat - ${props.current}%`} height="100%">
    <ProgressBar
      ranges={{
        good: [0.75, Infinity],
        average: [-Infinity, 0.75],
      }}
      value={props.current / 100}
    />
  </Section>
);

export const IntelComputer = (props) => {
  return (
    <Window width={400} height={500} theme="syndicate">
      <Window.Content scrollable>
        <IntelComputercontent />
      </Window.Content>
    </Window>
  );
};

export const IntelComputercontent = (props) => {
  const { act, data } = useBackend();

  const terminalMessages = [
    'WARNING UNREGISTERED USER...',
    'Override detected...',
    'ACCESS CONFIRMED...',
    'Contacting central database...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    'Awaiting response...',
    "Response received, welcome auth 'akjv9c88asdf12nb'...",
    'Credentials accepted. Welcome, akjv9c88asdf12nb...',
    'Installing OS from external drive...',
    'Installing...',
    'Installing...',
    'Installing...',
    'Installing...',
    'Installation complete...',
    'Connected to TGMC_Raptor_mainframe.mfg',
    'Connection established',
  ];

  if (!data.logged_in) {
    return (
      <Section minHeight="525px">
        <Box width="100%" textAlign="center">
          <Button.Confirm
            content="LOGIN REGISTERED USER"
            color="transparent"
            confirmContent="Confirm Military Override?"
            onClick={() => act('login')}
          />
        </Box>
        {!!data.error && <NoticeBox>{data.error}</NoticeBox>}
      </Section>
    );
  }
  if (data.logged_in && data.first_login) {
    return (
      <Box backgroundColor="rgba(0, 0, 0, 0.8)" minHeight="525px">
        <FakeTerminal
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('first_load')}
        />
      </Box>
    );
  }
  if (data.logged_in && !data.first_login && !data.printing && !data.printed) {
    return (
      <Section minHeight="525px">
        <Box width="100%" textAlign="center">
          <Button
            content="EXECUTE F:/DATA_RETRIEVAL.exe"
            color="transparent"
            onClick={() => act('start_progressing')}
          />
        </Box>
      </Section>
    );
  }

  if (data.printing && data.progress <= 50) {
    return (
      <Section title="EXECUTING F:/DATA_RETRIEVAL.exe">
        <DownloadProgress current={data.progress * 2} />
        <Uploadprogress current={0} />
      </Section>
    );
  }

  if (data.printing && data.progress >= 50) {
    return (
      <Section title="EXECUTING F:/DATA_RETRIEVAL.exe">
        <DownloadProgress current={100} />
        <Uploadprogress current={(data.progress - 50) * 2} />
      </Section>
    );
  }

  if (data.printed) {
    return (
      <Section title="F:/DATA_RETRIEVAL.exe returns SUCCESS">
        <DownloadProgress current={100} />
        <Uploadprogress current={100} />
      </Section>
    );
  }
};
