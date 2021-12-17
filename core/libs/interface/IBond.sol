// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IBond {
	function principle() external returns (address); 
    function bondPrice() external view returns ( uint price_ );
    function deposit( uint _amount, uint _maxPrice, address _depositor) external returns ( uint );
	function redeem( address _recipient, bool _stake ) external returns ( uint );
    function pendingPayoutFor( address _depositor ) external view returns ( uint pendingPayout_ );
	
}
