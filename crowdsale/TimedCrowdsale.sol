// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.7;

import "./Crowdsale.sol";

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
abstract contract TimedCrowdsale is Crowdsale {
    uint public openingTime;
    uint public closingTime;

    /**
     * Event for crowdsale extending
     * @param newClosingTime new closing time
     * @param prevClosingTime old closing time
     */
    event TimedCrowdsaleExtended(uint prevClosingTime, uint newClosingTime);

    /**
     * @dev Reverts if not in crowdsale time range.
     */
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    /**
     * @dev Constructor, takes crowdsale opening and closing times.
     * @param openingTime_ Crowdsale opening time
     * @param closingTime_ Crowdsale closing time
     */
    constructor (uint openingTime_, uint closingTime_) {
        // solhint-disable-next-line not-rely-on-time
        require(openingTime_ >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        // solhint-disable-next-line max-line-length
        require(closingTime_ > openingTime_, "TimedCrowdsale: opening time is not before closing time");

        openingTime = openingTime_;
        closingTime = closingTime_;
    }

    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp >= openingTime && block.timestamp <= closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp > closingTime;
    }

    /**
     * @dev Extend crowdsale.
     * @param newClosingTime Crowdsale closing time
     */
    function extendTime(uint newClosingTime) external onlyOwner {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        // solhint-disable-next-line max-line-length
        require(newClosingTime > closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(closingTime, newClosingTime);
        closingTime = newClosingTime;
    }

    function canClaim(address user) external view returns (bool) {
        uint tokenAmount = getTokenAmount(purchasedAddresses[user]);
        return !(
        !hasClosed() ||
        claimed[user] ||
        tokenAmount == 0 ||
        token.allowance(wallet, address(this)) < tokenAmount ||
        token.balanceOf(wallet) < tokenAmount
        );
    }
}
