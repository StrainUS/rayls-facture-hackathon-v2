// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {RLSToken} from "../src/RLSToken.sol";

contract RLSTokenTest is Test {
    RLSToken public token;
    address public owner;
    address public alice;
    address public bob;

    uint256 constant MAX_SUPPLY  = 368_000 * 10 ** 18;
    uint256 constant INITIAL_MINT = 184_000 * 10 ** 18; // 50% initial

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob   = makeAddr("bob");

        vm.prank(owner);
        token = new RLSToken(INITIAL_MINT);
    }

    // =========================================================
    // DEPLOYMENT
    // =========================================================

    function test_InitialState() public view {
        assertEq(token.name(),        "Rayls Liquidity Staking");
        assertEq(token.symbol(),      "RLS");
        assertEq(token.decimals(),    18);
        assertEq(token.MAX_SUPPLY(),  MAX_SUPPLY);
        assertEq(token.BURN_BPS(),    50);
        assertEq(token.totalSupply(), INITIAL_MINT);
        assertEq(token.balanceOf(owner), INITIAL_MINT);
        assertEq(token.totalBurned(), 0);
    }

    function test_RemainingMintable() public view {
        assertEq(token.remainingMintable(), MAX_SUPPLY - INITIAL_MINT);
    }

    // =========================================================
    // MINT
    // =========================================================

    function test_MintByOwner() public {
        vm.prank(owner);
        token.mint(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);
    }

    function test_MintRevertsIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(bob, 100 ether);
    }

    function test_MintRevertsIfExceedsMaxSupply() public {
        uint256 available = token.remainingMintable();
        uint256 tooMuch   = available + 1;
        vm.startPrank(owner);
        vm.expectRevert(abi.encodeWithSelector(RLSToken.ExceedsMaxSupply.selector, tooMuch, available));
        token.mint(alice, tooMuch);
        vm.stopPrank();
    }

    function test_MintRevertsZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(RLSToken.ZeroAddress.selector);
        token.mint(address(0), 100 ether);
    }

    function test_MintRevertsZeroAmount() public {
        vm.prank(owner);
        vm.expectRevert(RLSToken.ZeroAmount.selector);
        token.mint(alice, 0);
    }

    function test_BatchMint() public {
        address[] memory recipients = new address[](3);
        uint256[] memory amounts    = new uint256[](3);
        recipients[0] = alice;
        recipients[1] = bob;
        recipients[2] = makeAddr("carol");
        amounts[0] = 100 ether;
        amounts[1] = 200 ether;
        amounts[2] = 300 ether;

        vm.prank(owner);
        token.batchMint(recipients, amounts);

        assertEq(token.balanceOf(alice), 100 ether);
        assertEq(token.balanceOf(bob),   200 ether);
    }

    function test_BatchMintRevertsArrayMismatch() public {
        address[] memory recipients = new address[](2);
        uint256[] memory amounts    = new uint256[](3);
        vm.prank(owner);
        vm.expectRevert(RLSToken.ArrayLengthMismatch.selector);
        token.batchMint(recipients, amounts);
    }

    // =========================================================
    // DEFLATIONARY TRANSFERS
    // =========================================================

    function test_TransferBurns0_5Percent() public {
        // Use mint so alice gets exact amount (mint is exempt from burn fee)
        vm.prank(owner);
        token.mint(alice, 10_000 ether);

        uint256 aliceBalance  = token.balanceOf(alice); // 10_000 ether
        uint256 sendAmount    = 1_000 ether;
        uint256 expectedBurn  = (sendAmount * 50) / 10_000; // 5 ether
        uint256 expectedReceived = sendAmount - expectedBurn;

        uint256 supplyBefore  = token.totalSupply();
        uint256 burnedBefore  = token.totalBurned();

        vm.prank(alice);
        token.transfer(bob, sendAmount);

        assertEq(token.balanceOf(bob),   expectedReceived);
        assertEq(token.balanceOf(alice), aliceBalance - sendAmount);
        assertEq(token.totalBurned(),    burnedBefore + expectedBurn);
        assertEq(token.totalSupply(),    supplyBefore - expectedBurn);
    }

    function test_NetAmountHelper() public view {
        (uint256 received, uint256 burned) = token.netAmount(1_000 ether);
        assertEq(burned,   5 ether);
        assertEq(received, 995 ether);
    }

    function test_MintDoesNotBurn() public {
        uint256 burnedBefore = token.totalBurned();
        vm.prank(owner);
        token.mint(alice, 100 ether);
        assertEq(token.totalBurned(), burnedBefore);
        assertEq(token.balanceOf(alice), 100 ether);
    }

    function test_BurnFunctionDoesNotTriggerBurnFee() public {
        // Use mint to avoid deflationary fee on setup transfer
        vm.prank(owner);
        token.mint(alice, 1_000 ether);

        uint256 burnedBefore = token.totalBurned();
        uint256 supplyBefore = token.totalSupply();

        vm.prank(alice);
        token.burn(100 ether); // ERC20Burnable direct burn

        // Only 100 ether should be gone, no extra 0.5% burn
        assertEq(token.totalBurned(), burnedBefore); // totalBurned only tracks deflationary burn
        assertEq(token.totalSupply(), supplyBefore - 100 ether);
    }

    function test_FuzzTransferBurnAmount(uint256 amount) public {
        amount = bound(amount, 1, 100_000 ether);

        vm.prank(owner);
        token.mint(alice, amount);

        uint256 expectedBurn     = (amount * 50) / 10_000;
        uint256 expectedReceived = amount - expectedBurn;

        vm.prank(alice);
        token.transfer(bob, amount);

        assertEq(token.balanceOf(bob), expectedReceived);
        assertEq(token.totalBurned(),  expectedBurn);
    }
}
