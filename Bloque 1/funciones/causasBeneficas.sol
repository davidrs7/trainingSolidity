// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract causasBeneficas{

    struct Causa{
        uint Id;
        string nombre;
        uint precio_objetivo;
        uint cantidad_recaudada;
    }

    uint contador_causas = 0;
    mapping(string => Causa) causas;
 
    function nuevaCausa(string memory _nombre,uint _precioObjetivo) public payable{
        contador_causas += contador_causas;
        Causa memory causa = Causa(contador_causas,_nombre,_precioObjetivo,0); 
        causas[_nombre] = causa;
    }

    //validar Si ya se llegó a la cantidad recaudada (true se puede donar - false no se puede donar ya que se cumplió el objetivo) 
    function objetivoCumplido(string memory _nombre,uint _donar) private view returns(bool){
        bool banderaObjetivo;
        Causa memory causa = causas[_nombre];
        banderaObjetivo = (causa.cantidad_recaudada + _donar) <= causa.precio_objetivo ? true : false; 
        return banderaObjetivo;
    }

    //Donar a una causa
    function donar(string memory _nombre,uint _cantidadDonacion)public returns(bool){
        bool aceptarDonacion = true; 

        if(objetivoCumplido(_nombre,_cantidadDonacion)){
            causas[_nombre].cantidad_recaudada =  causas[_nombre].cantidad_recaudada + _cantidadDonacion;
        }else {
            aceptarDonacion = false;
        } 
        return aceptarDonacion;
    }
 
    //validar valor de recaudo de la causa
    function verCantidadRecaudada(string memory _nombre) public view returns(bool,uint,uint){
        bool limite_alcanzado = false;
        Causa memory causa = causas[_nombre];

        if(causa.cantidad_recaudada >= causa.precio_objetivo){
            limite_alcanzado = true;
        }
        
        return (limite_alcanzado,causa.precio_objetivo,causa.cantidad_recaudada);

    }

    function verCausas(string memory _nombre) public view returns(Causa memory){
        Causa memory causa = causas[_nombre];
        return causa;
    }


}