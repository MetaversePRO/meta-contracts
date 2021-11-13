// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/IERC20.sol";

//modified from OlympusDao
//author : _bing

contract StakingWarmup {

    address public immutable staking;
    address public immutable sMETA;

    constructor ( address _staking, address _sMETA ) {
        require( _staking != address(0) );
        staking = _staking;
        require( _sMETA != address(0) );
        sMETA = _sMETA;
    }

    function retrieve( address _staker, uint _amount ) external {
        require( msg.sender == staking );
        IERC20( sMETA ).transfer( _staker, _amount );
    }
}