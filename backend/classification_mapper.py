# classification_mapper.py
from typing import Optional
from classification_codes import GROWTH_STAGE_CODES, HEALTH_STATUS_CODES, DISEASE_CODES

class ClassificationMapper:
    """Maps classification results to standardized codes with consistent unknown handling."""
    
    # Constants for unknown codes
    UNKNOWN_GROWTH = GROWTH_STAGE_CODES["unknown"]
    UNKNOWN_HEALTH = HEALTH_STATUS_CODES["unknown"]
    UNKNOWN_DISEASE = DISEASE_CODES["unknown"]

    @staticmethod
    def get_growth_code(growth_stage: str) -> str:

        return GROWTH_STAGE_CODES.get(
            growth_stage.strip().lower(), 
            ClassificationMapper.UNKNOWN_GROWTH
        )
        
    @staticmethod
    def get_health_code(health_status: str) -> str:

        return HEALTH_STATUS_CODES.get(
            health_status.strip().lower(), 
            ClassificationMapper.UNKNOWN_HEALTH
        )
    
    @staticmethod
    def get_disease_code(disease_type: str) -> str:
        
        #print(f"Received disease type: {disease_type}")

        return DISEASE_CODES.get(
            disease_type.strip().lower(), 
            ClassificationMapper.UNKNOWN_DISEASE
        )

    
    
    @staticmethod
    def get_health_status_key(health_code: str) -> str:

        for key, value in HEALTH_STATUS_CODES.items():
            if value == health_code:
                return key
        return "unknown" 
    
    @staticmethod
    def get_growth_stage_key(growth_code: str) -> str:

        for key, value in GROWTH_STAGE_CODES.items():
            if value == growth_code:
                return key
        return "unknown" 
    
    @staticmethod
    def get_disease_type_key(disease_code: str) -> str:

        for key, value in DISEASE_CODES.items():
            if value == disease_code:
                return key
        return "unknown" 
