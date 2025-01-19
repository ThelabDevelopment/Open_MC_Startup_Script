#!/bin/sh

# Default values (used only when bypass flag is provided)
MODE="tmux"
RAM_GB="3"  # default RAM allocation in GB
JAR_FILE="server.jar"  # default JAR file name
CURRENT_DIR="."  # default working directory

# Check if we have the --bypass or -bp argument
if [ "$1" = "--bypass" ] || [ "$1" = "-bp" ]; then
    BYPASS=true
else
    BYPASS=false
fi

# If in bypass mode, use predefined variables (no user input)
if [ "$BYPASS" = true ]; then
    echo "Bypass mode enabled. Using default values..."
    echo "Session Manager: $MODE"
    echo "RAM Allocation: $RAM_GB GB"
    echo "JAR File: $JAR_FILE"
    echo "Working Directory: $CURRENT_DIR"
else
    # If NOT in bypass mode, prompt for inputs
    echo "Auto Configuration Is Starting..."
    sleep 0.5

    # Prompt for `SEPERATE_SCREEN_TYPE` if not set
    if [ -z "$SEPERATE_SCREEN_TYPE" ]; then
        echo "Enter session manager (screen or tmux):"
        read -r SEPERATE_SCREEN_TYPE
    fi

    # Prompt for `NAME` if not set
    if [ -z "$NAME" ]; then
        echo "Enter server name:"
        read -r NAME
    fi

    # Prompt for `RAM_GB` if not set
    if [ -z "$RAM_GB" ]; then
        echo "Enter allocated RAM (in GB):"
        read -r RAM_GB
    fi

    # Prompt for `JAR_FILE` if not set
    if [ -z "$JAR_FILE" ]; then
        echo "Enter the name of the JAR file (e.g., server.jar):"
        read -r JAR_FILE
    fi

    # Prompt for `CURRENT_DIR` if not set
    if [ -z "$CURRENT_DIR" ]; then
        echo "Enter the current working directory for the server:"
        read -r CURRENT_DIR
    fi
fi

# Show the configuration setup
echo "---- Current Configuration ----"
echo "Session Manager: $MODE"
echo "Server Name: $NAME"
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

if [ -z "$SESSION_NAME" ] || [ -z "$COMMAND" ] || [ -z "$WORK_DIR" ] || { [ "$MODE" != "screen" ] && [ "$MODE" != "tmux" ]; }; then
    echo "\033[1;31m[WARN] Missing or invalid configuration. Exiting..."
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
echo "\033[1;33m[INFO] \033[1;37mMinecraft server started successfully."
echo "\033[1;33m[INFO] \033[1;37mHow to control the server:"
case $MODE in
    tmux)
        echo "\033[1;33m[INFO] \033[1;37mUse: tmux a -t $SESSION_NAME"
        ;;
    screen)
        echo "\033[1;33m[INFO] \033[1;37mUse: screen -r $SESSION_NAME"
        ;;
esac

exit 0
