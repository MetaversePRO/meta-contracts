// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface ITreasury {
    function mintRewards( address _recipient, uint _amount ) external;
	function deposit( uint _amount, address _token, uint _profit ) external returns ( bool );
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
}