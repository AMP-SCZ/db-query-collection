import os
from pathlib import Path
import requests

# CONFIG
REPO = "AMP-SCZ/db-query-collection"
BRANCH = "mri_team_count"
TOKEN_FILE = ".token"
WORKDIR = "/data/predict1/home/kcho/software/db-query-collection"
LAST_SHA_FILE = Path(WORKDIR) / "tmp_last_sha.txt"

# Load GitHub token
if not os.path.exists(TOKEN_FILE):
    print(f"❌ Token file not found at {TOKEN_FILE}")
    exit(1)

with open(TOKEN_FILE, "r") as f:
    GITHUB_TOKEN = f.read().strip()


# Get latest SHA from GitHub
headers = {"Authorization": f"token {GITHUB_TOKEN}"}
url = f"https://api.github.com/repos/{REPO}/commits/{BRANCH}"
response = requests.get(url, headers=headers)

if response.status_code != 200:
    print("❌ Failed to fetch from GitHub:", response.json())
    exit(1)

latest_sha = response.json()["sha"]

# Get previously known SHA
if os.path.exists(LAST_SHA_FILE):
    with open(LAST_SHA_FILE, "r") as f:
        last_sha = f.read().strip()
else:
    last_sha = ""

# Compare and act
if latest_sha != last_sha:
    print(f"🔄 New commit detected: {latest_sha}")
    
    # Uncomment and implement as needed:
    os.chdir(WORKDIR)
    os.system("./mri_team_count/update_and_execute_view_creation.sh")

    with open(LAST_SHA_FILE, "w") as f:
        f.write(latest_sha)
else:
    print(f"✅ No new changes. Latest SHA: {latest_sha}")
