export const idlFactory = ({ IDL }) => {
  const Icon = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const Test = IDL.Service({
    'appendCanisters' : IDL.Func([], [], []),
    'burn' : IDL.Func([], [], []),
    'createIcon' : IDL.Func([Icon], [], ['oneway']),
    'createIconMultiple' : IDL.Func([IDL.Vec(Icon)], [], ['oneway']),
    'generateRandomNumber' : IDL.Func([], [IDL.Nat], []),
    'test' : IDL.Func([], [], []),
    'testTime' : IDL.Func([], [], ['oneway']),
  });
  return Test;
};
export const init = ({ IDL }) => { return []; };
