// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./BoringERC20.sol";
import "./IERC20.sol";


interface IRewarder {
    using BoringERC20 for IERC20;
    function onSymmReward(uint256 pid, address user, address recipient, uint256 symmAmount, uint256 newLpAmount) external;
    function pendingTokens(uint256 pid, address user, uint256 symmAmount) external view returns (IERC20[] memory, uint256[] memory);
}
