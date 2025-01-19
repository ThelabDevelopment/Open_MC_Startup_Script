#!/bin/sh
# easter egg
Attempt_Count=0
# screen or tmux
MODE="${SEPERATE_SCREEN_TYPE}"
# MyServer_1_7_9
SESSION_NAME="${NAME}"
# java -jar -Xmx4G server.jar -nogui
COMMAND="java -jar -Xmx${RAM_GB} ${JAR_FILE} -nogui"
# /home/peipei/minecraft-server
WORK_DIR="${CURRENT_DIR}"

echo "This Is Not Working Yet"
Attempt_Count = ${Attempt_Count} + 1
exit 1

if [ $Attempt_Count => 3 ]; then
    echo "Why You Attempting \nThis Build Is Broken Bruh"
fi

# Source the .env file
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
else
    echo ".env file not found \nSetting Up..."
    setup_env()
fi

# Use the variables
echo "Current Allocated Ram is: $RAM_GB"
echo "Current Java Jar Software Is : $JAR_FILE"
sleep .5
echo "Entering Into Startup Process"
sleep .5

if [ ${JAR_FILE}="" ] || [ ${RAM_GB}="" ]; then
    echo "Missing Jar String Or Missing Ram Config \nExiting..."
    sleep .7
    exit 1
fi

if [ -z "$SESSION_NAME" ] || [ -z "$COMMAND" ] || [ -z "$WORK_DIR" ] || [ "$MODE" != "screen" ] && [ "$MODE" != "tmux" ]; then
    echo "\033[1;31m[WARN] String is Empty"
    exit 1
fi

cd "$WORK_DIR"
echo "\033[1;33m[INFO] \033[1;37mEnter to: $(pwd)"
if [ "$1" = "debug" ]; then
    echo "\033[1;31m[DEBUG]: Start Minecraft Server IN DEBUG MODE (NO screen or tmux)"
    $COMMAND
    exit 0
fi

echo "\033[1;33m[INFO] \033[1;32mStart Minecraft Server IN $MODE \033[1;31m"
case $MODE in
    tmux)
        tmux kill-session -t "$SESSION_NAME"
        tmux new-session -d -s "$SESSION_NAME" $COMMAND
        ;;
    screen)
        screen -dmS "$SESSION_NAME" $COMMAND
        ;;
esac

if [ $? -ne 0 ]; then
    echo "\033[1;31m[WARN] ERROR Exit..."
    exit 1
fi

echo "\033[1;33m[INFO] \033[1;37mHow to control a Minecraft server"
case $MODE in
    tmux)
        echo "\033[1;33m[INFO] \033[1;37mUse: tmux a -t $SESSION_NAME"
        ;;
    screen)
        echo "\033[1;33m[INFO] \033[1;37mUse: screen -r $SESSION_NAME"
        ;;
esac
exit 0
