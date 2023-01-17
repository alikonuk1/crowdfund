//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IERC20 } from "./IERC20.sol";
import {Ownable} from "./Ownable.sol";

contract Crowdfund is Ownable{
    // ERC20 token
    address public tokenAddress;

    // Crowdfunded project information
    address public projectOwner;
    uint256 public fundingGoal;
    uint256 public raised;

    // Events
    event FundingGoalReached();
    event Refund(address indexed customer, uint256 amount);

    // Mapping to track customer contributions
    mapping(address => uint256) public contributions;

    function setVariables(address tokenAddress_, address projectOwner_, uint256 fundingGoal_) public onlyOwner {
        require(tokenAddress_ != address(0));
        require(projectOwner_ != address(0));
        require(fundingGoal_ > 0);

        tokenAddress = tokenAddress_;
        projectOwner = projectOwner_;
        fundingGoal = fundingGoal_;
    }

    function contribute(uint256 amount) external payable {
        // Get the ERC20 token contract
        IERC20 token = IERC20(tokenAddress);

        // Transfer tokens from user to this contract
        token.transferFrom(msg.sender, address(this), amount);

        // Record the contribution
        contributions[msg.sender] += amount;
        raised += amount;

        // Check if the funding goal has been reached
        if (raised >= fundingGoal) {
            emit FundingGoalReached();
        }
    }

    function refund() external {
        // Ensure that the project has not reached its funding goal
        require(raised < fundingGoal);

        // Refund the customer's contribution
        uint256 refundAmount = contributions[msg.sender];
        emit Refund(msg.sender, refundAmount);

        // Update the contract's state
        raised -= refundAmount;
        contributions[msg.sender] = 0;
    }
}
