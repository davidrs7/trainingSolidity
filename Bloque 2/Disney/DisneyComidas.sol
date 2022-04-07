pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./ERC20.sol";

contract DisneyComidas{

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
        string [] Comidas_disfrutadas;
    }

    //Mapping para el registro de cliente
    mapping(address => cliente) public Clientes;

    // -------------------------------------------------------- GESTION DE TOKENS---------------------------------------------------------- //

    // Funcion que establece el precio de un token
    function PrecioTokens(uint _numTokens) internal pure returns(uint){
        // Conversión de tokens a Ethers : 1 Token = 1 Ether
        return _numTokens * (1 ether);
    }

    // Funcion para comprar tokens en Disney y disfrutar de las Comidas
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
event disfruta_Comida(string,uint,address);
event nueva_Comida(string,uint);
event baja_Comida(string);

// Estructura de datos de la Comida
struct Comida{
    string nombre_Comida;
    uint precio_Comida;
    bool estado_Comida;
}

// Mapping para relacionar un nombre de una Comida con una estructura de datos de la atracción 
mapping(string => Comida) public MappingComidas;

//Array para almacenar el nombre de las Comidas
string[] Comidas;

//Mapping para relacionar un cliente con su historico de disney
mapping(address => string[]) HistorialComidas;

// Star Wars -> 2 Tokens
// Toy Story -> 5 Tokens
// Piratas del caribe -> 8 Tokens

// Crear nuevas Comidas para Disney, solo se permite ejecutar por Disney
function NuevaComida(string memory _nombreComida,uint _precio) public Unicamente(msg.sender){
    // Validar si existe la Comida
    require(keccak256(abi.encodePacked(MappingComidas[_nombreComida].nombre_Comida))  != keccak256(abi.encodePacked(_nombreComida)) , "Esta Comida ya existe" );
    // Creación de una Comida en disney
    MappingComidas[_nombreComida] = Comida(_nombreComida,_precio,true);
    // Almacenar la Comida en el array 
    Comidas.push(_nombreComida);
    // Emisión del evento para la nueva Comida
    emit nueva_Comida(_nombreComida,_precio);
}

// Inactivar la atracción de disney
function BajaComida(string memory _nombreComida) public Unicamente(msg.sender){
    //Validar si existe la atracción
    require(keccak256(abi.encodePacked(MappingComidas[_nombreComida].nombre_Comida))  == keccak256(abi.encodePacked(_nombreComida)) , "Esta Comida no existe" );
    //Cambiar el estado de la atraccióna  a FALSE => no está en uso
    MappingComidas[_nombreComida].estado_Comida = false;
    //Emisión del evento dar de baja 
    emit baja_Comida(_nombreComida); 
}

// Visualizar Comidas disponibles 
    function ComidasDisponibles() public view returns(string[] memory){
        return Comidas;
    }

    // Funcion para subirse a una atracción en Disney y pagar en tokens esta atracción
    function SubirseComida (string memory _nombreComida) public{
        // Precio de la atracción en tokens
        uint tokens_Comida = MappingComidas[_nombreComida].precio_Comida;
        // Verifica el estado de la atracción (si está disponible)
        require(MappingComidas[_nombreComida].estado_Comida == true, "Comida no disponible en este momento");
        //Validar si el cliente tiene el numero de clientes necesarios para subirse a la atracción
        require(tokens_Comida <= MisTokens(), "Necesitas mas tokens para subirte a esta Comida");     
   

    /* El cliente paga la atracción en tokens 
      - Ha sido necesario crear una funcion en ERC20.sol con el nombre 'transferencia_disney'
        ya que al usar el Transfer o TransferFrom escogía las direcciones equivocadas.  ya que el msg.sender que se recibía
        era la dirección del contrato.     
    */
    token.transferencia_disney(msg.sender,address(this), tokens_Comida);
    // Almacenamiento en el historial de Comidas del cliente
    HistorialComidas[msg.sender].push(_nombreComida);
    // Emisión del evento disfruta Comida
    emit disfruta_Comida(_nombreComida,tokens_Comida,msg.sender);    
    } 

    // Visualizar el historial completo de Comidas disfrutadas por un cliente

    function Historial() public returns(string[] memory){
        return HistorialComidas[msg.sender];
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