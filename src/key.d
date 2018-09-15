import std.stdio;
import std.digest;
import std.string;
import core.stdc.string;
import std.digest.sha;

import deimos.openssl.ecdsa;
import uint256;
import utils;


enum NID_secp256k1 = 714;


class CKey{

protected:
	EC_KEY* pkey;
public:
    this()
    {
        pkey = EC_KEY_new_by_curve_name(NID_secp256k1);
        if (pkey == null)
            throw new Exception("CKey::CKey() : EC_KEY_new_by_curve_name failed");
    }

    this(const CKey b){
        pkey = EC_KEY_dup(b.pkey);
        if (pkey == null)
            throw new Exception("CKey::CKey(const CKey&) : EC_KEY_dup failed");
    }


    ~this(){
    	EC_KEY_free(pkey);
    }

    void MakeNewKey(){
        if (!EC_KEY_generate_key(pkey))
            throw new Exception("CKey::MakeNewKey() : EC_KEY_generate_key failed");
    }


    bool SetPrivKey(const ubyte[] vchPrivKey){
    	const ubyte** pbegin = cast(const ubyte**)&vchPrivKey[0];
    	if (!d2i_ECPrivateKey(&pkey, cast(const(ubyte)**)&pbegin, cast(ubyte**)vchPrivKey.length)){
    		return false;
    	}
    	return true;
    }

   
    ubyte[] GetPubKey(){
    	uint nSize = i2o_ECPublicKey(pkey, null);
        if (!nSize)
        	throw new Exception("CKey::GetPubKey() : i2o_ECPublicKey failed");

        ubyte[] vchPubKey;
        vchPubKey.length = nSize;

        ubyte* pbegin = &vchPubKey[0];
        if (i2o_ECPublicKey(pkey, &pbegin) != nSize)
        	throw new Exception("CKey::GetPubKey() : i2o_ECPublicKey returned unexpected size");
        return vchPubKey;
    }

    string GetPubKeyHex(){
    	return toLower(GetPubKey().toHexString);
    }

    ubyte[] GetPrivKey(){
    	uint nSize = i2d_ECPrivateKey(pkey, null);
        if (!nSize)
        	throw new Exception("CKey::GetPrivKey() : i2d_ECPrivateKey failed");
        ubyte[] vchPrivKey;
        vchPrivKey.length = nSize;
        ubyte* pbegin = &vchPrivKey[0];
        if (i2d_ECPrivateKey(pkey, &pbegin) != nSize)
            throw new Exception("CKey::GetPrivKey() : i2d_ECPrivateKey returned unexpected size");
        return vchPrivKey;
    }

   

    string GetPrivKeyHex(){
    	return toLower(GetPrivKey().toHexString);
    }


    bool IsVaild(){
    	if(!EC_KEY_check_key(pkey))
    		throw new Exception("CKey::IsVaild() : EC_KEY_check_key failed");
    	return true;
    }

    bool SetPubKey(const ubyte[] vchPubKey){
    	const ubyte* pbegin = &vchPubKey[0];
    	if (!o2i_ECPublicKey(&pkey, cast(const(ubyte)**)&pbegin, vchPubKey.length))
            return false;
        return true;
    }


    bool Sign(Uint256 hash, ubyte[] vchSig){
    	vchSig = [];
        ubyte[10000] pchSig;
        uint nSize = 0;
        if (!ECDSA_sign(0, (cast(ubyte*)&hash), hash.sizeof, cast(ubyte*)pchSig, &nSize, pkey))
            return false;
        
        vchSig.length = nSize;
        memcpy(&vchSig[0], cast(const void*)pchSig, nSize);
        return true;
    }


    static bool Sign(const ubyte[] vchPrivKey, Uint256 hash, ubyte[] vchSig){
        CKey key = new CKey();
        if (!key.SetPrivKey(vchPrivKey))
            return false;
        return key.Sign(hash, vchSig);
    }


    bool Verify(Uint256 hash, ubyte[] vchSig)
    {
        // -1 = error, 0 = bad sig, 1 = good
        if (ECDSA_verify(0, (cast(ubyte*)&hash), hash.sizeof, &vchSig[0], cast(int)vchSig.length, pkey) != 1)
            return false;
        return true;
    }

    static bool Verify(const ubyte[] vchPubKey, Uint256 hash, ubyte[] vchSig){
    	CKey key = new CKey();
    	if (!key.SetPubKey(vchPubKey))
    		return false;
    	return key.Verify(hash, vchSig);
    }
}