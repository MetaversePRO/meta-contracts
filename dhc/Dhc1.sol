// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interface/IDhcCampaign.sol";
import "./interface/IDhc.sol";

contract Dhc1 is IDhcCampaign, Ownable {
    using SafeERC20 for IERC20;

    IDhc public dhc;

    struct UserInfo {
        uint staked;
        uint depositTime;
        uint nextClaimTime;
    }

    uint public minLockTime;

    uint public penaltyPercent; // 30% = * 30 / 100
    uint public rewardPeriod;
    uint public rewardPercent; // 1% = * 10000 / 1000000

    bool public emergencyWithdrawEnabled;

    uint public endTime;

    mapping(address => UserInfo) public userInfo;

    event ClaimReward(address indexed user, uint amount, bool stake);

    constructor(IDhc _dhc, uint _minLockTime, uint _penaltyPercent, uint _rewardPeriod, uint _rewardPercent, uint _endTime) {
        dhc = _dhc;
        setParam(_minLockTime, _penaltyPercent, _rewardPeriod, _rewardPercent, _endTime);
    }

    function setParam(uint _minLockTime, uint _penaltyPercent, uint _rewardPeriod, uint _rewardPercent, uint _endTime) public onlyOwner {
        minLockTime = _minLockTime;
        penaltyPercent = _penaltyPercent;
        rewardPeriod = _rewardPeriod;
        rewardPercent = _rewardPercent;
        endTime = _endTime;
    }

    function setEmergencyWithdraw(bool en) external onlyOwner {
        emergencyWithdrawEnabled = en;
    }

    function isActive() public view returns (bool) {
        return block.timestamp < endTime;
    }

    function getNextPeriod(uint timestamp) public view returns (uint) {
        return timestamp - (timestamp % rewardPeriod) + rewardPeriod;
    }

    function getUnlockTime(address user) public view returns (uint) {
        return userInfo[user].depositTime + minLockTime;
    }

    function deposit(uint amount) external {
        require(amount > 0, "DHC1: invalid deposit amount");
        require(endTime > block.timestamp, "DHC1: ended");

        claim(false);

        IERC20(dhc.wsMeta()).safeTransferFrom(msg.sender, address(this), amount);

        _deposit(amount);
    }

    function _deposit(uint amount) private {
        UserInfo storage user = userInfo[msg.sender];
        user.depositTime = block.timestamp;
        user.nextClaimTime = getNextPeriod(block.timestamp);
        user.staked += amount;

        dhc.updateDeposit(amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw() external {
        require(userInfo[msg.sender].staked > 0, "DHC1: nothing to withdraw");

        UserInfo storage user = userInfo[msg.sender];

        dhc.updateWithdraw(user.staked);

        if (getUnlockTime(msg.sender) < block.timestamp) {
            claim(false);
        } else {
			user.nextClaimTime += rewardPeriod;
            uint penalty = user.staked * penaltyPercent / 100;
            IERC20(dhc.wsMeta()).safeTransfer(address(dhc), penalty);
            user.staked -= penalty;
        }

        IERC20(dhc.wsMeta()).safeTransfer(msg.sender, user.staked);
        emit Withdraw(msg.sender, user.staked);
        user.staked = 0;
    }

    function emergencyWithdraw() external {
        require(emergencyWithdrawEnabled, "DHC1: emergencyWithdraw is unavailable");
        uint staked = userInfo[msg.sender].staked;
        IERC20(dhc.wsMeta()).safeTransfer(msg.sender, staked);
        userInfo[msg.sender].staked = 0;
        emit Withdraw(msg.sender, staked);
    }

    function getReward(address user) public view returns (uint, uint) {
        uint staked = userInfo[user].staked;
        uint nextClaimTime = userInfo[user].nextClaimTime;
        if (staked == 0) {
            return (0, nextClaimTime);
        }
        uint currentTime = block.timestamp > endTime ? endTime : block.timestamp;
        if (nextClaimTime > currentTime) {
            return (0, nextClaimTime);
        }
        uint baseReward = staked * rewardPercent / 1000000;
        uint rewardTimes = (currentTime - nextClaimTime) / rewardPeriod + 1;
        nextClaimTime += rewardTimes * rewardPeriod;
        return (baseReward * rewardTimes, nextClaimTime);
    }

    function claim(bool stake) public {
        (uint reward, uint nextClaimTime) = getReward(msg.sender);
        if (reward > 0) {
            if (stake && isActive()) {
                dhc.sendReward(address(this), msg.sender, reward);
                _deposit(reward);
                emit ClaimReward(msg.sender, reward, true);
            } else {
                userInfo[msg.sender].nextClaimTime = nextClaimTime;
				userInfo[msg.sender].depositTime = block.timestamp;
                dhc.sendReward(msg.sender, msg.sender, reward);
                emit ClaimReward(msg.sender, reward, false);
            }
        }
    }
}
