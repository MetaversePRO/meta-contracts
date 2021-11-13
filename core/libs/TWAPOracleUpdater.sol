// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./ERC20Permit.sol";
import "./VaultOwned.sol";
import "./interface/ITWAPOracle.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";

//modified from OlympusDao
//author : _bing

contract TWAPOracleUpdater is ERC20Permit, VaultOwned {

  using EnumerableSet for EnumerableSet.AddressSet;

  event TWAPOracleChanged( address indexed previousTWAPOracle, address indexed newTWAPOracle );
  event TWAPEpochChanged( uint previousTWAPEpochPeriod, uint newTWAPEpochPeriod );
  event TWAPSourceAdded( address indexed newTWAPSource );
  event TWAPSourceRemoved( address indexed removedTWAPSource );
    
  EnumerableSet.AddressSet private _dexPoolsTWAPSources;

  ITWAPOracle public twapOracle;

  uint public twapEpochPeriod;

  constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20(name_, symbol_, decimals_) {
    }

  function changeTWAPOracle( address newTWAPOracle_ ) external onlyOwner() {
    emit TWAPOracleChanged( address(twapOracle), newTWAPOracle_);
    twapOracle = ITWAPOracle( newTWAPOracle_ );
  }

  function changeTWAPEpochPeriod( uint newTWAPEpochPeriod_ ) external onlyOwner() {
    require( newTWAPEpochPeriod_ > 0, "TWAPOracleUpdater: TWAP Epoch period must be greater than 0." );
    emit TWAPEpochChanged( twapEpochPeriod, newTWAPEpochPeriod_ );
    twapEpochPeriod = newTWAPEpochPeriod_;
  }

  function addTWAPSource( address newTWAPSourceDexPool_ ) external onlyOwner() {
    require( _dexPoolsTWAPSources.add( newTWAPSourceDexPool_ ), "MetaERC20TOken: TWAP Source already stored." );
    emit TWAPSourceAdded( newTWAPSourceDexPool_ );
  }

  function removeTWAPSource( address twapSourceToRemove_ ) external onlyOwner() {
    require( _dexPoolsTWAPSources.remove( twapSourceToRemove_ ), "MetaERC20TOken: TWAP source not present." );
    emit TWAPSourceRemoved( twapSourceToRemove_ );
  }

  function _uodateTWAPOracle( address dexPoolToUpdateFrom_, uint twapEpochPeriodToUpdate_ ) internal {
    if ( _dexPoolsTWAPSources.contains( dexPoolToUpdateFrom_ )) {
      twapOracle.updateTWAP( dexPoolToUpdateFrom_, twapEpochPeriodToUpdate_ );
    }
  }

  function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal override virtual {
      if( _dexPoolsTWAPSources.contains( from_ ) ) {
        _uodateTWAPOracle( from_, twapEpochPeriod );
      } else {
        if ( _dexPoolsTWAPSources.contains( to_ ) ) {
          _uodateTWAPOracle( to_, twapEpochPeriod );
        }
      }
    }
}
