import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Random "mo:base/Random";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import TrieMap "mo:base/TrieMap";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import C1 "./C1";
import C2 "./C2";
import Types "./Types";


shared ({caller = owner}) actor class Test() = this {

  public type EntityT = {
    created: Time.Time;
  };

  public type IconTest = EntityT and {
    name : Text;
  }; 


  public shared ({ caller }) func createIcon (e: Types.Icon) : () {

  };

  public shared ({ caller }) func createIconMultiple (e: [Types.Icon]) : () {

  };

  public shared ({ caller }) func testTime () : () {
    Debug.print(debug_show(Time.now()));
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
    var t: Types.Value = #array(Array.make<Types.Value>(#text "test"));
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

  func getByte(f : Random.Finite) : Nat {
    let b: ?Bool = f.coin();
    switch(b){
      case (?b) {
        Debug.print(debug_show(b));
        if (b == true) 1 else 0; 
      };
      case (_) return 0;
    }
  };

  public func generateRandomNumber() : async Nat {
    Debug.print("dawdaw");
    let entropy = await Random.blob(); // get initial entropy
    var f = Random.Finite(entropy);
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    Debug.print(debug_show(f.coin()));
    // let b1 = getByte1(f);
    // Debug.print(Nat8.toText(b1)); //expression of type ?Nat8 cannot produce expected type TextMotoko
    var b2 = getByte(f);
    return b2;
  };

  // stable var upgradeIcon : [var (Text, ?Types.IconTest) ] = [var];
  // stable var upgradeIcon2 : [var ?(Text, Types.IconTest2) ] = [var];
  
   // public type Map<K, V> = TrieMap.TrieMap<K, V>;
  // type Map<X, Y> = Types.Map<X, Y>;
  // var data2 = TrieMap.TrieMap<Text, Types.IconTest2>(Text.equal, Text.hash);

  // system func preupgrade() {
  //     upgradeIcon := Array.init<(Text, ?Types.IconTest)>(data.size(), ("", null));
  //     // upgradeIcon2 := Array.init<?(Text, Types.IconTest2)>(data2.size(), ("", null));
  //      do {
  //       var i = 0;
  //       for ((x, y) in data.entries()) {
  //         upgradeIcon[i] := (x, ?y);
  //         i += 1;
  //       };
  //      };
  //     // do {
  //     //   var i = 0;
  //     //   for ((x, y) in data2.entries()) {
  //     //     upgradeIcon2[i] := (x, y);
  //     //     i += 1;
  //     //   };
  //     // };
  // }; 

  // system func postupgrade() {
  //   for ((k,v) in upgradeIcon.vals()) {
  //     switch(v) {
  //       case(?v) {
  //         data.put(k,v);
  //       };
  //       case (_) {};
  //     };
  //   };
  //   // for ((k,v) in upgradeIcon2.vals()) {
  //   //   data2.put(k,v);
  //   // };
  //   upgradeIcon := [var];
  //   // upgradeIcon2 := [var];
  // };
 // textFromBlob
  func textFromBlob(blob : Blob) : Text {
    Text.join(",", Iter.map<Nat8, Text>(blob.vals(), Nat8.toText));
  };


};


