import Types "./Types";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import TrieMap "mo:base/TrieMap";
import Cycles "mo:base/ExperimentalCycles";

shared ({caller = owner}) actor class C2 () = this {

  type ID = Types.ID;

  private let limit = 20_000_000_000_000;

  public type EntityT = {
    created: Time.Time;
  };

  public type E1 = EntityT and {
    name : Text;
  }; 

  public type E2 = EntityT and {
    name : Text;
  }; 

  let e1d = TrieMap.TrieMap<Types.ID, E1>(Text.equal, Text.hash);
  let e2d = TrieMap.TrieMap<ID, E2>(Text.equal, Text.hash);

  // Test
  public shared query({ caller }) func loadE1() : async () {
    Debug.print("works from c2 of e1!");
  };


  public func getSize(): async Nat {
    Debug.print("canister balance: " # Nat.toText(Cycles.balance()));
    Prim.rts_memory_size();
  };

  public func wallet_receive() : async { accepted: Nat64 } {
    let available = Cycles.available();
    let accepted = Cycles.accept(Nat.min(available, limit));
    { accepted = Nat64.fromNat(accepted) };
  };

  public func wallet_balance() : async Nat {
    return Cycles.balance();
  };

};