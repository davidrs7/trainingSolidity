// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./ERC20.sol";

contract loteria{

    // Instancia del contrato Token 
    ERC20Basic private token;

    // Direcciones 
    address public owner; 
    address public contrato;

    //Numero de tokens a crear
    uint public tokens_creados = 10000;

    constructor(){
        token = new ERC20Basic(tokens_creados);
        owner = msg.sender;
        contrato = address(this);
    }

    /* Modifiers */
       modifier Unicamente(address _direccion){
       require (_direccion == owner, "No tienes privilegios para ejecutar esta funcion.");
       _;
   }

   /* Eventos*/ 

   event ComprandoTokens(uint, address);

    // ----------------------------------------------------TOKEN ------------------------------------------------ //

    // Establecer el precio de los tokens en ethers
   function PrecioTokens(uint _numTokens) internal pure returns (uint){
       return _numTokens * (1 ether);
   }

   // Generar mas tokens por la loteria 
   function GeneraTokens(uint _numTokensNuevos) public Unicamente(msg.sender){
       token.increaseTotalSupply(_numTokensNuevos);
   } 

    // Funcion para comprar Tokens de loteria
    function CompraTokens(uint _numTokens) public payable{
        // validamos el costo de los tokens 
        uint costo = PrecioTokens(_numTokens);
        // se requiere que el valor pagado sea equivalente al costo que tiene
        require(msg.value >= costo , "Ethers insuficientes para esta transaccion");
        // diferencia a pagar 
        uint returnValue = msg.value - costo;
        // Transferir la diferencia
        payable(msg.sender).transfer(returnValue);
        // Obtener el balance de tokens del contrato
        uint Balance = TokensDisponibles();
        // filtro para evaluar los tokens a comprar con los tokens disponibles.
        require(_numTokens <= Balance, "Compra un numero de tokens adecuado.");
        //Transferencia de tokens al comprador
        token.transfer(msg.sender, _numTokens);
        // Emitir evento de compra tokens
        emit ComprandoTokens(_numTokens,msg.sender);
    }

    // Balance de tokens en el contrato de loteria
    function TokensDisponibles() public view returns(uint){
        return token.balanceOf(contrato);
    }

    // Balance de tokens acumulados para el Bote
    function Bote() public view returns(uint){
        return token.balanceOf(owner); 
    }

    //Balance de Tokens de una persona
    function MisTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

 // ----------------------------------------------------LOTERIA ------------------------------------------------ //

 // Precio del boleto en tokens
  uint public PrecioBoleto = 5;
  // Mapping relacion entre la persona que compra y los numeros de los boletos 
  mapping(address => uint[]) idPersona_boletos;
  // Relacion para identificar al ganador
  mapping(uint => address) ADN_boleto;
  // Numero aleatorio
  uint randNonce = 0;
  //Boletos generados
  uint[] boletos_comprados;

  /* Eventos */
  event boleto_Comprado(uint,address); // Evento cuando se compra una boleta
  event boleto_ganador(uint);  // Evento ganador
  event tokens_devueltos(uint,address);  // Evento para devolver tokens

   // Funcion para comprar boletos de loteria
   function CompraBoleto(uint _boletos) public{
       // Precio total de los boletos
       uint precio_total = _boletos * PrecioBoleto;
       //filtrado de los tokens a pagar
       require(precio_total <= MisTokens() , "Necesitas comprar mas tokens");
       //Transferencia de tokens al owner -> bote
       /* 
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre 'transfer_Loteria'
        ya que al usar el Transfer o TransferFrom escogía las direcciones equivocadas.  ya que el msg.sender que se recibía
        era la dirección del contrato.   y debe ser ha la dirección de la persona fisica
       */
       token.transfer_Loteria(msg.sender,owner,precio_total);

        /*
            Se toma la marca de tiempo actual, dirección msg.sender y nonce
            un numero que solo se utiliza una vez para que no se ejecute dos veces la misma funcion de hash con los mismos parametros
            Luego se utiliza keccak256 para convertir la entrada a un hash aleatorio y seguido convertimos el hash a un uniot y despues 
            se divide entre 10000 para tomar los ultimos 4 digitos.
            Danvo un valor aleatorio entre 0 - 9999
        */
       for (uint i=0; i < _boletos ; i++){
           uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 10000;
           randNonce++;
           // Almacenar los datos de los boletos
           idPersona_boletos[msg.sender].push(random);
           // se añade al array de boletos comprados
           boletos_comprados.push(random);
           //Asignación del ADN del boleto a la persona
           ADN_boleto[random] = msg.sender;
           // Emitir el boleto comprado 
           emit boleto_Comprado(random,msg.sender);
       }       
   } 

   // visualizar el numero de boletos de una persona
   function TusBoletos() public view returns (uint[] memory){
       return idPersona_boletos[msg.sender];
   }

   // Function para generar un ganador y transferirle los tokens
   function GenerarGanador() public Unicamente(msg.sender){
       // Confirmar que existan boletos comprados
       require(boletos_comprados.length > 0 , "No hay boletos comprados");
       // Delaracion de la longitud del array 
       uint longitud = boletos_comprados.length;
       // 1 - Aleatoreamente elijo un numero entre 0 y la longitud
       uint posicion_array = uint(uint(keccak256(abi.encodePacked(block.timestamp)))% longitud);
       // 2 - seleccion aleatorea
       uint seleccion = boletos_comprados[posicion_array];
       //emisión del evento del ganador
       emit boleto_ganador(seleccion);
       // Enviar premio al ganador -> se recupera la dirección
       address direccion_ganador = ADN_boleto[seleccion];
       // Enviarle los tokens del premio al ganador
       token.transfer_Loteria(msg.sender,direccion_ganador,Bote());
   }

     // Devolucion de los tokens 
    function DevolverTokens(uint _numTokens) public payable {
        // El numero de tokens a devolver debe ser mayor a 0 
        require(_numTokens > 0 , "Necesitas devolver un numero positivo de tokens.");
        // El usuario/cliente debe tener los tokens que desea devolver 
        require (_numTokens <= MisTokens(), "No tienes los tokens que deseas devolver.");
        // DEVOLUCION:
        // 1. El cliente devuelva los tokens
        // 2. La loteria paga los tokens devueltos en ethers
        token.transfer_Loteria(msg.sender, address(this), _numTokens);
        payable(msg.sender).transfer(PrecioTokens(_numTokens));
        // Emision del evento 
        emit tokens_devueltos(_numTokens, msg.sender);
    }


}