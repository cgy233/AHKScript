from PIL import Image

# Open the logo image
logo = Image.open('D:\\Tools\\AHKScript\\ImageProess\\hass-logo\\home-assistant-social-media-logo-round.png')

# Calculate the ratio to resize the logo while keeping its aspect ratio
ratio = 1
# Resize the logo
logo = logo.resize((logo.width // ratio, logo.height // ratio), Image.HAMMING)  # Use HAMMING filter for high-quality downsizing

# Create a new black image with the LCD screen size
new_image = Image.new('RGB', (1024, 600), 'black')

# Calculate the position to center the logo
x = (1024 - logo.width) // 2
y = (600 - logo.height) // 2

# Paste the logo onto the new image
new_image.paste(logo, (x, y))

# Save the new image
new_image.save('./hass_logo.bmp')