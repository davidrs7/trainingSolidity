// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Votaciones{

    /*
        CANTIDAD / EDAD / ID
        Toni      20      12345X
        Alberto   23      54321T
        Joan      21      98765P
        Javier    19      56789W
    */
    address public owner;

    constructor()  {
        owner = msg.sender;
    }
    //Relacion entre candidato y el hash de sus datos personales
    mapping(string => bytes32) id_Cantidato;

    //Relacion candidato y numero de votos
    mapping(string => uint) votos_Candidato;

    // Lista de todos los candidatos
    string[] candidatos;

    // Lista de los votantes
    bytes32[] votantes;

    function Representar(string memory _nombrePersona,uint _edadPersona,string memory _idPersona)public{

        bytes32 hash_Candidato = keccak256(abi.encodePacked(_nombrePersona,_edadPersona,_idPersona));
        id_Cantidato[_nombrePersona] = hash_Candidato;
        // añadir el nombre del candidato a la lista 
        candidatos.push(_nombrePersona);
    }

    function verCandidatos() public view returns(string[] memory){
        return candidatos;
    }

    function votar(string memory _candidato) public{
        //obtenemos el hash de la dirección del votante
        bytes32 hash_votante = keccak256(abi.encodePacked(msg.sender));

        // validamos si el votante ya ha votado
        for (uint i=0;i < votantes.length; i++){
            require(votantes[i]!=hash_votante,"ya has votado previamente");
        }    

        //Almacenar el hash del votante dentro del array
        votantes.push(hash_votante);
        
        //se añade el voto al candidato
        votos_Candidato[_candidato]++;
    }
function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function verVotos(string memory _candidato)public view returns(uint){
        return votos_Candidato[_candidato];
    }

    function verResultados() public view returns(string memory){
        string memory Resultados;

        for(uint i=0; i < candidatos.length; i++)
        {
            Resultados = string(abi.encodePacked(Resultados, "(" , candidatos[i], ", " , uint2str(votos_Candidato[candidatos[i]]),") -------- "));
        }

        return Resultados;
    }
 
}