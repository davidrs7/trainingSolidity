pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./ERC20.sol";

contract Disney{

    // --------------------------------------------------- DECLARACIONES INICIALES --------------------------------------------------------- //
    // Instancia del contrato token
    ERC20Basic private token;    
    //Direccion de owner disney
    address  public owner;

    constructor() public{
        token = new ERC20Basic(10000);
        owner = msg.sender;
    } 

    // Estructura de datos para almacenar los clientes de Disney
    struct cliente{
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }

    //Mapping para el registro de cliente
    mapping(address => cliente) public Clientes;

    // -------------------------------------------------------- GESTION DE TOKENS---------------------------------------------------------- //

    // Funcion que establece el precio de un token
    function PrecioTokens(uint _numTokens) internal pure returns(uint){
        // Conversión de tokens a Ethers : 1 Token = 1 Ether
        return _numTokens * (1 ether);
    }

    // Funcion para comprar tokens en Disney y disfrutar de las atracciones
    function CompraTokens(uint _numTokens)public payable{
        //Establecer el precio de los Tokens
        uint coste = PrecioTokens(_numTokens);
        // Se valida si el cliente cuenta con el dinero suficiente para pagar los Tokens.
        require(msg.value >= coste, "Compra menos tokens o paga con mas Ethers") ;
        // Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        // Disney retorna la cantidad de ethers al cliente
       payable(msg.sender).transfer(returnValue);
        //Obetener numero de tokens dispobibles.
        uint Balance = balanceOf();
        require(_numTokens <= Balance, "Compra un numero menos de Tokens");
        //Se transfiere el numero de Token
        token.transfer(msg.sender,_numTokens);
        //Registro tokens comprados
        Clientes[msg.sender].tokens_comprados += _numTokens;
    }

    // Retorna el total de tokens del contrato Disney
    function balanceOf()public view returns(uint){
        return token.balanceOf(address(this));
    }

    //Visualizar el numero de Tokens restantes de un cliente
    function MisTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    // funcion para generar mas Tokens
    function GeneraTokens(uint _numTokens)public Unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    // Modificador para controlar las funciones ejecutables por Disney 
    modifier Unicamente(address _direccion){
        require (_direccion == owner, "Privilegios insuficientes para ejcutar esta funcion");
        _;
    }



// ---------------------------------------- GESTION DE DISNEY ------------------------------------- //

// Eventos 
event disfruta_atraccion(string,uint,address);
event nueva_atraccion(string,uint);
event baja_atraccion(string);

// Estructura de datos de la atraccion
struct atraccion{
    string nombre_atraccion;
    uint precio_atraccion;
    bool estado_atraccion;
}

// Mapping para relacionar un nombre de una atraccion con una estructura de datos de la atracción 
mapping(string => atraccion) public MappingAtracciones;

//Array para almacenar el nombre de las atracciones
string[] Atracciones;

//Mapping para relacionar un cliente con su historico de disney
mapping(address => string[]) HistorialAtracciones;

// Star Wars -> 2 Tokens
// Toy Story -> 5 Tokens
// Piratas del caribe -> 8 Tokens

// Crear nuevas atracciones para Disney, solo se permite ejecutar por Disney
function NuevaAtraccion(string memory _nombreAtraccion,uint _precio) public Unicamente(msg.sender){
    // Validar si existe la atraccion
    require(keccak256(abi.encodePacked(MappingAtracciones[_nombreAtraccion].nombre_atraccion))  != keccak256(abi.encodePacked(_nombreAtraccion)) , "Esta atraccion ya existe" );
    // Creación de una atraccion en disney
    MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion,_precio,true);
    // Almacenar la atraccion en el array 
    Atracciones.push(_nombreAtraccion);
    // Emisión del evento para la nueva atraccion
    emit nueva_atraccion(_nombreAtraccion,_precio);
}

// Inactivar la atracción de disney
function BajaAtraccion(string memory _nombreAtraccion) public Unicamente(msg.sender){
    //Validar si existe la atracción
    require(keccak256(abi.encodePacked(MappingAtracciones[_nombreAtraccion].nombre_atraccion))  == keccak256(abi.encodePacked(_nombreAtraccion)) , "Esta atraccion no existe" );
    //Cambiar el estado de la atraccióna  a FALSE => no está en uso
    MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
    //Emisión del evento dar de baja 
    emit baja_atraccion(_nombreAtraccion); 
}

// Visualizar atracciones disponibles 
    function AtraccionesDisponibles() public view returns(string[] memory){
        return Atracciones;
    }

    // Funcion para subirse a una atracción en Disney y pagar en tokens esta atracción
    function SubirseAtraccion (string memory _nombreAtraccion) public{
        // Precio de la atracción en tokens
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Verifica el estado de la atracción (si está disponible)
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "Atraccion no disponible en este momento");
        //Validar si el cliente tiene el numero de clientes necesarios para subirse a la atracción
        require(tokens_atraccion <= MisTokens(), "Necesitas mas tokens para subirte a esta atraccion");     
   

    /* El cliente paga la atracción en tokens 
      - Ha sido necesario crear una funcion en ERC20.sol con el nombre 'transferencia_disney'
        ya que al usar el Transfer o TransferFrom escogía las direcciones equivocadas.  ya que el msg.sender que se recibía
        era la dirección del contrato.     
    */
    token.transferencia_disney(msg.sender,address(this), tokens_atraccion);
    // Almacenamiento en el historial de atracciones del cliente
    HistorialAtracciones[msg.sender].push(_nombreAtraccion);
    // Emisión del evento disfruta atraccion
    emit disfruta_atraccion(_nombreAtraccion,tokens_atraccion,msg.sender);    
    } 

    // Visualizar el historial completo de atracciones disfrutadas por un cliente

    function Historial() public returns(string[] memory){
        return HistorialAtracciones[msg.sender];
    } 
 
    // funcion para que a un cliente se le puedan retoranr sus tokens

    function DevolverTokens(uint _numTokens) public payable {
        //El numero de tokens a devolver debe ser positivo
        require(_numTokens > 0 , "Por favor ingresar una cantidad positiva de tokens");
        //El usuario debe tener el numero de Tokens que desea retornar
        require(_numTokens <= MisTokens(), "No tiene la cantidad suficiente de tokens para devolver " );
        //El cliente devuelve los tokens
        token.transferencia_disney(msg.sender,address(this), _numTokens);
        //Devolución de los ethers al cliente 
        payable(msg.sender).transfer(PrecioTokens(_numTokens));      
    }

}