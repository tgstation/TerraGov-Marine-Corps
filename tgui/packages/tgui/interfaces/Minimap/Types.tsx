export type Coordinate = {
  x : number,
  y : number;
}

export type ObjectData = {
  name : string,
  coordinate : Coordinate,
}

export type MinimapData = {
  map_name : string,
  map_size_x : number,
  map_size_y : number,
  view_size : number,
  player_data : ObjectData,
  visible_objects_data : ObjectData[];
}

export type MinimapObjectProp = {
  coordinate : Coordinate;
}

export const icon_size : number = 8;
export const minimapPadding : number = 10;