import type { Principal } from '@dfinity/principal';
export interface Test {
  'appendCanisters' : () => Promise<undefined>,
  'burn' : () => Promise<undefined>,
  'test' : () => Promise<undefined>,
}
export interface _SERVICE extends Test {}
