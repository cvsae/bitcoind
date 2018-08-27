// Copyright (c) 2009 Satoshi Nakamoto
// Copyright (c) 2018 Cvsae
// Distributed under the MIT/X11 software license, see the accompanying
// file license http://www.opensource.org/licenses/mit-license.php.

import core.stdc.stdint;
import std.conv: to;
import std.string;


import utils;


// START BASEUINT


// We have to keep a separate base class without constructors
// so the compiler will let us use it in a union
class base_uint{
protected:
  enum { WIDTH=256/32 };
  int[WIDTH] pn;
public:

  string GetHex() const{
    char[pn.sizeof * 2 + 1] psz;
    for (int i = 0; i < pn.sizeof; i++){
      psz[i] = (cast(char*)pn)[pn.sizeof - i - 1];
    }
    return toLower(to!string(psz[0..32]).encodeHex());
  }


  void SetHex(const string str){
    for (int i = 0; i < WIDTH; i++)
      pn[i] = 0;

    char* psz = str.dup.ptr;


    // skip 0x

    if (psz[0] == '0' && toLower(psz[1]) == 'x')
      psz += 2;

    // hex string to uint
    static char[256] phexdigit = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0, 0,0xa,0xb,0xc,0xd,0xe,0xf,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0xa,0xb,0xc,0xd,0xe,0xf,0,0,0,0,0,0,0,0,0];
    const char* pbegin = psz;
    while (phexdigit[*psz] || *psz == '0')
      psz++;
    psz--;
    char* p1 = cast(char*)pn;
    char* pend = p1 + WIDTH * 4;
    while (psz >= pbegin && p1 < pend){
      *p1 = phexdigit[cast(char)*psz--];
      if (psz >= pbegin){
        *p1 |= (phexdigit[cast(char)*psz--] << 4);
        p1++;
      }
    }
  }

  string ToString() const{
    return (GetHex());
  }

  unittest{
    Uint256 a = new Uint256(0);
    assert(a.ToString() == "0000000000000000000000000000000000000000000000000000000000000000");
  }

  
  void opUnary(string op : "++")(){
    int i = 0;
    while (++pn[i] == 0 && i < WIDTH-1)
      i++;
  }

  unittest{
    Uint256 a = new Uint256(8);
    a++;
  }


  void opUnary(string op : "--")(){
    int i = 0;
    while (--pn[i] == -1 && i < WIDTH-1)
      i++;
  }

  unittest{
    Uint256 a = new Uint256(8);
    a--;
  }


  alias opEquals = Object.opEquals;
  override bool opEquals(Object obj) const{
    return this.pn == (cast(Uint256)obj).pn;
  }

  unittest{
    Uint256 a = new Uint256(7);
    Uint256 b = new Uint256(7);
    assert( a == b);
  }

}



//////////////////////////////////////////////////////////////////////////////
//
// uint256
//

class Uint256: base_uint{
public:
  alias base_uint basetype;
  


  this(){

  }

  unittest{
    Uint256 a = new Uint256();
  }


  this(const basetype b){
    for (int i = 0; i < WIDTH; i++){
      pn[i] = b.pn[i];
    }
  }

  unittest{
    Uint256 a = new Uint256(9);
    Uint256 b = new Uint256(a);
  }


  this(uint64_t b){
    pn[0] = cast(int)b;
    pn[1] = cast(int)(b >> 32);
    for (int i = 2; i < WIDTH; i++){
      pn[i] = 0;
    }
  }
  
  unittest{
    Uint256 a = new Uint256(9);
  }

  
  void opAssign(uint64_t b) {
    pn[0] = cast(int)b;
    pn[1] = cast(int)(b >> 32);
    for (int i = 2; i < WIDTH; i++){
      pn[i] = 0;
    }
  }

  unittest{
    Uint256 a = new Uint256();
    a = 9;
  }


  this(string str){
    SetHex(str);
  }

  unittest{
    Uint256 a = new Uint256("dt67");
  }
}

// END UINT256