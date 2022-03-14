// SPDX-License-Identifier: GPL-3.0-or-later and SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Arrays{

    uint[5] public arrayEnteros = [1,2,3];

    struct Persona{
        string  persona;
        uint edad;
    }

    Persona[] public array_personas; 

    function crearPersonas(string memory _nombre,uint _edad)public{
        array_personas.push(Persona(_nombre,_edad));
    }

    function consultarArrayPersonas() public view returns(Persona[] memory){
        return array_personas;
    }

}