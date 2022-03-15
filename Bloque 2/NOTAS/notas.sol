//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*

    Notas: Para desplegar este contrato se puede hacer mediante la red de pruebas de Rinkeby Metamask
    -- Si no tienes saldo suficiente puedes enviarlo mendiante la siguiente página:
       https://faucets.chain.link/rinkeby?_ga=2.224721375.411349804.1638276408-1024165543.1638276408


    Data para pruebas: 
    
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

    function verNotas(string memory _idAlumno) public view returns(uint) {
        bytes32 hashAlumno = keccak256(abi.encodePacked(_idAlumno));
        uint nota_alumno = Notas[hashAlumno];
        return nota_alumno;
    }

    function Revision(string memory _idAlumno) public{
        revisiones.push(_idAlumno);
        emit evento_revision(_idAlumno);
    }

    function verRevisiones()public view soloProfesor(msg.sender) returns(string[] memory){
        return revisiones;
    }

}