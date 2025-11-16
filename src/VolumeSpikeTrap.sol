// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IVolumeOracle {
    function getVolume() external view returns (uint256);
}

contract VolumeSpikeTrap is ITrap {
    address public constant ORACLE = 0x6c75b16496384caE307f7E842e7133590E6D79Af;

    // 2000 = 20% increase required
    uint256 public constant THRESHOLD_BPS = 2000;

    // -------------------------
    // collect() → sample data
    // -------------------------
    function collect() external view override returns (bytes memory) {
        uint256 volume = 0;

        try IVolumeOracle(ORACLE).getVolume() returns (uint256 v) {
            volume = v;
        } catch {
            // leave volume = 0
        }

        return abi.encode(volume, block.number);
    }

    // ---------------------------------------
    // shouldRespond() → detect volume spikes
    // ---------------------------------------
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length < 2) return (false, "");

        (uint256 newVol, uint256 newBlock) =
            abi.decode(data[0], (uint256, uint256));

        uint256 totalVol = 0;
        uint256 count = 0;

        // calculate average volume of older samples
        for (uint256 i = 1; i < data.length; i++) {
            (uint256 vol, ) = abi.decode(data[i], (uint256, uint256));
            totalVol += vol;
            count++;
        }

        if (count == 0) return (false, "");

        uint256 avgVol = totalVol / count;

        if (avgVol == 0) return (false, "");

        // spike detection
        uint256 thresholdVol = avgVol + ((avgVol * THRESHOLD_BPS) / 10000);

        if (newVol >= thresholdVol) {
            return (true, abi.encode(avgVol, newVol, newVol - avgVol, newBlock));
        }

        return (false, "");
    }
}
