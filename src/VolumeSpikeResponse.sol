// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VolumeSpikeResponse {
    event VolumeSpike(
        uint256 avgDelta,
        uint256 newDelta,
        uint256 deltaAboveAvg,
        uint256 blockNumber,
        uint256 thresholdBps
    );

    function respondToVolumeSpike(
        uint256 avgDelta,
        uint256 newDelta,
        uint256 deltaAboveAvg,
        uint256 blockNumber,
        uint256 thresholdBps
    ) external {
        emit VolumeSpike(
            avgDelta,
            newDelta,
            deltaAboveAvg,
            blockNumber,
            thresholdBps
        );
    }
}
