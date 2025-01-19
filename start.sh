#!/bin/sh

# Version
VERSION="0.0.1"

# Default predefined values (for bypass mode)
BYPASS_MODE="tmux"
BYPASS_RAM_GB="2"
BYPASS_JAR_FILE="server.jar"
BYPASS_CURRENT_DIR="."
BYPASS_SESSION_NAME="Minecraft_Server"
ENV_DIR="${BYPASS_CURRENT_DIR}/.env"  # Fixed the missing quote
COMMAND="java -jar -Xmx${RAM_GB} ${JAR_FILE} -nogui"

# Display the version before booting
echo "Version: $VERSION"
sleep 1  # Delay by 1 second

# Check if .env exists; if not, create it
if [ ! -f "$ENV_DIR" ]; then
    echo ".env not found. Setting up new configuration..."

    # Prompt for `SESSION_NAME`
    echo "Enter server name (SESSION_NAME):"
    read -r SESSION_NAME

    # Prompt for `MODE` (screen/tmux)
    echo "Enter session manager (screen or tmux):"
    read -r MODE

    # Prompt for `RAM_GB`
    echo "Enter allocated RAM (in GB):"
    read -r RAM_GB

    # Prompt for `JAR_FILE`
    echo "Enter the name of the JAR file (e.g., server.jar):"
    read -r JAR_FILE

    # Prompt for `CURRENT_DIR`
    echo "Enter the current working directory for the server:"
    read -r CURRENT_DIR

    # Save the user input to .env file (normal variables)
    echo "Saving configuration to $ENV_DIR..."
    echo "SESSION_NAME=\"$SESSION_NAME\"" > "$ENV_DIR"
    echo "MODE=\"$MODE\"" >> "$ENV_DIR"
    echo "RAM_GB=\"$RAM_GB\"" >> "$ENV_DIR"
    echo "JAR_FILE=\"$JAR_FILE\"" >> "$ENV_DIR"
    echo "CURRENT_DIR=\"$CURRENT_DIR\"" >> "$ENV_DIR"
    echo "Preserving DIR Locally"
    BYPASS_CURRENT_DIR="$CURRENT_DIR"
else
    echo "Loading configuration from $ENV_DIR..."
    # Use `.` to load variables from .env file (for compatibility with sh)
    . "$ENV_DIR"
fi

# Validate if all necessary variables are loaded correctly
if [ -z "$SESSION_NAME" ] || [ -z "$MODE" ] || [ -z "$RAM_GB" ] || [ -z "$JAR_FILE" ] || [ -z "$CURRENT_DIR" ]; then
    echo "Error: Missing required variables from $ENV_DIR. Please check the .env file."
    exit 1
fi

# Check if we have the --bypass or -bp argument
if [ "$1" = "--bypass" ] || [ "$1" = "-bp" ]; then
    BYPASS=true
else
    BYPASS=false
fi

# If in bypass mode, use predefined variables with "BYPASS_" prefix ONLY
if [ "$BYPASS" = true ]; then
    echo "Bypass mode enabled. Using predefined variables..."

    # Ensure that BYPASS_ variables are set (SESSION_NAME, MODE, RAM_GB, JAR_FILE, CURRENT_DIR)
    if [ -z "$BYPASS_SESSION_NAME" ] || [ -z "$BYPASS_MODE" ] || [ -z "$BYPASS_RAM_GB" ] || [ -z "$BYPASS_JAR_FILE" ] || [ -z "$BYPASS_CURRENT_DIR" ]; then
        echo "Error: Missing required bypass variables (BYPASS_SESSION_NAME, BYPASS_MODE, BYPASS_RAM_GB, BYPASS_JAR_FILE, BYPASS_CURRENT_DIR). Exiting..."
        exit 1
    fi

    # Use the bypass variables directly
    SESSION_NAME="$BYPASS_SESSION_NAME"
    MODE="$BYPASS_MODE"
    RAM_GB="$BYPASS_RAM_GB"
    JAR_FILE="$BYPASS_JAR_FILE"
    CURRENT_DIR="$BYPASS_CURRENT_DIR"
else
    # If all necessary variables are already set in .env, skip user input and proceed to server startup
    if [ -n "$SESSION_NAME" ] && [ -n "$MODE" ] && [ -n "$RAM_GB" ] && [ -n "$JAR_FILE" ] && [ -n "$CURRENT_DIR" ]; then
        echo "All configuration variables are already set. Skipping configuration prompts..."
    else
        # Non-bypass mode: prompt for user input for variables
        echo "Auto Configuration Is Starting..."

        # Prompt for `SESSION_NAME` if not bypass mode
        if [ -z "$SESSION_NAME" ]; then
            echo "Enter server name (SESSION_NAME):"
            read -r SESSION_NAME
        fi

        # Prompt for `MODE` (screen/tmux) if not bypass mode
        if [ -z "$MODE" ]; then
            echo "Enter session manager (screen or tmux):"
            read -r MODE
        fi

        # Prompt for `RAM_GB` if not bypass mode
        if [ -z "$RAM_GB" ]; then
            echo "Enter allocated RAM (in GB):"
            read -r RAM_GB
        fi

        # Prompt for `JAR_FILE` if not bypass mode
        if [ -z "$JAR_FILE" ]; then
            echo "Enter the name of the JAR file (e.g., server.jar):"
            read -r JAR_FILE
        fi

        # Prompt for `CURRENT_DIR` if not bypass mode
        if [ -z "$CURRENT_DIR" ]; then
            echo "Enter the current working directory for the server:"
            read -r CURRENT_DIR
        fi

        # Save the user input to .env file (normal variables)
        echo "Saving configuration to $ENV_DIR..."
        echo "SESSION_NAME=\"$SESSION_NAME\"" > "$ENV_DIR"
        echo "MODE=\"$MODE\"" >> "$ENV_DIR"
        echo "RAM_GB=\"$RAM_GB\"" >> "$ENV_DIR"
        echo "JAR_FILE=\"$JAR_FILE\"" >> "$ENV_DIR"
        echo "CURRENT_DIR=\"$CURRENT_DIR\"" >> "$ENV_DIR"
    fi
fi

# Show the current configuration setup
echo "---- Current Configuration ----"
echo "Server Name: $SESSION_NAME"
echo "Session Manager: $MODE"
echo "Allocated RAM: ${RAM_GB}G"
echo "JAR File: $JAR_FILE"
echo "Current Directory: $CURRENT_DIR"
echo "------------------------------"

# Validate required variables
if [ -z "$RAM_GB" ] || [ -z "$JAR_FILE" ]; then
    echo "Missing JAR file or RAM configuration. Exiting..."
    sleep 0.7
    exit 1
fi

if [ -z "$MODE" ] || { [ "$MODE" != "screen" ] && [ "$MODE" != "tmux" ]; }; then
    echo "\033[1;31m[WARN] Invalid session manager. Exiting..."
    exit 1
fi

# Navigate to the working directory
cd "$CURRENT_DIR" || { echo "\033[1;31m[ERROR] Failed to access working directory: $CURRENT_DIR"; exit 1; }

# Display the current configuration before startup
echo "Current Allocated RAM: ${RAM_GB}G"
echo "Current Java JAR File: $JAR_FILE"
sleep 0.5
echo "Entering Startup Process..."
sleep 0.5

# Debug mode
if [ "$1" = "debug" ]; then
    echo "\033[1;31m[DEBUG]: Starting Minecraft Server in DEBUG MODE (No screen or tmux)"
    eval "$COMMAND"
    exit 0
fi

# Start the server with the selected session manager
echo "\033[1;33m[INFO] \033[1;32mStarting Minecraft Server in $MODE session..."
case $MODE in
    tmux)
        tmux kill-session -t "$SESSION_NAME" 2>/dev/null
        tmux new-session -d -s "$SESSION_NAME" "$COMMAND"
        ;;
    screen)
        screen -S "$SESSION_NAME" -dm bash -c "$COMMAND"
        ;;
    *)
        echo "\033[1;31m[ERROR] Invalid MODE: $MODE"
        exit 1
        ;;
esac

# Check if the session started successfully
if [ $? -ne 0 ]; then
    echo "\033[1;31m[ERROR] Failed to start the server. Exiting..."
    exit 1
fi

# Display control instructions
echo "\033[
