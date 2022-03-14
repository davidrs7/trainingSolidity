// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "./banco.sol";

import {Banco,banco2} from "./banco.sol";


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