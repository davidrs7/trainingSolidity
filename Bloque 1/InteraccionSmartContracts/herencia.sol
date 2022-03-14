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

contract Cliente is Banco{
    
    function AltaCliente(string memory _nombre) public{
        nuevoCliente(_nombre);
    }
    
    function IngresarDinero(string memory _nombre, uint _cantidad) public{
        clientes[_nombre].dinero = clientes[_nombre].dinero + _cantidad;
    }
    
    function RetirarDinero(string memory _nombre, uint _cantidad) public returns(bool){
        bool flag = true;
        
        if(int(clientes[_nombre].dinero)-int(_cantidad) >= 0){
            clientes[_nombre].dinero = clientes[_nombre].dinero - _cantidad;
        }else{
            flag = false;
        }
        
        return flag;
    }
    
    function ConsultarDinero(string memory _nombre) public view returns(uint){
        return clientes[_nombre].dinero;
    }
}


