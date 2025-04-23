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
        """
        Returns the growth stage code.
        
        Args:
            growth_stage: The growth stage classification string
            
        Returns:
            str: 2-letter growth code or UNK if unknown
        """
        return GROWTH_STAGE_CODES.get(
            growth_stage.strip().lower(), 
            ClassificationMapper.UNKNOWN_GROWTH
        )

    @staticmethod
    def get_health_code(
        health_status: str, 
        disease_type: Optional[str] = None
    ) -> str:
        """
        Returns the health status code with disease prefix if applicable.
        
        Args:
            health_status: The health classification string
            disease_type: Optional disease classification string
            
        Returns:
            str: Health code (H for healthy, DXX for diseased, U for unknown)
        """
        health_status = health_status.strip().lower()
        
        # Handle healthy case
        if health_status == "healthy":
            return HEALTH_STATUS_CODES["healthy"]
            
        # Handle diseased case with disease type
        if health_status == "diseased" and disease_type:
            disease_type = disease_type.strip().lower()
            disease_code = DISEASE_CODES.get(
                disease_type,
                ClassificationMapper.UNKNOWN_DISEASE
            )
            return f"D{disease_code}"
            
        # Fallback to unknown
        return ClassificationMapper.UNKNOWN_HEALTH