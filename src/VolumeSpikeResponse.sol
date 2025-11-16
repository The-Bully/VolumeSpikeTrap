// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VolumeSpikeResponse {
    event VolumeSpike(
        uint256 avgVolume,
        uint256 newVolume,
        uint256 delta,
        uint256 blockNumber
    );

    function respondToVolumeSpike(
        uint256 avgVolume,
        uint256 newVolume,
        uint256 delta,
        uint256 blockNumber
    ) external {
        emit VolumeSpike(avgVolume, newVolume, delta, blockNumber);
    }
}
