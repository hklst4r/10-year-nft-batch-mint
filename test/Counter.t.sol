// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BatchMint} from "../src/minter.sol";

contract BatchMintTest is Test {
    BatchMint public minter;
    address user = makeAddr("user");

    function setUp() public {
        vm.createSelectFork("https://ethereum-rpc.publicnode.com");
        minter = new BatchMint();
    }

    function testMint10() public {
        vm.startPrank(user);
        minter.batchMint(100, user);
    }
}
