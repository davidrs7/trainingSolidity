// SPDX-License-Identifier: GPL-3.0-or-later and SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mappings
{
    //Mapping que nos permita elegir un numero
    mapping (address => uint) public elegirNum;

    function elegirNumero(uint _numero) public 
    {
        elegirNum[msg.sender] = _numero;
    }

    function consultarNumero() public view returns(uint)
    {
        return elegirNum[msg.sender];
    }

    // Mapping que relaciona a una persona con una catidad de dinero
 
    mapping (string => uint) public cantidadDinero;


    function asignarDinero(string memory _nombre, uint _cantidad) public{
        cantidadDinero[_nombre] = _cantidad;
    }

    function consultarDinero(string memory _nombre)public view returns(uint){
        return cantidadDinero[_nombre];
    }0


    //declarar mapping con un struct
    struct persona
    {
        string nombre;
        uint edad;
    }

    mapping(uint => persona) public personas;

    function asignarDatosPersonas(uint _numDni, string memory _nombre, uint _edad) public
    {
        personas[_numDni] = persona(_nombre,_edad);
    }

    function consultarPersonas(uint _numDni) public view returns(persona memory)
    {
        return personas[_numDni];
    }

}