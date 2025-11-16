📈 Volume Spike Trap

Detect sudden increases in trading volume on Hoodi Testnet

This trap monitors trading activity for a target ERC-20 token and identifies abnormal spikes in trading volume. When the increase exceeds a configurable threshold, it signals a potential volatility event—helping automated responders (or humans) react quickly to emerging market conditions.

🎯 Purpose

Sudden increases in trading volume often precede:

Market volatility

Price breakouts

Manipulation attempts

Liquidity events

Whale accumulation or distribution

This trap lets you automatically detect such events.

⚙️ How It Works
collect()

Each cycle, the trap retrieves:

Current trading volume over the last block(s)

Block number or timestamp (for telemetry)

Optional: cumulative volume for smoothing

The data is encoded and returned to Drosera.

shouldRespond()

The trap compares:

Latest volume

Previous sample volume

If the percent increase exceeds the defined threshold (BPS-based), the trap returns true and encodes (prevVolume, newVolume, delta, blockNumber) for the responder.

Responder

Your responder contract (e.g., VolumeSpikeResponse.sol) is called when a spike is detected. It typically emits:

Previous volume

New volume

Delta amount

Timestamp or block number

This creates an immutable audit log.
