from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
from get_images import router
from file_path_config import router as get_model_router
from file_path_config import router as model_config_router  
from prediction_model import router as prediction_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_STORAGE = Path(
    r"C:\Users\Fadhi Safeer\OneDrive\Documents\Internship\Agri hub\STORAGE\camera_storage"
)

app.mount("/static", StaticFiles(directory=BASE_STORAGE), name="static")

app.include_router(router)
app.include_router(get_model_router)
app.include_router(model_config_router) 
app.include_router(prediction_router)
