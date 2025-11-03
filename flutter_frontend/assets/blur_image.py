from PIL import Image, ImageFilter
import os

# Input and output paths
input_path = "greenhouse_banner.jpg"
output_path = "greenhouse_banner_blurred.jpg"

# Open the image
img = Image.open(input_path)

# Apply Gaussian blur (adjust radius for more/less blur)
# radius=10 gives a nice soft blur, increase for more blur
blurred = img.filter(ImageFilter.GaussianBlur(radius=8))

# Save the blurred image
blurred.save(output_path, quality=95)

print(f"✅ Blurred image saved as: {output_path}")
print(f"Original size: {img.size}")
