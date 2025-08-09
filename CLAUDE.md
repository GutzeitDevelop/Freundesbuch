# CLAUDE.md

## Important boundaries for Claude

- We are working on this Project in a 4-Eye-Principle - You are the main developer and I am the reviewer
    -- ALWAYS explain the command in detail that you want to run next - so that I can understand what you are going to do!
    -- code in chunks (feature-by-feature) and run simulator in between to show WORKING results (so one user story after the other)
    -- indicate each chunk by a version-number of the application
    -- add Developer-Comments to each code snippet as In-Detail Documentation so that any developer taking over this project can start easily
    -- extend your claude timeout window when you run build or start commands
- check for all available dependency solutions (softwares, libraries) and explain their key features and key issues
    -- use free for commercial available tools to limit costs
    -- Explain each dependency/component and what the main features and disadvantages are
- **SECURITY FIRST**: Security MUST be a top priority throughout all development phases
    -- Use only current, actively maintained software dependencies
    -- Implement latest security best practices for mobile applications and web interactions
    -- Follow iOS Security Best-Practices
    -- Follow Android Security Best-Practices
    -- Follow OWASP Mobile Security Guidelines
    -- Regular security audits and dependency updates
    -- Secure authentication with latest JWT standards
    -- End-to-end encryption for sensitive communications
    -- Secure data storage with platform-specific encryption
    -- Protection against common mobile vulnerabilities (MITM, data leakage, etc.)
- Create one color scheme and use it for the whole development cycle
- Key Developer considerations for all code-snippets
    -- Follow clean code principle and refactor the code continously, so that the same formats etc. are followed in ALL files
    -- Keep the UI clean and simple
    -- UI Elements should have a clear position in the app - we should avoid UI change due to lazy load
    -- Prioritize fast loading and processing
    -- ensure mobile responsive design for all common screen sizes
    -- Error handling must be followod for all functions and states
        --- Create a clear documentation file for error handled, why they occured and how to solve them typically
    -- create all features as resistant as possible for connection issue, so that there is no interruption when no network is available and that once there is an active connection for a short time -> that the most important functions use the network first (prioritized)
    -- always check the simulator status about errors - build based on known WORKING versions (chunk-by-chunk)
- Document the whole plan and all steps in-detail and document your current implementation status after each change
    -- create a readme.md file covering all important topics
    -- create a visual overview of all files of the project and and indicate how they act with each other for a great overview
    -- create an architecture plan file
    -- create an error handling file as described above
    -- create a permissions file listing all permissions necessary and the usecase for them with a detailed description. Also add where in the code this is used
- Use only production-ready code, components and libraries as we have only one environment

## Project Overview

MyFriends App - an app to support all people you have meet during your live.
So App should provide a quick option to document people you have met.
It not important if the other person as the app as well or not
The application is hybrid and targeted for iOS and Android.
Features are
- The app can be used without a profile locally on the phone
- There is an option to create a profile to have pre-registered info to share with new friends
- the ability to create an entry for a new "friend"
    -- multiple input-templates are available and new templates can be created customized
        --- typical templates
            ---- classic: photo, Name, Nickname, home location, hair color, eye color, I like, i do not like, etc.
            ---- modern: photo, Nickname, I like, I do not like, Hit me up when, contact data (phone number, social account, etc.)
    -- a person which has a profile can share it with one-click
    -- always save the location of the first "meet" and ask to take a photo of the moment
- the ability to create "friendbooks" for multiple friend circles
    -- friends can be added to friendbooks
- language support for german and english (developing and testing language is german)
- offline features
- create placeholder for future features like:
    - Chat (text, voice message, internet phone call)
    - Status (Short Video or Photo)
    - Drinking-Alarm - share location with friendsbooks which can be choosed and add a 'Let's meet to drink' button
    - Connect Profile to MyFriends-Cloud to sync/save your data
    - a map showing the location of your friends (if they have location-sharing active)




### Documentation
- `README.md` - Project overview and setup instructions
- `IMPLEMENTATION_LOG.md` - Detailed development tracking
- `PROJECT_ROADMAP.md` - Future development phases
- `ARCHITECTURE_OVERVIEW.md` - Visual architecture guide
- `ERROR_HANDLING.md` - Error Handling guide
- `PERMISSIONS.md` - Visual permissions guide

## Development Commands

*Note: This section will be populated once package.json and build tools are configured.*


## Architecture

*Note: This section will be populated as the codebase develops.*

### Core Structure

## Important Notes

- This is a new project directory - core files and structure are yet to be established
- Update this file as the project architecture and tooling are implemented

## Implementation Status

### 🔄 Next Steps

### 📁 Project Structure
