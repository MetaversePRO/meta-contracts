// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

//modified from OlympusDao
//author : _bing @ MetaversePRO

contract MetaCirculatingSupplyConrtact {
    using SafeMath for uint;

    bool public isInitialized;

    address public Meta;
    address public owner;
    address[] public nonCirculatingMetaAddresses;

    constructor() {        
        owner = msg.sender;
    }

    function initialize( address _Meta ) external returns ( bool ) {
        require( msg.sender == owner, "caller is not owner" );
        require( isInitialized == false );

        Meta = _Meta;

        isInitialized = true;

        return true;
    }

    function MetaCirculatingSupply() external view returns ( uint ) {
        uint _totalSupply = IERC20( Meta ).totalSupply();

        uint _circulatingSupply = _totalSupply.sub( getNonCirculatingMeta() );

        return _circulatingSupply;
    }

    function getNonCirculatingMeta() public view returns ( uint ) {
        uint _nonCirculatingMeta;

        for( uint i=0; i < nonCirculatingMetaAddresses.length; i = i.add( 1 ) ) {
            _nonCirculatingMeta = _nonCirculatingMeta.add( IERC20( Meta ).balanceOf( nonCirculatingMetaAddresses[i] ) );
        }

        return _nonCirculatingMeta;
    }

    function setNonCirculatingMetaAddresses( address[] calldata _nonCirculatingAddresses ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );
        nonCirculatingMetaAddresses = _nonCirculatingAddresses;

        return true;
    }

    function transferOwnership( address _owner ) external returns ( bool ) {
        require( msg.sender == owner, "Sender is not owner" );

        owner = _owner;

        return true;
    }
}