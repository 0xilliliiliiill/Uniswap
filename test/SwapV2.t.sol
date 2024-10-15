// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SwapV2} from "../src/SwapV2.sol";
import {Test, console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


contract SwapV2Test is Test {
    SwapV2 public swapv2;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address tokenToSwap = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;



    function setUp() public {
        vm.prank(owner);
        swapv2 = new SwapV2();  //creates an object with "owner" owner

        //sending 1 eth to "owner"
        vm.deal(owner, 1 ether);
        assertEq(owner.balance, 1 ether);
    }


    function test_swap() public payable
    {
        vm.startPrank(owner);
        assertTrue(owner.balance > 0);
        swapv2.swap{value: owner.balance}(tokenToSwap);
        assertEq(owner.balance, 0);

        vm.stopPrank();        
    }


    function test_transferETH() public {
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);
        //receiving 1 ether to contract
        address(swapv2).call{value: 1 ether}("");

        swapv2.transferETH(owner, address(swapv2).balance);
        assertEq(address(swapv2).balance, 0);
        assertFalse(owner.balance == 0);
        vm.stopPrank();

        //Testing "onlyOwner" modifier
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user)));
        swapv2.transferETH(user, address(swapv2).balance);
        
        vm.stopPrank();
    }

    function test_transferTokens() public{
        vm.startPrank(owner);
        //swapping eth for tokens to transfer
        swapv2.swap{value: owner.balance}(tokenToSwap);
        IERC20 tokenContract = IERC20(tokenToSwap);

        assertTrue(tokenContract.balanceOf(owner) == 0);
        assertTrue(tokenContract.balanceOf(address(swapv2)) > 0);

        swapv2.transferTokens(owner, tokenToSwap, tokenContract.balanceOf(address(swapv2)));

        assertTrue(tokenContract.balanceOf(owner) > 0);
        assertTrue(tokenContract.balanceOf(address(swapv2)) == 0);
        vm.stopPrank();

        //Testing "onlyOwner" modifier
        vm.startPrank(user);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user)));
        swapv2.transferTokens(user, tokenToSwap, 1);

        vm.stopPrank();
    }

    function test_recieveETH() public {

    }
}