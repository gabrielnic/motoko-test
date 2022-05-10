export const idlFactory = ({ IDL }) => {
  const Test = IDL.Service({
    'appendCanisters' : IDL.Func([], [], []),
    'burn' : IDL.Func([], [], []),
    'test' : IDL.Func([], [], []),
  });
  return Test;
};
export const init = ({ IDL }) => { return []; };
