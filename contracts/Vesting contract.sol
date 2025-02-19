// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VestingContract {
    IERC20 public token;
    address public beneficiary;
    uint256 public startTime;
    uint256 public cliffTime;
    uint256 public vestingTime;
    uint256 public totalAmount;
    uint256 public released;

    constructor(
        address _token,
        address _beneficiary,
        uint256 _startTime,
        uint256 _cliffTime,
        uint256 _vestingTime,
        uint256 _totalAmount
    ) {
        token = IERC20(_token);
        beneficiary = _beneficiary;
        startTime = _startTime;
        cliffTime = _cliffTime;
        vestingTime = _vestingTime;
        totalAmount = _totalAmount;
        released = 0;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not the beneficiary");
        _;
    }

    modifier onlyAfterCliff() {
        require(block.timestamp >= cliffTime, "Cliff not reached");
        _;
    }

    function release() public onlyBeneficiary onlyAfterCliff {
        uint256 unreleased = releasableAmount();
        require(unreleased > 0, "No tokens to release");

        released += unreleased;
        token.transfer(beneficiary, unreleased);
    }

    function releasableAmount() public view returns (uint256) {
        uint256 elapsedTime = block.timestamp - startTime;
        if (elapsedTime < cliffTime) {
            return 0;
        } else if (elapsedTime >= vestingTime) {
            return totalAmount - released;
        } else {
            uint256 vestedAmount = (totalAmount * elapsedTime) / vestingTime;
            return vestedAmount - released;
        }
    }

    function vestedAmount() public view returns (uint256) {
        return (totalAmount * (block.timestamp - startTime)) / vestingTime;
    }
}
