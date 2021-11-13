// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

//modified from OlympusDao
//author : _bing

interface IsMETA {
    function rebase( uint256 METAProfit_, uint epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function gonsForBalance( uint amount ) external view returns ( uint );

    function balanceForGons( uint gons ) external view returns ( uint );
    
    function index() external view returns ( uint );
}