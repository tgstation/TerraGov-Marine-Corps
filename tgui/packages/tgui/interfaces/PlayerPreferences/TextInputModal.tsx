import { Button, Flex, Modal, TextArea } from "../../components";
import { useLocalState } from '../../backend';

export const TextInputModal = (props: TextInputModalData, context) => {

  const {
    label,
    button_text,
    onSubmit,
    onBack,
    areaHeigh,
    areaWidth,
  } = props;


  const [input, setInput] = useLocalState(context, label, "");

  return (
    <Modal id="grab-focus">
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {label}:
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height={areaHeigh}
            width={areaWidth}
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              setInput(value.substring(0, 300));
            }}
            value={input}
          />
        </Flex.Item>

        <Flex.Item>
          <Button
            content={button_text}
            color="good"
            tooltipPosition="right"
            onClick={() => {
              onSubmit(input);
            }}
          />
          <Button
            content="Cancel"
            color="bad"
            onClick={onBack}
          />
        </Flex.Item>
      </Flex>
      <script type="application/javascript">
        {"document.getElementById('grab-focus').focus();"}
      </script>
    </Modal>
  );
};
