import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Trie "mo:base/Trie";
import TrieMap "mo:base/TrieMap";
import Blob "mo:base/Blob";
import BNat32 "mo:base/Nat32";

module {

  public type ID = Text;
  // equal
  public func idEqual(x : ID, y : ID) : Bool { x == y };


  public type Timestamp = Int; // See mo:base/Time and Time.now()

  
 // Value
 public type Value = {
    #blob : Blob;
    #bool : Bool;
    #float : Float;
    #int : Int;
    #nat : Nat;
    #text : Text;
    #array : [Value];
  };

  public type Icon = {
    id: Nat;
    name: Text;
    description: Text;
  }



}