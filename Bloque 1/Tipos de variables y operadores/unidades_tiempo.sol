// SPDX-License-Identifier: GPL-3.0-or-later and SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract unidadesTiempo{
    
    // el valor real de la variable es 60 (segundos)
    uint public tiempo_actual = block.timestamp;
    uint public un_minuto = 1 minutes;
    uint public dos_horas = 2 hours;
    uint public cincuenta_dias = 50 days;
    uint public Una_semana = 1 weeks;

    
    function masSegundos() public view returns(uint){
        return block.timestamp + 50 seconds;
    }

      function masHoras() public view returns(uint){
        return block.timestamp + 2 hours;
    }


}