// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    address public user1 = address(0x123);
    address public user2 = address(0x456);

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.deal(user1, 1 ether); // Giving some initial balance to user1 for transactions
        vm.deal(user2, 1 ether); // Giving some initial balance to user2 for transactions
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowance() public {
        uint256 amount = 1000 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        ourToken.approve(user1, amount);

        assertEq(ourToken.allowance(msg.sender, user1), amount);
    }

    function testTransfer() public {
        uint256 amount = 1000 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        ourToken.transfer(user1, amount);

        assertEq(ourToken.balanceOf(user1), amount);
        assertEq(
            ourToken.balanceOf(msg.sender),
            deployer.INITIAL_SUPPLY() - amount
        );
    }

    function testTransferFrom() public {
        uint256 amount = 500 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        ourToken.approve(user1, amount);

        vm.prank(user1);
        ourToken.transferFrom(msg.sender, user2, amount);

        assertEq(ourToken.balanceOf(user2), amount);
        assertEq(ourToken.allowance(msg.sender, user1), 0);
    }

    function testFailTransferExceedsBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.prank(msg.sender);
        ourToken.transfer(user1, amount); // This should fail
    }

    function testFailApproveExceedsBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.expectRevert();
        vm.prank(msg.sender);
        ourToken.approve(user1, amount); // This should fail
    }
}
/*
### Explanation

- **testAllowance**: Tests the `approve` function by setting an allowance and checking if it is recorded correctly.
- **testTransfer**: Tests the `transfer` function by transferring tokens from the deployer to `user1` and verifying the balances.
- **testTransferFrom**: Tests the `transferFrom` function by approving `user1` to transfer tokens on behalf of the deployer and verifying the balances and allowance.
- **testFailTransferExceedsBalance**: Ensures that transferring more than the balance fails.
- **testFailApproveExceedsBalance**: Ensures that approving more than the balance fails.
- **testTransferEvent**: Verifies that the `Transfer` event is emitted correctly during a transfer.
- **testApprovalEvent**: Verifies that the `Approval` event is emitted correctly during an approval.
*/
