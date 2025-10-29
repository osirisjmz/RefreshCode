RefreshCode
General Description

RefreshCode is a personal technical lab designed for learning, experimentation, and development of automation frameworks, artificial intelligence modules, and reusable code components.
Its main goal is to serve as a controlled testing environment where different technologies, libraries, and architectures are combined to build real, scalable solutions later integrated into enterprise platforms such as Power Automate, UiPath, Azure AI, and Omnix Studio.

Each module within the lab has a specific purpose — testing libraries, training models, validating integrations, or experimenting with core logic structures.
This repository is not intended as a commercial or educational product but as a personal development sandbox for understanding, testing, and refining software automation components.

Lab Structure
1. MLL (Machine Learning Lab)

Purpose:
To train, validate, and test machine learning models using controlled data and Azure integration flows.
This module is designed to understand the entire lifecycle of a model — from data input and preprocessing to training and prediction.

Main libraries used:

pandas

scikit-learn

numpy

matplotlib

requests

Microsoft Graph SDK

Technical goal:
Develop an automated flow for data-driven predictions and integrate it into intelligent automation pipelines using Power Automate or Azure ML.

2. Playwrite

Purpose:
To explore browser automation using Playwright and Python, focused on RPA scenarios and controlled web scraping.
This module helps understand asynchronous and synchronous automation flows and how they integrate with external bot frameworks.

Main libraries used:

playwright

asyncio

logging

time

Technical goal:
Master browser control, DOM interaction, and dynamic data extraction to validate or automate complex web processes later integrated into RPA workflows.

3. AIZero

Purpose:
To create a baseline environment for experimenting with traditional machine learning using scikit-learn, independent from higher-level frameworks.
AIZero provides a self-contained setup to train, evaluate, and benchmark models.

Main libraries used:

scikit-learn

pandas

numpy

matplotlib

Technical goal:
Understand how classical ML models operate, including preprocessing, training, evaluation, and prediction pipelines. This serves as a foundation for integrating ML models into broader automation systems.

4. App (Academic Management Base)

Purpose:
To practice building web applications with Flask, implementing a modular CRUD structure (Create, Read, Update, Delete).
It provides an adaptable base to understand routing, templates, and backend logic.

Main libraries used:

Flask

Jinja2

SQLAlchemy (in future versions)

Technical goal:
Learn client-server architecture through Flask and establish a reusable foundation for dashboards, management systems, or internal automation panels.

5. Biblioteca Universitaria

Purpose:
To test the integration between Flask, static web resources (CSS/JS), and database models.
This module emulates a structured management system and serves as a learning base for full-stack data-driven applications.

Main libraries used:

Flask

Flask-SQLAlchemy

Jinja2

JavaScript, CSS

SQLite or MySQL

Technical goal:
Experiment with frontend-backend interaction, database handling, authentication, and project structuring under the MVC pattern in a Python environment.

6. Inferential Statistics

Purpose:
To experiment with Flask, NumPy, SciPy, and pandas for statistical computations and inferential analysis in an interactive web interface.
This project provides a foundation for learning hypothesis testing, confidence intervals, and data correlation.

Main libraries used:

Flask

numpy

scipy

pandas

matplotlib

Technical goal:
Develop interactive applications capable of running statistical computations, visualize results, and understand the computational logic behind inferential statistics in a web-based environment.

7. Lengtokens

Purpose:
To develop and test scripts for measuring token usage and estimating API costs in large language models such as OpenAI and Azure OpenAI.
It functions as a lightweight cost-monitoring and usage-tracking utility.

Main libraries used:

os

json

datetime

openai (planned integrations)

Technical goal:
Track token consumption, log usage history, and estimate associated costs for API-driven AI applications, supporting performance and cost optimization across development workflows.

8. VisionAI

Purpose:
To explore computer vision capabilities through Azure Cognitive Services, testing image classification and face detection.
This module allows experimentation with real-world visual recognition APIs and pretrained neural models.

Main libraries used:

azure-cognitiveservices-vision-computervision

azure-cognitiveservices-vision-face

requests

pillow

Technical goal:
Build a basic vision pipeline capable of connecting local images to Azure Vision API, processing them, and returning labels, attributes, or facial detection results.

9. Practices

Purpose:
A collection of Python scripts focused on strengthening core programming knowledge through targeted exercises.
Each file explores fundamental language behaviors and serves as a testbed for logic validation and syntax exploration.

Main libraries used:

Native Python standard libraries only

Technical goal:
Provide a rapid testing and learning area to reinforce Python syntax, string manipulation, operators, and data structures, directly applicable to automation and backend development.

Conclusion

RefreshCode serves as a personal technical laboratory for continuous development, experimentation, and applied learning.
Each module functions as a technical building block — designed to be tested, refined, and later integrated into production-level solutions.

Rather than a finished product, this repository is a living environment for:

Testing and debugging new libraries

Understanding API behaviors and ML workflows

Building reusable automation and AI components

Exploring integration between Python, cloud services, and automation tools

RefreshCode represents the foundation of a personal ecosystem for hands-on experimentation, professional skill growth, and applied understanding of software automation and AI development.

