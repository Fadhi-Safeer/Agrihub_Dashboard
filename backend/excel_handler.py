from fastapi import APIRouter, HTTPException, Query
from pathlib import Path
import pandas as pd

router = APIRouter()

EXCEL_PATH = Path("C:/Users/Fadhi Safeer/OneDrive/Documents/GitHub/Agrihub_Dashboard/backend/Data/agrivision_data.xlsx")  # adjust if needed

COLS = [
    "date",
    "time",
    "camera_id",
    "plant_id",
    "score",
    "nutrition_label",
    "disease_label",
    "disease_flag",
    "nutrition_ok",
]

def load_df() -> pd.DataFrame:
    print("[load_df] Called")
    print(f"[load_df] Excel path: {EXCEL_PATH}")

    if not EXCEL_PATH.exists():
        print("[load_df] ❌ Excel NOT FOUND")
        raise HTTPException(status_code=404, detail=f"Excel not found: {EXCEL_PATH}")

    print("[load_df] ✅ Excel found, loading...")
    df = pd.read_excel(EXCEL_PATH, header=None)
    print(f"[load_df] Raw shape: {df.shape}")

    if df.shape[1] < len(COLS):
        print("[load_df] ❌ Column count mismatch")
        raise HTTPException(
            status_code=400,
            detail=f"Excel has {df.shape[1]} cols, expected >= {len(COLS)}"
        )

    df = df.iloc[:, :len(COLS)].copy()
    df.columns = COLS
    print(f"[load_df] Trimmed shape: {df.shape}")

    # Combine date + time -> timestamp
    df["timestamp"] = pd.to_datetime(
        df["date"].astype(str) + " " + df["time"].astype(str),
        errors="coerce"
    )
    before_drop = len(df)
    df = df.dropna(subset=["timestamp"]).copy()
    print(f"[load_df] Dropped {before_drop - len(df)} invalid timestamps")

    df["day"] = df["timestamp"].dt.date.astype(str)

    # Normalize strings
    df["nutrition_label"] = df["nutrition_label"].astype(str).fillna("")
    df["disease_label"] = df["disease_label"].astype(str).fillna("")

    print(f"[load_df] Final shape: {df.shape}")
    return df


@router.get("/agrivision/summary")
def agrivision_summary(
    days: int = Query(30, ge=1, le=365),
    camera_id: int | None = Query(None, ge=1, le=100),
    day: str | None = Query(None, description="Optional YYYY-MM-DD"),
):
    print("\n[agrivision_summary] Endpoint called")
    print(f"[agrivision_summary] days={days}, camera_id={camera_id}, day={day}")

    df = load_df()
    print(f"[agrivision_summary] Loaded rows: {len(df)}")

    # Filter by camera if needed
    if camera_id is not None:
        before = len(df)
        df = df[df["camera_id"] == camera_id].copy()
        print(f"[agrivision_summary] Camera filter: {before} → {len(df)}")

    # Filter by day OR last N days
    if day is not None:
        before = len(df)
        df = df[df["day"] == day].copy()
        print(f"[agrivision_summary] Day filter ({day}): {before} → {len(df)}")
    else:
        max_ts = df["timestamp"].max()
        start = max_ts - pd.Timedelta(days=days)
        df = df[df["timestamp"] >= start].copy()
        print(f"[agrivision_summary] Last {days} days filter → {len(df)} rows")

    if df.empty:
        print("[agrivision_summary] ⚠️ No data after filtering")
        return {
            "growth": {"classes": [], "counts": []},
            "health": {"classes": [], "counts": []},
            "disease": {"classes": [], "counts": []},
        }

    # -------------------
    # GROWTH
    # -------------------
    growth_counts = df["nutrition_label"].value_counts(dropna=False)
    growth_classes = growth_counts.index.tolist()
    growth_values = growth_counts.values.tolist()
    print("[agrivision_summary] Growth counts:", dict(zip(growth_classes, growth_values)))

    # -------------------
    # HEALTH
    # -------------------
    health_counts = df["disease_label"].value_counts(dropna=False)
    health_classes = health_counts.index.tolist()
    health_values = health_counts.values.tolist()
    print("[agrivision_summary] Health counts:", dict(zip(health_classes, health_values)))

    # -------------------
    # DISEASE (exclude healthy)
    # -------------------
    disease_df = df[df["disease_label"].str.lower() != "healthy"].copy()
    disease_counts = disease_df["disease_label"].value_counts(dropna=False)
    disease_classes = disease_counts.index.tolist()
    disease_values = disease_counts.values.tolist()
    print("[agrivision_summary] Disease counts:", dict(zip(disease_classes, disease_values)))

    print("[agrivision_summary] ✅ Returning summary\n")

    return {
        "growth": {"classes": growth_classes, "counts": growth_values},
        "health": {"classes": health_classes, "counts": health_values},
        "disease": {"classes": disease_classes, "counts": disease_values},
    }

@router.get("/agrivision/health/timeline")
def agrivision_health_timeline(
    days: int = Query(30, ge=1, le=365),
    camera_id: int | None = Query(None, ge=1, le=100),
):
    """
    Returns daily health rate (%) based on disease_label:
    healthy_pct = (# healthy rows / total rows) * 100 per day
    Uses the SAME Excel file as /agrivision/summary (agrivision_data.xlsx).
    """
    df = load_df()

    if camera_id is not None:
        df = df[df["camera_id"] == camera_id].copy()

    # Last N days based on max timestamp (same logic as summary)
    max_ts = df["timestamp"].max()
    start = max_ts - pd.Timedelta(days=days)
    df = df[df["timestamp"] >= start].copy()

    if df.empty:
        return {"points": []}

    # Normalize
    df["is_healthy"] = df["disease_label"].astype(str).str.lower().eq("healthy")
    df["day"] = df["timestamp"].dt.date.astype(str)

    g = df.groupby("day", as_index=False).agg(
        total=("is_healthy", "size"),
        healthy=("is_healthy", "sum"),
    )
    g["healthy_pct"] = (g["healthy"] / g["total"]) * 100.0

    points = [
        {"day": row["day"], "healthy_pct": float(row["healthy_pct"])}
        for _, row in g.iterrows()
    ]

    return {"points": points}
@router.get("/agrivision/disease/timeline")
def agrivision_disease_timeline(
    days: int = Query(30, ge=1, le=365),
    camera_id: int | None = Query(None, ge=1, le=100),
):
    """
    Returns daily disease rate (%) based on disease_label:
    disease_pct = 100 - healthy_pct
    Uses the SAME Excel file as /agrivision/summary (agrivision_data.xlsx).
    """
    df = load_df()

    if camera_id is not None:
        df = df[df["camera_id"] == camera_id].copy()

    max_ts = df["timestamp"].max()
    start = max_ts - pd.Timedelta(days=days)
    df = df[df["timestamp"] >= start].copy()

    if df.empty:
        return {"points": []}

    df["is_healthy"] = df["disease_label"].astype(str).str.lower().eq("healthy")
    df["day"] = df["timestamp"].dt.date.astype(str)

    g = df.groupby("day", as_index=False).agg(
        total=("is_healthy", "size"),
        healthy=("is_healthy", "sum"),
    )
    g["healthy_pct"] = (g["healthy"] / g["total"]) * 100.0
    g["disease_pct"] = 100.0 - g["healthy_pct"]

    points = [
        {"day": row["day"], "disease_pct": float(row["disease_pct"])}
        for _, row in g.iterrows()
    ]

    return {"points": points}
@router.get("/agrivision/growth/timeline")
@router.get("/agrivision/growth/timeline")
def agrivision_growth_timeline(
    days: int = Query(30, ge=1, le=365),
    camera_id: int | None = Query(None, ge=1, le=100),
):
    """
    Nutrition status over time (daily %) derived from nutrition_label counts per day.
    Returns:
      fully_nutritional, k_deficient, n_deficient, p_deficient
    """
    df = load_df()

    if camera_id is not None:
        df = df[df["camera_id"] == camera_id].copy()

    max_ts = df["timestamp"].max()
    start = max_ts - pd.Timedelta(days=days)
    df = df[df["timestamp"] >= start].copy()

    if df.empty:
        return {"points": []}

    df["day"] = df["timestamp"].dt.date.astype(str)
    df["nutrition_label"] = df["nutrition_label"].astype(str).str.strip().str.lower()

    # Count per day per label
    pivot = (
        df.pivot_table(index="day", columns="nutrition_label", aggfunc="size", fill_value=0)
        .reset_index()
    )

    label_cols = [c for c in pivot.columns if c != "day"]
    pivot["total"] = pivot[label_cols].sum(axis=1)

    for c in label_cols:
        pivot[c] = (pivot[c] / pivot["total"]) * 100.0

    def col(name: str):
        return float(row.get(name, 0.0))

    points = []
    for _, row in pivot.iterrows():
        points.append({
            "day": row["day"],
            "fully_nutritional": col("fully_nutritional"),
            "k_deficient": col("k_deficient"),
            "n_deficient": col("n_deficient"),
            "p_deficient": col("p_deficient"),
        })

    return {"points": points}
