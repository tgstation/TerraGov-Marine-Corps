import { useState } from 'react';
import { Button, Flex, Modal, TextArea } from 'tgui-core/components';

export const TextInputModal = (props: TextInputModalData) => {
  const { label, button_text, onSubmit, onBack, areaHeigh, areaWidth } = props;
  const [input, setInput] = useState('');

  return (
    <Modal id="grab-focus">
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {label}
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height={areaHeigh}
            width={areaWidth}
            backgroundColor="black"
            textColor="white"
            onChange={(value) => {
              setInput(value.substring(0, 300));
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
      <script type="application/javascript">
        {"document.getElementById('grab-focus').focus();"}
      </script>
    </Modal>
  );
};
