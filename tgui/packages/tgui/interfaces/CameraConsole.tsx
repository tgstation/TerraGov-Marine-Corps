import { useState } from 'react';
import { Button, ByondUi, Flex, Input, Section } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const defaultRole = 'Other';

interface Camera {
  name: string;
  ref: string;
  role?: string;
}

interface CameraConsoleBaseProps {
  cameras: Camera[];
  activeCamera?: Camera;
}

interface CameraConsoleProps extends CameraConsoleBaseProps {
  mapRef?: string;
}

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
export const prevNextCamera = (cameras: Camera[], activeCamera: Camera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex((camera) => camera.ref === activeCamera.ref);
  return [cameras[index - 1]?.ref, cameras[index + 1]?.ref];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
export const selectCameras = (cameras?: Camera[], searchText = '') => {
  if (!cameras) {
    return [];
  }
  const useRoles = cameras.some((camera) => camera.role);

  let camerasToSort = cameras;
  if (useRoles) {
    camerasToSort = cameras.map((camera) => ({
      ...camera,
      role: camera.role || defaultRole,
    }));
  }

  const testSearch = createSearch(
    searchText,
    (camera: Camera) => camera.name + camera.role,
  );
  return camerasToSort
    .filter((camera) => camera?.name)
    .filter((camera) => !searchText || testSearch(camera))
    .sort((a, b) => {
      // prefer Other roles to be last
      if (a.role === defaultRole && b.role !== defaultRole) {
        return 1;
      }
      if (a.role !== defaultRole && b.role === defaultRole) {
        return -1;
      }
      return a.name.localeCompare(b.name);
    });
};

export const CameraConsole = () => {
  const { data } = useBackend<Partial<CameraConsoleProps>>();
  const { cameras, mapRef, activeCamera } = data;
  const filteredCameras = selectCameras(cameras);
  const [prevCameraRef, nextCameraRef] = prevNextCamera(
    filteredCameras,
    activeCamera || { ref: '', name: '' },
  );
  return (
    <Window width={870} height={708}>
      <div className="CameraConsole__left">
        <Window.Content scrollable>
          {cameras && cameras.length > 0 && (
            <CameraConsoleContent
              cameras={cameras}
              activeCamera={activeCamera}
            />
          )}
        </Window.Content>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {(activeCamera && activeCamera.name) || '—'}
        </div>
        <CameraConsoleList
          prevCameraRef={prevCameraRef}
          nextCameraRef={nextCameraRef}
        />
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }}
        />
      </div>
    </Window>
  );
};

interface CameraConsoleListProps {
  prevCameraRef: string;
  nextCameraRef: string;
}

export const CameraConsoleList = ({
  prevCameraRef,
  nextCameraRef,
}: CameraConsoleListProps) => {
  const { act } = useBackend();

  return (
    <div className="CameraConsole__toolbarRight">
      <Button
        icon="chevron-left"
        disabled={!prevCameraRef}
        onClick={() =>
          act('switch_camera', {
            ref: prevCameraRef,
          })
        }
      />
      <Button
        icon="chevron-right"
        disabled={!nextCameraRef}
        onClick={() =>
          act('switch_camera', {
            ref: nextCameraRef,
          })
        }
      />
    </div>
  );
};

export const CameraConsoleContent = ({
  activeCamera,
  cameras,
}: CameraConsoleBaseProps) => {
  const [searchText, setSearchText] = useState('');
  const useRoles = cameras.some((camera) => camera.role);
  const filteredCameras = selectCameras(cameras, searchText);
  return (
    <Flex direction={'column'} height="100%">
      <Flex.Item>
        <Input
          autoFocus
          fluid
          mt={1}
          placeholder="Search for a camera"
          onChange={setSearchText}
        />
      </Flex.Item>
      <Flex.Item height="100%">
        <Section fill scrollable>
          <CameraRoles
            cameras={filteredCameras}
            activeCamera={activeCamera}
            useRoles={useRoles}
          />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

interface CameraRoleProps extends CameraConsoleBaseProps {
  useRoles: boolean;
}
export const CameraRoles = ({
  cameras,
  activeCamera,
  useRoles,
}: CameraRoleProps) => {
  if (!cameras) {
    return null;
  }

  // Group cameras by role
  const rolesCameras: Record<string, Camera[]> = {};
  for (let i = 0; i < cameras.length; i++) {
    const role = cameras[i].role || defaultRole;
    if (!rolesCameras[role]) {
      rolesCameras[role] = [];
    }
    rolesCameras[role].push(cameras[i]);
  }

  // Render each role group
  return Object.entries(rolesCameras).map(([role, cameras]) => {
    return (
      <div key={role}>
        {useRoles && <div className="CameraConsole__role">{role}</div>}
        <CameraEntries cameras={cameras} activeCamera={activeCamera} />
      </div>
    );
  });
};

export const CameraEntries = ({
  cameras,
  activeCamera,
}: CameraConsoleBaseProps) => {
  const { act } = useBackend();
  return cameras.map((camera) => (
    // We're not using the component here because performance
    // would be absolutely abysmal (50+ ms for each re-render).
    <div
      key={camera.name}
      title={camera.name}
      className={classes([
        'Button',
        'Button--fluid',
        'Button--color--transparent',
        'Button--ellipsis',
        activeCamera && camera.ref === activeCamera.ref && 'Button--selected',
      ])}
      onClick={() =>
        act('switch_camera', {
          ref: camera.ref,
        })
      }
    >
      {camera.name}
    </div>
  ));
};
