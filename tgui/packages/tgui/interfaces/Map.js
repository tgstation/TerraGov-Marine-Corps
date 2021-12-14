import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const Map = (props, context) => {
  const { data } = useBackend(context);
  const { map_name, map_size_x, map_size_y } = data;

  const [isScrolling, setScrolling] = useLocalState(context, "is_scrolling", false);

  const [lastMousePos, setLastMousePos] = useLocalState(context, "last_mouse_pos", null);

  const startDragging = e => {
    setLastMousePos(null);
    setScrolling(true);
  };

  const stopDragging = e => {
    setScrolling(false);
  };

  const doDrag = e => {
    if (isScrolling) {
      const { screenX, screenY } = e;
      const element = document.getElementById("minimap");
      if (lastMousePos) {
        element.scrollLeft = element.scrollLeft + lastMousePos[0] - screenX;
        element.scrollTop = element.scrollTop + lastMousePos[1] - screenY;
      }
      setLastMousePos([screenX, screenY]);
    }
  };

  return (
    <Window
      width={500}
      height={500}
    >
      <Window.Content id="minimap">
        <div
          style={{
            'background-image': `url('minimap.${map_name}.png')`,
            'background-repeat': "no-repeat",
            'width': `${map_size_x}px`,
            'height': `${map_size_y}px`,
          }}
          onMouseDown={startDragging}
          onMouseUp={stopDragging}
          onMouseMove={doDrag}
        />
      </Window.Content>
    </Window>
  );
};
