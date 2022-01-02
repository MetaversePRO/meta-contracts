// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Crowdsale.sol";
import "./TimedCrowdsale.sol";

contract MetaPublicCrowdsale is Crowdsale, TimedCrowdsale {
    using SafeERC20 for IERC20;

    uint public hardCap;
    uint public individualCap;

    constructor(uint hardCap_, uint individualCap_, uint numerator_, uint denominator_, address wallet_, IERC20 subject_, IERC20 token_, uint openingTime, uint closingTime)
    Crowdsale(numerator_, denominator_, wallet_, subject_, token_)
    TimedCrowdsale(openingTime, closingTime)
    {
        hardCap = hardCap_;
        individualCap = individualCap_;
    }

    function setCap(uint hardCap_, uint individualCap_) external onlyOwner {
        hardCap = hardCap_;
        individualCap = individualCap_;
    }

    function getPurchasableAmount(address user, uint amount) public view returns (uint) {
        if (purchasedAddresses[user] > 0) {
            return 0;
        }
        amount = (amount + subjectRaised) > hardCap ? (hardCap - subjectRaised) : amount;
        return amount > individualCap ? individualCap : amount;
    }

    function buyTokens(uint amount) external onlyWhileOpen nonReentrant {
        amount = getPurchasableAmount(msg.sender, amount);
        require(amount > 0, "MetaCrowdsale: purchasable amount is 0");

        subject.safeTransferFrom(msg.sender, wallet, amount);

        // update state
        subjectRaised += amount;
        purchasedAddresses[msg.sender] = amount;

        emit TokenPurchased(msg.sender, amount);
    }

    function claim() external nonReentrant {
        require(hasClosed(), "MetaCrowdsale: not closed");
        require(!claimed[msg.sender], "MetaCrowdsale: already claimed");

        uint tokenAmount = getTokenAmount(purchasedAddresses[msg.sender]);
        require(tokenAmount > 0, "MetaCrowdsale: not purchased");

        require(address(token) != address(0), "MetaCrowdsale: token not set");
        token.safeTransferFrom(wallet, msg.sender, tokenAmount);
        claimed[msg.sender] = true;

        emit TokenClaimed(msg.sender, tokenAmount);
    }
}
