// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/SafeMath.sol";
import "./libs/SafeERC20.sol";
import "./libs/interface/IsMETA.sol";

contract wMETA is ERC20 {
    using SafeERC20 for ERC20;
    using Address for address;
    using SafeMath for uint;

    address public immutable sMETA;

    constructor( address _sMETA ) ERC20( 'Wrapped sMETA', 'wsMETA' , 18) {
        require( _sMETA != address(0) );
        sMETA = _sMETA;
    }

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5000000 * 10**9;

    // TOTAL_GONS is a multiple of INITIAL_FRAGMENTS_SUPPLY so that _gonsPerFragment is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 public constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    function METAindex() public view returns ( uint index ){
        uint256 _gonsPerFragment = TOTAL_GONS.div( IsMETA( sMETA ).totalSupply() );
        index = IsMETA( sMETA ).INDEX().mul(10**8).div(_gonsPerFragment);
    }

    /**
        @notice wrap sMETA
        @param _amount uint
        @return uint
     */
    function wrap( uint _amount ) external returns ( uint ) {
        IERC20( sMETA ).transferFrom( msg.sender, address(this), _amount );
        
        uint value = sMETATowMETA( _amount );
        _mint( msg.sender, value );
        return value;
    }

    /**
        @notice unwrap sMETA
        @param _amount uint
        @return uint
     */
    function unwrap( uint _amount ) external returns ( uint ) {
        _burn( msg.sender, _amount );

        uint value = wMETATosMETA( _amount );
        IERC20( sMETA ).transfer( msg.sender, value );
        return value;
    }

    /**
        @notice converts wMETA amount to sMETA
        @param _amount uint
        @return uint
     */
    function wMETATosMETA( uint _amount ) public view returns ( uint ) {
        return _amount.mul( METAindex() ).div( 10 ** decimals() );
    }

    /**
        @notice converts sMETA amount to wMETA
        @param _amount uint
        @return uint
     */
    function sMETATowMETA( uint _amount ) public view returns ( uint ) {
        return _amount.mul( 10 ** decimals() ).div( METAindex() );
    }

}