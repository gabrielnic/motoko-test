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

  stable var upgradeIcon : [var (Text, ?Types.IconTest) ] = [var];
  // stable var upgradeIcon2 : [var ?(Text, Types.IconTest2) ] = [var];
  
   // public type Map<K, V> = TrieMap.TrieMap<K, V>;
  // type Map<X, Y> = Types.Map<X, Y>;
  var data = TrieMap.TrieMap<Text, Types.IconTest>(Text.equal, Text.hash);
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

  // blobFromText
  func blobFromText(t : Text) : Blob {

    // textToNat8
    // turns "123" into 123
    func textToNat8(txt : Text) : Nat8 {
      var num : Nat32 = 0;
      for (v in txt.chars()) {
        num := num * 10 + (Char.toNat32(v) - 48);  // 0 in ASCII is 48
      };
      Nat8.fromNat(Nat32.toNat(num));
    };

    let ts = Text.split(t, #char(','));
    let bytes = Array.map<Text, Nat8>(Iter.toArray(ts), textToNat8);
    Blob.fromArray(bytes);
  };

  public func testing() : async () {
     let u : Types.Test = {
      text = "test";
      num = 1;
    };
    // [Nat8] to text
    var txt: Text = textFromBlob(to_candid(u));
    // text to blob
    let v : ?Types.TA = from_candid(blobFromText(txt));
    Debug.print(debug_show(v));
    
    // Debug.print(debug_show(arr));
    // Debug.print(debug_show(arr.size()));
    // let buf = Buffer.Buffer<Text>(arr.size());
    //  for (v in arr.vals()) {
    //   buf.add(Nat8.toText(v));
    // };
    // Debug.print(debug_show(buf.size()));
    // // reconstruct blob array 
  
    // for (bb in buf.vals()) {
    //   var txt = "";
    //   for (c in bb.chars()){
    //     Prim.charToWord312(c);
    //       // txt := txt # c;
    //   };
    //   let nc = Nat32.toNat((Char.toNat32(txt)));
    //   Debug.print(debug_show(nc));
    //   // buf.add(Nat8.fromNat());
    // };
    // let bytes = buf.toArray();
    // Debug.print(debug_show(bytes));
    // Debug.print("size: " # Nat.toText(bytes.size()));

    // let newBlob = Blob.fromArray(bytes);
    // Debug.print(debug_show(newBlob));
    // Debug.print("size: " # Nat.toText(newBlob.size()));

    // from_candid
    // let v : ?Types.TA = from_candid(newBlob);
    
    
  };

  public shared(msg) func addTest() : async () {
   
    for (i in Iter.range(1, 100)) {
      let e : Types.IconTest = {
        name = "test" # Nat.toText(i);
        created = Time.now();
      };

      let _ = data.put("uuid" # Nat.toText(i), e);
    };
   
    Debug.print(debug_show(data.size() ));
  };



  public shared(msg) func getTest() : async () {
    Debug.print(debug_show(data.size() ));
    // Debug.print(debug_show(data2.size() ));
  };

  public shared(msg) func getOne(id: Text) : async () {
    Debug.print(debug_show(data.size() ));
    // Debug.print(debug_show(data2.size() ));
  };

// // loadAll
//   public func loadAll() : Iter.Iter<(Nat, Row<E>)> {
//     let size = data.size();
//     let buf = Buffer.Buffer<(Nat, Row<E>)>(size);
//     for ((id, e) in data.entries()) {
//       buf.add((id, e));
//     };
//     buf.vals();
//   };
 public shared(msg) func getAll(cursor: Nat, size: Nat) : async () {
    let buf = Buffer.Buffer<(Text, Types.IconTest)>(size);
    let mappedIter = Iter.filter(getAllITer(), func (x : (Text, Types.IconTest)) : Bool { x.1.created > cursor  });
    for (i in Iter.range(0, size-1)) {
      switch(mappedIter.next()) {
        case (?v) {
        buf.add(v);
        };
        case (_) {}
      };
      
    };
  };
  // starting index = 50 and size = 10;
   public shared(msg) func getAllRange(index: Nat, size: Nat) : async () {
    let buf = Buffer.Buffer<(Text, Types.IconTest)>(size);
    Iter.iterate<(Text, Types.IconTest)>(getAllITer(), func (x : (Text, Types.IconTest), i : Nat) {
      if (i >= index and i < index + size ) {
          buf.add(x);
      }
    });
  };

  func getAllITer() : Iter.Iter<(Text, Types.IconTest)> {
    data.entries()
  };

};
