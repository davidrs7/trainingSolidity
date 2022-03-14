// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract comida{

    struct plato{
        string nombre;
        string ingredientes;
        uint tiempo;
    }

    plato[] platos;
    mapping (string => string) ingredientes;

    function nuevoPlato(string memory _nombre, string memory _ingredientes,uint _tiempo) internal{
        platos.push(plato(_nombre,_ingredientes,_tiempo));
        ingredientes[_nombre] = _ingredientes;
    }

    function retornaIngredientes(string memory _nombre) internal view returns(string memory) {
        return ingredientes[_nombre];
    }

}

contract sandwitch is comida{

    function nuevoSandwitch(string memory _ingredientes, uint _tiempo) external{
        nuevoPlato("sandwitch", _ingredientes, _tiempo);
    }

    function verIngredientes(string memory _nombre) external view returns(string memory){
        return retornaIngredientes(_nombre);
    }

}