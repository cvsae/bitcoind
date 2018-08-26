# Bitcoind

### What i can do with Bitcoind ?

- Serialize and Deserialize blocks 
- Basic transactions checks
- Build new blocks

### Todos 
- Each block can't have more than 1 tx, will be fixed
- <del>String is using instead of uint256, will be fixed</del> Fixed
- Coinbase transaction can't deserialized, will be fixed

# Examples

### Build the bitcoin genesis block 

``` d
import std.stdio;
import std.format;
import std.conv: to;
import bitcoin;

void main(){

  string pszTimestamp = "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks";
  
  Uint256 hashGenesisBlock = new Uint256("000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f");



  CTransaction txNew = new CTransaction();
  txNew.nVersion = 1;
  txNew.vin[0].prevout = new COutPoint(new Uint256(0), -1);
  txNew.vin[0].scriptSig = ("04ffff001d0104" ~ to!string(cast(char)(to!int(pszTimestamp.length))).encodeHex ~ pszTimestamp.encodeHex).decodeHex;
  txNew.vout[0].nValue = 50 * COIN;
  txNew.vout[0].scriptPubKey = "41" ~"04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f" ~"ac".encodeHex.decodeHex;
  
  CBlock pblock = new CBlock();
  pblock.vtx ~= txNew;


  pblock.nVersion = 1;
  pblock.hashPrevBlock = 0;
  pblock.hashMerkleRoot = pblock.BuildMerkleTree();
  pblock.nVersion = 1;
  pblock.nTime    = 1231006505;
  pblock.nBits    = 0x1d00ffff;
  pblock.nNonce = 2083236893;
  
  // get genesis block hash 
  writeln(pblock.GetHash().ToString()); // response 000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
  writeln("\n");
  // get block header hex format 
  writeln(pblock.Serialize()); // response 0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c
  writeln("\n");
  // get block network format included coinbase transaction
  writeln(pblock.DumpAll()); // response 0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c0101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000
}

```
### Deserialize the bitcoin genesis block
compile using dmd bitcoind example.d 
run it using ./bitcoin
``` d
import std.stdio;
import std.format;
import std.conv: to;
import bitcoin;

void main(){
  CBlock ppblock = new CBlock();
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
```
