// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "./libs/IRewarder.sol";
import "./libs/BoringERC20.sol";
import "./libs/BoringMath.sol";
import "./libs/BoringOwnable.sol";


contract SimpleRewarder is IRewarder , BoringOwnable {
    using BoringMath for uint256;
    using BoringERC20 for IERC20;
    uint256 private rewardMultiplier;
    IERC20 private immutable rewardToken;
    uint256 private constant REWARD_TOKEN_DIVISOR = 1e18;
    address private immutable chef;

    constructor (uint256 _rewardMultiplier, IERC20 _rewardToken, address _chef) public {
        rewardMultiplier = _rewardMultiplier;
        rewardToken = _rewardToken;
        chef = _chef;
    }

    /// @notice Sets the reward multiplier for rewards to be distributed. Can only be called by the owner.
    /// @param _rewardMultiplier Multiplier of reward
    function setRewardMultiplier(uint256 _rewardMultiplier) public onlyOwner {
        rewardMultiplier = _rewardMultiplier;
    }

    function onSymmReward (uint256, address, address to, uint256 symmAmount, uint256) onlyChef override external {
        uint256 pendingReward = symmAmount.mul(rewardMultiplier) / REWARD_TOKEN_DIVISOR;
        uint256 rewardBal = rewardToken.balanceOf(address(this));
        if (pendingReward > rewardBal) {
            rewardToken.safeTransfer(to, rewardBal);
        } else {
            rewardToken.safeTransfer(to, pendingReward);
        }
    }

    function pendingTokens(uint256, address, uint256 symmAmount) override external view returns (IERC20[] memory rewardTokens, uint256[] memory rewardAmounts) {
        IERC20[] memory _rewardTokens = new IERC20[](1);
        _rewardTokens[0] = (rewardToken);
        uint256[] memory _rewardAmounts = new uint256[](1);
        _rewardAmounts[0] = symmAmount.mul(rewardMultiplier) / REWARD_TOKEN_DIVISOR;
        return (_rewardTokens, _rewardAmounts);
    }

    modifier onlyChef {
        require(
            msg.sender == chef,
            "Only chef can call this function."
        );
        _;
    }

}
