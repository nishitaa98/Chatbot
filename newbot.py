import streamlit as st
import os
import pandas as pd
from datetime import datetime

# ----------------------------
# Authentication Logic
# ----------------------------
# Dummy User Credentials (Plain-text)
USER_CREDENTIALS = {
    "admin": "1234",
    "manager": "abcd"
}

def verify_login(username, password):
    return USER_CREDENTIALS.get(username) == password

# ----------------------------
# Login Interface
# ----------------------------
if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

if not st.session_state.logged_in:
    st.set_page_config(page_title="Bank CIF Portal", layout="wide")
    st.title("🔐 Bank CIF Portal Login")

    username = st.text_input("Username")
    password = st.text_input("Password", type="password")
    login_btn = st.button("Login")

    if login_btn:
        if verify_login(username, password):
            st.session_state.logged_in = True
            st.session_state.username = username
            st.success(f"Welcome, {username}!")
            st.rerun()
        else:
            st.error("Invalid username or password")

    st.stop()

# ----------------------------
# Config
# ----------------------------
BAT_FILE = r"C:\Users\nishu\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Python 3.9\your_bat_file.bat"
FINAL_SAVE_FILE = r"C:\Users\HP\Downloads\final_data.xlsx"
IMAGE_URL = "C:\\Users\\HP\\Downloads\\sbi.png"

# ----------------------------
# Sidebar and Logout
# ----------------------------
st.sidebar.markdown("---")
st.sidebar.button("🔓 Logout", on_click=lambda: st.session_state.update({"logged_in": False}))

# ----------------------------
# CSS Styling
# ----------------------------
st.markdown("""
    <style>
    section[data-testid="stSidebar"] {
        background-color: #003366 !important;
        color: white !important;
        padding: 1rem;
    }
    section[data-testid="stSidebar"] .stRadio,
    section[data-testid="stSidebar"] .stSelectbox,
    section[data-testid="stSidebar"] .stTextInput,
    section[data-testid="stSidebar"] .stMultiSelect,
    section[data-testid="stSidebar"] .stNumberInput {
        background-color: white !important;
        border-radius: 8px;
        padding: 8px 12px;
        color: #003366 !important;
    }
    div.stButton > button {
        background-color: #FFCC00 !important;
        color: #003366 !important;
        font-weight: 700;
        border: none;
        border-radius: 6px;
        padding: 0.6em 1.2em;
        font-size: 15px;
        cursor: pointer;
        transition: background-color 0.3s ease;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
    }
    div.stButton > button:hover {
        background-color: #e6b800 !important;
        color: #001a33 !important;
    }
    .css-18e3th9 {
        background-color: white !important;
        padding: 1rem 2rem 2rem 2rem;
        border-radius: 8px;
        color: #003366 !important;
    }
    h1, h2, h3 {
        color: #003366 !important;
        font-weight: 700;
    }
    .stAlert > div {
        border-left: 5px solid #003366 !important;
    }
    </style>
""", unsafe_allow_html=True)

# ----------------------------
# Banner
# ----------------------------
st.image(IMAGE_URL, width=200)

# ----------------------------
# Sidebar UI
# ----------------------------
st.sidebar.title("Configuration")

st.sidebar.text_input("No of CIF", key="no_of_cif")

st.sidebar.selectbox(
    "Select Region",
    ["-- Select Region --", "Region 0", "Region R1", "Region K", "Region R2"],
    key="region"
)

if st.session_state.get("region") != "-- Select Region --":
    st.sidebar.radio(
        "Choose Action",
        ["-- Select Action --", "Create", "Fetch", "Update", "Show Stats", "Activity Log"],
        key="action"
    )

    if st.session_state.get("action") != "-- Select Action --":
        st.sidebar.selectbox(
            "Select Account Type",
            ["-- Select Account Type --", "CIF", "Saving", "Other"],
            key="account_type"
        )

# ----------------------------
# Main UI
# ----------------------------
st.title("Bank CIF Management Portal")

region = st.session_state.get("region", "-- Select Region --")
action = st.session_state.get("action")
account_type = st.session_state.get("account_type")

if region == "-- Select Region --":
    st.info("Please select a region from the sidebar to continue.")
else:
    st.markdown(f"### 🌍 Selected Region: {region}")

    if not action or action == "-- Select Action --":
        st.info("Please select an action in the sidebar.")
    else:
        st.markdown(f"### 🛠️ Action: {action}")

        if not account_type or account_type == "-- Select Account Type --":
            st.info("Please select an account type in the sidebar.")
        else:
            st.markdown(f"### 🏦 Account Type: {account_type}")

            if account_type == "CIF":
                st.selectbox(
                    "Select CIF Type",
                    ["-- Select CIF Type --", "Individual", "Non Individual"],
                    key="cif_type"
                )

                if st.session_state.get("cif_type") == "Individual":
                    st.selectbox(
                        "Select Resident Type",
                        ["-- Select Resident Type --", "Resident", "NRI"],
                        key="resident_type"
                    )

                    if st.session_state.get("resident_type") in ["Resident", "NRI"]:
                        st.selectbox(
                            "Select Minor or Major",
                            ["-- Select Option --", "Minor", "Major"],
                            key="minor_major"
                        )

            # Show session data
            current_data = {
                "Region": region,
                "Action": action,
                "Account Type": account_type,
                "CIF Type": st.session_state.get("cif_type", ""),
                "Resident Type": st.session_state.get("resident_type", ""),
                "Minor/Major": st.session_state.get("minor_major", ""),
                "Timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }

            # ----------------------------
            # Action Buttons
            # ----------------------------
            col1, col2, col3 = st.columns(3)

            with col1:
                if st.button("▶ Execute Process"):
                    try:
                        os.startfile(BAT_FILE)
                        st.info("File opened successfully!")
                    except Exception as e:
                        st.error(f"Failed to open file: {e}")

            with col2:
                if st.button("📂 View Saved Data"):
                    if os.path.exists(FINAL_SAVE_FILE):
                        df_display = pd.read_excel(FINAL_SAVE_FILE)
                        st.dataframe(df_display)
                    else:
                        st.warning("No saved data found.")

            with col3:
                if st.button("💾 Save Now"):
                    try:
                        data = {
                            "no of cif": st.session_state.get("no_of_cif", ""),
                            "region": st.session_state.get("region", ""),
                            "action": st.session_state.get("action", ""),
                            "account type": st.session_state.get("account_type", ""),
                            "cif type": st.session_state.get("cif_type", ""),
                            "Resident Type": st.session_state.get("resident_type", ""),
                            "Minor or Major": st.session_state.get("minor_major", "")
                        }

                        if (
                            data["region"] != "-- Select Region --" and
                            data["action"] == "Create" and
                            data["account type"] == "CIF" and
                            data["cif type"] == "Individual" and
                            data["Resident Type"] in ["Resident", "NRI"]
                        ):
                            df_kv = pd.DataFrame(data.items(), columns=["Key", "Value"])
                            df_kv.to_excel(FINAL_SAVE_FILE, index=False)
                            st.success("✅ Data saved successfully.")
                        else:
                            st.warning("Please complete all required fields before saving.")
                    except Exception as e:
                        st.error(f"Save failed: {e}")
