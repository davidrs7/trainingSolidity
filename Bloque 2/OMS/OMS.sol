// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*------------------------------------------------------------------------ CONTRATO OMS - FACTORY ---------------------------------------------------------*/

contract OMS_COVID{

    // Dirección de la OMS -> Owner / Dueño del contrato
    address public OMS;

    // Constructor del contrato
    constructor () {
        OMS = msg.sender;
    }

    // Mapping para relacionar los centros de salud  (direccion -> validez del sistema de gestion)
    mapping (address => bool) public validacion_CentrosSalud;
    // Mapping para relacionar una direccion de un centro de salud con su contrato
    mapping(address => address)public CentroSalud_Contrato;

    // Ejemplo 1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 -> true: TIENE PERMISOS PARA CREAR SU SMART CONTRACT
    // Ejemplo 2: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 -> false: NO TIENE PERMISOS PARA CREAR SU SMART CONTRACT
    
    //  Array de direcciones que almacene los contratos de los centros de salud validados
    address [] public direcciones_contratos_salud;
    // Array de las direcciones de los centros de salud solicitantes 
    address[] solicitudes;

     
    event NuevoCentroValidado(address);
    //Eventos a emitir  direccion del contrato, direccion del dueño
    event NuevoContrato(address, address);
    
    event SolicitudAccesso(address);

    //Modificador que permita la ejecución de funciones unicamente por la OMS    
    modifier UnicamenteOMS(address _direccion){
        require(_direccion == OMS , "No tienes privilegios para ejecutar esta funcion");
        _;
    }

    // Funcion para solicitar acceso al sistema medico
    function SolicitarAccesso() public{
        solicitudes.push(msg.sender);
        //alamacenar la dirección que solicita en el array de solicitudes
        emit SolicitudAccesso(msg.sender);
    }

    // Funcion para ver las direcciones solicitantes del acceso
    function VisualizarSolicitudes()public view UnicamenteOMS(msg.sender) returns(address[] memory){
            return solicitudes;
        }

    //Funcion para validar nuevos centros de salud que puedan autogestionarse -> UnicamenteOMS
    function CentrosSalud(address _centroSalud) public UnicamenteOMS(msg.sender){
        // Asignación del estado de validez al centro de salud
        validacion_CentrosSalud[_centroSalud] = true;
        //Emisión del evento
        emit NuevoCentroValidado(_centroSalud);
    }

    //Funcion que permita crear un contrato inteligente de un centro de salud
    function FactoryCentroSalud() public{
        // filtrar que unicamente los centros de salud validados sean capaces de ejecutar esta funcion
        require(validacion_CentrosSalud[msg.sender] == true , "No tienes permisos para ejecutar esta funcion" ); 
        //Generar un contrato inteligente -> generar su direccion
        address contrato_CentroSalud = address(new CentroSalud(msg.sender));
        //Alamacenar la direccion del contrato en el array
        direcciones_contratos_salud.push(contrato_CentroSalud);
        //Relacion entre el centro de salud y su contrato
        CentroSalud_Contrato[msg.sender] = contrato_CentroSalud;
        // Emision del evento 
        emit NuevoContrato(contrato_CentroSalud,msg.sender);
    } 
}

 ///////// ------------------------------------------------CONTRATO AUTOGESTIONABLE POR EL CENTRO DE SALUD ---------------------------------////////////
contract CentroSalud{

    // Direcciones iniciales
    address public DireccionContrato;
    address public DireccionCentroSalud;

    constructor(address _direccion) {
        DireccionCentroSalud = _direccion;
        DireccionContrato = address(this); 
    }
    // Mapping para relacionar el hash de la persona con los resultados (diagnostico, codigoIPFS)
    mapping(bytes32 => Resultados) ResultadosCOVID;
    // Estructuras o clases
    struct Resultados{
        bool diagnostico;
        string codigoIPFS;
    }

    // Eventos
    event NuevoResultado(bool,string);
    
    //modificador 
    modifier UnicamenteCentroSalud(address _direccion){
        require(_direccion == DireccionCentroSalud , "No tienes permisos para ejecutar esta funcion");
        _;
    }

    // Funcion para emitir un resultado de una prueba de covid
    // Ejemplo -> ResultadosPruebaCovid( 12354X | true | QmUxBmZFiGeiWb53Tpz1NSwkrEUusg5cRp7HHgcDwfUrk5 ) 
    function ResultadosPruebaCovid(string memory _id,bool _resultadoCOVID, string memory _codigoIPFS) public UnicamenteCentroSalud(msg.sender){
        // Hash de la identificacion de la persona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_id));
        // Relacionamos el hash de la persona con la estructura de resultados
        ResultadosCOVID[hash_idPersona] = Resultados(_resultadoCOVID, _codigoIPFS);
        // Emision del evento
        emit NuevoResultado(_resultadoCOVID,_codigoIPFS);
    }

    //Funcion para visualizar los resultados
    function VisualizarResultados(string memory _id) public view returns (string memory,string memory) {
        // hash de la persona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_id));
        // Retorno de un bool como un string
        string memory resultadoPrueba; 
        resultadoPrueba = ResultadosCOVID[hash_idPersona].diagnostico ? "Positivo" : "Negativo";
        return (resultadoPrueba,ResultadosCOVID[hash_idPersona].codigoIPFS);
    }


}