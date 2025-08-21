import streamlit as st
import random
import string
import csv
import pandas as pd
import time
from PIL import Image
import subprocess
import os

# --- CIF Generation Helpers ---
def generate_user_id(index):
    return f"800{index:06d}"

def generate_fname():
    first = ''.join(random.choices(string.ascii_lowercase, k=random.randint(5, 8)))
    return first.capitalize()

def generate_lname():
    last = ''.join(random.choices(string.ascii_lowercase, k=random.randint(5, 8)))
    return last.capitalize()

def generate_random_email():
    valid_chars = string.ascii_lowercase + string.digits
    username_length = random.randint(5, 12)
    username = ''.join(random.choice(valid_chars) for _ in range(username_length))
    domains = ["example.com", "test.org", "mail.net", "domain.info"]
    domain = random.choice(domains)
    return f"{username}@{domain}"

def generate_status():
    return random.choice(['Active', 'Inactive'])

def generate_pan():
    return ''.join(random.choices(string.ascii_uppercase, k=5)) + \
           ''.join(random.choices(string.digits, k=4)) + \
           random.choice(string.ascii_uppercase)

def generate_phone():
    return ''.join(random.choices("6789", k=1)) + ''.join(random.choices(string.digits, k=9))

def generate_data(n=100):
    data = []
    for i in range(1, n + 1):
        user_id = generate_user_id(i)
        fname = generate_fname()
        lname = generate_lname()
        status = generate_status()
        email = generate_random_email()
        pan = generate_pan()
        phone = generate_phone()
        data.append([user_id, fname, lname, status, email, pan, phone])
    return data

def save_to_csv(data, filename="synthetic_data.csv"):
    headers = ["CIFID", "Fname", "Lname", "Account Status", "Email", "PAN", "Phone"]
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        writer.writerows(data)

# --- Page Management ---
if 'page' not in st.session_state:
    st.session_state.page = 'home'

def go_to_region(region):
    st.session_state.selected_region = region
    st.session_state.page = 'region_page'

def go_home():
    st.session_state.page = 'home'

def start_over():
    for key in list(st.session_state.keys()):
        del st.session_state[key]
    st.session_state.page = 'home'

# --- Load Logo Automatically ---
logo_path = "C:\\Users\\SBI\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Python 3.13\\sbi.png"
if os.path.exists(logo_path):
    logo = Image.open(logo_path)
else:
    logo = None

# --- CSS Styling ---
st.markdown("""
<style>
    div.stButton > button:first-child {
        background-color: #87CEFA;
        color: white;
        font-weight: bold;
        border-radius: 8px;
        border: none;
        padding: 8px 20px;
        margin-right: 10px;
    }
    div.stButton > button:first-child:hover {
        background-color: #45a049;
        color: white;
    }
</style>
""", unsafe_allow_html=True)

# --- MAIN APP LOGIC ---
if st.session_state.page == 'home':
    if logo:
        st.image(logo, width=120)

    st.title("🏦 Core Banking Services")
    st.markdown("""
        <div style='border: 2px solid #87CEFA; padding: 10px; border-radius: 10px; 
        color: #FFFFFF; background-color: #000080'; >
        Welcome to the Core Banking Services. Please choose your region to proceed.
        </div>
        """, unsafe_allow_html=True)

    region = st.selectbox("🌍 Choose a region:", ['Region A', 'Region B', 'Region C', 'Region D'])
    if st.button("Proceed"):
        go_to_region(region)

elif st.session_state.page == 'region_page':
    if logo:
        st.image(logo, width=120)

    st.title(f"📍 Region: {st.session_state.selected_region}")

    col1, col2 = st.columns(2)
    with col1:
        st.button("⬅️ Go Back", on_click=go_home)
    with col2:
        st.button("🔄 Start Over", on_click=start_over)

    st.subheader("📌 Select a Service")
    option = st.selectbox('Choose a service:', ['Create', 'Fetch', 'Update'])

    if option == 'Create':
        st.subheader("Manual Creation")

        st.subheader("📌 Select Columns")
        _ = st.selectbox('Choose a service:', ['CIF', 'Account', 'Savings', 'CCOD', 'KCC'])

        # ------------------- EXECUTE BAT FILE -------------------
        bat_file_path = r"C:\Users\nishu\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Python 3.9\run_file.bat"
        txt_file_path = r"C:\Users\nishu\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Python 3.9\85007899.txt"

        if st.button("Execute"):
            try:
                # Run the bat file
                result = subprocess.run(
                    [bat_file_path],
                    shell=True,
                    capture_output=True,
                    text=True
                )

                if result.returncode == 0:
                    time.sleep(1)  # give some time for file to be created
                    if os.path.exists(txt_file_path):
                        with open(txt_file_path, "r", encoding="utf-8") as f:
                            content = f.read()
                        st.success("✅ Bat file executed successfully and file read!")
                        st.text_area("📄 File Output:", content, height=300)
                    else:
                        st.error("⚠️ Txt file not found after executing bat.")
                else:
                    st.error(f"❌ Bat file failed. Error: {result.stderr}")

            except Exception as e:
                st.error(f"⚠️ Failed to execute bat file: {e}")

        # ------------------- CIF GENERATION -------------------
        st.subheader("📝 Generate Synthetic CIFs")
        num_cifs = st.number_input("Enter number of CIFs to generate:", min_value=1, value=5, step=1)

        if st.button("Generate CIFs"):
            with st.spinner("Creating CIF..."):
                time.sleep(2)
                data = generate_data(n=num_cifs)
                save_to_csv(data)

            st.success(f"✅ Successfully created {num_cifs} CIFs!")
            df = pd.DataFrame(data, columns=["CIFID", "Fname", "Lname", "Account Status", "Email", "PAN", "Phone"])
            st.dataframe(df)

            with open("synthetic_data.csv", "rb") as f:
                st.download_button(
                    label="⬇️ Download CSV",
                    data=f,
                    file_name="synthetic_data.csv",
                    mime="text/csv"
                )

    elif option == 'Fetch':
        st.subheader("🔎 Fetch CIF Details")
        cif_id = st.text_input("Enter CIF ID to search:")

        if st.button("Fetch"):
            try:
                df = pd.read_csv("synthetic_data.csv")
                result = df[df['CIFID'] == cif_id]
                if not result.empty:
                    st.dataframe(result)
                else:
                    st.warning("⚠️ CIF ID not found.")
            except FileNotFoundError:
                st.error("❌ No CIF data found. Please generate some first.")

    elif option == 'Update':
        st.info("⚙️ Update functionality not implemented yet.")
