#Post Api
from urllib.parse import quote
import http.client
import json

def get_valid_input(prompt, validator=None, error_msg=None):
    while True:
        value = input(prompt).strip()
        if not value:
            print("Input cannot be empty. Please try again.")
            continue
        if validator and not validator(value):
            print(error_msg or "Invalid input. Please try again.")
            continue
        return value

print("\n=== Equipment Booking System ===")

# Get required inputs with validation
item_id = get_valid_input(
    "Enter Item ID (e.g., DFRSPU): ",
    validator=lambda x: len(x) > 0,
    error_msg="Item ID cannot be empty"
).upper()

employee_id = get_valid_input(
    "Enter Employee ID (4 digits): ",
    validator=lambda x: x.isdigit() and len(x) == 4,
    error_msg="Employee ID must be 4 digits"
)

try:
    conn = http.client.HTTPSConnection("oracleapex.com")
    
    # Build the URL with parameters
    endpoint = f"/ords/uwc145/post/posst?item_id={quote(item_id)}&employee_id={quote(employee_id)}"
    
    print("\nSending booking request...")
    conn.request(
        "POST", 
        endpoint,
        headers={"Accept": "application/json"}
    )
    
    res = conn.getresponse()
    data = res.read()

    if res.status == 200:
        print("\n✅ Equipment booked successfully!")
        print("\nBooking Details:")
        print(f"🔧 Item ID: {item_id}")
        print(f"👤 Employee ID: {employee_id}")
        print(f"📅 Date: SYSDATE (Current date and time)")
        print(f"📊 Status: In Use")
    else:
        response_data = json.loads(data.decode('utf-8'))
        if "message" in response_data:
            print(f"\n❌ Booking failed: {response_data['message']}")
            if "cause" in response_data:
                print(f"Cause: {response_data['cause']}")
        else:
            print(f"\n❌ Booking failed with status {res.status}")

except Exception as e:
    print(f"\n❌ Error occurred: {str(e)}")
finally:
    if 'conn' in locals():
        conn.close()
        print("\n🔒 Connection closed")