import std.stdio;
import std.format;
import std.conv: to;

import bitcoin;
import uint256;
import utils;

// deserialize genesis block

void main(){
  CBlock ppblock = new CBlock();

  Uint256 hashGenesisBlock = new Uint256("000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f");

  ppblock.Deserialize("0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c");
  writeln("\n");
  writeln(format("[*] Hash: %s", ppblock.GetHash().ToString()));
  writeln(format("[*] Merkle: %s", ppblock.hashMerkleRoot.ToString()));
  writeln(format("[*] Version: %s", ppblock.nVersion));
  writeln(format("[*] Time: %s", ppblock.nTime));
  writeln(format("[*] Bits: %s", ppblock.nBits));
  writeln(format("[*] Nonce: %s", ppblock.nNonce));

  assert(ppblock.GetHash() == hashGenesisBlock);
}