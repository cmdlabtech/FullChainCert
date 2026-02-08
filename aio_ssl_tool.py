import base64
import tempfile
import os

# Add this constant at the top of your file (replace with actual base64 string)
ICON_BASE64 = "your_base64_string_here"

def get_icon_path():
    """Extract icon from base64 to temp file."""
    if not ICON_BASE64:
        return None
    
    temp_dir = tempfile.gettempdir()
    icon_path = os.path.join(temp_dir, 'aio_ssl_tool_icon.ico')
    
    # Only write if it doesn't exist
    if not os.path.exists(icon_path):
        icon_data = base64.b64decode(ICON_BASE64)
        with open(icon_path, 'wb') as f:
            f.write(icon_data)
    
    return icon_path

# In your GUI initialization, replace the icon reference:
# root.iconbitmap('icon.ico')  # OLD
root.iconbitmap(get_icon_path())  # NEW