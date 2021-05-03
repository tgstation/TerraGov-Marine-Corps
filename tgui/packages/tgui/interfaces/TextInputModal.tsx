import { useLocalState } from "../../backend";
import { Button, Flex, Modal, TextArea } from "../../components";

type TextInputModalData = {
	label : string,
	button_text : string,
	onSubmit : Function,
	onBack : Function,
	areaHeigh : string,
	areaWidth : string,
}

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
    <Modal>
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
              setInput(value.substring(0, 25));
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
    </Modal>
  );
};
