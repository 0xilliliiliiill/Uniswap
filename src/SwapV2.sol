// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;


import {console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
interface IUniswap{
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}


contract SwapV2 is Ownable{
    IUniswap public uniswapV2Rounter02;
    using SafeERC20 for IERC20;

    constructor() Ownable(msg.sender){
        uniswapV2Rounter02 = IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        console.log("construct ended");
        console.log("MSG SENDER", msg.sender);
    }


    function swap(address token_address) public payable {
        require(msg.value != 0, "You cant swap 0 value");
        address[] memory path = new address[](2);
        path[0] = uniswapV2Rounter02.WETH();
        path[1] = token_address;
        uniswapV2Rounter02.swapExactETHForTokens{value: msg.value}(1, path, address(this), block.timestamp + 100);
    }


    function transferETH(address receiver, uint256 amount) public payable onlyOwner{
        require(amount <= address(this).balance, "You are trying to transfer more than the contract has!");
        payable(receiver).transfer(amount);
    }


    function transferTokens(address reciever, address _tokenContract, uint256 amount) public payable onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.safeTransfer(reciever, amount);
    }

    function recieveETH() public payable{
        payable (address(this)).transfer(msg.value);
    }

    receive() payable external {}
}