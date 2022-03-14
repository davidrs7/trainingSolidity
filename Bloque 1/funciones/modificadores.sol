// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract view_pure_paybale{  
    string[] lista_alumnos;

    function nuevo_alumno(string memory _alumno) public{
        lista_alumnos.push(_alumno);
    }
 
   // accedemos a los datos pero no los modificamos
    function ver_alumno(uint _posicion)public view returns(string memory){
        return lista_alumnos[_posicion];
    }


  uint x = 10;
  
  function sumarAx(uint _a) public view returns(uint){ 
      return x + _a;
  }
    
    //modificardor pure
    function exponenciacion(uint _a,uint _b) public pure returns(uint){
        return _a**_b;
    } 
    
    //modificador payable 

    struct cartera{
        string nombre;
        address direccion_persona;
        uint dinero_persona;
    }
  
    mapping(address => cartera) dineroCartera;

    function pagar(string memory _nombrePersona, uint _cantidad) public payable{

     cartera memory miCartera;
     miCartera = cartera(_nombrePersona,msg.sender,_cantidad);
     dineroCartera[msg.sender] = miCartera;
    }

    function verSaldo()public view returns(cartera memory){
        return dineroCartera[msg.sender];
    }

  
}