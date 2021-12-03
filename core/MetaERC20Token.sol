// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./libs/TWAPOracleUpdater.sol";

//modified from OlympusDao
//author : _bing @ MetaversePRO

contract MetaERC20Token is TWAPOracleUpdater {

    using SafeMath for uint256;
	
    constructor() TWAPOracleUpdater("MetaversePRO", "Meta", 9) {
    }

    function mint(address account_, uint256 amount_) external onlyVault() {
        _mint(account_, amount_);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    // function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal override virtual {
    //   if( _dexPoolsTWAPSources.contains( from_ ) ) {
    //     _uodateTWAPOracle( from_, twapEpochPeriod );
    //   } else {
    //     if ( _dexPoolsTWAPSources.contains( to_ ) ) {
    //       _uodateTWAPOracle( to_, twapEpochPeriod );
    //     }
    //   }
    // }

    /*
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
     
    function burnFrom(address account_, uint256 amount_) public virtual {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) public virtual {
        uint256 decreasedAllowance_ =
            allowance(account_, msg.sender).sub(
                amount_,
                "ERC20: burn amount exceeds allowance"
            );

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}