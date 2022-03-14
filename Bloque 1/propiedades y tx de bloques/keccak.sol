pragma solidity ^0.8.0;

contract hash{

 
    function calcularHash(string memory _cadena)public pure returns (bytes32) {
            return keccak256(abi.encodePacked(_cadena));
    }
 
    function calcularHash2(string memory _cadena, uint _k, address _direction)public pure returns (bytes32) {
            return keccak256(abi.encodePacked(_cadena,_k,_direction));
    }

       function calcularHash3(string memory _cadena, uint _k, address _direction)public pure returns (bytes32) {
            return keccak256(abi.encodePacked(_cadena,_k,_direction,"Hola",uint(2)));
    }

}