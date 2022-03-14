// SPDX-License-Identifier: GPL-3.0-or-later and SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ejemplosEnums{

        //Enum de interruptor
        enum estado {ON, OFF}
        
        //variable de tipo enum
        estado state;

        function encender() public{
            state = estado.ON;
        }
        
        function fijarEstado(uint _k)public{
            state = estado(_k);
        }

        function retornaEstado() public view returns(estado){
            return state;
        }


        //Enumeracion de direcciones
        enum direcciones {ARRIBA, ABAJO, DERECHA, IZQUIERDA}
        direcciones direction = direcciones.ARRIBA;

        function fijarDireccion(uint _index)public{
            direction = direcciones(_index);
        }

        function retornaDireccion() public view returns(direcciones){
            return direction;
        }
         


}