
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IUniswapV2Pair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract TokenSwap {
    using Address for address;

    address private constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function swapTokens(
        address pairAddress,
        address tokenToBuy,
        uint256 buyAmount
    ) external {
        address token0 = IUniswapV2Pair(pairAddress).token0();
        address token1 = IUniswapV2Pair(pairAddress).token1();

        require(token0 != address(0) && token1 != address(0), "Invalid pair address");
        require(tokenToBuy == token0 || tokenToBuy == token1, "Invalid token to buy");

        uint256 amount0Out = tokenToBuy == token0 ? 0 : buyAmount;
        uint256 amount1Out = tokenToBuy == token1 ? 0 : buyAmount;
        address to = address(this);

        IERC20(token0).approve(UNISWAP_ROUTER, amount0Out);
        IERC20(token1).approve(UNISWAP_ROUTER, amount1Out);

        assembly {
            let success := call(
                gas(),
                UNISWAP_ROUTER,
                0,
                add(0x20, pairAddress),
                0x60,
                to,
                0x0
            )
            if iszero(success) {
                revert(0, 0)
            }
        }
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");

        (bool success, ) = tokenAddress.call(abi.encodeWithSelector(token.transfer.selector, msg.sender, amount));
        require(success, "Token transfer failed");
    }
}
