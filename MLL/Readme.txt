# Machine Learning Lab (MLL)

Author: Osiris Jiménez  
Purpose: Intelligent automation and email-based model training system integrated with Azure and Power Automate.

## Overview
MLL (Machine Learning Lab) is an experimental AI module designed to integrate automation workflows with Azure services. It reads email data, processes training sets, and predicts or classifies new entries through configurable Python scripts.

## Folder Structure
MLL/
├── config.json  
├── config_reader.py  
├── email_reader.py  
├── email_reader_graph.py  
├── logs/email_reader_graph.log  
├── main.py  
├── predictor.py  
└── trainer.py  

## Setup
1. Clone the repository.  
2. Create and activate a virtual environment.  
3. Install dependencies with `pip install -r requirements.txt`.  
4. Configure `config.json` with your Azure credentials.  
5. Run `python main.py`.

## Modules
- config_reader.py: Loads configuration from JSON.  
- email_reader_graph.py: Reads Outlook data via Microsoft Graph API.  
- trainer.py: Prepares and trains models.  
- predictor.py: Executes predictions.  
- main.py: Controls the execution pipeline.

## Future Work
- Integration with Power Automate Cloud.  
- Deployment to Azure ML.  
- Web dashboard for monitoring.
