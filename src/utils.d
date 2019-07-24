// Copyright (c) 2009 Satoshi Nakamoto
// Copyright (c) 2018 Cvsae
// Distributed under the MIT/X11 software license, see the accompanying
// file license http://www.opensource.org/licenses/mit-license.php.

import core.stdc.stdint;
import core.stdc.time;
import std.algorithm;
import std.conv: to;
import std.digest.sha: toHexString;
import std.range; 
import std.stdio;



static int64_t nTimeOffset = 0;



// encode hex 
string encodeHex(string i){return (cast(ubyte[]) i).toHexString;}
// decode hex 
string decodeHex(string i){return to!string(i.chunks(2).map!(digits => cast(char) digits.to!ubyte(16)).array);}
// unixtimestamp
int64_t GetTime(){return core.stdc.time.time(null);}
// adjusted time
int64_t GetAdjustedTime(){return GetTime() + nTimeOffset;}