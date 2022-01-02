// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Crowdsale.sol";
import "./TimedCrowdsale.sol";

contract MetaWhitelistCrowdsale is Crowdsale, TimedCrowdsale {
    using SafeERC20 for IERC20;

    bytes32 public merkleRoot;
    uint public cap;

    constructor(uint cap_, bytes32 merkleRoot_, uint numerator_, uint denominator_, address wallet_, IERC20 subject_, IERC20 token_, uint openingTime, uint closingTime)
    Crowdsale(numerator_, denominator_, wallet_, subject_, token_)
    TimedCrowdsale(openingTime, closingTime)
    {
        merkleRoot = merkleRoot_;
        cap = cap_;
    }

    function setCap(uint cap_) external onlyOwner {
        cap = cap_;
    }

    function setRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint i; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }

    function buyTokens(uint amount, bytes32[] calldata merkleProof) external onlyWhileOpen nonReentrant {
        require(amount > 0, "MetaCrowdsale: amount is 0");
        if (amount > cap) {
            amount = cap;
        }

        require(purchasedAddresses[msg.sender] == 0, "MetaCrowdsale: already purchased");
        bytes32 node = keccak256(abi.encodePacked(msg.sender));
        require(verify(merkleProof, merkleRoot, node), "MetaCrowdsale: invalid proof");

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
