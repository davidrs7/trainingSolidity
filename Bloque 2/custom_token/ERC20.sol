// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import  "./SafeMath.sol";

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
    //devuelve un valor bool con el resultado con el valor de gasto
    function approve(address spender,uint256 ammout) external  returns(bool);
    //devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando allowance()
    function transferFrom(address sender,address recipient,uint256 ammout) external returns(bool);
    //Evento que se emite cuando una cantidad de tokens pasa de un origen a un destino 
    event Transfer(address indexed from,address indexed to,uint value);
    //Evento que se debe emitir cuando se establece una asignación con el metodo allowance()
    event Approval(address indexed owner,address indexed spender,uint value);
}

// contrato ERC20 
contract ERC20Basic is IERC20{

    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8  public constant decimals = 18;

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

    //devuelve un valor bool resultado de la operación indicada(transferencia)
    function transfer(address recipient,uint256 amount)public override  returns(bool){
        return false;
    }
 
    //devuelve un valor bool con el resultado con el valor de gasto
    function approve(address spender,uint256 ammout) public override returns(bool){
        return false;
    }

        //devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando allowance()
    function transferFrom(address sender,address recipient,uint256 ammout) public override returns(bool){
        return false;
    }
    
}