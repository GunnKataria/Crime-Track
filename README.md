#                                                                                        CrimeTrack – Crime Management System


Crime-Track is a cross-platform Flutter application designed for effective offline crime reporting and case management. It supports both web and mobile, using Riverpod for state management and local JSON for data storage—making it lightweight and usable without internet access.


## Features🔑

👤 Citizens

- Report crimes with location, time, and description

- View case status updates

- Offline access with local data storage


🕵️‍♂️ Officers

- Case Management: Assign cases, track status, and view timelines

- Suspects & Witnesses: Add suspects and witness details with links to cases

- Evidence Logging: Record evidence types with metadata

- Analytics: Visual charts and statistics of crime data



## UI & Technical🖥️ 

- Responsive design with theme support (light/dark)

- Infinite scrolling for smooth data navigation

- Custom widgets for modular UI

- Role-based access control (Citizen / Officer)



## Getting Started🚀

Prerequisites

- Flutter 3.0.0 or higher

Setup

- bash:

  - git clone https://github.com/GunnKataria/Crime-Track.git

  - cd Crime-Track

  - flutter pub get

  - flutter run



## Demo Credentials🧪

| Role    | Email                  | Password  |
|---------|------------------------|-----------|
| Citizen | citizen@example.com    | password  |
| Officer | officer@example.com    | password  |



## Core Screens Implemented📂 

- Add Suspect: Link to case, enter criminal history

- Add Evidence: Support for multiple types (photo, video, etc.)

- Add Witness: Anonymous or identified, with credibility ratings

- Case Assignment: Officers assign cases and begin investigation

