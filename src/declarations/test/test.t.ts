import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Icon { 'id' : bigint, 'name' : string, 'description' : string }
export interface Test {
  'appendCanisters' : ActorMethod<[], undefined>,
  'burn' : ActorMethod<[], undefined>,
  'createIcon' : ActorMethod<[Icon], undefined>,
  'createIconMultiple' : ActorMethod<[Array<Icon>], undefined>,
  'generateRandomNumber' : ActorMethod<[], bigint>,
  'test' : ActorMethod<[], undefined>,
  'testTime' : ActorMethod<[], undefined>,
}
export interface _SERVICE extends Test {}
