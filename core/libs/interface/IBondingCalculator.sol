// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IBondingCalculator {
  function valuation( address pair_, uint amount_ ) external view returns ( uint _value );
}