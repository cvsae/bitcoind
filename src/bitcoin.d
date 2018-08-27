// Copyright (c) 2009 Satoshi Nakamoto
// Copyright (c) 2018 Cvsae
// Distributed under the MIT/X11 software license, see the accompanying
// file license http://www.opensource.org/licenses/mit-license.php.

import std.stdio;
import std.format;
import std.conv : to;
import std.digest.sha;
import std.digest;
import std.algorithm;
import std.range;
import std.bigint;
import std.bitmanip;
import std.uni;
import core.stdc.stdint;

import uint256;
import utils;


const uint64_t COIN = 100000000;



string CompactSize(int x){
  if(x < 253){
    return format("%c", to!char(x));
  }

  return "";
}



class COutPoint{
public:
  Uint256 hash = new Uint256();
  int n;

  this(){
    SetNull();
  }

  this(Uint256 hashIn, uint nIn) { 
    hash = hashIn; 
    n = nIn; 
  }

  bool IsNull() const { 
    return (hash == new Uint256(0)  && n == -1); 
  }

  void SetNull(){ 
    hash = 0; 
    n = -1; 
  }

  bool opEquals(const COutPoint a, const COutPoint b) const{
    return a.hash == b.hash && a.n == b.n;
  }

  



  string ToString() const{
    writeln(hash == hash);
    return format("COutPoint(%s, %d)", hash.ToString(), n);
  }

  void print() const{
    writeln(ToString());
  }
}

//
// An input of a transaction.  It contains the location of the previous
// transaction's output that it claims and a signature that matches the
// output's public key.
//

class CTxIn{
public:
  COutPoint prevout;
  string scriptSig;
  uint nSequence;

  this(){
    nSequence = uint.max;
  }

  this(Uint256 hashPrevTx, string scriptSigIn, uint nOut, uint nSequenceIn=uint.max){
    prevout = new COutPoint(hashPrevTx, nOut);
    scriptSig = scriptSigIn;
    nSequence = nSequenceIn;
  }

  this(COutPoint prevoutIn, string scriptSigIn, uint nSequenceIn=uint.max){
    prevout = prevoutIn;
    scriptSig = scriptSigIn;
    nSequence = nSequenceIn;
  }

  bool IsFinal() const{
    return (nSequence == uint.max);
  }

  string Serialize() const{
    byte[] header;
    header ~= prevout.hash.ToString().decodeHex();
    header ~= "FFFFFFFF".decodeHex;
    header ~= CompactSize(cast(int)(scriptSig.length));
    header ~= scriptSig;
    header ~= "FFFFFFFF".decodeHex;


    return toLower((cast(ubyte[]) header).toHexString);
  }

  bool opEquals(const CTxIn a, const CTxIn b) const{
    return (a.prevout   == b.prevout &&
            a.scriptSig == b.scriptSig &&
            a.nSequence == b.nSequence);
  }




  string ToString() const{
    writeln(prevout == prevout);
    string str;
    str ~= ("CTxIn(");
    str ~= prevout.ToString();
    if(prevout.IsNull())
      str ~= format(", coinbase %s", "");
    else{
      str ~= format(", scriptSig=%s", scriptSig.encodeHex);
    }

    if (nSequence != uint.max)
      str ~= format(", nSequence=%u", nSequence);

    str ~= ")";

    return str;
  }

  void print() const{
    writeln(ToString());
  }
}


//
// An output of a transaction.  It contains the public key that the next input
// must be able to sign with to claim it.
//

class CTxOut{
public:
  uint64_t nValue;
  string scriptPubKey;

  this(){
    SetNull();
  }

  this(uint64_t nValueIn, string scriptPubKeyIn){
    nValue = nValueIn;
    scriptPubKey = scriptPubKeyIn;
  }

  void SetNull(){
    nValue = -1;
    scriptPubKey = "0";
  }

  bool IsNull(){
    return (nValue == -1);
  }


  bool opEquals(const CTxOut a, const CTxOut b) const{
    return (a.nValue == b.nValue && a.scriptPubKey == b.scriptPubKey);
  }

  string ToString() const{
    return format("CTxOut(nValue=%d.%08d, scriptPubKey=%s)", nValue / COIN, nValue % COIN, scriptPubKey);
  }

  string Serialize() const{
    byte[] header;
    header ~= nativeToLittleEndian!ulong(nValue);
    header ~= CompactSize(cast(char)(scriptPubKey.length / 2));
    header ~= scriptPubKey.decodeHex;
    return toLower((cast(ubyte[]) header).toHexString);
  }


  void print() const{
    writeln(ToString());
  }
}


//
// The basic transaction that is broadcasted on the network and contained in
// blocks.  A transaction can contain multiple inputs and outputs.
//
class CTransaction{
public:
  int nVersion;
  CTxIn[] vin;
  CTxOut[] vout;
  int nLockTime;

  this(){
    SetNull();
  }

  void SetNull(){
    nVersion = 1;
    vin  ~= new CTxIn;
    vout ~= new CTxOut;
    nLockTime = 0;
  }



  bool IsFinal() const{
    if (nLockTime == 0 || nLockTime < 7){
      return true;
    }
    foreach(const CTxIn txin; vin){
      if(!txin.IsFinal()){
        return false;
      }
    }

    return true;
  }


  string Serialize() const{
    byte[] header;
    // version
    header ~= nativeToLittleEndian(nVersion);
    // number of transaction inputs
    header ~= CompactSize(to!int(vin.length));
    
    // transactions inputs 
    for( int i = 0; i < vin.length; ++i ) {
      foreach(const txin; vin){
        header ~= vin[i].Serialize().decodeHex();
      }
    }

    // number of transaction inputs
    header ~= CompactSize(to!int(vout.length));

    // transactions inputs 
    for( int i = 0; i < vout.length; ++i ) {
      foreach(const txout; vout){
        header ~= vout[i].Serialize().decodeHex();
      }
    }

    // locktime 
    header ~= nativeToLittleEndian(nLockTime);




      
    return toLower((cast(ubyte[]) header).toHexString);
  }

  bool opEquals(const CTransaction a, const CTransaction b) const{
    return (a.nVersion  == b.nVersion &&
            a.vin       == b.vin &&
            a.vout      == b.vout &&
            a.nLockTime == b.nLockTime);
  }

  Uint256 GetHash() const{
    auto sha256 = new SHA256Digest();
    return new Uint256(toLower(to!string(toHexString(sha256.digest(sha256.digest(Serialize.decodeHex))).chunks(2).array.retro.joiner)));

  }

  bool IsCoinBase() const{
    return (vin.length == 1 && vin[0].prevout.IsNull());
  }
  
  int64_t GetValueOut() const{
    int64_t nValueOut = 0;
    foreach(const CTxOut txout; vout){
      if (txout.nValue < 0){
        throw new Exception("CTransaction::GetValueOut() : negative value");
      }
      nValueOut += txout.nValue;
    }
      return nValueOut;
  } 

  bool CheckTransaction() const{
    // Basic checks that don't depend on any context
    if (vin.length == 0 || vout.length == 0){
      throw new Exception("CTransaction::CheckTransaction() : vin or vout empty");
    }
    // Check for negative values
    foreach(const CTxOut txout; vout)
      if (txout.nValue < 0){
        throw new Exception("CTransaction::CheckTransaction() : txout.nValue negative");
      }

    if (IsCoinBase()){
      if (vin[0].scriptSig.length < 2 || vin[0].scriptSig.length > 100){
        throw new Exception("CTransaction::CheckTransaction() : coinbase script size");
      }
    }
    else{
      foreach(const CTxIn txin; vin)
        if (txin.prevout.IsNull())
          throw new Exception("CTransaction::CheckTransaction() : prevout is null");
    }

    return true;
  }

   string ToString() const{
    string str;
    str ~= format("CTransaction(hash=%s, ver=%d, vin.size=%d, vout.size=%d, nLockTime=%d)\n", GetHash().ToString(), nVersion, vin.length, vout.length, nLockTime);
    for (int i = 0; i < vin.length; i++)
      str ~= format(" %s \n", vin[i].ToString());
    for (int i = 0; i < vout.length; i++)
      str ~= format(" %s \n", vout[i].ToString());

    return str;
  }

  void print() const{
    writeln(ToString());
  }
}


//
// Nodes collect new transactions into a block, hash them into a hash tree,
// and scan through nonce values to make the block's hash satisfy proof-of-work
// requirements.  When they solve the proof-of-work, they broadcast the block
// to everyone and the block is added to the block chain.  The first transaction
// in the block is a special one that creates a new coin owned by the creator
// of the block.
//
// Blocks are appended to blk0001.dat files on disk.  Their location on disk
// is indexed by CBlockIndex objects in memory.
//
class CBlock{
public:
  // block header 
  uint32_t nVersion;
  Uint256 hashPrevBlock = new Uint256();
  Uint256 hashMerkleRoot = new Uint256();
  uint32_t nTime;
  uint32_t nBits;
  uint32_t nNonce;

  CTransaction[] vtx;


  this(){
    SetNull();
  }

  void SetNull(){
    nVersion = 1;
    hashPrevBlock = 0;
    hashMerkleRoot = 0;
    nTime = 0;
    nBits = 0;
    nNonce = 0;
    //vtx.clear();
    //vMerkleTree.clear();
    }

  bool IsNull() const{
    return (nBits == 0);
  }

  string Serialize() const{
    // block header serialization
    byte[] header;
    
    header ~= nativeToLittleEndian(nVersion);
    header ~= to!string(hashPrevBlock.ToString().chunks(2).array.retro.joiner).decodeHex;
    header ~= to!string(hashMerkleRoot.ToString().chunks(2).array.retro.joiner).decodeHex;
    header ~= nativeToLittleEndian(nTime);
    header ~= nativeToLittleEndian(nBits);
    header ~= nativeToLittleEndian(nNonce);

    return toLower((cast(ubyte[]) header).toHexString);
  }


  void Deserialize(string block){
    nVersion = littleEndianToNative!int(cast(ubyte[4])block.decodeHex()[0..4]);
    hashPrevBlock = new Uint256(to!string(block[8..72].chunks(2).array.retro.joiner));
    hashMerkleRoot = new Uint256(to!string(block[72..136].chunks(2).array.retro.joiner));
    nTime = littleEndianToNative!int(cast(ubyte[4])block.decodeHex()[68..72]);
    nBits = littleEndianToNative!int(cast(ubyte[4])block.decodeHex()[72..76]);
    nNonce = littleEndianToNative!int(cast(ubyte[4])block.decodeHex()[76..80]);


  }




  string DumpAll(){
    byte[] header;
    
    header ~= nativeToLittleEndian(nVersion);
    header ~= to!string(hashPrevBlock.ToString().chunks(2).array.retro.joiner).decodeHex;
    header ~= to!string(hashMerkleRoot.ToString().chunks(2).array.retro.joiner).decodeHex;
    header ~= nativeToLittleEndian(nTime);
    header ~= nativeToLittleEndian(nBits);
    header ~= nativeToLittleEndian(nNonce);

    header ~= CompactSize(to!int(vtx.length));

    foreach(const CTransaction tx; vtx){
      header ~= tx.Serialize().decodeHex;
    }

    return toLower((cast(ubyte[]) header).toHexString);
  }

  Uint256 GetHash() const{
    auto sha256 = new SHA256Digest();
    return new Uint256(toLower(to!string(toHexString(sha256.digest(sha256.digest(Serialize.decodeHex))).chunks(2).array.retro.joiner)));
  }

  Uint256 BuildMerkleTree() const{
    Uint256[] txhashes;

    foreach(const CTransaction tx; vtx){
      // calculate transactions hashes and add them to an array 
      txhashes ~= new Uint256(tx.GetHash());
    }

    if(txhashes.length == 1){
      // case block have only a coinbase tx 
      // merkle root is the coinbase transaction hash 
      return txhashes[0];
    }

    if(txhashes.length > 1){
      // case we have a regualr tx
      // calculate merkle root 
      }

    return new Uint256(0);
  }
  bool CheckBlock() const{
    // These are checks that are independent of context
    // that can be verified before saving an orphan block.

    // Size limits
    if (vtx.length == 0 || vtx.length > 100000000){
      throw new Exception("CheckBlock() : size limits failed");
    }
    
    // Check timestamp
    if (nTime > GetAdjustedTime() + 2 * 60 * 60){
      throw new Exception("CheckBlock() : block timestamp too far in the future");
    }

    // First transaction must be coinbase, the rest must not be
    if (vtx.length == 0 || !vtx[0].IsCoinBase()){
      throw new Exception("CheckBlock() : first tx is not coinbase");
    }

    for (int i = 1; i < vtx.length; i++){
      if (vtx[i].IsCoinBase()){
        throw new Exception("CheckBlock() : more than one coinbase");
      }
    }

    // Check transactions
    foreach(const CTransaction tx; vtx){
      if (!tx.CheckTransaction()){
        throw new Exception("CheckBlock() : CheckTransaction failed");
      }
    }       

    // Check merkleroot 
    if (hashMerkleRoot != BuildMerkleTree()){
      throw new Exception("CheckBlock() : hashMerkleRoot mismatch");
    }

    return true;
  }


  void print() const{
    writeln(format("CBlock(hash=%s, ver=%d, hashPrevBlock=%s, hashMerkleRoot=%s, nTime=%u, nBits=%08x, nNonce=%u)\n", GetHash().ToString(), nVersion,
      hashPrevBlock.ToString(), hashMerkleRoot.ToString(), nTime, nBits, nNonce));
     for (int i = 0; i < vtx.length; i++){
      writeln("  ");
      vtx[i].print();
    }
  }
}


bool ProcessBlock(CBlock pblock){
  Uint256 hash = pblock.GetHash();
  // Check for duplicate
  // stable 
  // orphan 

  // Preliminary checks
  if (!pblock.CheckBlock()){
    throw new Exception("ProcessBlock() : CheckBlock FAILED");
  }

  writeln("ProcessBlock: ACCEPTED\n");

  return true;
}
