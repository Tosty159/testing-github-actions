# testing-github-actions
This repository is for testing github actions and experimenting

To download the program, run:
On Linux/MacOS:
```
curl -sL "https://api.github.com/repos/Tosty159/testing-github-actions/contents/install/install.sh" | jq -r '.download_url' | xargs curl -L -o install.sh && chmod +x install.sh && ./install.sh
```
On Windows:
```
curl -sL "https://api.github.com/repos/Tosty159/testing-github-actions/contents/install/install.bat" | jq -r '.download_url' | xargs curl -L -o install.bat && start install.bat
```