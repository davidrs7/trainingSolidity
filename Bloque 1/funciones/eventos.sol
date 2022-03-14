// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract eventos{

    //declaración de los eventos a utilizar
    event nombre_evento1 (string _nombrePesona);
    event nombre_evento2 (string _nombrePesona,uint edad); 


    function emitirEvento1(string memory _nombrePersona)public {
        emit nombre_evento1(_nombrePersona);
    }

    function emitirEvento1(string memory _nombrePersona,uint _edad)public {
            emit nombre_evento2(_nombrePersona,_edad);
        }
}