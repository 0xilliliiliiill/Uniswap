// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;


import {console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IUniswapV2, IUniswapV3} from "src/interfaces/ISwapper.sol";


contract Swapper is Ownable{
    IUniswapV2 public uniswapV2Router;
    IUniswapV3 public uniswapV3Router;
    address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    using SafeERC20 for IERC20;

    constructor(address uniswapTokenV2, address uniswapTokenV3) Ownable(msg.sender){

        uniswapV2Router = IUniswapV2(uniswapTokenV2);
        uniswapV3Router = IUniswapV3(uniswapTokenV3);
    }


    function swapExactETHForTokens(address token, uint256 amountOutMin) public payable {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;
        uniswapV2Router.swapExactETHForTokens{value: msg.value}(amountOutMin, path, address(this), block.timestamp + 100);
    }


    function swapExactInput(address token, uint256 amountOutMinimum, uint160 sqrtPriceLimitX96, uint256 amountIn) public payable {

        IERC20(weth).transferFrom(msg.sender, address(this), amountIn);
        IERC20(weth).approve(address(uniswapV3Router), type(uint256).max);

        IUniswapV3.ExactInputSingleParams memory params;
        params.tokenIn = weth;
        params.tokenOut = token;
        params.fee = 3000;
        params.recipient = address(this);
        params.deadline = block.timestamp + 100;
        params.amountIn = amountIn;
        params.amountOutMinimum = amountOutMinimum;
        params.sqrtPriceLimitX96 = sqrtPriceLimitX96;
        
        uniswapV3Router.exactInputSingle(params);
    }




    function withdraw(address receiver) public payable onlyOwner{
        require(address(this).balance > 0, "You are trying to transfer more than the contract has!");
        payable(receiver).transfer(address(this).balance);
    }


    function withdrawTokens(address reciever, address _tokenContract, uint256 amount) public payable onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.safeTransfer(reciever, amount);
    }

    receive() payable external {}
}