// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

contract Mdifier{

    //Ejemplo modifier que compruebe que la dirección de la persona que ejecuta el contrato sea quien pueda ejecutar la función

    address public owner;

    constructor(){
        owner = msg.sender;
    }

    modifier soloPropietario(){
        require(msg.sender == owner , "sin privilegios para ejecutar la funcion");
        _;
    }

    // function   + modifier 
    function ejemploModifier()public soloPropietario(){
        // Aqui va el codigo de la funcion si se cumple el require del modifier
    }

    struct cliente{
        address direccion_cliente;
        string nombre;
    }

    mapping(string => address) clientes;

    function nuevoCliente(string memory _nombre) public {
        clientes[_nombre] = msg.sender; 
    }

    modifier soloClientes(string memory _nombre){
        require (clientes[_nombre] == msg.sender);
        _;
    }

    function Ejemplo2Modifier (string memory _nombre) public soloClientes(_nombre){
        // Aqui va la lógica de la funcion para los clientes;
    }


}