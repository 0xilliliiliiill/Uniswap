// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Swapper} from "../src/Swapper.sol";
import {Test, console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


contract SwapperTest is Test {
    Swapper public swapper;
    address owner = address(this);
    address user = makeAddr("user");
    address tokenToSwap = vm.envAddress("SWAP_TOKEN");
    address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    string forkAddress = vm.envString("API_KEY");


    function setUp() public {
        //setting fork
        uint256 forkID = vm.createFork(forkAddress);
        vm.selectFork(forkID);

        swapper = new Swapper(vm.envAddress("SWAP_ROUTERV2"), vm.envAddress("SWAP_ROUTERV3"));  //creates an object with "owner" owner

        //sending 1 eth to "owner"
        vm.deal(owner, 1 ether);
        assertEq(owner.balance, 1 ether);
    }


    function test_swapExactETHForTokens() public{
        swapper.swapExactETHForTokens{value: owner.balance}(tokenToSwap, 1);
        assertEq(owner.balance, 0);   
    }


    function testFuzz_swapExactInput(uint64 amountIn) public {
        // vm.assumeNoRevert();
        vm.assume(amountIn > 0.1 ether);
        vm.deal(owner, amountIn);
        uint256 ownerBalance = owner.balance;

        deal(weth, owner, amountIn);

        IERC20(weth).approve(address(swapper), type(uint256).max);

        swapper.swapExactInput{value: amountIn}(tokenToSwap, 1, 0, amountIn);

        assertEq(owner.balance + amountIn, ownerBalance);
    }


    function testFuzz_withdraw(uint96 amount) public {
        // receiving amount ether to contract
        address(swapper).call{value: amount}("");


        swapper.withdraw(owner);
        assertEq(address(swapper).balance, 0);
        assertTrue(owner.balance > 0);
    }


    function test_withdrawOnlyOwnerModifier() public{
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user)));
        swapper.withdraw(user);
        
        vm.stopPrank();
    }


    function test_withdrawTokens() public{
        //swapping eth for tokens to transfer
        swapper.swapExactETHForTokens{value: owner.balance}(tokenToSwap, 1);
        IERC20 tokenContract = IERC20(tokenToSwap);

        assertTrue(tokenContract.balanceOf(owner) == 0);
        assertTrue(tokenContract.balanceOf(address(swapper)) > 0);

        swapper.withdrawTokens(owner, tokenToSwap, tokenContract.balanceOf(address(swapper)));

        assertTrue(tokenContract.balanceOf(owner) > 0);
        assertTrue(tokenContract.balanceOf(address(swapper)) == 0);
    }


    function test_withdrawTokensOnlyOwnerModifier() public{
        vm.startPrank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(user)));
        swapper.withdrawTokens(user, tokenToSwap, 1);
        vm.stopPrank();
    }

    receive() payable external {}
}