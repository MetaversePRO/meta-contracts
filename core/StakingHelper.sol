// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/IERC20.sol";
import "./libs/interface/IStaking.sol";

//modified from OlympusDao
//author : _bing @ MetaversePRO

contract StakingHelper {

    address public immutable staking;
    address public immutable META;

    constructor ( address _staking, address _META ) {
        require( _staking != address(0) );
        staking = _staking;
        require( _META != address(0) );
        META = _META;
    }

    function stake( uint _amount, address _recipient ) external {
        IERC20( META ).transferFrom( msg.sender, address(this), _amount );
        IERC20( META ).approve( staking, _amount );
        IStaking( staking ).stake( _amount, _recipient );
        IStaking( staking ).claim( _recipient );
    }
}