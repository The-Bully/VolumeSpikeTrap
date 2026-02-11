// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";


interface IApi3Proxy {
    function read() external view returns (int224 value, uint32 timestamp);
}

contract VolumeSpikeTrap is ITrap {
    address public constant ORACLE =
        0x6c75b16496384caE307f7E842e7133590E6D79Af;

    
    uint256 public constant THRESHOLD_BPS = 2000;

    // -------------------------
    // collect() → sample data
    // -------------------------
    function collect() external view override returns (bytes memory) {
        uint256 cumVolume = 0;

        try IApi3Proxy(ORACLE).read() returns (int224 value, uint32) {
            if (value > 0) {
                cumVolume = uint256(uint224(value));
            }
        } catch {
            // leave cumVolume = 0
        }

        return abi.encode(cumVolume, block.number);
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
        if (data[0].length == 0) return (false, "");

        
        (uint256 newCum, uint256 newBlock) =
            abi.decode(data[0], (uint256, uint256));

        if (data[1].length == 0) return (false, "");

        
        (uint256 prevCum, ) =
            abi.decode(data[1], (uint256, uint256));

        if (newCum <= prevCum) return (false, "");

        uint256 newDelta = newCum - prevCum;

       
        uint256 sum;
        uint256 cnt;

        for (uint256 i = 2; i < data.length; i++) {
            if (data[i].length == 0 || data[i - 1].length == 0) continue;

            (uint256 older, ) =
                abi.decode(data[i - 1], (uint256, uint256));
            (uint256 newer, ) =
                abi.decode(data[i], (uint256, uint256));

            if (newer <= older) continue;

            sum += (newer - older);
            cnt++;
        }

       
        if (cnt < 3) return (false, "");

        uint256 avgDelta = sum / cnt;
        if (avgDelta == 0) return (false, "");

        uint256 threshold =
            avgDelta + ((avgDelta * THRESHOLD_BPS) / 10_000);

        if (newDelta >= threshold) {
            return (
                true,
                abi.encode(
                    avgDelta,
                    newDelta,
                    newDelta - avgDelta,
                    newBlock
                )
            );
        }
         return (false, "");
    }
}
