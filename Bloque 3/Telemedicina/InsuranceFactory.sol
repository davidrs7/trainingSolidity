// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./OperacionesBasicas.sol";
import "./ERC20.sol";


/* 
Tests: 
Compañia de seguros: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
ASegurado o cliente: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
Laboratorio: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

*/ 

/* -------------------------------------------- CONTRATO COMPAÑIA SEGUROS ------------------------------------------- */
contract InsuranceFactory is OperacionesBasicas {

    constructor() public{
        token = new ERC20Basic(100);
        Insurance = address(this);
        Aseguradora = payable(msg.sender);
    }

    struct Asegurado{
        address DireccionAsegurado;
        bool AutorizacionAsegurado;
        address DireccionContrato;
    }

    struct servicio{
        string Nombre_Servicio;
        uint PrecioTokensServicio;
        bool EstadoServicio;
    }

    struct lab{
        address DireccionContratoLab;
        bool ValidacionLab;
    }
    // Instancia del contrato token
    ERC20Basic private token;
    // Declaracion de las direcciones 
    address Insurance; 
    // Recibirá el pago de los Asegurados
    address payable public Aseguradora;

    // Mappings  para Asegurados, servicios y laboratorios
    mapping(address => Asegurado) public MappingAsegurados; 
    mapping(string => servicio) public MappingServicios;
    mapping(address => lab) public MappingLab;
 
    // Arrays
    string[] private nombreServicios;
    address[] DireccionesLaboratorios;  
    address[] Direcciones_Asegurados;

    function FuncionUnicamenteAsegurados(address _direccionAsegurado) public view{
        require (MappingAsegurados[_direccionAsegurado].AutorizacionAsegurado == true, "Direccion de Asegurado NO autorizado.");
    }

    /* ---------- Modificadores y restricciones sobre asegurados y aseguradoras ------------- */

    modifier UnicamenteAsegurados(address _direccionAsegurado){
        FuncionUnicamenteAsegurados(_direccionAsegurado);
        _;
    }

    modifier UnicamenteAseguradora(address _direccionAseguradora){
        require(Aseguradora == _direccionAseguradora , "Direccion de aseguradora NO autorizada.");
        _;
    }

    modifier Asegurado_o_Aseguradora(address _direccionAsegurado, address _direccionEntrante){
        require((MappingAsegurados[_direccionAsegurado].AutorizacionAsegurado == true && _direccionAsegurado == _direccionEntrante ) || Aseguradora == _direccionEntrante , "Solamente compañia de seguros o asegurados");
        _;
    }

    /* ----------------- Eventos -------------------*/

    // Evento de compra de token
    event EventComprado(uint256);
    // Evento de un servicio proporcionado // DirAsegurado,nombreServicio, Precio
    event EventServicioProporcionado(address,string,uint256);
    // Retornara la direccion del laboratorio // dirLaboratorio, DirContrato
    event EventLaboratorioCreado(address,address);
    // Evento que retorna la direccion del asegurado y la direccion del contrato creado
    event EventAseguradoCreado (address, address);
    //retorna la direccion del asegurado que se ha dado de baja
    event EventBajaAsegurado(address);
    // Nombre servicio , Precio
    event EventServicioCreado(string, uint256);
    // Baja del servicio
    event EventBajaServicio(string);



    /* -------------- Funciones ---------------- */ 

    // funcion para crear un laboratorio
    function creacionLab() public{        
        DireccionesLaboratorios.push(msg.sender);
        address direccionLab = address(new Laboratorio(msg.sender,Insurance)); 
        MappingLab[msg.sender] =lab(direccionLab, true);
        emit EventLaboratorioCreado(msg.sender,direccionLab);
    } 

    function CrearContratoAsegurado() public{
        
        Direcciones_Asegurados.push(msg.sender);
        address direccionAsegurado = address(new InsuranceHealthRecord(msg.sender, token , Insurance, Aseguradora));
        MappingAsegurados[msg.sender] = Asegurado(msg.sender, true,direccionAsegurado);
        emit EventAseguradoCreado(msg.sender,direccionAsegurado);
    }

    function Laboratorios() public view UnicamenteAseguradora(msg.sender) returns(address[] memory){
        return DireccionesLaboratorios;
    }

    function Asegurados() public view UnicamenteAseguradora(msg.sender) returns(address[] memory){
        return Direcciones_Asegurados;
    }

    function consultarHistorialAsegurado(address _direccionAsegurado, address _direccionConsultor) public view  Asegurado_o_Aseguradora(_direccionAsegurado,_direccionConsultor) returns(string memory) {
        string memory historial = "";
        address direccionContratoAsegurado = MappingAsegurados[_direccionAsegurado].DireccionContrato;
        for (uint i=0; i < nombreServicios.length; i++){
            if (MappingServicios[nombreServicios[i]].EstadoServicio &&
                InsuranceHealthRecord(direccionContratoAsegurado).ServicioEstadoAsegurado(nombreServicios[i]))
            {
               (string memory nombreServicio,uint precioServicio) = InsuranceHealthRecord(direccionContratoAsegurado).HistorialAsegurado(nombreServicios[i]);  
                historial = string(abi.encodePacked(historial, "(" , nombreServicio ,", ", uint2str(precioServicio),") -----" ));
            }
        }
        return historial;
    }

    function AseguradoBaja(address _direccionAsegurado) public UnicamenteAseguradora(msg.sender){
        MappingAsegurados[_direccionAsegurado].AutorizacionAsegurado = false;
        InsuranceHealthRecord(MappingAsegurados[_direccionAsegurado].DireccionContrato).darBaja;
        emit EventBajaAsegurado(_direccionAsegurado);
    }

    function NuevoServicio(string memory _nombreServicio, uint256 _precioServicio) public UnicamenteAseguradora(msg.sender){
        MappingServicios[_nombreServicio] = servicio(_nombreServicio,_precioServicio,true);
        nombreServicios.push(_nombreServicio);
        emit EventServicioCreado(_nombreServicio,_precioServicio);
    }

       function darBajaServicio(string memory _nombreServicio) public UnicamenteAseguradora(msg.sender){
        require(ServicioEstado(_nombreServicio) == true ,"No se ha creado este servicio");
         MappingServicios[_nombreServicio].EstadoServicio = false;
        emit EventBajaServicio(_nombreServicio);
    }

    function ServicioEstado(string memory _nombreServicio) public view returns(bool){
        return MappingServicios[_nombreServicio].EstadoServicio;       
    }

    function PrecioServicio(string memory _nombreServicio) public view returns(uint256){
        require(ServicioEstado(_nombreServicio) == true ,"No se ha creado este servicio");
        return MappingServicios[_nombreServicio].PrecioTokensServicio;
    }

    // Funcion para retornar todos los servicios activos de la aseguradora

    function ConsultarServiciosActivos() public view returns(string[] memory){
        string[] memory ArrayServicios = new string[](nombreServicios.length);
        uint contador = 0;
        for (uint i=0; i< nombreServicios.length ; i ++){
            if (ServicioEstado(nombreServicios[i])){
                ArrayServicios[contador] = nombreServicios[i];
                contador ++;
            }
        }
        return ArrayServicios;
    }

    function compraTokens(address _direccionAsegurado,uint _numTokens)public payable UnicamenteAsegurados(_direccionAsegurado){
        uint256 Balance= balanceOf();
        require (_numTokens <= Balance, "Compra menos tokens");
        require (_numTokens > 0 , "Compra un numero positivo de tokens");
        token.transfer(msg.sender,_numTokens);
        emit EventComprado(_numTokens);
    }

    // retorna balance de la aseguradora
    function balanceOf()public view returns(uint256){
        return token.balanceOf(Insurance);
    }

    function GenerarTokens(uint _numTokens)public UnicamenteAseguradora(msg.sender) {
        token.increaseTotalSuply(_numTokens);
    }
}

/* ----------------------------------------------- CONTRATO ASEGURADOS ------------------------------------------- */

contract InsuranceHealthRecord is OperacionesBasicas{

    enum Estado{alta, baja}
    
    struct Owner{
        address direccionPropietario;
        uint saldoPropietario;
        Estado estado;
        IERC20 tokens;
        address insurance;
        address payable aseguradora;
    }
    Owner propietario;

    constructor(address _owner,IERC20 _token, address _insurance, address payable _aseguradora) public{
        propietario.direccionPropietario = _owner;
        propietario.saldoPropietario = 0;
        propietario.estado = Estado.alta;
        propietario.tokens = _token;
        propietario.insurance = _insurance;
        propietario.aseguradora = _aseguradora;
    }

    struct ServiciosSolicitados{
        string nombreServicio;
        uint256 precioServicio;
        bool estadoServicio;
    }

    struct ServiciosSolicitadosLab{
        string nombreServicio;
        uint256 precioServicio;
        address direccionLab;
    } 

    mapping (string => ServiciosSolicitados) MappingHistorialAsegurado;
    ServiciosSolicitadosLab[] historialAseguradoLab;
    ServiciosSolicitados[] ServiciosSolicitado;

    /*  Eventos */

    event EventSelfDestruct(address);
    event EventDevolverTokens(address,uint256);
    // Asegurado,Nombre,Precio
    event ServicioPagado(address,string,uint256);
    event EventPeticionServicioLab(address,address,string);

    // propietario de la poliza
    modifier Unicamente(address _direccion){
        require (_direccion == propietario.direccionPropietario , "No eres el propietario de la poliza");
        _;
    }
 
    function HistorialAseguradoLab() public view returns(ServiciosSolicitadosLab[] memory){
        return historialAseguradoLab;
    }

    function HistorialAsegurado(string memory _servicio) public view returns(string memory nombreServicio,uint256 precioServicio){
        return (MappingHistorialAsegurado[_servicio].nombreServicio,MappingHistorialAsegurado[_servicio].precioServicio);
    }

    function ServicioEstadoAsegurado(string memory _servicio) public view returns(bool){
        return MappingHistorialAsegurado[_servicio].estadoServicio;
    }

    function darBaja() public Unicamente(msg.sender){
        emit EventSelfDestruct(msg.sender);
        selfdestruct(msg.sender);
    }

    function CompraTokens(uint _numTokens) payable public Unicamente(msg.sender){
        require (_numTokens > 0 , "Compra un numero de tokens positivo");
        uint Precio = calcularPrecioTokens(_numTokens);
        require (msg.value >= Precio, "Saldo insuficiente");
        uint returnValue = msg.value - Precio;
        msg.sender.transfer(returnValue);
        InsuranceFactory(propietario.insurance).compraTokens(msg.sender,_numTokens);
    }

    function BalanceOf()public view Unicamente(msg.sender) returns(uint256 _balance) {
        return (propietario.tokens.balanceOf(address(this)));
    }   

    function DevolverTokens(uint _numtokens)public payable Unicamente(msg.sender){
        require (_numtokens > 0 , "Retorna un valor positivo de tokens");
        require (_numtokens <= BalanceOf(), "No tienes los tokens que deseas devolver");
        propietario.tokens.transfer(propietario.aseguradora, _numtokens);
        msg.sender.transfer(calcularPrecioTokens(_numtokens));
        emit EventDevolverTokens(msg.sender,_numtokens);
    }

    function PeticionServicio(string memory _servicio) public Unicamente(msg.sender){
        require (InsuranceFactory(propietario.insurance).ServicioEstado(_servicio) , "El servicio no se encuentra disponible");
        uint256 pagoTokens = InsuranceFactory(propietario.insurance).PrecioServicio(_servicio);
        require(pagoTokens <= BalanceOf(), "Saldo insuficiente para este servicio");
        propietario.tokens.transfer(propietario.aseguradora, pagoTokens);
        MappingHistorialAsegurado[_servicio] = ServiciosSolicitados(_servicio,pagoTokens,true);
        emit ServicioPagado(msg.sender, _servicio,pagoTokens);
    }

    function PeticionServicioLab(address _direccionLab,string memory _servicio)public payable Unicamente(msg.sender){
        Laboratorio contratoLab = Laboratorio(_direccionLab);
        require(msg.value == contratoLab.ConsultarPrecioServicio(_servicio)* 1 ether , "Error en el costo del servicio");
        contratoLab.PrestarServicio(msg.sender, _servicio);
        payable(contratoLab.DireccionLab()).transfer(contratoLab.ConsultarPrecioServicio(_servicio)*1 ether);
        historialAseguradoLab.push(ServiciosSolicitadosLab(_servicio, contratoLab.ConsultarPrecioServicio(_servicio),_direccionLab));
        emit EventPeticionServicioLab(_direccionLab,msg.sender,_servicio);
    }
 
}

/* -------------------------------------------------- CONTRATO LABS ---------------------------------------------- */

contract Laboratorio is OperacionesBasicas{

    address public DireccionLab;
    address contratoAseguradora;    

    constructor(address _account, address _direccionContratoAseguradora) public {
        DireccionLab = _account;
        contratoAseguradora = _direccionContratoAseguradora;        
    }

    struct ResultadoServicio{
        string diagnostico_servicio;
        string codigo_IPFS;
    }

    struct ServicioLab{
        string nombre_servicio;
        uint precio_servicio;
        bool enFuncionamiento;
    }

    // Relacion entre el asegurado y el servicio que ha solicitado
    mapping (address => string) public ServicioSolicitado;
    // Relacion entre el asegurado y los resultados
    mapping (address => ResultadoServicio) public ResultadosServiciosLab;
    //
    mapping (string => ServicioLab) public ServiciosLab;

    //direcciones de los asegutados que solicitan servicios
    address[] public PeticionesServicios;
    string[] nombreServiciosLab;

    event EventServicioFuncionando(string,uint);
    event EventDarServicio(address, string);
    
    // modificador
    modifier UnicamenteLab(address _direccion){
        require (_direccion == DireccionLab , "No tienes privilegios para ejecutar esta funcion");
        _;
    }

    function NuevoServicioLab(string memory _nombreServicio,uint _precio) public UnicamenteLab(msg.sender){
        ServiciosLab[_nombreServicio] = ServicioLab(_nombreServicio,_precio,true);
        nombreServiciosLab.push(_nombreServicio);
        emit EventServicioFuncionando(_nombreServicio,_precio);
    }

    function ConsultarServicios() public view returns(string[] memory){
        return nombreServiciosLab;
    }

    // TODO: RETORNAR PRECIO FINAL DEL SERVICIO;
    function ConsultarPrecioServicio(string memory _servicio) public view returns(uint){
        return ServiciosLab[_servicio].precio_servicio;
    }
    // TODO: IMPLEMENTAR EL SERVICIO
    function PrestarServicio(address _direccionAsegurado, string memory _servicio)public{
        InsuranceFactory IF = InsuranceFactory(contratoAseguradora);
        IF.FuncionUnicamenteAsegurados(_direccionAsegurado);
        require (ServiciosLab[_servicio].enFuncionamiento , "El servicio no se encuentra disponible");
        ServicioSolicitado[_direccionAsegurado] = _servicio;
        PeticionesServicios.push(_direccionAsegurado);
        emit EventDarServicio(_direccionAsegurado,_servicio);
    }

    function DarResultados(address _direccionAsegurado, string memory _Dx,string memory _codigoIPFS) public UnicamenteLab(msg.sender){
        ResultadosServiciosLab[_direccionAsegurado] = ResultadoServicio(_Dx,_codigoIPFS);
    }

    function VisualizarResultados(address _direccionAsegurado) public view returns (string memory _diagnostico,string memory _codigoIPFS){
      _diagnostico = ResultadosServiciosLab[_direccionAsegurado].diagnostico_servicio;
      _codigoIPFS = ResultadosServiciosLab[_direccionAsegurado].codigo_IPFS;
    }

}

