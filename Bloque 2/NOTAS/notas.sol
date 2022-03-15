// SPDX-License-Identifier: GPL-3.0-or-later and SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    alumno |  id    |  nota
    Marcos   77755N      5
    Joan     12345X      9 
    Maria    02468T      2
    Marta    13579U      3
    Alba     98765Z      5
*/

contract notas{

    //Direccion del profesor
    address public profesor;

    //Construtor
    constructor(){
        profesor = msg.sender;
    }

    //Mapping relacion hash id alumno con su nota
    mapping(bytes32 => uint) Notas;

    // Array de los alumnos que pidan revisiónd de examenes
    string[] revisiones;

    // Eventos 
    event alumno_evaluado(bytes32,uint);
    event evento_revision(string);

    //funcion para evaluar a alumnos
    function Evaluar(string memory _idAlumno,uint _nota)public soloProfesor(msg.sender){
            //hash id alumno
            bytes32 hash_idAlumno = keccak256(abi.encodePacked(_idAlumno));
            //Relacion entre hash de alumno y nota
            Notas[hash_idAlumno] = _nota;
            //emision del evento 
            emit alumno_evaluado(hash_idAlumno,_nota);
    }

    modifier soloProfesor(address _direccionProfesor){
        //require que valide que el parametro de entrada sea igual al owner del contrato
        require(_direccionProfesor == profesor, "No tienes permisos para ejecutar esta funcion" );
        _;


    }

}