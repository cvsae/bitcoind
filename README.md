# Bitcoind

### What i can do with Bitcoind ?

- Serialize and Deserialize blocks 
- Basic transactions checks
- Build new blocks

### Todos 
- Each block can't have more than 1 tx, will be fixed
- <del>String is using instead of uint256, will be fixed</del> Fixed
- Coinbase transaction can't deserialized, will be fixed

# Run Tests

``` bash
git clone https://github.com/cvsae/bitcoind
cd bitcoind/tests
./make_tests

# runing mk_genesis 
./mk_genesis

# OUTPUT

# genesis block hash 
000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
# genesis block header without coinbase tx 
0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c
# genesis block network format with coinbase tx 
0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c0101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000

# runing deser_genesis 
# deserialize 0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a29ab5f49ffff001d1dac2b7c
./deser_genesis

# OUTPUT

[*] Hash: 000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
[*] Merkle: 4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b
[*] Version: 1
[*] Time: 1231006505
[*] Bits: 486604799
[*] Nonce: 2083236893


# delete executable tests files 
./clean 
```
