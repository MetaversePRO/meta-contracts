// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/DaoOwnable.sol";
import "./libs/interface/IBond.sol";

//modified from OlympusDao
//author : _bing @ MetaversePRO

contract RedeemHelper is DaoOwnable {

    address[] public bonds;

    function redeemAll( address _recipient, bool _stake ) external {
        for( uint i = 0; i < bonds.length; i++ ) {
            if ( bonds[i] != address(0) ) {
                if ( IBond( bonds[i] ).pendingPayoutFor( _recipient ) > 0 ) {
                    IBond( bonds[i] ).redeem( _recipient, _stake );
                }
            }
        }
    }

    function addBondContract( address _bond ) external onlyManager() {
        require( _bond != address(0) );
        bonds.push( _bond );
    }

    function removeBondContract( uint _index ) external onlyManager() {
        bonds[ _index ] = address(0);
    }
}