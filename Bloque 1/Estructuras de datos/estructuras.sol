//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Estructuras
{
    struct cliente
    {
        uint id;
        string name;
        string dni;
        string mail;
        uint phone_number;
        uint credit_number;
        uint secret_number;
    }

    struct producto
    {
        string nombre;
        uint precio;
    }

    struct ong
    {
        address ong;
        string nombre;
    }

    struct causa
    {
        uint id;
        string nombre;
        uint precio_objetivo;

    }

    //inicializar structs (o modelos)

    cliente clientes = cliente(1,"David","1234","david@hotmail.com",12345,2222,4444);
    producto product = producto("Gato",2000);
    ong ongs = ong("educacion",2000000);
    

}