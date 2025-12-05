# XLSX to DOCX with n8n and DocxTemplater

Versão em Português: [../readme.md](../readme.md)

## Project Overview
This project is a proof of concept that automates the processing of XLSX spreadsheets and the generation of documents using n8n workflows, all running locally. It includes a user-friendly Python GUI to manage the n8n Docker container, upload files, and retrieve results. The main goal is to simplify workflow automation for non-technical users, making setup and usage accessible.

The motivation for this project arose from the need for a local and simple solution to generate documents from spreadsheet data without relying on cloud services. Additionally, the project serves as a basis for future improvements, such as more complex workflows and an enhanced user experience.

## Hardware Requirements
There are no specific hardware requirements for this project, other than a computer capable of running Docker and Python 3. Recommended:
- Processor with virtualization support (for Docker)
- 4 GB of RAM or more
- 5 GB of available disk space

## Software Requirements
- **Operating System:**
  - Linux (any recent distribution)
  - macOS (untested)
  - Windows (with WSL2 configured as default)
- **Required Software:**
  - Docker
  - Python 3
  - pip3
  - python3-tk (for GUI)
  - curl, sqlite3, jq (used in setup scripts)
- **Python Dependencies:**
  - Listed in the `src/requirements.txt` file, automatically installed by the entry script.

For dependency installation details, see [`docs/dependencies_en.md`](dependencies_en.md).

## Environment Setup
### Step-by-Step Configuration
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Luan-Daniel/n8n-xlsx-to-docx.git
   cd n8n-xlsx-to-docx
   ```
2. **Run the entry script:**
   - On Linux/macOS: `./run.sh`
   - On Windows: `./run.ps1`
3. **Wait for dependencies to install:**
   - The script sets up the Python virtual environment and installs dependencies automatically.
4. **Start the GUI:**
   - The GUI window will appear automatically after the initial setup.
5. **Import n8n data:**
   - Use the "Import n8n Data" button to load a sample workflow and settings from `n8n-files/user-data/default.zip`.
   - Warning: Use the provided credentials only for convenience. For production use, create your own. See N8N_USER_EMAIL and N8N_USER_PASSWORD in `src/docker-n8n/.env` extracted from `n8n-files/user-data/default.zip`.
6. **Start the n8n container:**
   - Use the corresponding button in the GUI.
7. **Test the workflow:**
   - Upload a sample XLSX file via the GUI and retrieve the generated document.

## How to Use
### Daily Usage
1. **Start the n8n Docker container:**
   - Use the GUI to start/stop the container as needed.
2. **Upload XLSX files:**
   - Upload XLSX files via the GUI to trigger the workflow.
3. **Retrieve generated documents:**
   - The generated files will be available in the `n8n-files/documents/` directory.
4. **Manage workflows:**
   - Access the n8n web interface via the GUI to create or modify workflows.

## Project Structure and Implementation Overview
### File Organization
- `src/entrypoint.py`: Sets up the environment, checks dependencies, and launches the GUI.
- `src/service-manager/main.py`: Main GUI application, manages the n8n container and user interactions.
- `src/docker-n8n/`: Scripts for building and managing the n8n Docker container.
- `n8n-files/`: Directory shared with the n8n container, containing sample data and workflow files.
- `docs/`: Project documentation, including dependencies and future ideas.

### Key HTTP Interactions in the Workflow:
- GUI sends HTTP POST to the n8n webhook with file information.
- n8n processes files and sends the result back to the GUI via HTTP POST.

### Example Workflow Steps:
- Triggered by an HTTP request from the GUI (xlsx file name and template file name).
- Reads XLSX and template files from shared folders in `n8n-files/sheets/` and `n8n-files/templates/`, respectively.
- Extracts data from the XLSX and merges it with the template binary.
- [Docxtemplater](https://github.com/jreyesr/n8n-nodes-docxtemplater) is used to process data and generate a DOCX document.
- Saves the result in `n8n-files/documents/`.
- Sends an HTTP POST to the GUI webhook with the result or error code.

### Known Limitations and Future Work
Due to time constraints, some features were left incomplete:
- Automatic system dependency installation is incomplete.
- Setup process can be improved (replaced by export/import data).
- JavaScript components for data visualization are present but not fully integrated.
- Error handling needs improvement.
- Docx template is hardcoded; future versions should allow user selection.

## Troubleshooting
### Common Issues and Solutions
1. **Error starting the Docker container:**
   - Ensure Docker is installed and running.
   - Make sure the current user has permission to execute Docker commands.
2. **GUI does not appear after running the script:**
   - Verify that all Python dependencies are installed correctly.
   - Check the `src/requirements.txt` file to install dependencies manually.
3. **n8n workflow does not process files:**
   - Ensure XLSX and template files are in the correct directories (`n8n-files/sheets/` and `n8n-files/templates/`).
   - Check the n8n container logs to identify errors.

## Images
![](../docs/img/GUI.png)
*Figure 1: Service Manager GUI*
![](../docs/img/workflow.png)
*Figure 2: Example n8n Workflow*

## Contributors
- **Luan Daniel (20102096):** Lead developer, workflow design, GUI implementation.