export type Coordinate = {
  x : number,
  y : number;
}

export type ObjectData = {
  ref : string,
  coordinate : Coordinate,
  image? : string,
  marker_flags : number,
}

export type PlayerData = {
  ref : string, 
  coordinate : Coordinate,
  minimap_flags : number,
}

export type MinimapData = {
  map_name : string,
  map_size_x : number,
  map_size_y : number,
  view_size : number,
  zoomlevel : number,
  player_data : PlayerData,
  visible_objects_data : ObjectData[];
}

export type MinimapBlipProp = {
  coordinate : Coordinate;
  image? : string,
  zoom: number,
}

export const icon_size : number = 8;
export const minimapPadding : number = 10;
