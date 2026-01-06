# backend/mcp_tools/vision_tools.py

from pathlib import Path
from datetime import datetime, timedelta
import pandas as pd

# Path to your vision excel file
AGRIVISION_PATH = Path("backend/Data/agrivision_data.xlsx")


from pathlib import Path
from datetime import datetime, timedelta
import pandas as pd

AGRIVISION_PATH = Path("backend/Data/agrivision_data.xlsx")

def _load_vision_df() -> pd.DataFrame:
    """Load and normalize the vision detection data."""
    df = pd.read_excel(AGRIVISION_PATH)

    # Optional: print columns once to confirm
    # print("COLUMNS:", df.columns)

    # If you want to enforce expected column names, you can keep this:
    expected_cols = [
        "date",
        "time",
        "camera_number",
        "plant_id",
        "growth",
        "health",
        "disease",
        "disease_status",
        "health_status",
    ]
    missing = [c for c in expected_cols if c not in df.columns]
    if missing:
        raise ValueError(f"Missing columns in agrivision_data.xlsx: {missing}")

    # 🔹 Build timestamp safely

    # Case 1: both date + time exist
    if "date" in df.columns and "time" in df.columns:
        # Convert both to string before concatenation
        df["timestamp"] = pd.to_datetime(
            df["date"].astype(str) + " " + df["time"].astype(str),
            errors="coerce",
        )
    # Case 2: maybe there is already a timestamp column
    elif "timestamp" in df.columns:
        df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")
    else:
        raise ValueError(
            "Could not create 'timestamp': need either (date + time) or a 'timestamp' column."
        )

    # Ensure numeric types where needed
    df["disease_status"] = df["disease_status"].astype(int)
    df["health_status"] = df["health_status"].astype(int)

    # If growth / health are numeric scores, also cast them:
    if "growth" in df.columns:
        df["growth"] = pd.to_numeric(df["growth"], errors="coerce")
    if "health" in df.columns:
        df["health"] = pd.to_numeric(df["health"], errors="coerce")

    return df


def get_overall_status(days: int = 14) -> dict:
    """
    Returns overall farm health summary for last `days` days using the vision file.
    """
    df = _load_vision_df()
    cutoff = datetime.now() - timedelta(days=days)
    df = df[df["timestamp"] >= cutoff]

    total = len(df)
    healthy = int((df["health_status"] == 1).sum())
    unhealthy = int((df["health_status"] == 0).sum())
    diseased = int((df["disease_status"] == 1).sum())

    return {
        "days": days,
        "total_records": total,
        "healthy_count": healthy,
        "unhealthy_count": unhealthy,
        "diseased_count": diseased,
    }


def get_disease_overview(days: int = 14) -> dict:
    """
    Returns disease counts by type for last `days` days.
    """
    df = _load_vision_df()
    cutoff = datetime.now() - timedelta(days=days)
    df = df[df["timestamp"] >= cutoff]

    diseased_df = df[df["disease_status"] == 1]
    by_disease = (
        diseased_df.groupby("disease")["disease_status"]
        .count()
        .sort_values(ascending=False)
        .to_dict()
    )

    return {
        "days": days,
        "total_diseased": int(len(diseased_df)),
        "by_disease": {str(k): int(v) for k, v in by_disease.items()},
    }


