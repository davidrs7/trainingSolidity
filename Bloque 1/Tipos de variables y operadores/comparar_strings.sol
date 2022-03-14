// SPDX-License-Identifier: GPL-3.0-or-later and SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract comparaStrings{

    function comparar(string memory param1, string memory param2)public pure returns(bool){

        bytes32 hash_param1 = keccak256(abi.encodePacked(param1));
        bytes32 hash_param2 = keccak256(abi.encodePacked(param2));
        bool retorno = false;

        if (hash_param2 == hash_param1){
            retorno = true;
        } 
        return retorno;
    }
}