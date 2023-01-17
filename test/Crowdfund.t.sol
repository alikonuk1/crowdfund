// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../src/Crowdfund.sol";
import "./mock/mockERC20.sol";

contract CounterTest is Test {
    Crowdfund cfund;
    MockERC20 cfToken;

    address creator = address(1);
    address funder1 = address(2);
    address funder2 = address(3);
    address funder3 = address(4);
    address hacker = address(9);

    function setUp() public {
        vm.startPrank(creator);
        cfToken = new MockERC20("MockToken", "TKN");
        cfund = new Crowdfund();
        cfund.setVariables(address(cfToken), address(creator), 100 ether);
        vm.stopPrank();

        //top up accounts with mock token
        vm.startPrank(funder1);
        cfToken.mint(999 ether);
        vm.stopPrank();
        vm.startPrank(funder2);
        cfToken.mint(999 ether);
        vm.stopPrank();
        vm.startPrank(funder3);
        cfToken.mint(999 ether);
        vm.stopPrank();
    }

    function testSuccess_contribute() public {
        // Crowfund contract address should not have any tokens at the start
        assertEq(cfToken.balanceOf(address(cfund)), 0);
        assertEq(cfund.raised(), 0);

        // funder1 funds the contract with 33 token
        vm.startPrank(funder1);
        cfToken.approve(address(cfund), 33 ether);
        cfund.contribute(33 ether);
        vm.stopPrank();

        // Crowfund contract now should have 33 tokens
        assertEq(cfToken.balanceOf(address(cfund)), 33 ether);
        assertEq(cfund.raised(), 33 ether);
    }

    function testSuccess_contribute_refund() public {
        // Crowfund contract should not have any tokens at the start
        assertEq(cfToken.balanceOf(address(cfund)), 0);
        assertEq(cfund.raised(), 0);

        // funder1 funds the contract with 33 token
        vm.startPrank(funder1);
        cfToken.approve(address(cfund), 33 ether);
        cfund.contribute(33 ether);
        vm.stopPrank();

        // Crowfund contract now should have 33 tokens
        assertEq(cfToken.balanceOf(address(cfund)), 33 ether);
        assertEq(cfund.raised(), 33 ether);

        // funder1 calls refund before goal reaches
        vm.startPrank(funder1);
        cfund.refund();
        vm.stopPrank();

        // Crowfund contract now should have 0 tokens
        assertEq(cfToken.balanceOf(address(cfund)), 0 ether);
        assertEq(cfund.raised(), 0 ether);
    }

    function testRevert_contribute_refund() public {
        // Crowfund contract should not have any tokens at the start
        assertEq(cfToken.balanceOf(address(cfund)), 0);
        assertEq(cfund.raised(), 0);

        // funder1 funds the contract with 100 token
        vm.startPrank(funder1);
        cfToken.approve(address(cfund), 100 ether);
        cfund.contribute(100 ether);
        vm.stopPrank();

        // Crowfund contract now should have 100 tokens
        assertEq(cfToken.balanceOf(address(cfund)), 100 ether);
        assertEq(cfund.raised(), 100 ether);

        // funder1 calls refund before goal reaches
        vm.startPrank(funder1);
        vm.expectRevert("Funding goal has been reached!");
        cfund.refund();
        vm.stopPrank();

        // Crowfund contract now should still have 100 tokens
        assertEq(cfToken.balanceOf(address(cfund)), 100 ether);
        assertEq(cfund.raised(), 100 ether);
    }
}
