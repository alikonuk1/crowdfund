//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Crowdfund is Ownable {
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
        require(raised == 0);

        tokenAddress = tokenAddress_;
        projectOwner = projectOwner_;
        fundingGoal = fundingGoal_;
    }

    function contribute(uint256 amount) external payable {
        // Get the ERC20 token contract
        IERC20 token = IERC20(tokenAddress);
        
        require(token.balanceOf(msg.sender) >= amount);

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
        require(raised < fundingGoal, "Funding goal has been reached!");

        // Get the ERC20 token contract
        IERC20 token = IERC20(tokenAddress);

        // Calculate refund amount
        uint256 refundAmount = contributions[msg.sender];

        // Refund the customer's contribution
        token.approve(address(this), refundAmount);
        token.transferFrom(address(this), msg.sender, refundAmount);

        // Update the contract's state
        raised -= refundAmount;
        contributions[msg.sender] = 0;

        emit Refund(msg.sender, refundAmount);
    }

    function withdraw() public {
        require(msg.sender == projectOwner, "Cant access!");
        require(raised >= fundingGoal, "Funding goal has not been reached!");

        IERC20 token = IERC20(tokenAddress);

        uint256 amount = token.balanceOf(address(this));
        token.approve(address(this), amount);
        token.transferFrom(address(this), msg.sender, amount);
    }
}
