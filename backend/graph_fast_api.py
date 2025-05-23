from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import re
from datetime import datetime
from typing import List, Dict
from pydantic import BaseModel

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Constants
DATA_DIR = "C:/Users/Fadhi Safeer/OneDrive/Documents/GitHub/Agrihub_Dashboard/backend"
EXCEL_FILE = f"{DATA_DIR}/Excel_Data.xlsx"

# Helper functions
def parse_percentages(percentage_str: str) -> Dict[str, float]:
    """Parse percentage strings into dictionary"""
    result = {}
    if isinstance(percentage_str, str):
        matches = re.findall(r'([^:,]+):\s*(\d+(?:\.\d+)?)%', percentage_str)
        for label, value in matches:
            result[label.strip().lower()] = float(value)
    return result

def load_data(sheet_name: str) -> pd.DataFrame:
    """Load and clean data from Excel sheet"""
    df = pd.read_excel(EXCEL_FILE, sheet_name=sheet_name)
    if 'TIMESTAMP' in df.columns:
        df['TIMESTAMP'] = pd.to_datetime(df['TIMESTAMP'], errors='coerce')
        df = df.dropna(subset=['TIMESTAMP'])
    return df

# Page 1: Growth Stage Visualizations
@app.get("/api/growth/timeline")
async def growth_stage_timeline():
    """1. Growth Stage Timeline (Stacked Area Chart)"""
    df = load_data("DetectionData")
    df['growth_stages'] = df['GROWTH_STAGE (%)'].apply(parse_percentages)
    
    timeline_data = []
    for _, row in df.iterrows():
        parsed = row['growth_stages']
        timeline_data.append({
            "date": row['TIMESTAMP'].strftime("%Y-%m-%d %H:%M"),
            "early_growth": parsed.get('early growth', 0.0),
            "leafy_growth": parsed.get('leafy growth', 0.0),
            "head_formation": parsed.get('head formation', 0.0),
            "harvest_stage": parsed.get('harvest stage', 0.0)
        })
    
    return {
        "labels": [d["date"] for d in timeline_data],
        "early_growth": [d["early_growth"] for d in timeline_data],
        "leafy_growth": [d["leafy_growth"] for d in timeline_data],
        "head_formation": [d["head_formation"] for d in timeline_data],
        "harvest_stage": [d["harvest_stage"] for d in timeline_data]
    }

@app.get("/api/growth/environmental-factors")
async def growth_vs_environmental():
    """2. Growth Rate vs. Environmental Factors (Combination Chart)"""
    sensor_df = load_data("SensorData")
    detection_df = load_data("DetectionData")
    detection_df['growth_stages'] = detection_df['GROWTH_STAGE (%)'].apply(parse_percentages)
    
    # Merge data on nearest timestamp
    merged = pd.merge_asof(
        detection_df.sort_values('TIMESTAMP'),
        sensor_df.sort_values('TIMESTAMP'),
        on='TIMESTAMP',
        direction='nearest'
    )
    
    chart_data = []
    for _, row in merged.iterrows():
        parsed = row['growth_stages']
        chart_data.append({
            "label": row['TIMESTAMP'].strftime("%m-%d %H:%M"),
            "temperature": row['TEMP (°C)'],
            "ec": row['EC (µS/cm)'],
            "total_growth": sum(parsed.values())  # Sum of all growth percentages
        })
    
    return {
        "data": chart_data[:20]  # Limit to 20 points for better visualization
    }

@app.get("/api/growth/distribution-by-location")
async def growth_by_location():
    """3. Growth Stage Distribution by Camera Location (Grouped Bar Chart)"""
    df = load_data("DetectionData")
    df['growth_stages'] = df['GROWTH_STAGE (%)'].apply(parse_percentages)
    
    camera_stats = {}
    for camera_id, group in df.groupby('CAMERA_ID'):
        averages = {
            'early_growth': group['growth_stages'].apply(lambda x: x.get('early growth', 0.0)).mean(),
            'leafy_growth': group['growth_stages'].apply(lambda x: x.get('leafy growth', 0.0)).mean(),
            'head_formation': group['growth_stages'].apply(lambda x: x.get('head formation', 0.0)).mean(),
            'harvest_stage': group['growth_stages'].apply(lambda x: x.get('harvest stage', 0.0)).mean()
        }
        camera_stats[camera_id] = averages
    
    return {
        "labels": list(camera_stats.keys()),
        "datasets": [
            {"label": "Early Growth", "data": [v['early_growth'] for v in camera_stats.values()]},
            {"label": "Leafy Growth", "data": [v['leafy_growth'] for v in camera_stats.values()]},
            {"label": "Head Formation", "data": [v['head_formation'] for v in camera_stats.values()]},
            {"label": "Harvest Stage", "data": [v['harvest_stage'] for v in camera_stats.values()]}
        ]
    }

# Page 2: Disease Status Visualizations
@app.get("/api/disease/prevalence")
async def disease_prevalence():
    """1. Disease Prevalence Timeline (Stacked Area Chart)"""
    df = load_data("DetectionData")
    df['diseases'] = df['DISEASE_STATUS (%)'].apply(parse_percentages)
    
    timeline_data = []
    for _, row in df.iterrows():
        parsed = row['diseases']
        timeline_data.append({
            "date": row['TIMESTAMP'].strftime("%Y-%m-%d %H:%M"),
            "bacterial": parsed.get('bacterial', 0.0),
            "downy_mildew": parsed.get('downy_mildew_on_lettuce', 0.0),
            "powdery_mildew": parsed.get('powdery_mildew_on_lettuce', 0.0),
            "septoria_blight": parsed.get('septoria_blight_on_lettuce', 0.0),
            "viral": parsed.get('viral', 0.0),
            "wilt_leaf_blight": parsed.get('wilt_and_leaf_blight_on_lettuce', 0.0)
        })
    
    return {
        "labels": [d["date"] for d in timeline_data],
        "datasets": [
            {"label": "Bacterial", "data": [d["bacterial"] for d in timeline_data]},
            {"label": "Downy Mildew", "data": [d["downy_mildew"] for d in timeline_data]},
            {"label": "Powdery Mildew", "data": [d["powdery_mildew"] for d in timeline_data]},
            {"label": "Septoria Blight", "data": [d["septoria_blight"] for d in timeline_data]},
            {"label": "Viral", "data": [d["viral"] for d in timeline_data]},
            {"label": "Wilt & Leaf Blight", "data": [d["wilt_leaf_blight"] for d in timeline_data]}
        ]
    }

@app.get("/api/disease/environmental-triggers")
async def disease_triggers():
    """2. Environmental Triggers for Disease (Multi-line Chart)"""
    sensor_df = load_data("SensorData")
    detection_df = load_data("DetectionData")
    detection_df['diseases'] = detection_df['DISEASE_STATUS (%)'].apply(parse_percentages)
    
    merged = pd.merge_asof(
        detection_df.sort_values('TIMESTAMP'),
        sensor_df.sort_values('TIMESTAMP'),
        on='TIMESTAMP',
        direction='nearest'
    )
    
    chart_data = []
    for _, row in merged.iterrows():
        parsed = row['diseases']
        chart_data.append({
            "label": row['TIMESTAMP'].strftime("%m-%d"),
            "temperature": row['TEMP (°C)'],
            "humidity": row['HUMIDITY (%)'],
            "total_disease": 100 - parsed.get('healthy', 0.0)  # Total disease percentage
        })
    
    return {
        "data": chart_data
    }

@app.get("/api/disease/hotspots")
async def disease_hotspots():
    """3. Disease Hotspot Map (Radar Chart)"""
    df = load_data("DetectionData")
    df['diseases'] = df['DISEASE_STATUS (%)'].apply(parse_percentages)
    
    camera_stats = {}
    for camera_id, group in df.groupby('CAMERA_ID'):
        averages = {
            'bacterial': group['diseases'].apply(lambda x: x.get('bacterial', 0.0)).mean(),
            'downy_mildew': group['diseases'].apply(lambda x: x.get('downy_mildew_on_lettuce', 0.0)).mean(),
            'powdery_mildew': group['diseases'].apply(lambda x: x.get('powdery_mildew_on_lettuce', 0.0)).mean(),
            'septoria_blight': group['diseases'].apply(lambda x: x.get('septoria_blight_on_lettuce', 0.0)).mean(),
            'viral': group['diseases'].apply(lambda x: x.get('viral', 0.0)).mean(),
            'wilt_leaf_blight': group['diseases'].apply(lambda x: x.get('wilt_and_leaf_blight_on_lettuce', 0.0)).mean()
        }
        camera_stats[camera_id] = averages
    
    return {
        "labels": list(camera_stats.keys()),
        "datasets": [
            {
                "label": "Bacterial",
                "data": [v['bacterial'] for v in camera_stats.values()],
                "borderColor": "#FF6384",
                "backgroundColor": "rgba(255, 99, 132, 0.2)"
            },
            {
                "label": "Downy Mildew",
                "data": [v['downy_mildew'] for v in camera_stats.values()],
                "borderColor": "#36A2EB",
                "backgroundColor": "rgba(54, 162, 235, 0.2)"
            },
            {
                "label": "Powdery Mildew",
                "data": [v['powdery_mildew'] for v in camera_stats.values()],
                "borderColor": "#FFCE56",
                "backgroundColor": "rgba(255, 206, 86, 0.2)"
            },
            {
                "label": "Septoria Blight",
                "data": [v['septoria_blight'] for v in camera_stats.values()],
                "borderColor": "#4BC0C0",
                "backgroundColor": "rgba(75, 192, 192, 0.2)"
            },
            {
                "label": "Viral",
                "data": [v['viral'] for v in camera_stats.values()],
                "borderColor": "#9966FF",
                "backgroundColor": "rgba(153, 102, 255, 0.2)"
            },
            {
                "label": "Wilt & Leaf Blight",
                "data": [v['wilt_leaf_blight'] for v in camera_stats.values()],
                "borderColor": "#FF9F40",
                "backgroundColor": "rgba(255, 159, 64, 0.2)"
            }
        ]
    }

# Page 3: Plant Health Status Visualizations
@app.get("/api/health/deficiency-timeline")
async def nutrient_deficiency_timeline():
    """1. Nutrient Deficiency Timeline (Stacked Area Chart)"""
    df = load_data("DetectionData")
    df['health_status'] = df['HEALTH_STATUS (%)'].apply(parse_percentages)
    
    timeline_data = []
    for _, row in df.iterrows():
        parsed = row['health_status']
        timeline_data.append({
            "date": row['TIMESTAMP'].strftime("%Y-%m-%d %H:%M"),
            "fully_nutritional": parsed.get('fully nutritional', 0.0),
            "k_deficient": parsed.get('k deficient', 0.0),
            "n_deficient": parsed.get('n deficient', 0.0),
            "p_deficient": parsed.get('p deficient', 0.0)
        })
    
    return {
        "labels": [d["date"] for d in timeline_data],
        "datasets": [
            {"label": "Fully Nutritional", "data": [d["fully_nutritional"] for d in timeline_data]},
            {"label": "K Deficient", "data": [d["k_deficient"] for d in timeline_data]},
            {"label": "N Deficient", "data": [d["n_deficient"] for d in timeline_data]},
            {"label": "P Deficient", "data": [d["p_deficient"] for d in timeline_data]}
        ]
    }

@app.get("/api/health/ec-ph-correlation")
async def ec_ph_correlation():
    """2. EC/pH vs. Nutrient Deficiencies (Combination Chart)"""
    sensor_df = load_data("SensorData")
    detection_df = load_data("DetectionData")
    detection_df['health_status'] = detection_df['HEALTH_STATUS (%)'].apply(parse_percentages)
    
    merged = pd.merge_asof(
        detection_df.sort_values('TIMESTAMP'),
        sensor_df.sort_values('TIMESTAMP'),
        on='TIMESTAMP',
        direction='nearest'
    )
    
    chart_data = []
    for _, row in merged.iterrows():
        parsed = row['health_status']
        chart_data.append({
            "label": row['TIMESTAMP'].strftime("%m-%d"),
            "ec": row['EC (µS/cm)'],
            "ph": row['PH'],
            "k_deficient": parsed.get('k deficient', 0.0),
            "n_deficient": parsed.get('n deficient', 0.0),
            "p_deficient": parsed.get('p deficient', 0.0)
        })
    
    return {
        "data": chart_data
    }

@app.get("/api/health/status-by-growth")
async def health_by_growth_stage():
    """3. Health Status by Growth Stage (Heat Map)"""
    df = load_data("DetectionData")
    df['health_status'] = df['HEALTH_STATUS (%)'].apply(parse_percentages)
    df['growth_stages'] = df['GROWTH_STAGE (%)'].apply(parse_percentages)
    
    # Create mapping between growth stages and health statuses
    heatmap_data = {
        "early_growth": {"fully_nutritional": 0, "k_deficient": 0, "n_deficient": 0, "p_deficient": 0},
        "leafy_growth": {"fully_nutritional": 0, "k_deficient": 0, "n_deficient": 0, "p_deficient": 0},
        "head_formation": {"fully_nutritional": 0, "k_deficient": 0, "n_deficient": 0, "p_deficient": 0},
        "harvest_stage": {"fully_nutritional": 0, "k_deficient": 0, "n_deficient": 0, "p_deficient": 0}
    }
    
    for _, row in df.iterrows():
        health = row['health_status']
        growth = row['growth_stages']
        
        # Find dominant growth stage for this observation
        dominant_stage = max(growth.items(), key=lambda x: x[1])[0]
        stage_key = dominant_stage.replace(" ", "_")
        
        if stage_key in heatmap_data:
            heatmap_data[stage_key]["fully_nutritional"] += health.get('fully nutritional', 0)
            heatmap_data[stage_key]["k_deficient"] += health.get('k deficient', 0)
            heatmap_data[stage_key]["n_deficient"] += health.get('n deficient', 0)
            heatmap_data[stage_key]["p_deficient"] += health.get('p deficient', 0)
    
    # Convert to percentage averages
    for stage in heatmap_data:
        total = sum(heatmap_data[stage].values())
        if total > 0:
            for key in heatmap_data[stage]:
                heatmap_data[stage][key] = round(heatmap_data[stage][key] / total * 100, 1)
    
    return {
        "labels": ["Early Growth", "Leafy Growth", "Head Formation", "Harvest Stage"],
        "datasets": [
            {
                "label": "Fully Nutritional",
                "data": [heatmap_data[stage]["fully_nutritional"] for stage in heatmap_data]
            },
            {
                "label": "K Deficient",
                "data": [heatmap_data[stage]["k_deficient"] for stage in heatmap_data]
            },
            {
                "label": "N Deficient",
                "data": [heatmap_data[stage]["n_deficient"] for stage in heatmap_data]
            },
            {
                "label": "P Deficient",
                "data": [heatmap_data[stage]["p_deficient"] for stage in heatmap_data]
            }
        ]
    }