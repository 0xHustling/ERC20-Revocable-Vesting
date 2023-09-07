// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RevocableVesting is Ownable, ReentrancyGuard {
    uint256 public NUMBER_OF_EPOCHS;
    uint256 public EPOCH_DURATION;

    IERC20 public vestedToken;

    uint256 public lastClaimedEpoch;
    uint256 public startTime;
    uint256 public totalDistributedBalance;
    address public controller;

    modifier onlyController() {
        require(_msgSender() == controller, "Not called from the controller!");
        _;
    }

    constructor(
        address owner,
        address vestingController,
        address vestedTokenAddress,
        uint256 vestingStartTime,
        uint256 totalBalance,
        uint256 numberOfEpochs,
        uint256 epochDuration
    ) {
        transferOwnership(owner);
        vestedToken = IERC20(vestedTokenAddress);
        startTime = vestingStartTime;
        controller = vestingController;
        totalDistributedBalance = totalBalance;
        NUMBER_OF_EPOCHS = numberOfEpochs;
        EPOCH_DURATION = epochDuration;
    }

    function claim() public nonReentrant {
        uint256 balanceToClaim;
        uint256 currentEpoch = getCurrentEpoch();
        if (currentEpoch > NUMBER_OF_EPOCHS + 1) {
            lastClaimedEpoch = NUMBER_OF_EPOCHS;
            vestedToken.transfer(
                owner(),
                vestedToken.balanceOf(address(this))
            );
            return;
        }

        if (currentEpoch > lastClaimedEpoch) {
            balanceToClaim =
                ((currentEpoch - 1 - lastClaimedEpoch) *
                    totalDistributedBalance) /
                NUMBER_OF_EPOCHS;
        }
        lastClaimedEpoch = currentEpoch - 1;
        if (balanceToClaim > 0) {
            vestedToken.transfer(owner(), balanceToClaim);
        }
    }

    function revokeVesting() external nonReentrant onlyController {
        vestedToken.transfer(
            controller,
            vestedToken.balanceOf(address(this))
        );
    }

    function balance() public view returns (uint256) {
        return vestedToken.balanceOf(address(this));
    }

    function getCurrentEpoch() public view returns (uint256) {
        if (block.timestamp < startTime) return 0;
        return (block.timestamp - startTime) / EPOCH_DURATION + 1;
    }

    fallback() external {
        claim();
    }
}
