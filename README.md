# 📈 Volume Spike Trap

Detect abnormal spikes in trading volume on Hoodi Testnet using a Drosera trap.

This trap monitors **cumulative trading volume** from an external oracle and detects **sudden increases in per-interval volume**. When activity exceeds a configurable threshold, it triggers a responder—helping surface potential volatility events early.

---

## 🎯 What It Detects

Volume spikes often precede:

* Market volatility
* Price breakouts
* Liquidity events
* Manipulation attempts
* Whale activity

---

## ⚙️ How It Works

### `collect()`

* Reads cumulative trading volume from an oracle (API3-style proxy)
* Captures the current block number
* Encodes `(cumulativeVolume, blockNumber)`
* Uses `try/catch` so oracle failures never revert

### `shouldRespond()`

* Computes the **latest volume delta** from cumulative samples
* Builds a **moving average of historical deltas**
* Applies a **BPS-based threshold** (e.g. 2000 = 20%)
* Requires a **minimum number of valid samples** to reduce noise
* Returns a typed payload when a spike is detected

Payload:

```
(avgDelta, newDelta, deltaAboveAvg, blockNumber)
```

---

## 🔔 Responder

When triggered, a responder contract (e.g. `VolumeSpikeResponse.sol`) is called and typically emits an event containing:

* Average historical delta
* Newest delta
* Delta above average
* Block number
* Threshold (BPS)

This provides an immutable on-chain audit log of volume spike events.

---

## 🛡️ Design Notes

* Planner-safe (empty blobs skipped)
* Works with cumulative oracles (API3 / Chainlink-style)
* Stateless trap (constants only)
* Cooldown handled via Drosera TOML config

---

## ✅ Summary

A lightweight, production-ready Drosera trap for detecting unusual trading activity using cumulative volume data.
