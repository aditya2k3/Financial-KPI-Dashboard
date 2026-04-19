"""
Generate synthetic but realistic sales rows for the Financial KPI Dashboard.
Run from repo root:  python scripts/generate_raw_data.py
Writes: data/raw_data.csv (default 16,220 rows — 15,000+ transactions).
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

REGIONS = [
    "North America",
    "EMEA",
    "APAC",
    "LATAM",
    "Middle East",
]
CATEGORIES = [
    "Electronics",
    "Apparel",
    "Food & Beverage",
    "Home & Garden",
    "Sports",
]


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("--rows", type=int, default=16_220, help="Number of data rows (default 16220)")
    p.add_argument("--seed", type=int, default=42)
    p.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Output CSV path (default: data/raw_data.csv under repo root)",
    )
    args = p.parse_args()
    rng = np.random.default_rng(args.seed)

    start = pd.Timestamp("2022-01-01")
    end = pd.Timestamp("2025-03-31")
    n = args.rows

    dates = pd.to_datetime(rng.integers(start.value // 10**9, end.value // 10**9, size=n), unit="s")
    region = rng.choice(REGIONS, size=n)
    category = rng.choice(CATEGORIES, size=n)

    # Base unit price and volume drive revenue; profit margin varies by segment.
    base_price = rng.lognormal(mean=7.0, sigma=0.55, size=n)
    qty = rng.integers(1, 51, size=n).astype(float)
    segment_factor = rng.uniform(0.85, 1.15, size=n)
    revenue = np.round(base_price * qty * segment_factor, 2)

    margin_raw = rng.beta(2.5, 4.0, size=n) * 0.42 + 0.08
    profit = np.round(revenue * margin_raw, 2)

    df = pd.DataFrame(
        {
            "Date": dates.normalize(),
            "Region": region,
            "Category": category,
            "Revenue": revenue,
            "Profit": profit,
            "Quantity": qty,
        }
    )

    # Inject a few duplicates and nulls so the cleaning notebook has real work (optional noise).
    dup_idx = rng.choice(df.index, size=min(120, n // 50), replace=False)
    dup_rows = df.loc[dup_idx].copy()
    df = pd.concat([df, dup_rows], ignore_index=True)

    null_rev = rng.choice(df.index, size=min(45, len(df) // 200), replace=False)
    df.loc[null_rev, "Revenue"] = np.nan

    root = Path(__file__).resolve().parent.parent
    out = args.output if args.output is not None else root / "data" / "raw_data.csv"
    out.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(out, index=False)
    print(f"Wrote {len(df)} rows to {out}")


if __name__ == "__main__":
    main()
