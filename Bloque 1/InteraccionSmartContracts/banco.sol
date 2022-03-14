// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Banco{
     
    struct cliente{
        string _nombre;
        address direccion;
        uint dinero;
    } 
    mapping (string => cliente) clientes; 
    
    function nuevoCliente(string memory _nombre) public {
        clientes[_nombre] = cliente(_nombre, msg.sender, 0);
    }
}

contract banco2{

}

contract banco3{
    
}