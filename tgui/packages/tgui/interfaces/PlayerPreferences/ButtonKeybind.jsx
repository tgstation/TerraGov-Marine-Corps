import { Component } from 'react';
import { Button } from 'tgui-core/components';
import { globalEvents } from 'tgui-core/events';

// this used to be button.keybind
// it has been moved out of buttons/components due to tgui-core port
export class ButtonKeybind extends Component {
  constructor(props) {
    super(props);
    this.state = {
      focused: false,
      keysDown: {},
    };
  }

  preventPassthrough(key) {
    key.event.preventDefault();
  }

  doFinish() {
    const { onFinish } = this.props;
    const { keysDown } = this.state;

    const listOfKeys = Object.keys(keysDown).filter(
      (isTrue) => keysDown[isTrue],
    );

    onFinish(listOfKeys);
    document.activeElement.blur();
    clearInterval(this.timer);
  }

  handleKeyPress(e) {
    const { keysDown } = this.state;

    e.preventDefault();

    let pressedKey = e.key.toUpperCase();

    this.finishTimerStart(200);

    // Prevents repeating
    if (keysDown[pressedKey] && e.type === 'keydown') {
      return;
    }

    if (e.keyCode >= 96 && e.keyCode <= 105) {
      pressedKey = 'Numpad' + pressedKey;
    }

    keysDown[pressedKey] = e.type === 'keydown';
    this.setState({
      keysDown: keysDown,
    });
  }

  finishTimerStart(time) {
    clearInterval(this.timer);
    this.timer = setInterval(() => this.doFinish(), time);
  }

  doFocus() {
    this.setState({
      focused: true,
      keysDown: {},
    });
    this.finishTimerStart(2000);
    globalEvents.on('keydown', this.preventPassthrough);
  }

  doBlur() {
    this.setState({
      focused: false,
      keysDown: {},
    });
    globalEvents.off('keydown', this.preventPassthrough);
  }

  render() {
    const { focused, keysDown } = this.state;
    const { content, ...rest } = this.props;

    return (
      <Button
        {...rest}
        content={
          focused
            ? Object.keys(keysDown)
                .filter((isTrue) => keysDown[isTrue])
                .join('+') || content
            : content
        }
        selected={focused}
        inline
        onClick={(e) => {
          if (focused && Object.keys(keysDown).length) {
            this.doFinish();
            e.preventDefault();
          }
        }}
        onFocus={() => this.doFocus()}
        onBlur={() => this.doBlur()}
        onKeyDown={(e) => this.handleKeyPress(e)}
      />
    );
  }
}
