***Plataform Preparetion***

Install Pyton:
    mac: brew install python

    windows: 
    Download the installer:
        Visit the official Python website (https://www.python.org/downloads/) and download the latest Python version for Windows.
    Run the installer:
        Double-click the downloaded installer.
        Follow the on-screen instructions, making sure to check the option "Add Python to PATH".
    Verify the installation:
        Open a command prompt and type:python --version


Install the dependencies:
    pip install -r requirements.txt

Install Docker:
    Windows
    -Using Docker Desktop:
        Download: Go to the Docker Desktop download page (https://www.docker.com/products/docker-desktop/)1 and download the installer. 
        Install: Run the installer and follow the on-screen instructions. You might need to enable Hyper-V and WSL 2 features on your Windows system.
        Verify: Open a command prompt and type:
            Bash: docker --version

    macOS
    -Using Docker Desktop:
        Download: Go to the Docker Desktop download page (https://docs.docker.com/desktop/setup/install/mac-install/) and download the installer.
        Install: Run the installer and follow the on-screen instructions.
        Verify: Open a terminal and type:
            Bash: docker --version

Create the Databases in docker:
    docker compose up -d

    to turn down: docker compose down