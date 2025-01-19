#!/bin/sh

BYPASS_MODE="tmux"
BYPASS_RAM_GB="2"
BYPASS_JAR_FILE="server.jar"
BYPASS_CURRENT_DIR="."
COMMAND="java -jar -Xmx${RAM_GB} ${JAR_FILE} -nogui"


# Check if we have the --bypass or -bp argument
if [ "$1" = "--bypass" ] || [ "$1" = "-bp" ]; then
    BYPASS=true
else
    BYPASS=false
fi

# If in bypass mode, use predefined variables with "BYPASS_" prefix ONLY
if [ "$BYPASS" = true ]; then
    echo "Bypass mode enabled. Using predefined variables..."

    # Ensure that BYPASS_ variables are set (MODE, RAM_GB, JAR_FILE, CURRENT_DIR)
    if [ -z "$BYPASS_MODE" ] || [ -z "$BYPASS_RAM_GB" ] || [ -z "$BYPASS_JAR_FILE" ] || [ -z "$BYPASS_CURRENT_DIR" ]; then
        echo "Error: Missing required bypass variables (BYPASS_MODE, BYPASS_RAM_GB, BYPASS_JAR_FILE, BYPASS_CURRENT_DIR). Exiting..."
        exit 1
    fi

    # Use the bypass variables directly
    MODE="$BYPASS_MODE"
    RAM_GB="$BYPASS_RAM_GB"
    JAR_FILE="$BYPASS_JAR_FILE"
    CURRENT_DIR="$BYPASS_CURRENT_DIR"

else
    # Non-bypass mode: prompt for user input for variables
    echo "Auto Configuration Is Starting..."

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
fi

# Show the current configuration setup
echo "---- Current Configuration ----"
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
echo "\033[1;33m[INFO] \033[1;37mMinecraft server started successfully."
echo "\033[1;33m[INFO] \033[1;37mHow to control the server:"
case $MODE in
    tmux)
        echo "\033[1;33m[INFO] \033[1;37mUse: tmux a -t $SESSION_NAME to attach to the tmux session."
        ;;
    screen)
        echo "\033[1;33m[INFO] \033[1;37mUse: screen -r $SESSION_NAME to attach to the screen session."
        ;;
esac
