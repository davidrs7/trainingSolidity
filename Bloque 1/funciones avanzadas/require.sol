// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

contract Rquire{

    // funcion que valida una contraseña (123456)
    function password (string memory _pas) public pure returns(string memory){
            require(keccak256(abi.encodePacked(_pas)) == keccak256(abi.encodePacked("123456")), "La clave es incorrecta"); 
            return "Clave correcta";
    }

    //funcion de pago
    uint tiempo=0;
    uint cartera = 0;
    function Pagar(uint _cantidad) public returns(uint){
        require(block.timestamp > tiempo + 5 seconds, "No se ha cumpldo el tiempo de pago");
        tiempo = block.timestamp ;
        cartera += _cantidad;
        return cartera;
    }

    //Actualizar valor de array
    string[] nombres;
    function nuevoNombre(string memory _nombre) public{
        for (uint i=0; i < nombres.length; i++ ){
                require(keccak256(abi.encodePacked(_nombre)) == (keccak256(abi.encodePacked(nombres[i]))), "ya existe en la lista este nombre");
        }
        nombres.push(_nombre);

    }

}