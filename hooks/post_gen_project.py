import subprocess

subprocess.run(["git", "init"], check=True)
subprocess.run(["git", "add", "."], check=True)
subprocess.run(["git", "commit", "-m", "init: scaffold from sqlmesh-scaffold"], check=True)

print("✅ Git repository initialized")

subprocess.run(["uv", "sync"], check=True)

print("✅ uv synced")