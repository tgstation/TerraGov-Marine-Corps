export const hexToRGB = function (hex: string, alpha: number): string {
  let r = parseInt(hex.slice(1, 3), 16);
  let g = parseInt(hex.slice(3, 5), 16);
  let b = parseInt(hex.slice(5, 7), 16);

  return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + alpha + ')';
};

export const objectToArray = (objectArray: Object) => {
  return Object.keys(objectArray).map((key) => objectArray[key]);
};
