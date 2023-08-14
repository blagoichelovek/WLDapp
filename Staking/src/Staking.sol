// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Staking contract. Users can stake ETH and get a reward after a certain period of time.
 * @author Zakhar Nechepurenko
 * @dev Simple functionality for staking ETH. User get a reward of 10% of the staked amount after 30 days.
 * @notice This contract is untested
 */

contract Staking is Ownable, ReentrancyGuard {
    error Staking__StakeAmountTooLow();
    error Staking__OwnerCannotStake();
    error Staking__AddressZeroError();
    error Staking__StakeDurationNotOver();
    error Staking__WithdrawalFailed();
    error Staking__PositionIsNotOpen();

    struct StakePosition {
        uint256 id;
        address staker;
        uint256 amountOfWeiStaked;
        uint256 timeOfStake;
        uint256 reward;
        bool open;
    }

    StakePosition[] public positions;

    uint256 public s_stakePositionId = 0;
    uint256 public immutable STAKE_DURATION = 30 days;
    uint256 public immutable MIN_STAKE_AMOUNT = 1e18 wei;

    mapping(address => uint256) public s_stakePositionIdOf;

    event Staked(address indexed staker, uint256 amountOfWeiStaked, uint256 timeOfStake);
    event Unstaked(address indexed staker, uint256 amountOfWeiStaked, uint256 timeOfUnstake);

    constructor() payable {}

    function stake() external payable nonReentrant {
        if (msg.value < MIN_STAKE_AMOUNT) {
            revert Staking__StakeAmountTooLow();
        }

        if (msg.sender == owner()) {
            revert Staking__OwnerCannotStake();
        }

        if (msg.sender == address(0)) {
            revert Staking__AddressZeroError();
        }

        positions.push(
            StakePosition({
                id: s_stakePositionId,
                staker: msg.sender,
                amountOfWeiStaked: msg.value,
                timeOfStake: block.timestamp,
                reward: _reward(msg.value),
                open: true
            })
        );
        s_stakePositionIdOf[msg.sender] = s_stakePositionId;
        s_stakePositionId++;
        emit Staked(msg.sender, msg.value, block.timestamp);
    }

    function unstakeAndWithdraw() external nonReentrant {
        uint256 id = _getIdByAddress(msg.sender);
        if (positions[id].timeOfStake + STAKE_DURATION > block.timestamp) {
            revert Staking__StakeDurationNotOver();
        }
        if (!positions[id].open) {
            revert Staking__PositionIsNotOpen();
        }
        uint256 amount = positions[id].amountOfWeiStaked + positions[id].reward;
        positions[id].open = false;
        delete s_stakePositionIdOf[msg.sender];
        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert Staking__WithdrawalFailed();
        }
        emit Unstaked(msg.sender, positions[id].amountOfWeiStaked, block.timestamp);
    }

    function getTimeStake(uint256 id) public view returns (uint256) {
        return positions[id].timeOfStake;
    }

    function _reward(uint256 amountOfWeiStaked) internal view returns (uint256) {
        return (amountOfWeiStaked * 10) / 100;
    }

    function _getIdByAddress(address wallet) internal view returns (uint256) {
        return s_stakePositionIdOf[wallet];
    }
}