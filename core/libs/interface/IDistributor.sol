// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IDistributor {
    function distribute() external returns ( bool );
}