from ultralytics import YOLO

# Load your model
model = YOLO('backend/Models/LETTUCE_DETECTION_MODEL.pt')

# Get class names
class_names = model.names  # Returns dictionary {id: class_name}
print(class_names)

# Example output: {0: 'healthy', 1: 'diseased', 2: 'vegetative', ...}