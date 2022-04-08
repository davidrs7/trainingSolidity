// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import  "./SafeMath.sol";
 

/*
Luciana Rodriguez - 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
Carolina Cantor - 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
David Rodriguez - 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
*/

// interface de token ERC20
interface IERC20{
    //devuelve cantidad de tokens en existencia
    function totalSupply() external view returns(uint256);
    //devuelve la cantidad de tokens para una dirección indicada por parametro
    function balanceOf(address account)external view returns(uint256);
    // devuelve el numero de tokens que el spdender podrá gastar en nombre del owner
    function allowance(address owner, address spender)external view returns(uint256); 
    //devuelve un valor bool resultado de la operación indicada(transferencia)
    function transfer(address recipient,uint256 amount)external  returns(bool);  

    function transfer_Loteria(address recipient, address emisor ,uint256 numTokens)external returns (bool);
    //devuelve un valor bool con el resultado con el valor de gasto
    function approve(address spender,uint256 ammout) external  returns(bool);
    //devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando allowance()
    function transferFrom(address sender,address recipient,uint256 ammout) external returns(bool);
    //Evento que se emite cuando una cantidad de tokens pasa de un origen a un destino 
    event Transfer(address indexed from,address indexed to,uint value);
    //Evento que se debe emitir cuando se establece una asignación con el metodo allowance()
    event Approval(address indexed owner,address indexed spender,uint value);
}
/*
  URL con los datos de binance smart chain Testnet: https://docs.ricefarm.fi/guides/metamask-add-bsc
  URL de Faucet binance smart chain: https://testnet.binance.org/faucet-smart
*/
// contrato ERC20 
contract ERC20Basic is IERC20{

    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8  public constant decimals = 2;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed; 
    uint256 totalSupply_;

    constructor(uint256 initialSupply){
          totalSupply_ = initialSupply;
          balances[msg.sender] = totalSupply_;  
    } 

    using SafeMath for uint256; 

  //devuelve cantidad de tokens en existencia
    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    function  increaseTotalSupply(uint newTokensAmmount) public{
        totalSupply_ += newTokensAmmount;
        balances[msg.sender] += newTokensAmmount;
    }

    //devuelve la cantidad de tokens para una dirección indicada por parametro
    function balanceOf(address tokenOwner)public override view returns(uint256){
        return balances[tokenOwner];
    } 

    // devuelve el numero de tokens que el spdender podrá gastar en nombre del owner
    function allowance(address owner, address delegate)public override view returns(uint256){
        return allowed[owner][delegate];
    }

    //Tranfiere tokens de un emisor a un receptor - devuelve un valor bool resultado de la operación indicada(transferencia)
    function transfer(address recipient,uint256 numTokens)public override  returns(bool){
        require(numTokens <= balances[msg.sender] , "Supera la cantidad disponible");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender,recipient,numTokens);
        return true;
    }

        //Tranfiere tokens de un emisor a un receptor - devuelve un valor bool resultado de la operación indicada(transferencia)
    function transfer_Loteria(address emisor,address recipient,uint256 numTokens)public override  returns(bool){
        require(numTokens <= balances[emisor] , "Supera la cantidad disponible");
        balances[emisor] = balances[emisor].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(emisor,recipient,numTokens);
        return true;
    }
 
    //devuelve un valor bool con el resultado con el valor de gasto
    function approve(address delegate,uint256 numTokens) public override returns(bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender,delegate,numTokens);
        return true;
    }

        //devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando allowance()
    function transferFrom(address owner,address buyer,uint256 numTokens) public override returns(bool){
        //el propietario debe disponer de los tokens a comprar
        require(numTokens <= balances[owner], "El propietario no cuenta con la disponibilidad de los tokens a comprar");        
        //el numro de Tokens debe ser menor o igual a los tokens aprovados 
        require(numTokens <= allowed[owner][msg.sender], "No es posible aprobar la transaccion.");
        //Se resta el numero de tokens al propietario.
        balances[owner] = balances[owner].sub(numTokens);
        //Se resta el numero de tokens al intermediario.
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        //Se adiciona el numero de tokens al comprador.
        balances[buyer] = balances[buyer].add(numTokens); 
        emit Transfer(owner,buyer,numTokens);
        return true;
    }
    
}