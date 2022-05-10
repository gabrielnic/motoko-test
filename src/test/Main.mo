import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import C1 "./C1";
import C2 "./C2";


shared ({caller = owner}) actor class Test() = this {

  public type EntityT = {
    created: Time.Time;
  };

  public type IconTest = EntityT and {
    name : Text;
  }; 

  // Use an actor reference to access the well-known, virtual
  // IC management canister with specified Principal "aaaaa-aa",
  // asserting its interface type
  // NB: this is a smaller supertype of the full interface at
  //     https://sdk.dfinity.org/docs/interface-spec/index.html#ic-management-canister
  let IC =
    actor "aaaaa-aa" : actor {

      create_canister : {
          // richer in ic.did
        } -> async { canister_id : Principal };

      canister_status : { canister_id : Principal } ->
        async { // richer in ic.did
          cycles : Nat
        };

      stop_canister : { canister_id : Principal } -> async ();

      delete_canister : { canister_id : Principal } -> async ();
    };

  // Burn half of this actor's cycle balance by provisioning,
  // creating, stopping and deleting a fresh canister
  // (without ever installing any code)

  let data = TrieMap.TrieMap<Text, IconTest>(Text.equal, Text.hash);

  type CanisterState = {
    canister : actor {};
    name : Text;
  };

  type CanisterData = {
    name: Text;
    balance: Nat;
  };

  private stable var canisters : [var ?CanisterState] = Array.init(2, null);

  public func appendCanisters() : async () {
    var c1 : CanisterState = {
      canister = await C1.C1();
      name = "C1";
    };
    var c2 : CanisterState = {
      canister = await C2.C2();
      name = "C2";
    };
    canisters[0] := ?c1;
    canisters[1] := ?c2;
  };

   public func test() : async () {
   
  };

  func getCanister(name : Text): async ?CanisterState {
    let cs: ?(?CanisterState) =  Array.find<?CanisterState>(Array.freeze(canisters), 
        func(cs: ?CanisterState) : Bool {
          switch (cs) {
            case null { false };
            case (?cs) {
             if (cs.name == name) {
               return true;
             };

             return false;
            };
          };
    });
    return do ? { 
        let c = cs!;
        let nb: ?CanisterState = switch (c) {
          case (?c) { ?(c) };
          case _ { null };
        };

        nb!;
    };

  };

  public func burn() : async () {
    Debug.print("balance before: " # Nat.toText(Cycles.balance()));
    Cycles.add(Cycles.balance()/2);
    let cid = await IC.create_canister({});
    let status = await IC.canister_status(cid);
    Debug.print("cycles: " # Nat.toText(status.cycles));
    await IC.stop_canister(cid);
    await IC.delete_canister(cid);
    Debug.print("balance after: " # Nat.toText(Cycles.balance()));
  };

};
