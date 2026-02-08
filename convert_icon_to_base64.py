import base64

with open('icon.ico', 'rb') as icon_file:
    icon_data = base64.b64encode(icon_file.read()).decode('utf-8')
    
print(f'ICON_BASE64 = "{icon_data}"')
