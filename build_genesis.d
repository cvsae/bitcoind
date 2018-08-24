import std.stdio;
import std.format;
import std.conv: to;
import bitcoin;



void main(){

  string pszTimestamp = "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks";



  CTransaction txNew = new CTransaction();
  txNew.nVersion = 1;
  txNew.vin[0].prevout = new COutPoint("000000000000000000000000000000000000000000000000000000000000000", -1);
  txNew.vin[0].scriptSig = ("04ffff001d0104" ~ to!string(cast(char)(to!int(pszTimestamp.length))).encodeHex ~ pszTimestamp.encodeHex).decodeHex;
  txNew.vout[0].nValue = 50 * COIN;
  txNew.vout[0].scriptPubKey = "41" ~"04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f" ~"ac".encodeHex.decodeHex;
  
  CBlock pblock = new CBlock();
  pblock.vtx ~= txNew;


  pblock.nVersion = 1;
  pblock.hashPrevBlock = "0000000000000000000000000000000000000000000000000000000000000000";
  pblock.hashMerkleRoot = pblock.BuildMerkleTree();
  pblock.nVersion = 1;
  pblock.nTime    = 1231006505;
  pblock.nBits    = 0x1d00ffff;
  pblock.nNonce = 2083236893;

  writeln("Serialized");
  writeln("\n");
  writeln("##########################################################");
  writeln("\n");
  writeln("[*] Block header");
  writeln(pblock.Serialize());

  writeln("\n");
  writeln("[*] Full block network format");
  writeln(pblock.DumpAll());

  writeln("\n");
  writeln(format("[*] Hash: %s", pblock.GetHash()));
  writeln(format("[*] Merkle: %s", pblock.BuildMerkleTree()));
  writeln(format("[*] Version: %s", pblock.nVersion));
  writeln(format("[*] Time: %s", pblock.nTime));
  writeln(format("[*] Bits: %s", pblock.nBits));
  writeln(format("[*] Nonce: %s", pblock.nNonce));

  assert(pblock.GetHash() == "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f");


  writeln("\n");
  writeln("Serialized End");
  writeln("##########################################################");
  writeln("\n");
  writeln("Deserializing 0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c");
  writeln("\n");


  CBlock ppblock = new CBlock();
  ppblock.Deserialize("0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c");
  writeln("\n");
  writeln(format("[*] Hash: %s", ppblock.GetHash()));
  writeln(format("[*] Merkle: %s", ppblock.hashMerkleRoot));
  writeln(format("[*] Version: %s", ppblock.nVersion));
  writeln(format("[*] Time: %s", ppblock.nTime));
  writeln(format("[*] Bits: %s", ppblock.nBits));
  writeln(format("[*] Nonce: %s", ppblock.nNonce));

  assert(ppblock.GetHash() == "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f");
  writeln("\n");
  writeln("Deserialized End\n");
  writeln("##########################################################");
}
