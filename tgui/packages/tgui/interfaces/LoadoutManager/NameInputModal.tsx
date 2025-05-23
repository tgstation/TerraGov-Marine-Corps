import { useState } from 'react';
import { Button, Flex, Modal, TextArea } from 'tgui-core/components';

import { NameInputModalData } from './Types';

export const NameInputModal = (props: NameInputModalData) => {
  const { label, button_text, onSubmit, onBack } = props;
  const [input, setInput] = useState('');

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {label}:
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            autoFocus
            height="10vh"
            width="70vw"
            backgroundColor="black"
            textColor="white"
            onChange={(value) => {
              setInput(value.substring(0, 150));
            }}
            value={input}
          />
        </Flex.Item>

        <Flex.Item>
          <Button
            color="good"
            tooltipPosition="right"
            onClick={() => {
              onSubmit(input);
              setInput('');
            }}
          >
            {button_text}
          </Button>
          <Button
            color="bad"
            onClick={() => {
              onBack(input);
            }}
          >
            Cancel
          </Button>
        </Flex.Item>
      </Flex>
    </Modal>
  );
};
