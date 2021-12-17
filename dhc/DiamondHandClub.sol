// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interface/IDhc.sol";
import "./interface/IDhcCampaign.sol";

contract DiamondHandClub is Ownable, Pausable, IDhc {
    using SafeERC20 for IERC20;

    address public wsMeta;
    uint public totalStaked;

    mapping(address => bool) public campaigns;

    event ClaimReward(address indexed user, address indexed campaign, uint amount);

    constructor(address _wsMeta) {
        wsMeta = _wsMeta;
    }

    function setTotalStaked(uint staked) external onlyOwner {
        totalStaked = staked;
    }

    modifier onlyCampaign() {
        require(campaigns[msg.sender], "DHC: caller is not campaign");
        _;
    }

    function registerCampaigns(address[] calldata c, bool[] calldata s) external onlyOwner {
        require(c.length == s.length, "DHC: invalid campaign data");
        for (uint i; i < c.length; i++) {
            campaigns[c[i]] = s[i];
        }
    }

    function setPause(bool _status) external onlyOwner {
        if (_status && !paused()) {
            _pause();
        }

        if (!_status && paused()) {
            _unpause();
        }
    }

    function updateDeposit(uint value) external onlyCampaign whenNotPaused {
        totalStaked += value;
    }

    function updateWithdraw(uint value) external onlyCampaign {
        totalStaked -= value;
    }

    function sendReward(address receiver, address user, uint amount) external onlyCampaign whenNotPaused {
        IERC20(wsMeta).safeTransfer(receiver, amount);
        emit ClaimReward(user, msg.sender, amount);
    }

    function emergencyWithdraw(address token_) public onlyOwner {
        IERC20(token_).transfer(msg.sender, IERC20(token_).balanceOf(address(this)));
    }
}
