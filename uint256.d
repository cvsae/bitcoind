// Copyright (c) 2009 Satoshi Nakamoto
// Copyright (c) 2018 Cvsae
// Distributed under the MIT/X11 software license, see the accompanying
// file license http://www.opensource.org/licenses/mit-license.php.

import std.stdio;
import std.path;
import std.format;
import std.conv : to;
import std.digest.sha;
import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.bigint;
import std.bitmanip;
import std.uni;
import std.file;
import core.stdc.stdint;
import core.stdc.stdlib;
import std.string;

// encode hex 
string encodeHex(string i){return (cast(ubyte[]) i).toHexString;}


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



  void opUnary(string op : "++")(){
    int i = 0;
    while (++pn[i] == 0 && i < WIDTH-1)
      i++;
  }

  void opUnary(string op : "--")(){
    int i = 0;
    while (--pn[i] == -1 && i < WIDTH-1)
      i++;
  }
  
  alias opEquals = Object.opEquals;
  override bool opEquals(Object obj) const{
    return this.pn == (cast(Uint256)obj).pn;
  }
}



//////////////////////////////////////////////////////////////////////////////
//
// uint256
//

class uint256: base_uint{
public:
  alias base_uint basetype;

  this(){

  }

  this(const basetype b){
    for (int i = 0; i < WIDTH; i++){
      pn[i] = b.pn[i];
    }
  }

  this(uint64_t b){
    pn[0] = cast(int)b;
    pn[1] = cast(int)(b >> 32);
    for (int i = 2; i < WIDTH; i++){
      pn[i] = 0;
    }
  }

  this(string str){
    SetHex(str);
  }
}



/*
void main(){


  uint256 a = new uint256(7);
  writeln(a.ToString());
  a--;
  writeln(a.ToString());
  a++;
  writeln(a.ToString());

}

*/
