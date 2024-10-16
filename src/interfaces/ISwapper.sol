// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

interface IUniswapV2{
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
}

interface IUniswapV3{
	struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
	function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}